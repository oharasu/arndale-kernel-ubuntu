#!/bin/bash

TOP=${PWD}
BUILD_DATE=$(date +"%Y%m%d.%H%M%S")
SRC_GIT_LOG=$(git log -1 --pretty=format:"%cd %an : %s" --date=short)
export BUILD_NUMBER=$(date +%Y%m%d)

#################################################################################
#             Environment Setting                                               #
#################################################################################
#set -x #debug echo on
TOOLCHAIN_ROOT=$HOME/gcc-linaro-4.9-2015.05-x86_64_arm-linux-gnueabihf
TOOLCHAIN_PREFIX=$TOOLCHAIN_ROOT/bin/arm-linux-gnueabihf-
thread_num=8

# echo color message
echoc()
{
    case $1 in
        red)    color=31;;
        green)  color=32;;
        yellow) color=33;;
        blue)   color=34;;
        purple) color=35;;
        *)      color=36;;
    esac
    echo -e "\033[;${color}m$2\033[0m"
}

export CROSS_COMPILE=$TOOLCHAIN_PREFIX
export ARCH=arm

[ -d out ] || mkdir out
make O=out distclean
echo '-KumaO' > .scmversion
make O=out exynos5250-arndale_defconfig
make O=out -j${thread_num} uImage || exit
make O=out exynos5250-arndale.dtb
make O=out -j${thread_num} modules
#make O=out -j${thread_num} INSTALL_MOD_PATH=MOD_INSTALL modules_install
#make O=out -j${thread_num} INSTALL_MOD_PATH=MOD_INSTALL firmware_install
make O=out -j${thread_num} KBUILD_DEBARCH=armhf KBUILD_IMAGE=uImage deb-pkg
rm .scmversion
if [[ $? == "0" ]]; then
    echoc green "Build kernel, all success."
    echoc blue  out/arch/arm/boot/uImage
    echoc blue  out/arch/arm/boot/dts/exynos5250-arndale.dtb
    echoc blue  linux-headers-3.10.37+_3.10.37+-2_armhf.deb
    echoc blue  linux-image-3.10.37+_3.10.37+-2_armhf.deb
    echoc blue  linux-libc-dev_3.10.37+-2_armhf.deb
fi
