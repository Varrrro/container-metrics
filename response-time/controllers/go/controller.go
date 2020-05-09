package main

import (
	"log"
	"net"
)

func main() {
	laddr, err := net.ResolveUDPAddr("udp", ":8080")
	if err != nil {
		log.Fatalf("Unable to resolve local UDP address: %s\n", err.Error())
	}

	conn, err := net.ListenUDP("udp", laddr)
	if err != nil {
		log.Fatalf("Unable to listen for packets: %s\n", err.Error())
	}
	defer conn.Close()

	for {
		buf := make([]byte, 1024)
		_, raddr, err := conn.ReadFromUDP(buf)
		if err != nil {
			log.Printf("Unable to receive packet: %s\n", err.Error())
		}
		log.Println("Packet received")
		conn.WriteToUDP([]byte("pong"), raddr)
	}
}
