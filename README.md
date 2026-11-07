# op8pro-kernel-ci

GitHub Actions CI for the OnePlus 8 Pro (IN2020, SM8250/kona) Linux 4.19 kernel.

## What it builds

Source: [OnePlusOSS/android_kernel_oneplus_sm8250](https://github.com/OnePlusOSS/android_kernel_oneplus_sm8250)
branch `oneplus/sm8250_t_13.1_op8` (shallow clone), defconfig
`arch/arm64/configs/vendor/kona-perf_defconfig`.

- Toolchain: AOSP clang r399163b (mirror: AOSP-11/prebuilts_clang_host_linux-x86_clang-r399163b)
  + GNU aarch64 binutils (`CROSS_COMPILE=aarch64-linux-gnu-`).
  `CC=clang` is passed on the make command line, bypassing the python2-only
  `scripts/gcc-wrapper.py` (the tree's intended invocation
  `REAL_CC=<clang> CLANG_TRIPLE=aarch64-linux-gnu-` needs python2, which GH
  runners no longer provide).
- `TECHPACK=` skips the empty gitlink dirs `techpack/{camera,display,video}`
  (their sources live in separate repos; stock vendor modules stay in use).
- Known deviation: `CONFIG_QCOM_FSA4480_I2C` is disabled. The built-in
  fsa4480 USB-C audio-switch driver is the only non-techpack driver that
  references display-techpack symbols (`get_main_display` / `dsi_display.h`);
  that techpack repo is not publicly available, so the driver is disabled in
  CI. Everything else is stock kona-perf_defconfig.
- Devicetree + oplus vendor sources from
  [OnePlusOSS/android_kernel_modules_and_devicetree_oneplus_sm8250](https://github.com/OnePlusOSS/android_kernel_modules_and_devicetree_oneplus_sm8250)
  are copied into the kernel tree's `vendor/` directory: `vendor/qcom/proprietary/devicetree-4.19`
  (target of the git symlink `arch/arm64/boot/dts/vendor`) and
  `vendor/oplus/{kernel,kernel_4.19,secure,sensor}` (targets of ~80 git
  symlinks such as `kernel/sched_assist`, `drivers/power/oplus`, `fs/erofs`,
  `mm/multi_kswapd` ...). `BRAND_SHOW_FLAG=oneplus` selects the OnePlus
  sm8250 panel dirs for the dtb build. The workflow verifies every git
  symlink resolves before configuring.
- Targets: `Image.gz dtbs modules` -> Image (uncompressed), Image.gz,
  `dtb.img` (cat of `out/arch/arm64/boot/dts/vendor/*/*.dtb`, same recipe as
  AndroidKernel.mk line 211).

Expected release string / vermagic base: `4.19.157-perf+`
(`CONFIG_LOCALVERSION="-perf"`, `CONFIG_LOCALVERSION_AUTO` unset, untagged
shallow tree -> "+" suffix). The workflow verifies it via
`out/include/generated/utsrelease.h`, the vmlinux banner, and `modinfo
-F vermagic` on a built module, and prints all three to the log.

## Artifacts

Per run (artifact name `op8pro-kernel-<sha>`):

- `Image` - uncompressed arm64 kernel
- `Image.gz` - gzip variant (not used on this device, built for reference)
- `dtb.img` - concatenated vendor dtbs
- `OnePlus8Pro-kernel-4.19.157-perf-<sha>.zip` - AnyKernel3 flashable zip
  (flashes Image to the active slot's boot partition; dtb.img included for
  manual vendor_boot repacking - see README-FLASH.txt in the zip)
- `.config` - final kernel config
- `build.log` - full build log

sha256 of all artifacts is printed in the "sha256 of artifacts" step.

## Usage

Runs on every push to `main`, or manually: Actions -> build-op8pro-kernel ->
Run workflow.

```sh
gh workflow run build.yml --ref main
gh run watch   # or poll with: gh run view <id>
```

Flashable zip semantics: OnePlus 8 Pro is A/B with bootimage header v2 and an
uncompressed kernel; the AK3 zip uses `split_boot` + `flash_boot`, i.e. it
writes the raw Image to `boot_a`/`boot_b` and touches neither ramdisk nor
dtbo. Bootloader-side dtb comes from vendor_boot and stays stock.
