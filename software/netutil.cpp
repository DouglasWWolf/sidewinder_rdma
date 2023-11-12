//==========================================================================================================
// netutil.cpp - Implements some common networking utility functions
//==========================================================================================================
#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <string>
#include "netutil.h"
using namespace std;


//==========================================================================================================
// get_local_addrinfo() - Returns an addrinfo structure for the local machine
//
// Passed:  type    = SOCK_STREAM or SOCK_DGRAM
//          port    = The TCP port number we want to create a socket on
//          bind_to = The IP address of the network card to bind to (optional)
//          family  = AF_UNSPEC, AF_INET, or AF_INET6
//
// Returns: an addrinfo_t structure.
//          if addrinfo.family == 0, the call failed
//==========================================================================================================
addrinfo_t NetUtil::get_local_addrinfo(int type, int port, string bind_to, int family)
{
    char ascii_port[20];
    struct addrinfo hints, *p_res;
    addrinfo_t result;

    // If we fail, our entire return structure will be zero
    memset(&result, 0, sizeof(result));

    // Get a pointer to the IP address we want to bind to
    const char* bind_addr = bind_to.empty() ? NULL : bind_to.c_str();

    // Get an ASCII version of the port number
    sprintf(ascii_port, "%i", port);

    // Tell getaddrinfo about the socket family and type
    memset(&hints, 0, sizeof hints);
    hints.ai_family   = family;  
    hints.ai_socktype = type;
    
    // Handle the case where we're not binding to a specific IP address
    if (bind_addr == NULL) hints.ai_flags = AI_PASSIVE;  

    // Fetch important information about the socket we're going to create
    if (getaddrinfo(bind_addr, ascii_port, &hints, &p_res) != 0) return result;

    // If we didn't get a result from getaddrinfo, something's wrong
    if (p_res == NULL) return result;

    // Save a copy of the results
    result = *p_res;

    // Free the memory that was allocated by getaddrinfo
    freeaddrinfo(p_res);

    // And hand the result to the caller
    return result;
}
//==========================================================================================================



//==========================================================================================================
// get_server_addrinfo() - Returns connection information for a remote server
//==========================================================================================================
bool NetUtil::get_server_addrinfo(int type, string server, int port, int family, addrinfo_t* p_result)
{
    char ascii_port[20];
    struct addrinfo hints, *p_res;

    // If we fail, our entire return structure will be zero
    memset(p_result, 0, sizeof(addrinfo));

    // Get an ASCII version of the port number
    sprintf(ascii_port, "%i", port);

    // We're going to build an IPv4/IPv6 TCP socket
    memset(&hints, 0, sizeof hints);
    hints.ai_family   = family;
    hints.ai_socktype = type;
    
    // Get information about this server.  If we can't, it doesn't exist
    if (getaddrinfo(server.c_str(), ascii_port, &hints, &p_res) != 0) return false;

    // If we didn't get a result from getaddrinfo, something's wrong
    if (p_res == NULL) return false;

    // Save a copy of the results
    *p_result = *p_res;

    // Free the memory that was allocated by getaddrinfo
    freeaddrinfo(p_res);

    // Tell the caller that we have information about the server he wants to connect o
    return true;
}
//==========================================================================================================



//==========================================================================================================
// ip_to_string() - Converts an IP address to a string
//==========================================================================================================
string NetUtil::ip_to_string(sockaddr* addr)
{
    // This is the field that will get returned
    char ip_address[64] = {0};

    // Figure out how long the socket address structure is for this family
    socklen_t socklen = (addr->sa_family == AF_INET) ? 
              sizeof(struct sockaddr_in) :
              sizeof(struct sockaddr_in6);

    // Fetch the ASCII IP address for this entry
    int rc = getnameinfo(addr, socklen, ip_address, sizeof(ip_address), NULL, 0, NI_NUMERICHOST);

    // On the off chance that the call to getnameinfo() fails, tell the caller
    if (rc != 0) return "";

    // Is there a '%' in this IP address?
    char* p = strchr(ip_address, '%');
        
    // If so, truncate the IP address at that '%' character
    if (p) *p = 0;

    // Hand the resulting IP address to the caller
    return ip_address;
}
//==========================================================================================================


