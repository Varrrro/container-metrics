import os
import sys

import numpy as np
import pandas as pd

from datetime import datetime
from socket import socket, AF_INET, SOCK_DGRAM, timeout, gethostname, gethostbyname
from time import sleep, time

from dotenv import load_dotenv
from paramiko import SSHClient, AutoAddPolicy


# Read connection values from .env
load_dotenv()
hostname = os.getenv('REMOTE_HOST')
username = os.getenv('REMOTE_USER')
password = os.getenv('REMOTE_PASS')

# Create SSH client to remote host
ssh = SSHClient()
ssh.set_missing_host_key_policy(AutoAddPolicy)
ssh.connect(hostname=hostname, username=username, password=password)

# Set local IP address and port
lhostname = gethostname()
laddr = gethostbyname(lhostname)
lport = 8080

# Open UDP socket
udp_sock = socket(AF_INET, SOCK_DGRAM)
udp_sock.bind(('', lport))
udp_sock.settimeout(20)

# Check command-line args
args = sys.argv
if len(args) != 2:
    sys.exit('Usage: test.py <niter>')

# Create docker network and retrieve its ID
_, netstdout, _ = ssh.exec_command('docker network create benchmarks')
netstdout = netstdout.read().decode('ascii').strip('\n')
netid = netstdout[:12]

# Start testing loop
niter = int(args[1])
masters = ['master_running', 'master_stopped', 'master_paused']
controllers = ['controller_c', 'controller_go', 'controller_rs']
results = pd.DataFrame(columns=['iter', 'mst', 'cont', 'resp_time'])
for mst in masters:
    for cont in controllers:
        ssh.exec_command(
            f'docker run -d --name master -v /var/run/docker.sock:/var/run/docker.sock -p 8080:8080/udp --network benchmarks {mst} {cont} {netid} {laddr} {lport}')
        udp_sock.recvfrom(1024)  # wait until master is ready

        for i in range(0, niter):
            start = time()
            udp_sock.sendto("ping".encode(), (hostname, 8080))

            try:
                udp_sock.recvfrom(1024)  # receive response
                end = time()

                if mst != 'master_running':
                    udp_sock.recvfrom(1024)  # wait until master says continue

                elapsed = end - start

                # Add times to dataframe
                results = results.append(pd.DataFrame({
                    'iter': pd.Series([i], dtype='int'),
                    'mst': pd.Series([mst], dtype='str'),
                    'cont': pd.Series([cont], dtype='str'),
                    'resp_time': pd.Series([elapsed], dtype='float')
                }), ignore_index=True)

                print(f'[{mst} | {cont} | {i}] Request recorded')
            except timeout:
                print(f'[{mst} | {cont} | {i}] Request timed out')

        _, stdout, _ = ssh.exec_command('docker rm -f master controller')
        stdout.channel.recv_exit_status()  # wait for command to finish

        # Show mean values so far
        mean_values = results.groupby(
            ['mst', 'cont']).agg({
                'resp_time': np.mean
            })
        print(f'[{mst} | {cont}] Mean values so far:\n{mean_values}')

ssh.exec_command('docker network rm benchmarks')

results.to_csv(
    f'results/response-time-{datetime.now().strftime("%Y%M%d")}-{niter}.csv', index_label='id')
print('Tests finished correctly')

ssh.close()
udp_sock.close()
