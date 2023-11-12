# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DATA_WBITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_WBYTS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RDMA_DEST_PORT1" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RDMA_DEST_PORT2" -parent ${Page_0}


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

proc update_PARAM_VALUE.RDMA_DEST_PORT1 { PARAM_VALUE.RDMA_DEST_PORT1 } {
	# Procedure called to update RDMA_DEST_PORT1 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RDMA_DEST_PORT1 { PARAM_VALUE.RDMA_DEST_PORT1 } {
	# Procedure called to validate RDMA_DEST_PORT1
	return true
}

proc update_PARAM_VALUE.RDMA_DEST_PORT2 { PARAM_VALUE.RDMA_DEST_PORT2 } {
	# Procedure called to update RDMA_DEST_PORT2 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RDMA_DEST_PORT2 { PARAM_VALUE.RDMA_DEST_PORT2 } {
	# Procedure called to validate RDMA_DEST_PORT2
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

proc update_MODELPARAM_VALUE.RDMA_DEST_PORT1 { MODELPARAM_VALUE.RDMA_DEST_PORT1 PARAM_VALUE.RDMA_DEST_PORT1 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RDMA_DEST_PORT1}] ${MODELPARAM_VALUE.RDMA_DEST_PORT1}
}

proc update_MODELPARAM_VALUE.RDMA_DEST_PORT2 { MODELPARAM_VALUE.RDMA_DEST_PORT2 PARAM_VALUE.RDMA_DEST_PORT2 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RDMA_DEST_PORT2}] ${MODELPARAM_VALUE.RDMA_DEST_PORT2}
}

