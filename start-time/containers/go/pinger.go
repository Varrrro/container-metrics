package main

import (
	"fmt"
	"log"
	"net"
	"os"
)

func main() {
	args := os.Args
	if len(args) != 3 {
		log.Fatalln("Usage: pinger <ip> <port>")
	}
	targetaddr := fmt.Sprintf("%s:%s", os.Args[1], os.Args[2])

	taddr, err := net.ResolveUDPAddr("udp", targetaddr)
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
