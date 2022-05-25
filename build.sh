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
git clone --single-branch https://github.com/iceows/aosp_manifest_leaos .repo/local_manifests
repo sync -j${para} -c -q --force-sync --no-tags --no-clone-bundle --optimized-fetch --prune ||exit
bash ${rund}/apply-patches.sh ${rund} ||echo "*!* NOT ALL PATCHES APPLIED, CHECK THEM MANUALLY" && exit
cd device/phh/treble
bash generate.sh
cd -
. build/envsetup.sh
lunch treble_arm64_bvN-userdebug
make -j${para} systemimage

popd

