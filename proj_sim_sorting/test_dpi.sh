export COSIM_PORT=2019

cd xsim
rm xsim* webtalk* -rf

xsc ../../ip_sim_bridge/QEMUPCIeBridge/hdl/dpi-pcie.c --additional_option "-lczmq -lzmq" -v

sed -i 's/xelab --relax/xelab -sv_lib dpi --relax/g' test_top.sh
sed -i 's/xsim test_top/xsim -gui -view ..\/test_top.wcfg test_top/g' test_top.sh
source test_top.sh

cd ..

