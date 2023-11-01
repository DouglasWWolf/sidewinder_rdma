# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DST_IP0" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DST_IP1" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DST_IP2" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DST_IP3" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DST_PORT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SRC_IP0" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SRC_IP1" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SRC_IP2" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SRC_IP3" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SRC_MAC" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SRC_PORT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SWIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.DST_IP0 { PARAM_VALUE.DST_IP0 } {
	# Procedure called to update DST_IP0 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DST_IP0 { PARAM_VALUE.DST_IP0 } {
	# Procedure called to validate DST_IP0
	return true
}

proc update_PARAM_VALUE.DST_IP1 { PARAM_VALUE.DST_IP1 } {
	# Procedure called to update DST_IP1 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DST_IP1 { PARAM_VALUE.DST_IP1 } {
	# Procedure called to validate DST_IP1
	return true
}

proc update_PARAM_VALUE.DST_IP2 { PARAM_VALUE.DST_IP2 } {
	# Procedure called to update DST_IP2 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DST_IP2 { PARAM_VALUE.DST_IP2 } {
	# Procedure called to validate DST_IP2
	return true
}

proc update_PARAM_VALUE.DST_IP3 { PARAM_VALUE.DST_IP3 } {
	# Procedure called to update DST_IP3 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DST_IP3 { PARAM_VALUE.DST_IP3 } {
	# Procedure called to validate DST_IP3
	return true
}

proc update_PARAM_VALUE.DST_PORT { PARAM_VALUE.DST_PORT } {
	# Procedure called to update DST_PORT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DST_PORT { PARAM_VALUE.DST_PORT } {
	# Procedure called to validate DST_PORT
	return true
}

proc update_PARAM_VALUE.SRC_IP0 { PARAM_VALUE.SRC_IP0 } {
	# Procedure called to update SRC_IP0 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SRC_IP0 { PARAM_VALUE.SRC_IP0 } {
	# Procedure called to validate SRC_IP0
	return true
}

proc update_PARAM_VALUE.SRC_IP1 { PARAM_VALUE.SRC_IP1 } {
	# Procedure called to update SRC_IP1 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SRC_IP1 { PARAM_VALUE.SRC_IP1 } {
	# Procedure called to validate SRC_IP1
	return true
}

proc update_PARAM_VALUE.SRC_IP2 { PARAM_VALUE.SRC_IP2 } {
	# Procedure called to update SRC_IP2 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SRC_IP2 { PARAM_VALUE.SRC_IP2 } {
	# Procedure called to validate SRC_IP2
	return true
}

proc update_PARAM_VALUE.SRC_IP3 { PARAM_VALUE.SRC_IP3 } {
	# Procedure called to update SRC_IP3 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SRC_IP3 { PARAM_VALUE.SRC_IP3 } {
	# Procedure called to validate SRC_IP3
	return true
}

proc update_PARAM_VALUE.SRC_MAC { PARAM_VALUE.SRC_MAC } {
	# Procedure called to update SRC_MAC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SRC_MAC { PARAM_VALUE.SRC_MAC } {
	# Procedure called to validate SRC_MAC
	return true
}

proc update_PARAM_VALUE.SRC_PORT { PARAM_VALUE.SRC_PORT } {
	# Procedure called to update SRC_PORT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SRC_PORT { PARAM_VALUE.SRC_PORT } {
	# Procedure called to validate SRC_PORT
	return true
}

proc update_PARAM_VALUE.SWIDTH { PARAM_VALUE.SWIDTH } {
	# Procedure called to update SWIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SWIDTH { PARAM_VALUE.SWIDTH } {
	# Procedure called to validate SWIDTH
	return true
}


proc update_MODELPARAM_VALUE.SRC_MAC { MODELPARAM_VALUE.SRC_MAC PARAM_VALUE.SRC_MAC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SRC_MAC}] ${MODELPARAM_VALUE.SRC_MAC}
}

proc update_MODELPARAM_VALUE.SRC_IP0 { MODELPARAM_VALUE.SRC_IP0 PARAM_VALUE.SRC_IP0 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SRC_IP0}] ${MODELPARAM_VALUE.SRC_IP0}
}

proc update_MODELPARAM_VALUE.SRC_IP1 { MODELPARAM_VALUE.SRC_IP1 PARAM_VALUE.SRC_IP1 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SRC_IP1}] ${MODELPARAM_VALUE.SRC_IP1}
}

proc update_MODELPARAM_VALUE.SRC_IP2 { MODELPARAM_VALUE.SRC_IP2 PARAM_VALUE.SRC_IP2 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SRC_IP2}] ${MODELPARAM_VALUE.SRC_IP2}
}

proc update_MODELPARAM_VALUE.SRC_IP3 { MODELPARAM_VALUE.SRC_IP3 PARAM_VALUE.SRC_IP3 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SRC_IP3}] ${MODELPARAM_VALUE.SRC_IP3}
}

proc update_MODELPARAM_VALUE.DST_IP0 { MODELPARAM_VALUE.DST_IP0 PARAM_VALUE.DST_IP0 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DST_IP0}] ${MODELPARAM_VALUE.DST_IP0}
}

proc update_MODELPARAM_VALUE.DST_IP1 { MODELPARAM_VALUE.DST_IP1 PARAM_VALUE.DST_IP1 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DST_IP1}] ${MODELPARAM_VALUE.DST_IP1}
}

proc update_MODELPARAM_VALUE.DST_IP2 { MODELPARAM_VALUE.DST_IP2 PARAM_VALUE.DST_IP2 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DST_IP2}] ${MODELPARAM_VALUE.DST_IP2}
}

proc update_MODELPARAM_VALUE.DST_IP3 { MODELPARAM_VALUE.DST_IP3 PARAM_VALUE.DST_IP3 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DST_IP3}] ${MODELPARAM_VALUE.DST_IP3}
}

proc update_MODELPARAM_VALUE.SRC_PORT { MODELPARAM_VALUE.SRC_PORT PARAM_VALUE.SRC_PORT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SRC_PORT}] ${MODELPARAM_VALUE.SRC_PORT}
}

proc update_MODELPARAM_VALUE.DST_PORT { MODELPARAM_VALUE.DST_PORT PARAM_VALUE.DST_PORT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DST_PORT}] ${MODELPARAM_VALUE.DST_PORT}
}

proc update_MODELPARAM_VALUE.SWIDTH { MODELPARAM_VALUE.SWIDTH PARAM_VALUE.SWIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SWIDTH}] ${MODELPARAM_VALUE.SWIDTH}
}

