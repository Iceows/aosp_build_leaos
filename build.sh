#!/bin/bash
#set -e

rund="$(pwd)"
para="$(nproc)"

if [ ! "$1" ]; then
	echo "set build directory"
	exit
fi

pushd "$1"

repo init -u https://android.googlesource.com/platform/manifest -b android-11.0.0_r48

echo "Preparing local manifests"
rm -rf .repo/local_manifests
mkdir -p .repo/local_manifests
cp ./aosp_build_leaos/local_manifests_leaos/*.xml .repo/local_manifests
echo ""

repo sync -j${para} -c -q --force-sync --no-tags --no-clone-bundle --optimized-fetch --prune ||exit
bash ./aosp_build_leaos/apply-patches.sh ${rund} ||echo "*!* NOT ALL PATCHES APPLIED, CHECK THEM MANUALLY" && exit

echo ""

cd device/phh/treble
bash generate.sh
cd -
. build/envsetup.sh
lunch treble_arm64_bvN-userdebug
make -j${para} systemimage

popd

