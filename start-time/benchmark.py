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
udp_sock.settimeout(5)

args = sys.argv
if len(args) != 2:
    sys.exit('Usage: test.py <niter>')

# Start testing loop
niter = int(args[1])
containers = ['pinger_c', 'pinger_go', 'pinger_rs']
results = pd.DataFrame(columns=['iter', 'impl', 'start_time', 'run_time'])
for cont in containers:
    for i in range(0, niter):
        ssh.exec_command(
            f'docker run --name pinger {cont} {laddr} {lport}')

        try:
            udp_sock.recvfrom(1024)
            sleep(1)  # ensure container has finished

            # Retrieve timestamps from container
            _, created, _ = ssh.exec_command(
                "docker inspect --format='{{.Created}}' pinger")
            _, started, _ = ssh.exec_command(
                "docker inspect --format='{{.State.StartedAt}}' pinger")
            _, finished, _ = ssh.exec_command(
                "docker inspect --format='{{.State.FinishedAt}}' pinger")

            # Decode stdout
            created = created.read().decode('ascii').strip('\n')
            started = started.read().decode('ascii').strip('\n')
            finished = finished.read().decode('ascii').strip('\n')

            # Parse to datetime objects
            dt_created = pd.to_datetime(
                created, format='%Y-%m-%dT%H:%M:%S.%fZ')
            dt_started = pd.to_datetime(
                started, format='%Y-%m-%dT%H:%M:%S.%fZ')
            dt_finished = pd.to_datetime(
                finished, format='%Y-%m-%dT%H:%M:%S.%fZ')

            # Calculate start and run times
            start_time = (dt_started - dt_created).total_seconds() * 1000
            run_time = (dt_finished - dt_started).total_seconds() * 1000

            # Add times to dataframe
            results = results.append(pd.DataFrame({
                'iter': pd.Series([i], dtype='int'),
                'impl': pd.Series([cont], dtype='str'),
                'start_time': pd.Series([start_time], dtype='float'),
                'run_time': pd.Series([run_time], dtype='float')
            }), ignore_index=True)

            print(f'[{cont} | {i}] Request recorded')
        except timeout:
            print(f'[{cont} | {i}] Request timed out')
        finally:
            _, stdout, _ = ssh.exec_command('docker rm -f pinger')
            stdout.channel.recv_exit_status()  # wait for command to finish

    # Show mean values for each container
    cont_mean = results.groupby(
        ['impl']).get_group(cont).agg({
            'start_time': np.mean,
            'run_time': np.mean,
        })
    print(f'[{cont}] Mean values:\n{cont_mean}')

results.to_csv(
    f'results/start-time-{datetime.now().strftime("%Y%M%d")}-{niter}.csv', index_label='id')
print('Tests finished correctly')

ssh.close()
udp_sock.close()
