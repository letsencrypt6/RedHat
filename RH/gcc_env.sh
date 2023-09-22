#!/bin/bash

# kernel-headers kernel-devel gcc

function install_kernel {
    KERNEL_VER=$(uname -r | sed "s/.$(uname -m)//")
    for i in kernel-headers kernel-devel; do
        if ! rpm -q $i-$KERNEL_VER &>/dev/null; then
            yum -y install $i-$KERNEL_VER
        fi
    done
}

function install_gcc {
    GCC_VER=$(rpm -q libgcc | sed "s/libgcc//")
    if ! rpm -q gcc${GCC_VER} &>/dev/null; then
        yum -y install gcc${GCC_VER}
    fi
}

# Main Area
install_kernel
install_gcc