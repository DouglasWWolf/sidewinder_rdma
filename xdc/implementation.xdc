#===============================================================================
#                                False paths
#===============================================================================

#
# The status signals of the Ethernet/QSFP channels
#
set_false_path -through [get_nets */ethernet/ch?_ethernet/eth_core/stat_rx_status]
set_false_path -through [get_nets */ethernet/ch?_ethernet/pkt_dropped]


