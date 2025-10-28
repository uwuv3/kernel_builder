#!/bin/bash
#

export maindir="$(pwd)"
export outside="${maindir}/.."
source "${outside}/$1env"

curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s next
git add . && git commit -am "drivers: KernelSUNext"
ifeq ($(shell test -e $(srctree)/$(src)/../.git; echo $$?),0)
KSU_VERSION_TAG := $(shell cd $(srctree)/$(src); /usr/bin/env PATH="$$PATH":/usr/bin:/usr/local/bin git describe --tags --abbrev=0 2>/dev/null)
$(info -- KernelSU-Next tag: $(KSU_VERSION_TAG))

patchesdir="$outside/ksu/patches/$(echo $kernel_ver | cut -d. -f1,2)"
if [[ -d "$patchesdir" ]]; then
  for patch_file in "$patchesdir"/*.patch ; do
    git am "$patch_file"
  done
else
  echo "patching ksu failed, the kernel version you want to patch doesnt have patches here yet"
  exit 1
fi

sed -i "s/\(CONFIG_LOCALVERSION=\)\(.*\)/\1\"-${kernel_name}-ksn${KSU_VERSION_TAG}\"/" "${defconfig_file}"

echo "$(grep 'CONFIG_LOCALVERSION=' ${defconfig_file})"

