close_project -quiet
source create_proj.tcl

source ./top.bd.tcl

make_wrapper -files [get_files ./proj_cosim/proj_cosim.srcs/sources_1/bd/top/top.bd] -top
add_files -norecurse           ./proj_cosim/proj_cosim.srcs/sources_1/bd/top/hdl/top_wrapper.v


set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse {\
 ./test_top.v}
set_property top test_top [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]


update_compile_order -fileset sources_1
generate_target Simulation [get_files ./proj_cosim/proj_cosim.srcs/sources_1/bd/top/top.bd]
export_ip_user_files -no_script -force
export_simulation  -force -directory "./" -simulator xsim  -ip_user_files_dir "./proj_cosim/proj_cosim.ip_user_files" -ipstatic_source_dir "./proj_cosim/proj_cosim.ip_user_files/ipstatic" -use_ip_compiled_libs


#generate_target Simulation [get_files /home/bibo/work/pcie/kcu105/cosim_release_fpga2018/proj_sim_sorting/proj_cosim/proj_cosim.srcs/sources_1/bd/top/top.bd]
#export_ip_user_files -of_objects [get_files /home/bibo/work/pcie/kcu105/cosim_release_fpga2018/proj_sim_sorting/proj_cosim/proj_cosim.srcs/sources_1/bd/top/top.bd] -no_script -sync -force -quiet

#generate_target Simulation [get_files ./proj_*/proj_*.srcs/sources_1/bd/shell_region/shell_region.bd]
