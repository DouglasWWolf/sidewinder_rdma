# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DATA_WBITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_WBYTS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "LOCAL_SERVER_PORT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "REMOTE_SERVER_PORT" -parent ${Page_0}


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

proc update_PARAM_VALUE.LOCAL_SERVER_PORT { PARAM_VALUE.LOCAL_SERVER_PORT } {
	# Procedure called to update LOCAL_SERVER_PORT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LOCAL_SERVER_PORT { PARAM_VALUE.LOCAL_SERVER_PORT } {
	# Procedure called to validate LOCAL_SERVER_PORT
	return true
}

proc update_PARAM_VALUE.REMOTE_SERVER_PORT { PARAM_VALUE.REMOTE_SERVER_PORT } {
	# Procedure called to update REMOTE_SERVER_PORT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.REMOTE_SERVER_PORT { PARAM_VALUE.REMOTE_SERVER_PORT } {
	# Procedure called to validate REMOTE_SERVER_PORT
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

proc update_MODELPARAM_VALUE.LOCAL_SERVER_PORT { MODELPARAM_VALUE.LOCAL_SERVER_PORT PARAM_VALUE.LOCAL_SERVER_PORT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LOCAL_SERVER_PORT}] ${MODELPARAM_VALUE.LOCAL_SERVER_PORT}
}

proc update_MODELPARAM_VALUE.REMOTE_SERVER_PORT { MODELPARAM_VALUE.REMOTE_SERVER_PORT PARAM_VALUE.REMOTE_SERVER_PORT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.REMOTE_SERVER_PORT}] ${MODELPARAM_VALUE.REMOTE_SERVER_PORT}
}

