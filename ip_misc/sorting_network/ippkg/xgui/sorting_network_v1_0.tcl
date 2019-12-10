# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "AXIS_DATW" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXIS_KEPW" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_S_ADRW" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_S_DATW" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_S_STBW" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BUFD_ORDER" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_ARUSER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_AWUSER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_BASEADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_BUSER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_HIGHADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_RUSER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_WUSER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATW" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WRDN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WRDW" -parent ${Page_0}


}

proc update_PARAM_VALUE.AXIS_DATW { PARAM_VALUE.AXIS_DATW } {
	# Procedure called to update AXIS_DATW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXIS_DATW { PARAM_VALUE.AXIS_DATW } {
	# Procedure called to validate AXIS_DATW
	return true
}

proc update_PARAM_VALUE.AXIS_KEPW { PARAM_VALUE.AXIS_KEPW } {
	# Procedure called to update AXIS_KEPW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXIS_KEPW { PARAM_VALUE.AXIS_KEPW } {
	# Procedure called to validate AXIS_KEPW
	return true
}

proc update_PARAM_VALUE.AXI_S_ADRW { PARAM_VALUE.AXI_S_ADRW } {
	# Procedure called to update AXI_S_ADRW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_S_ADRW { PARAM_VALUE.AXI_S_ADRW } {
	# Procedure called to validate AXI_S_ADRW
	return true
}

proc update_PARAM_VALUE.AXI_S_DATW { PARAM_VALUE.AXI_S_DATW } {
	# Procedure called to update AXI_S_DATW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_S_DATW { PARAM_VALUE.AXI_S_DATW } {
	# Procedure called to validate AXI_S_DATW
	return true
}

proc update_PARAM_VALUE.AXI_S_STBW { PARAM_VALUE.AXI_S_STBW } {
	# Procedure called to update AXI_S_STBW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_S_STBW { PARAM_VALUE.AXI_S_STBW } {
	# Procedure called to validate AXI_S_STBW
	return true
}

proc update_PARAM_VALUE.BUFD_ORDER { PARAM_VALUE.BUFD_ORDER } {
	# Procedure called to update BUFD_ORDER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BUFD_ORDER { PARAM_VALUE.BUFD_ORDER } {
	# Procedure called to validate BUFD_ORDER
	return true
}

proc update_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_ARUSER_WIDTH { PARAM_VALUE.C_S_AXI_ARUSER_WIDTH } {
	# Procedure called to update C_S_AXI_ARUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ARUSER_WIDTH { PARAM_VALUE.C_S_AXI_ARUSER_WIDTH } {
	# Procedure called to validate C_S_AXI_ARUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_AWUSER_WIDTH { PARAM_VALUE.C_S_AXI_AWUSER_WIDTH } {
	# Procedure called to update C_S_AXI_AWUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_AWUSER_WIDTH { PARAM_VALUE.C_S_AXI_AWUSER_WIDTH } {
	# Procedure called to validate C_S_AXI_AWUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_BASEADDR { PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to update C_S_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_BASEADDR { PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to validate C_S_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_BUSER_WIDTH { PARAM_VALUE.C_S_AXI_BUSER_WIDTH } {
	# Procedure called to update C_S_AXI_BUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_BUSER_WIDTH { PARAM_VALUE.C_S_AXI_BUSER_WIDTH } {
	# Procedure called to validate C_S_AXI_BUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_HIGHADDR { PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to update C_S_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_HIGHADDR { PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to validate C_S_AXI_HIGHADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_RUSER_WIDTH { PARAM_VALUE.C_S_AXI_RUSER_WIDTH } {
	# Procedure called to update C_S_AXI_RUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_RUSER_WIDTH { PARAM_VALUE.C_S_AXI_RUSER_WIDTH } {
	# Procedure called to validate C_S_AXI_RUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_WUSER_WIDTH { PARAM_VALUE.C_S_AXI_WUSER_WIDTH } {
	# Procedure called to update C_S_AXI_WUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_WUSER_WIDTH { PARAM_VALUE.C_S_AXI_WUSER_WIDTH } {
	# Procedure called to validate C_S_AXI_WUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.DATW { PARAM_VALUE.DATW } {
	# Procedure called to update DATW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATW { PARAM_VALUE.DATW } {
	# Procedure called to validate DATW
	return true
}

