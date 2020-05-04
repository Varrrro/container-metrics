use std::net;
use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: pinger <ip> <port>");
    }

    let socket = net::UdpSocket::bind("0.0.0.0:0")
        .expect("Unable to bind socket");

    socket.send_to(b"ping", format!("{}:{}", &args[1], &args[2]))
        .expect("Unable to send UDP packet");
}
