
##########################################################################
# User Setting
##########################################################################

set proj_dir                ./ip_proj
set device                  xcku040-ffva1156-2-e

set ip_design               QEMUPCIeBridge 
set ip_top                  axi4_ip
set ip_vender               COMPAS
set ip_url                  {http://www.compas.cs.stonybrook.edu}
set ip_description          {QEMU-HDL PCIe Bridge}
set ip_version              1.0.0
set ip_lib                  COMPAS
set ip_families             {{kintexu} {Production}}
set ip_taxonomy             {{/COMPAS/IP}}

set adrw                    32

##########################################################################
# Create IP
##########################################################################

#create_project -name ${ip_design} -force -dir "./${proj_dir}" -part ${device} -ip
create_project -name ${ip_design} -force -dir "./${proj_dir}" -part ${device} 
set_property source_mgmt_mode All [current_project]  
set_property top ${ip_top} [current_fileset]
set_property ip_repo_paths ./ip  [current_fileset]
puts "Creating IP"

##########################################################################
# Add Files
##########################################################################

#foreach vfile [glob ./hdl/*.v] {
#    read_verilog $vfile
#}


read_verilog ./hdl/axi4_ip_mod.sv
read_verilog ./hdl/axi4_s_r.sv
read_verilog ./hdl/axi4_s_w.sv
read_verilog ./hdl/axi4_s_i.sv
read_verilog ./hdl/axi4_m_r.sv
read_verilog ./hdl/axi4_m_w.sv
##########################################################################
# Create IP
##########################################################################

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
ipx::package_project -generated_files

set_property name                   ${ip_design}                            [ipx::current_core]
set_property display_name           ${ip_design}                            [ipx::current_core]
set_property vendor                 ${ip_vender}                            [ipx::current_core]
set_property vendor_display_name    ${ip_vender}                            [ipx::current_core]
set_property version                ${ip_version}                           [ipx::current_core]
set_property library                ${ip_lib}                               [ipx::current_core]
set_property company_url            ${ip_url}                               [ipx::current_core]
set_property description            ${ip_description}                       [ipx::current_core]
set_property supported_families     ${ip_families}                          [ipx::current_core]
set_property taxonomy               ${ip_taxonomy}                          [ipx::current_core]

update_ip_catalog -rebuild 

##########################################################################
# Create Interfaces
##########################################################################

# remove all inferred interfaces/address spaces
ipx::remove_all_address_space [ipx::current_core]
ipx::remove_all_bus_interface [ipx::current_core]

#==========================================================
# Create Interfaces: CLK/RST
#==========================================================

#-------------------------------------------
# Create Interfaces: CLK/RST: axi_aclk
#-------------------------------------------

ipx::add_bus_interface axi_aclk [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0 [ipx::get_bus_interfaces axi_aclk -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:signal:clock:1.0 [ipx::get_bus_interfaces axi_aclk -of_objects [ipx::current_core]]
set_property interface_mode master [ipx::get_bus_interfaces axi_aclk -of_objects [ipx::current_core]]
ipx::add_port_map CLK [ipx::get_bus_interfaces axi_aclk -of_objects [ipx::current_core]]
set_property physical_name o_axi_aclk [ipx::get_port_maps CLK -of_objects [ipx::get_bus_interfaces axi_aclk -of_objects [ipx::current_core]]]

# Due to a bug of Vivado, user have to manually set the FREQ_HZ of axi_aclk to 250000000 after instantiate the bridge IP
#ipx::add_bus_parameter FREQ_HZ [ipx::get_bus_interfaces axi_aclk -of_objects [ipx::current_core]]
#set_property description 250000000 [ipx::get_bus_parameters FREQ_HZ -of_objects [ipx::get_bus_interfaces axi_aclk -of_objects [ipx::current_core]]]

#-------------------------------------------
# Create Interfaces: CLK/RST: axi_aresetn
#-------------------------------------------

ipx::add_bus_interface axi_aresetn [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0 [ipx::get_bus_interfaces axi_aresetn -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:signal:reset:1.0 [ipx::get_bus_interfaces axi_aresetn -of_objects [ipx::current_core]]
set_property interface_mode master [ipx::get_bus_interfaces axi_aresetn -of_objects [ipx::current_core]]
ipx::add_port_map RST [ipx::get_bus_interfaces axi_aresetn -of_objects [ipx::current_core]]
set_property physical_name o_axi_aresetn [ipx::get_port_maps RST -of_objects [ipx::get_bus_interfaces axi_aresetn -of_objects [ipx::current_core]]]
ipx::associate_bus_interfaces -clock axi_aclk -reset o_axi_aresetn [ipx::current_core]

#-------------------------------------------
# Create Interfaces: CLK/RST: Not Used
#-------------------------------------------

ipx::add_bus_interface axi_ctl_aclk [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0 [ipx::get_bus_interfaces axi_ctl_aclk -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:signal:clock:1.0 [ipx::get_bus_interfaces axi_ctl_aclk -of_objects [ipx::current_core]]
ipx::add_port_map CLK [ipx::get_bus_interfaces axi_ctl_aclk -of_objects [ipx::current_core]]
set_property physical_name i_axi_ctl_aclk [ipx::get_port_maps CLK -of_objects [ipx::get_bus_interfaces axi_ctl_aclk -of_objects [ipx::current_core]]]

ipx::add_bus_interface refclk [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:aximm_rtl:1.0 [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:aximm:1.0 [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]
set_property abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0 [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:signal:clock:1.0 [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]
ipx::add_port_map CLK [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]
set_property physical_name i_refclk [ipx::get_port_maps CLK -of_objects [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]]


ipx::add_bus_interface sys_rst_n [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0 [ipx::get_bus_interfaces sys_rst_n -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:signal:reset:1.0 [ipx::get_bus_interfaces sys_rst_n -of_objects [ipx::current_core]]
ipx::add_port_map RST [ipx::get_bus_interfaces sys_rst_n -of_objects [ipx::current_core]]
set_property physical_name i_sys_rst_n [ipx::get_port_maps RST -of_objects [ipx::get_bus_interfaces sys_rst_n -of_objects [ipx::current_core]]]
ipx::associate_bus_interfaces -clock axi_ctl_aclk -reset i_sys_rst_n [ipx::current_core]


#==========================================================
# Create Interfaces: AXI
#==========================================================

#-------------------------------------------
# Create Interfaces: AXI: S_AXI
#-------------------------------------------

ipx::add_bus_interface                  S_AXI                             [ipx::current_core]
ipx::associate_bus_interfaces -busif    S_AXI     -clock axi_aclk         [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:aximm_rtl:1.0   [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:aximm:1.0               [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
set_property interface_mode slave                                       [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]

ipx::add_port_map ARID      [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARADDR    [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARLEN     [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARSIZE    [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARBURST   [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARLOCK    [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARCACHE   [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARPROT    [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARREGION  [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARVALID   [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARREADY   [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]

ipx::add_port_map RID       [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map RDATA     [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map RRESP     [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map RLAST     [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map RVALID    [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map RREADY    [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]

ipx::add_port_map AWID      [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWADDR    [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWLEN     [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWSIZE    [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWBURST   [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWLOCK    [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWCACHE   [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWPROT    [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWREGION  [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWVALID   [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWREADY   [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]

ipx::add_port_map WID       [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map WDATA     [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map WLAST     [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map WSTRB     [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map WVALID    [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map WREADY    [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]

ipx::add_port_map BID       [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map BRESP     [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map BVALID    [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map BREADY    [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]

set_property physical_name i_s_arid       [ipx::get_port_maps ARID        -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_araddr     [ipx::get_port_maps ARADDR      -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_arlen      [ipx::get_port_maps ARLEN       -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_arsize     [ipx::get_port_maps ARSIZE      -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_arburst    [ipx::get_port_maps ARBURST     -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_arlock     [ipx::get_port_maps ARLOCK      -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_arcache    [ipx::get_port_maps ARCACHE     -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_arprot     [ipx::get_port_maps ARPROT      -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_arregion   [ipx::get_port_maps ARREGION    -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_arvalid    [ipx::get_port_maps ARVALID     -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_s_arready    [ipx::get_port_maps ARREADY     -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]

set_property physical_name o_s_rid        [ipx::get_port_maps RID         -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_s_rdata      [ipx::get_port_maps RDATA       -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_s_rresp      [ipx::get_port_maps RRESP       -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_s_rlast      [ipx::get_port_maps RLAST       -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_s_rvalid     [ipx::get_port_maps RVALID      -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_rready     [ipx::get_port_maps RREADY      -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]

set_property physical_name i_s_awid       [ipx::get_port_maps AWID        -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_awaddr     [ipx::get_port_maps AWADDR      -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_awlen      [ipx::get_port_maps AWLEN       -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_awsize     [ipx::get_port_maps AWSIZE      -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_awburst    [ipx::get_port_maps AWBURST     -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_awlock     [ipx::get_port_maps AWLOCK      -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_awcache    [ipx::get_port_maps AWCACHE     -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_awprot     [ipx::get_port_maps AWPROT      -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_awregion   [ipx::get_port_maps AWREGION    -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_awvalid    [ipx::get_port_maps AWVALID     -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_s_awready    [ipx::get_port_maps AWREADY     -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]

set_property physical_name i_s_wid        [ipx::get_port_maps WID         -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_wdata      [ipx::get_port_maps WDATA       -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_wstrb      [ipx::get_port_maps WSTRB       -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_wlast      [ipx::get_port_maps WLAST       -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_wvalid     [ipx::get_port_maps WVALID      -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_s_wready     [ipx::get_port_maps WREADY      -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]

set_property physical_name o_s_bid        [ipx::get_port_maps BID         -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_s_bresp      [ipx::get_port_maps BRESP       -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_s_bvalid     [ipx::get_port_maps BVALID      -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_s_bready     [ipx::get_port_maps BREADY      -of_objects [ipx::get_bus_interfaces S_AXI    -of_objects [ipx::current_core]]]

ipx::add_memory_map                     S_AXI                                                                [ipx::current_core]
set_property slave_memory_map_ref       S_AXI        [ipx::get_bus_interfaces    S_AXI    -of_objects [ipx::current_core]]
set_property display_name               S_AXI        [ipx::get_memory_maps       S_AXI    -of_objects [ipx::current_core]]
ipx::add_address_block                  BAR0        [ipx::get_memory_maps       S_AXI    -of_objects [ipx::current_core]]
set_property range 4G [ipx::get_address_blocks BAR0 -of_objects [ipx::get_memory_maps S_AXI -of_objects [ipx::current_core]]]

ipx::add_bus_parameter NUM_READ_OUTSTANDING [ipx::get_bus_interfaces S_AXI -of_objects [ipx::current_core]]
set_property description {Num Read Outstanding} [ipx::get_bus_parameters NUM_READ_OUTSTANDING -of_objects [ipx::get_bus_interfaces S_AXI -of_objects [ipx::current_core]]]
set_property value 1 [ipx::get_bus_parameters NUM_READ_OUTSTANDING -of_objects [ipx::get_bus_interfaces S_AXI -of_objects [ipx::current_core]]]

#-------------------------------------------
# Create Interfaces: AXI: M_AXI
#-------------------------------------------

ipx::add_bus_interface                  M_AXI                             [ipx::current_core]
ipx::associate_bus_interfaces -busif    M_AXI     -clock axi_aclk         [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:aximm_rtl:1.0   [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:aximm:1.0               [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
set_property interface_mode master                                      [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]

ipx::add_port_map ARID      [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARADDR    [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARLEN     [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARSIZE    [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARBURST   [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARLOCK    [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARCACHE   [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARPROT    [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARREGION  [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARVALID   [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map ARREADY   [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]

ipx::add_port_map RID       [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map RDATA     [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map RRESP     [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map RLAST     [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map RVALID    [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map RREADY    [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]

ipx::add_port_map AWID      [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWADDR    [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWLEN     [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWSIZE    [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWBURST   [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWLOCK    [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWCACHE   [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWPROT    [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWREGION  [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWVALID   [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map AWREADY   [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]

ipx::add_port_map WID       [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map WDATA     [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map WLAST     [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map WSTRB     [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map WVALID    [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map WREADY    [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]

ipx::add_port_map BID       [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map BRESP     [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map BVALID    [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
ipx::add_port_map BREADY    [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]

set_property physical_name o_m_arid       [ipx::get_port_maps ARID        -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_araddr     [ipx::get_port_maps ARADDR      -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_arlen      [ipx::get_port_maps ARLEN       -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_arsize     [ipx::get_port_maps ARSIZE      -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_arburst    [ipx::get_port_maps ARBURST     -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_arlock     [ipx::get_port_maps ARLOCK      -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_arcache    [ipx::get_port_maps ARCACHE     -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_arprot     [ipx::get_port_maps ARPROT      -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_arregion   [ipx::get_port_maps ARREGION    -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_arvalid    [ipx::get_port_maps ARVALID     -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_m_arready    [ipx::get_port_maps ARREADY     -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]

set_property physical_name i_m_rid        [ipx::get_port_maps RID         -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_m_rdata      [ipx::get_port_maps RDATA       -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_m_rresp      [ipx::get_port_maps RRESP       -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_m_rlast      [ipx::get_port_maps RLAST       -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_m_rvalid     [ipx::get_port_maps RVALID      -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_rready     [ipx::get_port_maps RREADY      -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]

set_property physical_name o_m_awid       [ipx::get_port_maps AWID        -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_awaddr     [ipx::get_port_maps AWADDR      -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_awlen      [ipx::get_port_maps AWLEN       -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_awsize     [ipx::get_port_maps AWSIZE      -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_awburst    [ipx::get_port_maps AWBURST     -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_awlock     [ipx::get_port_maps AWLOCK      -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_awcache    [ipx::get_port_maps AWCACHE     -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_awprot     [ipx::get_port_maps AWPROT      -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_awregion   [ipx::get_port_maps AWREGION    -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_awvalid    [ipx::get_port_maps AWVALID     -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_m_awready    [ipx::get_port_maps AWREADY     -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]

set_property physical_name o_m_wid        [ipx::get_port_maps WID         -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_wdata      [ipx::get_port_maps WDATA       -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_wstrb      [ipx::get_port_maps WSTRB       -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_wlast      [ipx::get_port_maps WLAST       -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_wvalid     [ipx::get_port_maps WVALID      -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_m_wready     [ipx::get_port_maps WREADY      -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]

set_property physical_name i_m_bid        [ipx::get_port_maps BID         -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_m_bresp      [ipx::get_port_maps BRESP       -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name i_m_bvalid     [ipx::get_port_maps BVALID      -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]
set_property physical_name o_m_bready     [ipx::get_port_maps BREADY      -of_objects [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]]

ipx::add_address_space                  M_AXI                                                     [ipx::current_core]
set_property master_address_space_ref   M_AXI     [ipx::get_bus_interfaces M_AXI    -of_objects [ipx::current_core]]
set_property width ${adrw}                          [ipx::get_address_spaces M_AXI    -of_objects [ipx::current_core]]
set_property range 4G                        [ipx::get_address_spaces M_AXI    -of_objects [ipx::current_core]]
set_property range_dependency pow(2,(spirit:decode(id('MODELPARAM_VALUE.ADRW'))-1)+1 [ipx::get_address_spaces M_AXI  -of_objects [ipx::current_core]]

ipx::add_bus_parameter NUM_READ_OUTSTANDING [ipx::get_bus_interfaces M_AXI -of_objects [ipx::current_core]]
set_property description {Num Read Outstanding} [ipx::get_bus_parameters NUM_READ_OUTSTANDING -of_objects [ipx::get_bus_interfaces M_AXI -of_objects [ipx::current_core]]]
set_property value 32 [ipx::get_bus_parameters NUM_READ_OUTSTANDING -of_objects [ipx::get_bus_interfaces M_AXI -of_objects [ipx::current_core]]]

#-------------------------------------------
# Create Interfaces: AXI: S_AXI_CTL
#-------------------------------------------

ipx::add_bus_interface S_AXI_CTL [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:aximm_rtl:1.0 [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:aximm:1.0 [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]
ipx::add_port_map BVALID [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]
set_property physical_name o_s_ctl_bvalid [ipx::get_port_maps BVALID -of_objects [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]]
ipx::add_port_map RREADY [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]
set_property physical_name i_s_ctl_rready [ipx::get_port_maps RREADY -of_objects [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]]
ipx::add_port_map BREADY [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]
set_property physical_name i_s_ctl_bready [ipx::get_port_maps BREADY -of_objects [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]]
ipx::add_port_map AWVALID [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]
set_property physical_name i_s_ctl_awvalid [ipx::get_port_maps AWVALID -of_objects [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]]
ipx::add_port_map AWREADY [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]
set_property physical_name o_s_ctl_awready [ipx::get_port_maps AWREADY -of_objects [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]]
ipx::add_port_map WDATA [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]
set_property physical_name i_s_ctl_wdata [ipx::get_port_maps WDATA -of_objects [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]]
ipx::add_port_map RRESP [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]
set_property physical_name o_s_ctl_rresp [ipx::get_port_maps RRESP -of_objects [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]]
ipx::add_port_map RVALID [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]
set_property physical_name o_s_ctl_rvalid [ipx::get_port_maps RVALID -of_objects [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]]
ipx::add_port_map ARADDR [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]
set_property physical_name i_s_ctl_araddr [ipx::get_port_maps ARADDR -of_objects [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]]
ipx::add_port_map AWADDR [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]
set_property physical_name i_s_ctl_awaddr [ipx::get_port_maps AWADDR -of_objects [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]]
ipx::add_port_map ARREADY [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]
set_property physical_name o_s_ctl_arready [ipx::get_port_maps ARREADY -of_objects [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]]
ipx::add_port_map WVALID [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]
set_property physical_name i_s_ctl_wvalid [ipx::get_port_maps WVALID -of_objects [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]]
ipx::add_port_map WREADY [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]
set_property physical_name o_s_ctl_wready [ipx::get_port_maps WREADY -of_objects [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]]
ipx::add_port_map ARVALID [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]
set_property physical_name i_s_ctl_arvalid [ipx::get_port_maps ARVALID -of_objects [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]]
ipx::add_port_map WSTRB [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]
set_property physical_name i_s_ctl_wstrb [ipx::get_port_maps WSTRB -of_objects [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]]
ipx::add_port_map BRESP [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]
set_property physical_name o_s_ctl_bresp [ipx::get_port_maps BRESP -of_objects [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]]
ipx::add_port_map RDATA [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]
set_property physical_name o_s_ctl_rdata [ipx::get_port_maps RDATA -of_objects [ipx::get_bus_interfaces S_AXI_CTL -of_objects [ipx::current_core]]]
ipx::associate_bus_interfaces -busif S_AXI_CTL -clock axi_ctl_aclk [ipx::current_core]

ipx::add_memory_map                     S_AXI_CTL                                                                 [ipx::current_core]
set_property slave_memory_map_ref       S_AXI_CTL               [ipx::get_bus_interfaces    S_AXI_CTL -of_objects [ipx::current_core]]
set_property display_name               S_AXI_CTL               [ipx::get_memory_maps       S_AXI_CTL -of_objects [ipx::current_core]]
ipx::add_address_block                  CTL0                   [ipx::get_memory_maps       S_AXI_CTL -of_objects [ipx::current_core]]
set_property range 4096 [ipx::get_address_blocks CTL0 -of_objects [ipx::get_memory_maps       S_AXI_CTL -of_objects [ipx::current_core]]]

#==========================================================
# Create Interfaces: Others
#==========================================================


#-------------------------------------------
# Create Interfaces: cfg_interrupt_msix
#-------------------------------------------

ipx::add_bus_interface cfg_interrupt_msix [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:pcie3_cfg_msix_rtl:1.0 [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:pcie3_cfg_msix:1.0 [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]
set_property interface_mode master [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]
set_property interface_mode slave [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]
ipx::add_port_map vf_mask [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]
set_property physical_name cfg_interrupt_msix_vf_mask [ipx::get_port_maps vf_mask -of_objects [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]]
ipx::add_port_map fail [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]
set_property physical_name cfg_interrupt_msix_fail [ipx::get_port_maps fail -of_objects [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]]
ipx::add_port_map address [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]
set_property physical_name cfg_interrupt_msix_address [ipx::get_port_maps address -of_objects [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]]
ipx::add_port_map data [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]
set_property physical_name cfg_interrupt_msix_data [ipx::get_port_maps data -of_objects [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]]
ipx::add_port_map enable [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]
set_property physical_name cfg_interrupt_msix_enable [ipx::get_port_maps enable -of_objects [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]]
ipx::add_port_map vf_enable [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]
set_property physical_name cfg_interrupt_msix_vf_enable [ipx::get_port_maps vf_enable -of_objects [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]]
ipx::add_port_map int_vector [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]
set_property physical_name cfg_interrupt_msix_int [ipx::get_port_maps int_vector -of_objects [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]]
ipx::add_port_map sent [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]
set_property physical_name cfg_interrupt_msix_sent [ipx::get_port_maps sent -of_objects [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]]
ipx::add_port_map mask [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]
set_property physical_name cfg_interrupt_msix_mask [ipx::get_port_maps mask -of_objects [ipx::get_bus_interfaces cfg_interrupt_msix -of_objects [ipx::current_core]]]

#-------------------------------------------
# Create Interfaces: pcie_7x_mgt
#-------------------------------------------

ipx::add_bus_interface pcie_7x_mgt [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 [ipx::get_bus_interfaces pcie_7x_mgt -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:pcie_7x_mgt:1.0 [ipx::get_bus_interfaces pcie_7x_mgt -of_objects [ipx::current_core]]
set_property interface_mode master [ipx::get_bus_interfaces pcie_7x_mgt -of_objects [ipx::current_core]]
ipx::add_port_map rxn [ipx::get_bus_interfaces pcie_7x_mgt -of_objects [ipx::current_core]]
set_property physical_name pci_exp_rxn [ipx::get_port_maps rxn -of_objects [ipx::get_bus_interfaces pcie_7x_mgt -of_objects [ipx::current_core]]]
ipx::add_port_map txn [ipx::get_bus_interfaces pcie_7x_mgt -of_objects [ipx::current_core]]
set_property physical_name pci_exp_txn [ipx::get_port_maps txn -of_objects [ipx::get_bus_interfaces pcie_7x_mgt -of_objects [ipx::current_core]]]
ipx::add_port_map rxp [ipx::get_bus_interfaces pcie_7x_mgt -of_objects [ipx::current_core]]
set_property physical_name pci_exp_rxp [ipx::get_port_maps rxp -of_objects [ipx::get_bus_interfaces pcie_7x_mgt -of_objects [ipx::current_core]]]
ipx::add_port_map txp [ipx::get_bus_interfaces pcie_7x_mgt -of_objects [ipx::current_core]]
set_property physical_name pci_exp_txp [ipx::get_port_maps txp -of_objects [ipx::get_bus_interfaces pcie_7x_mgt -of_objects [ipx::current_core]]]


# #-------------------------------------------
# # Create Interfaces: AXI: axim_cmp
# #-------------------------------------------
# 
# ipx::add_bus_interface                  axim_cmp                            [ipx::current_core]
# ipx::associate_bus_interfaces -busif    axim_cmp    -clock clk              [ipx::current_core]
# set_property abstraction_type_vlnv xilinx.com:interface:aximm_rtl:1.0   [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]
# set_property bus_type_vlnv xilinx.com:interface:aximm:1.0               [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]
# set_property interface_mode master                                      [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]
# 
# #    ARADDR ARBURST ARLEN ARSIZE ARID ARPROT ARLOCK ARQOS ARCACHE ARREGION ARUSER ARVALID ARREADY
# #    RDATA RLAST RRESP RID RUSER RVALID RREADY
# #    AWADDR AWBURST AWLEN AWSIZE AWID AWPROT AWLOCK AWQOS AWCACHE AWREGION AWUSER AWVALID AWREADY
# #    WDATA WLAST WSTRB WID WUSER WVALID WREADY
# #    BRESP BID BUSER BVALID BREADY
# foreach signal {
#     ARADDR ARBURST ARLEN ARSIZE ARID ARPROT ARLOCK ARQOS ARCACHE ARREGION ARVALID ARREADY
#     RDATA RLAST RRESP RID RVALID RREADY
#     AWADDR AWBURST AWLEN AWSIZE AWID AWPROT AWLOCK AWQOS AWCACHE AWREGION AWVALID AWREADY
#     WDATA WLAST WSTRB WID WVALID WREADY
#     BRESP BID BVALID BREADY
# } {
#     ipx::add_port_map $signal    [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]
# }
# 
# set_property physical_name o_axim_cmp_araddr    [ipx::get_port_maps ARADDR      -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_arburst   [ipx::get_port_maps ARBURST     -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_arlen     [ipx::get_port_maps ARLEN       -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_arsize    [ipx::get_port_maps ARSIZE      -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_arid      [ipx::get_port_maps ARID        -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_arprot    [ipx::get_port_maps ARPROT      -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_arlock    [ipx::get_port_maps ARLOCK      -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_arqos     [ipx::get_port_maps ARREGION    -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_arcache   [ipx::get_port_maps ARCACHE     -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_arregion  [ipx::get_port_maps ARQOS       -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# #set_property physical_name o_axim_cmp_aruser    [ipx::get_port_maps ARUSER      -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_arvalid   [ipx::get_port_maps ARVALID     -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name i_axim_cmp_arready   [ipx::get_port_maps ARREADY     -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# 
# set_property physical_name i_axim_cmp_rdata     [ipx::get_port_maps RDATA       -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name i_axim_cmp_rlast     [ipx::get_port_maps RLAST       -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name i_axim_cmp_rresp     [ipx::get_port_maps RRESP       -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name i_axim_cmp_rid       [ipx::get_port_maps RID         -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# #set_property physical_name i_axim_cmp_ruser     [ipx::get_port_maps RUSER       -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name i_axim_cmp_rvalid    [ipx::get_port_maps RVALID      -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_rready    [ipx::get_port_maps RREADY      -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# 
# set_property physical_name o_axim_cmp_awlen     [ipx::get_port_maps AWLEN       -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_awqos     [ipx::get_port_maps AWQOS       -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_awprot    [ipx::get_port_maps AWPROT      -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_awsize    [ipx::get_port_maps AWSIZE      -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_awid      [ipx::get_port_maps AWID        -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_awregion  [ipx::get_port_maps AWREGION    -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_awaddr    [ipx::get_port_maps AWADDR      -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_awcache   [ipx::get_port_maps AWCACHE     -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_awlock    [ipx::get_port_maps AWLOCK      -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# #set_property physical_name o_axim_cmp_awuser    [ipx::get_port_maps AWUSER      -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_awburst   [ipx::get_port_maps AWBURST     -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_awvalid   [ipx::get_port_maps AWVALID     -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name i_axim_cmp_awready   [ipx::get_port_maps AWREADY     -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# 
# set_property physical_name o_axim_cmp_wdata     [ipx::get_port_maps WDATA       -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_wlast     [ipx::get_port_maps WLAST       -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_wstrb     [ipx::get_port_maps WSTRB       -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_wid       [ipx::get_port_maps WID         -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# #set_property physical_name o_axim_cmp_wuser     [ipx::get_port_maps WUSER       -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_wvalid    [ipx::get_port_maps WVALID      -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name i_axim_cmp_wready    [ipx::get_port_maps WREADY      -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# 
# set_property physical_name i_axim_cmp_bresp     [ipx::get_port_maps BRESP       -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name i_axim_cmp_bid       [ipx::get_port_maps BID         -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# #set_property physical_name i_axim_cmp_buser     [ipx::get_port_maps BUSER       -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name i_axim_cmp_bvalid    [ipx::get_port_maps BVALID      -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# set_property physical_name o_axim_cmp_bready    [ipx::get_port_maps BREADY      -of_objects [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]]
# 
# ipx::add_address_space                  axim_cmp                                                    [ipx::current_core]
# set_property master_address_space_ref   axim_cmp    [ipx::get_bus_interfaces axim_cmp   -of_objects [ipx::current_core]]
# set_property width ${adrw}                          [ipx::get_address_spaces axim_cmp   -of_objects [ipx::current_core]]
# set_property range 16777216T                        [ipx::get_address_spaces axim_cmp   -of_objects [ipx::current_core]]
# set_property range_dependency pow(2,(spirit:decode(id('MODELPARAM_VALUE.C_M_AXI_CMP_ADDR_WIDTH'))-1)+1 [ipx::get_address_spaces axim_cmp -of_objects [ipx::current_core]]

##########################################################################
# Save IP
##########################################################################

ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
update_ip_catalog
close_project


