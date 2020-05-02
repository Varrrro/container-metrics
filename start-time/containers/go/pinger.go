package main

import (
	"log"
	"net"
	"os"
)

func main() {
	args := os.Args
	if len(args) != 2 {
		log.Fatalln("Incorrect argument: The target's IP address is needed")
	}
	targetIP := os.Args[1]

	taddr, err := net.ResolveUDPAddr("udp", targetIP)
	if err != nil {
		log.Fatalf("Unable to resolve target address: %s\n", err.Error())
	}

	conn, err := net.DialUDP("udp", nil, taddr)
	if err != nil {
		log.Fatalf("Unable to dial target address: %s\n", err.Error())
	}

	if _, err := conn.Write([]byte("ping")); err != nil {
		log.Fatalf("Unable to send UDP packet: %s\n", err.Error())
	}
}
