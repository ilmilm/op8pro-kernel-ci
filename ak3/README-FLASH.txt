OnePlus 8 Pro (IN2020) kernel - op8pro-kernel-ci build
=======================================================

Contents of this zip:
  anykernel.sh  - AnyKernel3 installer config (boot partition, A/B slot aware)
  Image         - uncompressed arm64 kernel (bootimage v2 style)
  dtb.img       - concatenated dtbs: arch/arm64/boot/dts/vendor/*/*.dtb
  README.txt    - this file

What flashing does
------------------
AnyKernel3 writes Image raw into the active slot's boot partition
(boot_a / boot_b). Ramdisk and dtbo are NOT touched. This matches the
stock OnePlus 8 Pro layout: header v2, uncompressed kernel.

dtb.img usage
-------------
On kona (SM8250) the bootloader takes the dtb from the vendor_boot
partition, not from boot. This zip only flashes the kernel, so the
stock vendor_boot dtb keeps being used - fine, because this kernel is
built from the same OnePlus device tree sources (identical DT content).

If you later change device tree sources and need the new dtb to be
used, repack it into vendor_boot manually:
  - unpack your vendor_boot.img (mkbootimg/unpack_bootimg)
  - replace the dtb blob with this dtb.img
  - repack and fastboot flash vendor_boot

Module compatibility (vermagic)
-------------------------------
This kernel is built to reproduce the stock release string
"4.19.157-perf+" (CONFIG_LOCALVERSION="-perf", no LOCALVERSION_AUTO,
untagged git tree -> "+" suffix). The exact vermagic is printed in the
CI build log (modinfo on a built module). Stock vendor modules from
the OPLUS partition load as long as vermagic matches.
techpack camera/display/video modules were NOT rebuilt in CI (kept
from stock vendor partition).
