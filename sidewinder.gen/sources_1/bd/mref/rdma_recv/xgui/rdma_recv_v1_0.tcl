# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ADDR_WBITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_WBITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_WBYTS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PACKET_FIFO_DEPTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RDMA_HDR_BYTES" -parent ${Page_0}


}

proc update_PARAM_VALUE.ADDR_WBITS { PARAM_VALUE.ADDR_WBITS } {
	# Procedure called to update ADDR_WBITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDR_WBITS { PARAM_VALUE.ADDR_WBITS } {
	# Procedure called to validate ADDR_WBITS
	return true
}

proc update_PARAM_VALUE.DATA_WBITS { PARAM_VALUE.DATA_WBITS } {
	# Procedure called to update DATA_WBITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WBITS { PARAM_VALUE.DATA_WBITS } {
	# Procedure called to validate DATA_WBITS
	return true
}

proc update_PARAM_VALUE.DATA_WBYTS { PARAM_VALUE.DATA_WBYTS } {
	# Procedure called to update DATA_WBYTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WBYTS { PARAM_VALUE.DATA_WBYTS } {
	# Procedure called to validate DATA_WBYTS
	return true
}

proc update_PARAM_VALUE.PACKET_FIFO_DEPTH { PARAM_VALUE.PACKET_FIFO_DEPTH } {
	# Procedure called to update PACKET_FIFO_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PACKET_FIFO_DEPTH { PARAM_VALUE.PACKET_FIFO_DEPTH } {
	# Procedure called to validate PACKET_FIFO_DEPTH
	return true
}

proc update_PARAM_VALUE.RDMA_HDR_BYTES { PARAM_VALUE.RDMA_HDR_BYTES } {
	# Procedure called to update RDMA_HDR_BYTES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RDMA_HDR_BYTES { PARAM_VALUE.RDMA_HDR_BYTES } {
	# Procedure called to validate RDMA_HDR_BYTES
	return true
}


proc update_MODELPARAM_VALUE.DATA_WBITS { MODELPARAM_VALUE.DATA_WBITS PARAM_VALUE.DATA_WBITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WBITS}] ${MODELPARAM_VALUE.DATA_WBITS}
}

proc update_MODELPARAM_VALUE.DATA_WBYTS { MODELPARAM_VALUE.DATA_WBYTS PARAM_VALUE.DATA_WBYTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WBYTS}] ${MODELPARAM_VALUE.DATA_WBYTS}
}

proc update_MODELPARAM_VALUE.ADDR_WBITS { MODELPARAM_VALUE.ADDR_WBITS PARAM_VALUE.ADDR_WBITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDR_WBITS}] ${MODELPARAM_VALUE.ADDR_WBITS}
}

proc update_MODELPARAM_VALUE.RDMA_HDR_BYTES { MODELPARAM_VALUE.RDMA_HDR_BYTES PARAM_VALUE.RDMA_HDR_BYTES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RDMA_HDR_BYTES}] ${MODELPARAM_VALUE.RDMA_HDR_BYTES}
}

proc update_MODELPARAM_VALUE.PACKET_FIFO_DEPTH { MODELPARAM_VALUE.PACKET_FIFO_DEPTH PARAM_VALUE.PACKET_FIFO_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PACKET_FIFO_DEPTH}] ${MODELPARAM_VALUE.PACKET_FIFO_DEPTH}
}

