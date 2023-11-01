# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ACTIVE_STATE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLOCKS_PER_USEC" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DEBOUNCE_MSEC" -parent ${Page_0}


}

proc update_PARAM_VALUE.ACTIVE_STATE { PARAM_VALUE.ACTIVE_STATE } {
	# Procedure called to update ACTIVE_STATE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ACTIVE_STATE { PARAM_VALUE.ACTIVE_STATE } {
	# Procedure called to validate ACTIVE_STATE
	return true
}

proc update_PARAM_VALUE.CLOCKS_PER_USEC { PARAM_VALUE.CLOCKS_PER_USEC } {
	# Procedure called to update CLOCKS_PER_USEC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLOCKS_PER_USEC { PARAM_VALUE.CLOCKS_PER_USEC } {
	# Procedure called to validate CLOCKS_PER_USEC
	return true
}

proc update_PARAM_VALUE.DEBOUNCE_MSEC { PARAM_VALUE.DEBOUNCE_MSEC } {
	# Procedure called to update DEBOUNCE_MSEC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEBOUNCE_MSEC { PARAM_VALUE.DEBOUNCE_MSEC } {
	# Procedure called to validate DEBOUNCE_MSEC
	return true
}


proc update_MODELPARAM_VALUE.ACTIVE_STATE { MODELPARAM_VALUE.ACTIVE_STATE PARAM_VALUE.ACTIVE_STATE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ACTIVE_STATE}] ${MODELPARAM_VALUE.ACTIVE_STATE}
}

proc update_MODELPARAM_VALUE.CLOCKS_PER_USEC { MODELPARAM_VALUE.CLOCKS_PER_USEC PARAM_VALUE.CLOCKS_PER_USEC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLOCKS_PER_USEC}] ${MODELPARAM_VALUE.CLOCKS_PER_USEC}
}

proc update_MODELPARAM_VALUE.DEBOUNCE_MSEC { MODELPARAM_VALUE.DEBOUNCE_MSEC PARAM_VALUE.DEBOUNCE_MSEC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEBOUNCE_MSEC}] ${MODELPARAM_VALUE.DEBOUNCE_MSEC}
}

