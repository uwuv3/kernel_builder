#!/bin/bash
#

export maindir="$(pwd)"
export outside="${maindir}/.."
source "${outside}/$1env"

curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s next
git add . && git commit -am "drivers: KernelSUNext"
KSU_GIT_VERSION := $(shell cd KernelSU-Next && git rev-list --count HEAD)
KSU_VERSION := $(shell expr 10000 + $(KSU_GIT_VERSION) + 200)

$(info -- KernelSU-Next version: $(KSU_VERSION))

patchesdir="$outside/ksu/patches/$(echo $kernel_ver | cut -d. -f1,2)"
if [[ -d "$patchesdir" ]]; then
  for patch_file in "$patchesdir"/*.patch ; do
    git am "$patch_file"
  done
else
  echo "patching ksu failed, the kernel version you want to patch doesnt have patches here yet"
  exit 1
fi

sed -i "s/\(CONFIG_LOCALVERSION=\)\(.*\)/\1\"-${kernel_name}-KSUNext${KSU_ver}\"/" "${KSU_VERSION}"

echo "$(grep 'CONFIG_LOCALVERSION=' ${defconfig_file})"

