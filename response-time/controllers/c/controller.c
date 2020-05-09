#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define PORT 8080
#define BUFSIZE 1024

int main()
{
    int sockfd;                                /* socket */
    int clientlen;                             /* byte size of client's address */
    struct sockaddr_in serveraddr, clientaddr; /* server and client addresses */
    char *buf;                                 /* message buffer */
    char *hostaddrp;                           /* dotted decimal host address string */
    int n;                                     /* message byte size */

    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
    {
        perror("Unable to open socket");
        exit(1);
    }

    bzero((char *)&serveraddr, sizeof(serveraddr));
    serveraddr.sin_family = AF_INET;
    serveraddr.sin_addr.s_addr = htonl(INADDR_ANY);
    serveraddr.sin_port = htons(PORT);

    if (bind(sockfd, (struct sockaddr *)&serveraddr, sizeof(serveraddr)) < 0)
    {
        perror("Unable to bind socket");
        exit(1);
    }

    clientlen = sizeof(clientaddr);
    buf = malloc(BUFSIZE);
    while (1)
    {
        n = recvfrom(sockfd, buf, BUFSIZE, 0, (struct sockaddr *)&clientaddr, &clientlen);
        if (n < 0)
        {
            perror("Unable to receive packet");
            exit(1);
        }
        printf("Packet received\n");
        sendto(sockfd, "pong", strlen("pong"), 0, (struct sockaddr *)&clientaddr, clientlen);
    }
}
