#===============================================================================
#                                False paths
#===============================================================================

#
# The status signals of the Ethernet/QSFP channels
#
set_false_path -through [get_nets */ethernet/ch?_ethernet/ethernet/stat_rx_status]

