#include <unistd.h>
#include <cstdio>
#include <cstdlib>
#include "udpsock.h"
#include <string>

using namespace std;

UDPSock server;
UDPSock sender;

const char* dest_ip = "10.1.1.255";
int server_port = 32002;

char buffer[64 * 1024];

//============================================================================
// This program serves as a "loopback" for RDMA packets.   The (optional) IP
// address you specify on the command line MUST be a broadcast IP address.
//
// Don't forget to change the MTU on your network interface to allow jumbo
// Ethernet packets.   In Ubuntu, you can do this by:
//     sudo ifconfig <interface_name> mtu 9600 up
//============================================================================
int main(int argc, char** argv)
{
    int count = 0;

    // If there's an IP address on the command line, use it.
    if (argc > 1) dest_ip = argv[1];

    // If there's a UDP port on the command line, use it
    if (argc > 2) server_port = atoi(argv[2]);

    // Create the UDP server socket
    if (!server.create_server(server_port))
    {
        printf("Can't create server\n");
        exit(1);        
    }

    // Create the UDP sender socket in broadcast mode
    if (!sender.create_broadcaster(11111, dest_ip))
    {
        printf("Can't create sender\n");
        exit(1);        
    }
    
    while (true)
    {
        // Wait for a packet to arrive
        int packet_len = server.receive(buffer, sizeof(buffer));        

        // Tell the user how many packets we've received
        printf("%d %d\n", packet_len, ++count);
        
        // Send the packet back to whomever sent it
        sender.send(buffer, packet_len);
    }

}
//============================================================================