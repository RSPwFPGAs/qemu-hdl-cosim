<span style="display: inline-block;">

# Table of Contents
1. [Overview of qemu-hdl-cosim](#overview)
2. [Install Qemu and Create a VM image on Host](#installhost)
3. [Run Co-Simulation](#runcosim)
    - [Run Vivado Xsim in Host](#runxsim)
    - [Run application in Guest](#runapp)

<a name="overview"></a>
# Overview of qemu-hdl-cosim

This repository contains work by `COMPAS Lab`. The original project introduction is [here](http://compas.cs.stonybrook.edu/projects/fpgacloud/vm-hdl-cosim/). Please site the [paper](http://compas.cs.stonybrook.edu/~shcho/publication/FPGA_2018_CoSim.pdf) and watch the [presentation](http://www.isfpga.org/fpga2018/slides/2-3.pptx).

The [demo code](https://compas.cs.stonybrook.edu/wordpress/wp-content/uploads/2018/02/cosim_release_fpga2018.tar.gz) is ported here to use Vivado XSim instead of VCS, with minor improvements to the README.
This example source release is the cosim demo for an accelerated sorting application.

Install Tools
----------------------------
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

<a name="installhost"></a>
# Install Qemu and Create a VM image on Host

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

2. Launch QEMU in one terminal

>
>```bash
>    cd $COSIM_REPO_HOME/qemu/qemu-2.10.0-rc3/build
>    ./launch_fpga.sh
>    (sudo -E x86_64-softmmu/qemu-system-x86_64 -m 4G -enable-kvm -cpu host -smp cores=1 -drive file=../../cosim.qcow2,cache=writethrough -device accelerator-pcie -redir tcp:2200::22 -display none)

3. Log in to the VM in another terminal

>
>```bash
>    ssh -p 2200 user@localhost

4. In the VM, Install necessary tools for compiling userspace program and kernel module

>
>```bash
>    sudo apt-get update
>    sudo apt-get upgrade
>    sudo apt-get install build-essential

Copy driver and application to the image
----------------------------
1. Copy $COSIM_REPO_HOME/software_sorting to the image.

>
>```bash
>    cd $COSIM_REPO_HOME
>    scp -P 2200 -r software_sorting/ user@localhost:/home/user/.

Shutdown and backup the image
----------------------------
1. In the VM, shutdown the VM

>
>```bash
>    sudo poweroff

2. In the host, Backup the installed image
>
>```bash
>    cd $COSIM_REPO_HOME/qemu
>    zip cosim.qcow2.zip cosim.qcow2


<a name="runcosim"></a>
# Run co-simulation

<a name="runxsim"></a>
## Run Vivado Xsim in Host

1. In the host, Launch Vivado XSim Simulation in the 1st terminal

>
>```bash
>    cd $COSIM_REPO_HOME/proj_sim_sorting
>    source run_sim.sh

The waveform window will show AXI transactions when the application is launched in the VM.

<a name="runapp"></a>
## Run application in Guest

1. In the host, Launch QEMU with accelerator in the 2nd terminal

>
>```bash
>    cd $COSIM_REPO_HOME/qemu/qemu-2.10.0-rc3/build
>    ./launch_fpga.sh
>    (sudo -E x86_64-softmmu/qemu-system-x86_64 -m 4G -enable-kvm -cpu host -smp cores=1 -drive file=../../cosim.qcow2,cache=writethrough -device accelerator-pcie -redir tcp:2200::22 -display none)

2. In the host, Log in to the VM in the 3rd terminal

>
>```bash
>    ssh -p 2200 user@localhost

3. In the VM, compile and load driver

>
>```bash
>    cd software_sorting/driver/
>    ./loadRunModule.sh

4. In the VM, compile the user space program

>
>```bash
>    cd ../application
>    gcc sort.c -o sort

5. In the VM, run the sort program

>
>```bash
>    sudo ./sort

The program will first print unsorted data, then print sorted result.




