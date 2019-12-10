# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ADRW" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLKOFREQ" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATW" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DTMP" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NSTB" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "STBW" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TAGW" -parent ${Page_0}


}

proc update_PARAM_VALUE.ADRW { PARAM_VALUE.ADRW } {
	# Procedure called to update ADRW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADRW { PARAM_VALUE.ADRW } {
	# Procedure called to validate ADRW
	return true
}

proc update_PARAM_VALUE.CLKOFREQ { PARAM_VALUE.CLKOFREQ } {
	# Procedure called to update CLKOFREQ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLKOFREQ { PARAM_VALUE.CLKOFREQ } {
	# Procedure called to validate CLKOFREQ
	return true
}

proc update_PARAM_VALUE.DATW { PARAM_VALUE.DATW } {
	# Procedure called to update DATW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATW { PARAM_VALUE.DATW } {
	# Procedure called to validate DATW
	return true
}

proc update_PARAM_VALUE.DTMP { PARAM_VALUE.DTMP } {
	# Procedure called to update DTMP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DTMP { PARAM_VALUE.DTMP } {
	# Procedure called to validate DTMP
	return true
}

proc update_PARAM_VALUE.NSTB { PARAM_VALUE.NSTB } {
	# Procedure called to update NSTB when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NSTB { PARAM_VALUE.NSTB } {
	# Procedure called to validate NSTB
	return true
}

proc update_PARAM_VALUE.SIZE { PARAM_VALUE.SIZE } {
	# Procedure called to update SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SIZE { PARAM_VALUE.SIZE } {
	# Procedure called to validate SIZE
	return true
}

proc update_PARAM_VALUE.STBW { PARAM_VALUE.STBW } {
	# Procedure called to update STBW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.STBW { PARAM_VALUE.STBW } {
	# Procedure called to validate STBW
	return true
}

proc update_PARAM_VALUE.TAGW { PARAM_VALUE.TAGW } {
	# Procedure called to update TAGW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TAGW { PARAM_VALUE.TAGW } {
	# Procedure called to validate TAGW
	return true
}


proc update_MODELPARAM_VALUE.TAGW { MODELPARAM_VALUE.TAGW PARAM_VALUE.TAGW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TAGW}] ${MODELPARAM_VALUE.TAGW}
}

proc update_MODELPARAM_VALUE.ADRW { MODELPARAM_VALUE.ADRW PARAM_VALUE.ADRW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADRW}] ${MODELPARAM_VALUE.ADRW}
}

proc update_MODELPARAM_VALUE.DATW { MODELPARAM_VALUE.DATW PARAM_VALUE.DATW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATW}] ${MODELPARAM_VALUE.DATW}
}

proc update_MODELPARAM_VALUE.SIZE { MODELPARAM_VALUE.SIZE PARAM_VALUE.SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SIZE}] ${MODELPARAM_VALUE.SIZE}
}

proc update_MODELPARAM_VALUE.STBW { MODELPARAM_VALUE.STBW PARAM_VALUE.STBW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.STBW}] ${MODELPARAM_VALUE.STBW}
}

proc update_MODELPARAM_VALUE.DTMP { MODELPARAM_VALUE.DTMP PARAM_VALUE.DTMP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DTMP}] ${MODELPARAM_VALUE.DTMP}
}

proc update_MODELPARAM_VALUE.NSTB { MODELPARAM_VALUE.NSTB PARAM_VALUE.NSTB } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NSTB}] ${MODELPARAM_VALUE.NSTB}
}

proc update_MODELPARAM_VALUE.CLKOFREQ { MODELPARAM_VALUE.CLKOFREQ PARAM_VALUE.CLKOFREQ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLKOFREQ}] ${MODELPARAM_VALUE.CLKOFREQ}
}