proc update_PARAM_VALUE.WRDN { PARAM_VALUE.WRDN } {
	# Procedure called to update WRDN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WRDN { PARAM_VALUE.WRDN } {
	# Procedure called to validate WRDN
	return true
}

proc update_PARAM_VALUE.WRDW { PARAM_VALUE.WRDW } {
	# Procedure called to update WRDW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WRDW { PARAM_VALUE.WRDW } {
	# Procedure called to validate WRDW
	return true
}


proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_BASEADDR { MODELPARAM_VALUE.C_S_AXI_BASEADDR PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_BASEADDR}] ${MODELPARAM_VALUE.C_S_AXI_BASEADDR}
}

proc update_MODELPARAM_VALUE.C_S_AXI_HIGHADDR { MODELPARAM_VALUE.C_S_AXI_HIGHADDR PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_HIGHADDR}] ${MODELPARAM_VALUE.C_S_AXI_HIGHADDR}
}

proc update_MODELPARAM_VALUE.C_S_AXI_AWUSER_WIDTH { MODELPARAM_VALUE.C_S_AXI_AWUSER_WIDTH PARAM_VALUE.C_S_AXI_AWUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_AWUSER_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_AWUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_ARUSER_WIDTH { MODELPARAM_VALUE.C_S_AXI_ARUSER_WIDTH PARAM_VALUE.C_S_AXI_ARUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ARUSER_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ARUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_WUSER_WIDTH { MODELPARAM_VALUE.C_S_AXI_WUSER_WIDTH PARAM_VALUE.C_S_AXI_WUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_WUSER_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_WUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_RUSER_WIDTH { MODELPARAM_VALUE.C_S_AXI_RUSER_WIDTH PARAM_VALUE.C_S_AXI_RUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_RUSER_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_RUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_BUSER_WIDTH { MODELPARAM_VALUE.C_S_AXI_BUSER_WIDTH PARAM_VALUE.C_S_AXI_BUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_BUSER_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_BUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.WRDW { MODELPARAM_VALUE.WRDW PARAM_VALUE.WRDW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WRDW}] ${MODELPARAM_VALUE.WRDW}
}

proc update_MODELPARAM_VALUE.WRDN { MODELPARAM_VALUE.WRDN PARAM_VALUE.WRDN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WRDN}] ${MODELPARAM_VALUE.WRDN}
}

proc update_MODELPARAM_VALUE.DATW { MODELPARAM_VALUE.DATW PARAM_VALUE.DATW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATW}] ${MODELPARAM_VALUE.DATW}
}

proc update_MODELPARAM_VALUE.BUFD_ORDER { MODELPARAM_VALUE.BUFD_ORDER PARAM_VALUE.BUFD_ORDER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BUFD_ORDER}] ${MODELPARAM_VALUE.BUFD_ORDER}
}

proc update_MODELPARAM_VALUE.AXI_S_ADRW { MODELPARAM_VALUE.AXI_S_ADRW PARAM_VALUE.AXI_S_ADRW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_S_ADRW}] ${MODELPARAM_VALUE.AXI_S_ADRW}
}

proc update_MODELPARAM_VALUE.AXI_S_DATW { MODELPARAM_VALUE.AXI_S_DATW PARAM_VALUE.AXI_S_DATW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_S_DATW}] ${MODELPARAM_VALUE.AXI_S_DATW}
}

proc update_MODELPARAM_VALUE.AXI_S_STBW { MODELPARAM_VALUE.AXI_S_STBW PARAM_VALUE.AXI_S_STBW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_S_STBW}] ${MODELPARAM_VALUE.AXI_S_STBW}
}

proc update_MODELPARAM_VALUE.AXIS_DATW { MODELPARAM_VALUE.AXIS_DATW PARAM_VALUE.AXIS_DATW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIS_DATW}] ${MODELPARAM_VALUE.AXIS_DATW}
}

proc update_MODELPARAM_VALUE.AXIS_KEPW { MODELPARAM_VALUE.AXIS_KEPW PARAM_VALUE.AXIS_KEPW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIS_KEPW}] ${MODELPARAM_VALUE.AXIS_KEPW}
}

