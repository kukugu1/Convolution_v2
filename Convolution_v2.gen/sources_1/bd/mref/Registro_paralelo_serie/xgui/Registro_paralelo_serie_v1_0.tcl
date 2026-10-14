# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "Data_length" -parent ${Page_0}
  ipgui::add_param $IPINST -name "Pad_words" -parent ${Page_0}


}

proc update_PARAM_VALUE.Data_length { PARAM_VALUE.Data_length } {
	# Procedure called to update Data_length when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Data_length { PARAM_VALUE.Data_length } {
	# Procedure called to validate Data_length
	return true
}

proc update_PARAM_VALUE.Pad_words { PARAM_VALUE.Pad_words } {
	# Procedure called to update Pad_words when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Pad_words { PARAM_VALUE.Pad_words } {
	# Procedure called to validate Pad_words
	return true
}


proc update_MODELPARAM_VALUE.Data_length { MODELPARAM_VALUE.Data_length PARAM_VALUE.Data_length } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Data_length}] ${MODELPARAM_VALUE.Data_length}
}

proc update_MODELPARAM_VALUE.Pad_words { MODELPARAM_VALUE.Pad_words PARAM_VALUE.Pad_words } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Pad_words}] ${MODELPARAM_VALUE.Pad_words}
}

