use std::net;

fn main() {
    let socket = net::UdpSocket::bind("0.0.0.0:8080").expect("Unable to bind UDP socket");
    
    let mut buf = [0; 1024];
    loop {
        match socket.recv_from(&mut buf) {
            Ok((_, src)) => {
                println!("Packet received");
                socket.send_to(b"pong", src).expect("Unable to send packet");
            },
            Err(e) => {
                eprintln!("Unable to receive packet: {}", e);
            }
        }
    }
}
