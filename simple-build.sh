#!/bin/bash
#set -e

rund="$(pwd)"
para="$(nproc)"


echo "Current dir : ${rund} "
echo "Nb proc : ${para}"

if [ ! "$1" ]; then
	echo "set build directory"
	exit
fi

echo "AOSP Source directory : $1"

pushd "$1"



repo init -u https://android.googlesource.com/platform/manifest -b android-11.0.0_r48

echo "Preparing local manifests"
rm -rf .repo/local_manifests
mkdir -p .repo/local_manifests
cp ./aosp_build_leaos/local_manifests_leaos/*.xml .repo/local_manifests
echo ""

echo "Synchronize repos"
repo sync -j${para} -c -q --force-sync --no-tags --no-clone-bundle --optimized-fetch --prune || exit

#echo "Applying patches"
#bash ${rund}/aosp_build_leaos/apply-patches.sh ${rund}  || exit

echo "Generate all make phh treble"
cd device/phh/treble
bash generate.sh


cd -
. build/envsetup.sh
lunch treble_arm64_bvN-userdebug

make installclean
make -j${para} systemimage

popd

