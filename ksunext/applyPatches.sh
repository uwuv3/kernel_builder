#!/bin/bash
#

export maindir="$(pwd)"
export outside="${maindir}/.."
source "${outside}/$1env"

curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s next
git add . && git commit -am "drivers: KernelSU-Next"
KSU_GIT_VERSION=$(cd KernelSU-Next && git rev-list --count HEAD)
KSU_VERSION=$(( 10000 + KSU_GIT_VERSION + 200 ))


patchesdir="$outside/ksunext/patches/$(echo $kernel_ver | cut -d. -f1,2)"
if [[ -d "$patchesdir" ]]; then
  for patch_file in "$patchesdir"/*.patch ; do
    git am "$patch_file"
  done
else
  echo "patching ksunext failed, the kernel version you want to patch doesnt have patches here yet"
  exit 1
fi

sed -i "s/\(CONFIG_LOCALVERSION=\)\(.*\)/\1\"-${kernel_name}-Next${KSU_VERSION}\"/" "${defconfig_file}"

echo "$(grep 'CONFIG_LOCALVERSION=' ${defconfig_file})"

echo "" >> "${defconfig_file}"
echo "CONFIG_KSU=y" >> "${defconfig_file}"
echo "CONFIG_KSU_KPROBES_HOOK=n" >> "${defconfig_file}"
echo "CONFIG_KSU_LSM_SECURITY_HOOKS=y" >> "${defconfig_file}"
echo "" >> "${defconfig_file}"

echo -e " \nincludes KernelSU-Next, ver ${KSU_VERSION}" >> banner_append

