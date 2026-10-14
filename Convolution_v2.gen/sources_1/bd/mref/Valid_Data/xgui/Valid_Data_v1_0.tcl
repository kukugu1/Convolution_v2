# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DELAY_AdderTree_Enable" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DELAY_VALID_OUT" -parent ${Page_0}


}

proc update_PARAM_VALUE.DELAY_AdderTree_Enable { PARAM_VALUE.DELAY_AdderTree_Enable } {
	# Procedure called to update DELAY_AdderTree_Enable when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DELAY_AdderTree_Enable { PARAM_VALUE.DELAY_AdderTree_Enable } {
	# Procedure called to validate DELAY_AdderTree_Enable
	return true
}

proc update_PARAM_VALUE.DELAY_VALID_OUT { PARAM_VALUE.DELAY_VALID_OUT } {
	# Procedure called to update DELAY_VALID_OUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DELAY_VALID_OUT { PARAM_VALUE.DELAY_VALID_OUT } {
	# Procedure called to validate DELAY_VALID_OUT
	return true
}


proc update_MODELPARAM_VALUE.DELAY_AdderTree_Enable { MODELPARAM_VALUE.DELAY_AdderTree_Enable PARAM_VALUE.DELAY_AdderTree_Enable } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DELAY_AdderTree_Enable}] ${MODELPARAM_VALUE.DELAY_AdderTree_Enable}
}

proc update_MODELPARAM_VALUE.DELAY_VALID_OUT { MODELPARAM_VALUE.DELAY_VALID_OUT PARAM_VALUE.DELAY_VALID_OUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DELAY_VALID_OUT}] ${MODELPARAM_VALUE.DELAY_VALID_OUT}
}

