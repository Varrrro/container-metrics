#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

int main(int argc, char *argv[])
{
    int sockfd;                    /* socket */
    struct sockaddr_in targetaddr; /* target socket address */

    if (argc != 3)
    {
        perror("Usage: pinger <ip> <port>");
        exit(1);
    }

    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
    {
        perror("Unable to open socket");
        exit(1);
    }

    bzero((char *)&targetaddr, sizeof(targetaddr));
    targetaddr.sin_family = AF_INET;
    targetaddr.sin_addr.s_addr = inet_addr(argv[1]); /* target IP */
    targetaddr.sin_port = htons(atoi(argv[2]));      /* target port */

    if (sendto(sockfd, "ping", strlen("ping") + 1, 0, // +1 to include terminator
               (struct sockaddr *)&targetaddr, sizeof(targetaddr)) < 0)
    {
        perror("Unable to send UDP packet");
        exit(1);
    }

    close(sockfd);
}
