#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <operation>"
    exit 1
fi

# Set variable toolchain flags for building
export CROSS_COMPILE=$(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-buildroot-linux-gnu-
export CC=$(pwd)/toolchain/clang/host/linux-x86/clang-r383902/bin/clang
export CLANG_TRIPLE=aarch64-buildroot-linux-gnu-

# Set variable arch flags for building
export ARCH=arm64
export SUBARCH="arm64"

# Set variable flags for building
export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

# Set variable android version
export PLATFORM_VERSION=13
export ANDROID_MAJOR_VERSION=t

# Set variable user info for building kernel 
export KBUILD_BUILD_USER=ArcticAquila
export KBUILD_BUILD_HOST=$(hostname)

# Logic for LOCAL_VERSION config
GIT_BRANCH_TEMP=$(git branch --show-current)
if [ "$GIT_BRANCH_TEMP" == "main" ]; then
    GIT_BRANCH=stable
else
    GIT_BRANCH=$(echo $GIT_BRANCH_TEMP)
fi

GIT_TAGS=$(git describe --tags)

export BASH_KBUILD_COMMAND="make -C $(pwd) O=$(pwd)/out CONFIG_LOCALVERSION=\"-`echo $GIT_TAGS`-`echo $GIT_BRANCH`\""

# Function
case $1 in
    "anykernel3")
        git clone --depth=1 https://github.com/ArcticAquila/AnyKernel3
        cp -rv out/arch/arm64/boot/Image.gz AnyKernel3
        cd AnyKernel3
        zip -r9 ../../UPDATE-AnyKernel3.zip * -x .git README.md *placeholder
        cd ..
        ;;
    "build")
        $BASH_KBUILD_COMMAND -j$(nproc --all)
        ;;
    "clang")
        wget -nc https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/fb69815b96ce8dd4821078dd36ac92dde80a23e1/clang-r383902.tar.gz
        mkdir -pv toolchain/clang/host/linux-x86/clang-r383902/
        tar xfv clang-r383902.tar.gz -C toolchain/clang/host/linux-x86/clang-r383902/
        ;;
    "gcc")
        git clone --depth=1 https://github.com/ArcticAquila/toolchains toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/
        ;;
    "menuconfig")
        $BASH_KBUILD_COMMAND menuconfig
	    ;;
    "kernelsu")
        curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -
        git apply ../ksu.patch
        ;;
    "prepare")
        $BASH_KBUILD_COMMAND aqua_defconfig
    ;;
    
    *)
    echo "Invalid operation!"
    exit 1
esac
