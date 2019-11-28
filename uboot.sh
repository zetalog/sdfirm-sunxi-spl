#!/bin/bash
set -eu

SCRIPT=`(cd \`dirname $0\`; pwd)`

. ${SCRIPT}/config
true ${DISABLE_MKIMG:=0}

build_uboot

if [ x"$DISABLE_MKIMG" = x"1" ]; then
	exit 0
fi

prepare_rom

# Automatically re-run script under sudo if not root
#if [ $(id -u) -ne 0 ]; then
#	echo "Re-running script under sudo..."
#	sudo "$0" "$@"
#	exit
#fi

if [ "x${REBUILD}" != "x" ]; then
	cp -af ${UBOOT_DIR}/spl/sunxi-spl.bin ${TARGET_OS}
	cp -af ${UBOOT_DIR}/u-boot.itb ${TARGET_OS}
	if [ $? -ne 0 ]; then
		echo "failed to update sunxi-spl.bin and u-boot.itb."
		exit 1
	fi
	echo "updating sunxi-spl.bin and u-boot.itb to ${TARGET_OS} ok."
fi