//==========================================================================================================
// ip_to_string() - Converts an IP address to a string
//==========================================================================================================
std::string NetUtil::ip_to_string(sockaddr_storage& ss)
{
    return ip_to_string((sockaddr*)&ss);
}
//==========================================================================================================


//==========================================================================================================
// wait_for_data() - Waits for the specified amount of time for data to be available for reading
//
// Passed:  timeout_ms = timeout in milliseconds.  -1 = Wait forever
//
// Returns: a bitmap of which descriptors are available for reading
//==========================================================================================================
int NetUtil::wait_for_data(int timeout_ms, int fd1, int fd2, int fd3, int fd4)
{
    int    i, fd;
    fd_set rfds;
    timeval timeout;

    // Put them into an array
    int fd_list[] = {fd1, fd2, fd3, fd4};

    // Find out how many items are in the array
    const int ARRAY_COUNT = sizeof(fd_list) / sizeof(fd_list[0]);

    // We don't know what the highest file descriptor is yet
    int highest_fd = -1;

    // Clear our file descriptor set
    FD_ZERO(&rfds);

    // Loop through each file descriptor that was provided by the caller...
    for (i=0; i<ARRAY_COUNT; ++i)
    {
        // Fetch this file descriptor
        fd = fd_list[i];

        // Skip any invalid file descriptor
        if (fd < 0) continue;   

        // Include this file descriptor in our fd_set
        FD_SET(fd, &rfds);

        // Keep track of the highest file descriptor we have
        if (fd > highest_fd) highest_fd = fd;
    }

    // Assume for the moment that we are going to wait forever
    timeval* p_timeout = NULL;

    // If the caller wants us to wait for a finite amount of time...
    if (timeout_ms != -1)
    {
        // Convert milliseconds to microseconds
        int usecs = timeout_ms * 1000;

        // Determine the timeout in seconds and microseconds
        timeout.tv_sec  = usecs / 1000000;
        timeout.tv_usec = usecs % 1000000;

        // Point to the timeout structure we just initialized
        p_timeout = &timeout;
    }

    // Wait for one of the descriptors to become available for reading
    if (select(highest_fd+1, &rfds, NULL, NULL, p_timeout) < 1) return 0;

    // This is going to be a bitmap of which descriptors are readable
    int result = 0;

    // Loop through each possible descriptor...
    for (i=0; i<ARRAY_COUNT; ++i)
    {
        // Fetch this file descriptor
        fd = fd_list[i];

        // Skip any invalid file descriptor
        if (fd < 0) continue;   

        // If this descriptor is readable, set the appropriate bit in the result
        if (FD_ISSET(fd, &rfds)) result |= (1 << i);
    }

    // Hand the caller a bitmap of which of his descriptors are readable
    return result;
}
//==========================================================================================================


//==========================================================================================================
// get_local_ip() - Fetches the IP address of the local machine
//
// Passed:  iface  = Name of the interface ("eth0", "eth1", etc)
//          family = AF_INET or AF_INET6
//          buffer = Pointer to the buffer where the binary address should end up
//
// Returns: True if an IP address was found, else false
//==========================================================================================================
static bool get_local_ip(string iface, int family, void* buffer)
{
    struct ifaddrs *ifaddr, *ifa;

    // Updating any one of these three variables updates all three of them
    union
    {
        sockaddr     *addr;
        sockaddr_in  *addr4;
        sockaddr_in6 *addr6;
    };
    
    // We haven't found an address yet
    bool is_found = false;

    // Fetch the list of network interfaces
    if (getifaddrs(&ifaddr) < 0) return false;

    // Walk through the linked list of interface information entries
    for (ifa = ifaddr; ifa != NULL; ifa = ifa->ifa_next)
    {
        // Get a handy reference to this entry
        ifaddrs& entry = *ifa;

        // If this entry is for a different interface, skip it
        if (entry.ifa_name != iface) continue;

        // Get a convenient pointer to the IP address for this entry
        addr = entry.ifa_addr;

        // If there's no IP address for this entry, skip it
        if (addr == NULL) continue;

        // If this entry is for the wrong family, skip it
        if (addr->sa_family != family) continue;

        // We've found our IP address
        is_found = true;

        // Copy the IP address into the caller's buffer
        if (family == AF_INET)
            memcpy(buffer, &addr4->sin_addr, 4);
        else
            memcpy(buffer, &addr6->sin6_addr, 16);

        // And break out of the loop
        break;
    }

    // Free the linked-list that was allocated by getifaddrs()
    freeifaddrs(ifaddr);

    // Tell the caller whether or not this worked
    return is_found;
}
//==========================================================================================================



