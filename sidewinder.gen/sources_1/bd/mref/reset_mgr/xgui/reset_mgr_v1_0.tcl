# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ACTIVE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLKS_PER_USEC" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INACTIVE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RESET_TIMEOUT" -parent ${Page_0}


}

proc update_PARAM_VALUE.ACTIVE { PARAM_VALUE.ACTIVE } {
	# Procedure called to update ACTIVE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ACTIVE { PARAM_VALUE.ACTIVE } {
	# Procedure called to validate ACTIVE
	return true
}

proc update_PARAM_VALUE.CLKS_PER_USEC { PARAM_VALUE.CLKS_PER_USEC } {
	# Procedure called to update CLKS_PER_USEC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLKS_PER_USEC { PARAM_VALUE.CLKS_PER_USEC } {
	# Procedure called to validate CLKS_PER_USEC
	return true
}

proc update_PARAM_VALUE.INACTIVE { PARAM_VALUE.INACTIVE } {
	# Procedure called to update INACTIVE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INACTIVE { PARAM_VALUE.INACTIVE } {
	# Procedure called to validate INACTIVE
	return true
}

proc update_PARAM_VALUE.RESET_TIMEOUT { PARAM_VALUE.RESET_TIMEOUT } {
	# Procedure called to update RESET_TIMEOUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RESET_TIMEOUT { PARAM_VALUE.RESET_TIMEOUT } {
	# Procedure called to validate RESET_TIMEOUT
	return true
}


proc update_MODELPARAM_VALUE.CLKS_PER_USEC { MODELPARAM_VALUE.CLKS_PER_USEC PARAM_VALUE.CLKS_PER_USEC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLKS_PER_USEC}] ${MODELPARAM_VALUE.CLKS_PER_USEC}
}

proc update_MODELPARAM_VALUE.RESET_TIMEOUT { MODELPARAM_VALUE.RESET_TIMEOUT PARAM_VALUE.RESET_TIMEOUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RESET_TIMEOUT}] ${MODELPARAM_VALUE.RESET_TIMEOUT}
}

proc update_MODELPARAM_VALUE.ACTIVE { MODELPARAM_VALUE.ACTIVE PARAM_VALUE.ACTIVE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ACTIVE}] ${MODELPARAM_VALUE.ACTIVE}
}

proc update_MODELPARAM_VALUE.INACTIVE { MODELPARAM_VALUE.INACTIVE PARAM_VALUE.INACTIVE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INACTIVE}] ${MODELPARAM_VALUE.INACTIVE}
}

