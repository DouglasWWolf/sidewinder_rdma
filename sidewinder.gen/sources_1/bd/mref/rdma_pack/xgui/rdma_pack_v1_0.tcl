# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "RDMA_HDR_LEN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "STREAM_WB" -parent ${Page_0}


}

proc update_PARAM_VALUE.RDMA_HDR_LEN { PARAM_VALUE.RDMA_HDR_LEN } {
	# Procedure called to update RDMA_HDR_LEN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RDMA_HDR_LEN { PARAM_VALUE.RDMA_HDR_LEN } {
	# Procedure called to validate RDMA_HDR_LEN
	return true
}

proc update_PARAM_VALUE.STREAM_WB { PARAM_VALUE.STREAM_WB } {
	# Procedure called to update STREAM_WB when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.STREAM_WB { PARAM_VALUE.STREAM_WB } {
	# Procedure called to validate STREAM_WB
	return true
}


proc update_MODELPARAM_VALUE.STREAM_WB { MODELPARAM_VALUE.STREAM_WB PARAM_VALUE.STREAM_WB } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.STREAM_WB}] ${MODELPARAM_VALUE.STREAM_WB}
}

proc update_MODELPARAM_VALUE.RDMA_HDR_LEN { MODELPARAM_VALUE.RDMA_HDR_LEN PARAM_VALUE.RDMA_HDR_LEN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RDMA_HDR_LEN}] ${MODELPARAM_VALUE.RDMA_HDR_LEN}
}