//==========================================================================================================
// get_local_ip() - Fetches the IP address of the local machine
//
// Passed:  iface  = Name of the interface ("eth0", "eth1", etc)
//          dest   = A pointer to either an ipv4_t or an ipv6_t
//
// Returns: true if an IP address was retreived
//          If false is returned, the destination field is all zeros
//==========================================================================================================
bool NetUtil::get_local_ip(string iface, ipv4_t* dest)
{
    // If we were able to fetch an IP address, tell the caller
    if (::get_local_ip(iface, AF_INET, dest)) return true;
    
    // Otherwise, clear the destination to zeros, and tell the caller
    dest->clear();
    return false;
}

bool NetUtil::get_local_ip(string iface, ipv6_t* dest)
{
    // If we were able to fetch an IP address, tell the caller
    if (::get_local_ip(iface, AF_INET6, dest)) return true;

    // Otherwise, clear the destination to zeros, and tell the caller
    dest->clear();
    return false;
}
//==========================================================================================================


//==========================================================================================================
// text() - Returns the ASCII version of an IPv4 address
//==========================================================================================================
string ipv4_t::text()
{
    char buffer[64];
    sprintf(buffer, "%d.%d.%d.%d", octet[0], octet[1], octet[2], octet[3]);
    return buffer;
}
//==========================================================================================================


//==========================================================================================================
// text4() - Returns the ASCII version of an IPv4 address
//==========================================================================================================
string ipv6_t::text4()
{
    char buffer[64];
    sprintf(buffer, "%d.%d.%d.%d", octet[0], octet[1], octet[2], octet[3]);
    return buffer;
}
//==========================================================================================================



//==========================================================================================================
// text() - Returns the ASCII version of an IPv6 address
//==========================================================================================================
string ipv6_t::text()
{
    char buffer[64];
    sprintf
    (
        buffer,
        "%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x",
         octet[ 0], octet[ 1], octet[ 2], octet[ 3],
         octet[ 4], octet[ 5], octet[ 6], octet[ 7],
         octet[ 8], octet[ 9], octet[10], octet[11],
         octet[12], octet[13], octet[14], octet[15]
    );
    return buffer;         
}
//==========================================================================================================

//==========================================================================================================
// Clear the ipv4_t and ipv6_t objects to all zeros
//==========================================================================================================
void ipv4_t::clear() {memset(octet, 0, sizeof(octet));}
void ipv6_t::clear() {memset(octet, 0, sizeof(octet));}
//==========================================================================================================


//==========================================================================================================
// from_ipv4() - Stores an IPv4 address into the first 4 bytes of an IPv6 object
//==========================================================================================================
void ipv6_t::from_ipv4(ipv4_t rhs)
{
    clear();
    octet[0] = rhs.octet[0];
    octet[1] = rhs.octet[1];
    octet[2] = rhs.octet[2];
    octet[3] = rhs.octet[3];
}
//==========================================================================================================


//==========================================================================================================
// is_ipv4() - This will return true if the lower 12 bytes of the field are all zeros
//==========================================================================================================
bool ipv6_t::is_ipv4()
{
    for (int i=4; i<16; ++i)
    {
        if (octet[i]) return false;
    }

    return true;
}
//==========================================================================================================


//==========================================================================================================
// from_ai() - Fill in a addrinfo_t structure from a 'struct addrinfo'
//==========================================================================================================
void addrinfo_t::from_ai(addrinfo& ai)
{
    // Save the IP address, port, family, etc
    addr = *(sockaddr_storage*)ai.ai_addr;

    // Save the length of m_addr
    addrlen = ai.ai_addrlen;

    // Save the address family (AF_INET or AF_INET6)
    family = ai.ai_family;
    
    // Save the socket type (SOCK_DGRAM or SOCK_STREAM)
    socktype = ai.ai_socktype;

    // Save the protocol
    protocol = ai.ai_protocol;
}
//==========================================================================================================
