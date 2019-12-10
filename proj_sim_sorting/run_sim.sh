source cleanup.sh

vivado -mode batch -source create_proj.tcl  -source sim_proj.tcl

source test_dpi.sh
