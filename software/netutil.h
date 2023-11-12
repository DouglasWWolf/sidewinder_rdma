//==========================================================================================================
// netutil.h - Defines some helpful utility functions for networking
//==========================================================================================================
#pragma once
#include <netinet/in.h>
#include <string>
#include <netdb.h>

struct ipv4_t
{
    // Data
    unsigned char octet[4];
    
    // Conversion to IPv4 ASCII address
    std::string   text();
    
    // Clear the data to zeros
    void          clear();
};

struct ipv6_t
{
    // Data
    unsigned char octet[16];
    
    // Default constructor
    ipv6_t() {};
    
    // Constructor from an ipv4_t
    ipv6_t(ipv4_t rhs) {from_ipv4(rhs);}
    
    // Assignment from an ipv4_t
    ipv6_t& operator=(ipv4_t rhs) {from_ipv4(rhs); return *this;}
    
    // Conversion to IPv6 ASCII address
    std::string   text();
    
    // Clear the data to zeros
    void          clear();
    
    // Conversion to IPv4 ASCII address
    std::string   text4();
    
    // Assignment from an ipv4_t
    void          from_ipv4(ipv4_t rhs);
    
    // Test to see if this is potentially an IPv4 address
    bool          is_ipv4();
};


// This is the equivalent of a 'struct addrinfo', but with no pointers
struct addrinfo_t
{
    addrinfo_t& operator=(addrinfo& rhs) {from_ai(rhs); return *this;}
    operator sockaddr*() const {return (sockaddr*)&addr;}
    void      from_ai(addrinfo& rhs);
    sockaddr_storage addr;
    socklen_t        addrlen;
    int              family;
    int              socktype;
    int              protocol;
};

struct NetUtil
{
    // These fetch a binary IP address for the local host
    static bool get_local_ip(std::string iface, ipv4_t* dest);
    static bool get_local_ip(std::string iface, ipv6_t* dest);

    // Returns addrinfo about the local machine
    static addrinfo_t get_local_addrinfo(int type, int port, std::string bind_to, int family);

    // Returns addrinfo about a remove server
    static bool get_server_addrinfo(int type, std::string server, int port, int family, addrinfo_t* p_result);

    // Fetches the ASCII IP address from a sockaddr*.  
    static std::string ip_to_string(sockaddr* addr);

    // Converts a sockaddr_storage to an ASCII IP address.
    static std::string ip_to_string(sockaddr_storage& ss);

    // Call this to wait for data to arrive on anywhere from 1 to 4 descriptors
    // timeout_ms of -1 means "wait forever"
    static int wait_for_data(int timeout_ms, int fd1, int fd2 = -1, int fd3 = -1, int fd4 = -1);
};


