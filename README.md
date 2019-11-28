

                            sdfirm sunxi-spl

This repository contains scripts and patches for converting u-boot
(sun50i h5 nanopi) into sdfirm.

After running the uboot.sh, downloading the necessary u-boot source code,
we can apply sdfirm_spl.patch to the u-boot source code and copy the
necessary files from sdfirm source tree to u-boot/sdfirm folder, add the
necessary Makefiles, so that it compiles nanopi_h5_defconfig into a sdfirm
interface binary - spl/sunxi-spl.bin

Then by running fusing.sh, you can find extracted folder of
friendlycore-xenial_4.14_arm64 here. After updating its partmap.txt with
the one located in this folder to save SD card fusing time, and you'll get
the environment to develop sdfirm drivers on top of u-boot source tree.
