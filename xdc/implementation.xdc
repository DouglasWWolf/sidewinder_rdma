#===============================================================================
#                                False paths
#===============================================================================

#
# The status signals of the Aurora/QSFP channels
#
set_false_path -through [get_nets */qsfp_data/qsfp_status/ss0_*]
set_false_path -through [get_nets */qsfp_data/qsfp_status/ss1_*]
