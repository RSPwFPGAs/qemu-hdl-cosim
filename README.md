This repository contains work by `COMPAS Lab`. The original project introduction is [here](http://compas.cs.stonybrook.edu/projects/fpgacloud/vm-hdl-cosim/). Please site the [paper](http://compas.cs.stonybrook.edu/~shcho/publication/FPGA_2018_CoSim.pdf) and read the [presentation](http://www.isfpga.org/fpga2018/slides/2-3.pptx).

The [demo code](https://compas.cs.stonybrook.edu/wordpress/wp-content/uploads/2018/02/cosim_release_fpga2018.tar.gz) is ported here to use XSim instead of VCS, with minor improvements to the README.

# README

This example source release is the cosim demo for the sorting platform.
This release has been tested with the following tools and libs:
>
>```
>Linux 18.04.3
>Vivado 2018.3
>QEMU 2.10 rc3
>```


Environment variables to set
----------------------------
>
>```
>COSIM_REPO_HOME -> Root of the source release
>COSIM_PORT -> Any 4-digit number. If you want to run multiple instances on 
>              the same machine, each one needs to have a different number.
>```


Compile QEMU
----------------------------
1. Install Dependencies:
>
>```bash
>    sudo apt-get install libzmq3-dev libczmq-dev libncurses5-dev libncursesw5-dev libsdl2-dev

2. Download QEMU 2.10 rc3

>
>```bash
>    cd $COSIM_REPO_HOME/qemu
>    wget http://download.qemu-project.org/qemu-2.10.0-rc3.tar.xz
>    tar -xJf qemu-2.10.0-rc3.tar.xz

3. Apply the patch

>
>```bash
>    patch -s -p0 < qemu-cosim.patch
>
>    Apply another patch
>    https://git.qemu.org/?p=qemu.git;a=commitdiff;h=75e5b70e6b5dcc4f2219992d7cffa462aa406af0

4. Configure and build

>
>```bash
>    cd qemu-2.10.0-rc3
>    mkdir build
>    cd build
>    ../configure --target-list=x86_64-softmmu --disable-vnc --enable-sdl --enable-curses
>
>    Modify config-host.mak, Add " -lzmq -lczmq" to the end of LIBS
>
>    make -j32

5. Copy the launch script

>
>```bash
>    cp ../../../scripts/launch_fpga.sh ./
>    cd ../../



Create a QEMU image
----------------------------
1. Create a QEMU image file called cosim.qcow2 in $COSIM_REPO_HOME/qemu and install Ubuntu 16.04.3.

>
>```bash
>    qemu-2.10.0-rc3/build/qemu-img create -f qcow2 cosim.qcow2 16G
>    sudo qemu-2.10.0-rc3/build/x86_64-softmmu/qemu-system-x86_64 -boot d -cdrom /path/to/ubuntu-16.04.6-server-amd64.iso -smp cpus=2 -accel kvm -m 4096 -hda cosim.qcow2
>    (name: user; passwd: user)

2. Launch QEMU 

>
>```bash
>    cd $COSIM_REPO_HOME/qemu/qemu-2.10.0-rc3/build
>    ./launch_fpga.sh
>    (sudo -E x86_64-softmmu/qemu-system-x86_64 -m 4G -enable-kvm -cpu host -smp cores=1 -drive file=../../cosim.qcow2,cache=writethrough -device accelerator-pcie -redir tcp:2200::22 -display none)

3. Log in to the VM from ssh port 2200

>
>```bash
>    ssh -p 2200 user@localhost

3. In the VM, Install necessary tools for compiling userspace program and kernel module.

>
>```bash
>    sudo apt-get update
>    sudo apt-get upgrade
>    sudo apt-get install build-essential

4. In the host, Copy $COSIM_REPO_HOME/software_sorting to the image.

>
>```bash
>    cd $COSIM_REPO_HOME
>    scp -P 2200 -r software_sorting/ user@localhost:/home/user/.


Launch QEMU with accelerator
----------------------------
1. Launching QEMU with accelerator

>
>```bash
>    cd $COSIM_REPO_HOME/qemu/qemu-2.10.0-rc3/build
>    ./launch_fpga.sh

2. In the VM, compile and load driver

>
>```bash
>    cd software_sorting/driver/
>    ./loadRunModule.sh

3. In the VM, compile the user space program

>
>```bash
>    cd ../application
>    gcc sort.c -o sort

4. Wait here and use another terminal to launch Vivado XSim



Launch Vivado XSim
----------------------------
1. Launch Vivado XSim Simulation

>
>```bash
>    cd $COSIM_REPO_HOME/proj_sim_sorting
>    source run_sim.sh



Run the sorting program
----------------------------

1. In the VM, run the sort program

>
>```bash
>    sudo ./sort

2. The program will first print unsorted data, then print sorted result.




