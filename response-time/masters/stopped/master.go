package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"os"

	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/container"
	"github.com/docker/docker/api/types/network"
	docker "github.com/docker/docker/client"
)

func main() {
	if len(os.Args) != 5 {
		log.Fatalln("Usage: master <image> <networkID> <ip> <port>")
	}
	img, netID, remoteIP, remoteport := os.Args[1], os.Args[2], os.Args[3], os.Args[4]

	cli, err := docker.NewEnvClient()
	if err != nil {
		log.Fatalf("Unable to create Docker API client: %s\n", err.Error())
	}
	defer cli.Close()

	// Create container connected to the given network and start it
	ctx := context.Background()
	cont, err := cli.ContainerCreate(
		ctx,
		&container.Config{
			Image: img,
		},
		nil,
		&network.NetworkingConfig{
			EndpointsConfig: map[string]*network.EndpointSettings{
				"benchmarks": {
					NetworkID: netID,
				}},
		},
		"controller",
	)
	if err != nil {
		log.Fatalf("Unable to create controller container: %s\n", err.Error())
	} else if err := cli.ContainerStart(ctx, cont.ID, types.ContainerStartOptions{}); err != nil {
		log.Fatalf("Unable to start controller container: %s\n", err.Error())
	}

	// Resolve controller address and open connection to it
	caddr, err := net.ResolveUDPAddr("udp", "controller:8080")
	if err != nil {
		log.Fatalf("Unable to resolve controller UDP address: %s\n", err.Error())
	}

	cconn, err := net.DialUDP("udp", nil, caddr)
	if err != nil {
		log.Printf("Unable to establish UDP connection to controller: %s\n", err.Error())
	}
	defer cconn.Close()

	// Stop controller container
	if err := cli.ContainerStop(ctx, cont.ID, nil); err != nil {
		log.Fatalf("Unable to pause controller container: %s\n", err.Error())
	}

	// Resolve local address and open connection on it
	laddr, err := net.ResolveUDPAddr("udp", ":8080")
	if err != nil {
		log.Fatalf("Unable to resolve local UDP address: %s\n", err.Error())
	}

	lconn, err := net.ListenUDP("udp", laddr)
	if err != nil {
		log.Fatalf("Unable to listen for packets: %s\n", err.Error())
	}
	defer lconn.Close()

	// Resolve remote address
	raddr, err := net.ResolveUDPAddr("udp", fmt.Sprintf("%s:%s", remoteIP, remoteport))
	if err != nil {
		log.Fatalf("Unable to resolve remote UDP address: %s\n", err.Error())
	}

	// Start goroutine that listens for controller responses and
	// responds back to remote address
	go func(taddr *net.UDPAddr) {
		cbuf := make([]byte, 1024)
		for {
			_, err := cconn.Read(cbuf)
			if err != nil {
				log.Printf("Unable to receive packet from controller: %s\n", err.Error())
			}
			lconn.WriteToUDP([]byte("pong"), taddr)

			if err := cli.ContainerStop(ctx, cont.ID, nil); err != nil {
				log.Fatalf("Unable to stop controller container: %s\n", err.Error())
			}
			lconn.WriteToUDP([]byte("continue"), taddr)
		}
	}(raddr)

	// Tell remote that we are ready
	lconn.WriteToUDP([]byte("ready"), raddr)

	// Start server loop
	buf := make([]byte, 1024)
	for {
		n, _, err := lconn.ReadFromUDP(buf)
		if err != nil {
			log.Printf("Unable to receive packet from remote address: %s\n", err.Error())
		}
		log.Println("Packet received")

		if err := cli.ContainerStart(ctx, cont.ID, types.ContainerStartOptions{}); err != nil {
			log.Fatalf("Unable to start controller container: %s\n", err.Error())
		}

		cconn.Write(buf[0:n])
	}
}
