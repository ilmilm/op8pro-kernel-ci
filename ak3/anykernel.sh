### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers
##
## OnePlus 8 Pro (IN2020, kona) - op8pro-kernel-ci
## Flashes the uncompressed arm64 Image to the A/B boot partition
## (bootimage header v2, kernel-only write, ramdisk untouched).

### AnyKernel setup
# global properties
properties() { '
kernel.string=op8pro-kernel 4.19.157-perf+
do.devicecheck=0
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=OnePlus8Pro
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties

### AnyKernel install
## boot shell variables
BLOCK=/dev/block/bootdevice/by-name/boot;
IS_SLOT_DEVICE=1;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# boot install
split_boot; # split boot image, skip ramdisk (A/B, header v2)
flash_boot; # write raw Image kernel to boot partition
## end boot install
