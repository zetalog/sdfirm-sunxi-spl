#!/bin/bash
set -eu

SCRIPT=`(cd \`dirname $0\`; pwd)`

. ${SCRIPT}/config

case $1 in
/dev/sd[a-z] | /dev/loop[0-9]* | /dev/mmcblk1)
	if [ ! -e $1 ]; then
		echo "Error: $1 does not exist."
		exit 1
	fi
	DEV_NAME=`basename $1`
	BLOCK_CNT=`cat /sys/block/${DEV_NAME}/size` ;;&
/dev/sd[a-z])
	DEV_PART=${DEV_NAME}3
	REMOVABLE=`cat /sys/block/${DEV_NAME}/removable` ;;

/dev/mmcblk1 | /dev/loop[0-9]*)
	DEV_PART=${DEV_NAME}p3
	REMOVABLE=1 ;;
*)
	echo "Error: Unsupported SD reader"
	exit 0
esac

if [ ${REMOVABLE} -le 0 ]; then
	echo "Error: $1 is a non-removable device. Stop."
	exit 1
fi
if [ -z ${BLOCK_CNT} -o ${BLOCK_CNT} -le 0 ]; then
	echo "Error: $1 is inaccessible. Stop fusing now!"
	exit 1
fi
let DEV_SIZE=${BLOCK_CNT}/2
if [ ${DEV_SIZE} -gt 64000000 ]; then
	echo "Error: $1 size (${DEV_SIZE} KB) is too large"
	exit 1
fi
if [ ${DEV_SIZE} -le 7000000 ]; then
	echo "Error: $1 size (${DEV_SIZE} KB) is too small"
	echo "       At least 8GB SDHC card is required, please try another card."
	exit 1
fi

prepare_rom

# Automatically re-run script under sudo if not root
if [ $(id -u) -ne 0 ]; then
	echo "Re-running script under sudo..."
	sudo "$0" "$@"
	exit
fi

# umount all at first
set +e
umount /dev/${DEV_NAME}* > /dev/null 2>&1
set -e

# partition card & fusing filesystem
SD_UPDATE=${SCRIPT}/sd_update

echo "${TARGET_OS^} filesystem fusing"
echo "Image root: `dirname ${PARTMAP}`"
echo

# write ext4 image
${SD_UPDATE} -d /dev/${DEV_NAME} -p ${PARTMAP}
if [ $? -ne 0 ]; then
	echo "Error: filesystem fusing failed, Stop."
	exit 1
fi
echo "${TARGET_OS^} is fused successfully."
echo "All done."
