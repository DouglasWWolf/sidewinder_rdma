//==========================================================================================================
// UDPSock.h - Defines a class for managing UDP sockets
//==========================================================================================================
#pragma once
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <string>
#include "netutil.h"

//==========================================================================================================
// UDPSock() - UDP socket for sending or receiving UDP datagrams
//==========================================================================================================
class UDPSock
{
public:

    // Constructor, marks the socket as closed
    UDPSock() {m_sd = -1;}
    
    // Destructor - Closes the socket
    ~UDPSock() {close();}

    // Create a socket that we will send UDP packets on.
    bool    create_broadcaster(int port, std::string dest, int family = AF_INET);

    // Create a socket that we will send UDP packets on.
    bool    create_sender(int port, std::string dest, int family = AF_INET);

    // Create a socket that we will use to receive UDP packets
    bool    create_server(int port, std::string bind_to = "", int family = AF_UNSPEC);

    // Closes the socket
    void    close();

    // Call this to send a message
    void    send(const void* msg, int length);

    // Call this to wait for data to arrive on the socket
    bool    wait_for_data(int milliseconds = -1);

    // Call this to wait for a UDP packet to arrive
    int     receive(void* buffer, int buffer_length, std::string* p_peer_ip = NULL);

    // Returns the socket descriptor of this socket
    int     get_sd() {return m_sd;}

protected:

    // The file descriptor
    int        m_sd;

    // The address IP address/port/etc of the UDP target
    addrinfo_t m_target;
};
//==========================================================================================================
