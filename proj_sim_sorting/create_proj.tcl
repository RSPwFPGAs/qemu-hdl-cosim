create_project proj_cosim ./proj_cosim -part xcku040-ffva1156-2-e -f
set_property board_part xilinx.com:kcu105:part0:1.5 [current_project]

#set_property ip_repo_paths ../ip_misc/sorting_network/ippkg [current_fileset]
#update_ip_catalog
#set_property ip_repo_paths ../ip_sim_bridge/QEMUPCIeBridge/ [current_fileset]
#update_ip_catalog

set_property  ip_repo_paths  {../ip_sim_bridge/QEMUPCIeBridge ../ip_misc/sorting_network/ippkg} [current_project]
update_ip_catalog

update_compile_order -fileset sources_1

