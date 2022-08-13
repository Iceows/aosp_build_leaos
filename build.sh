#!/bin/bash
echo ""
echo "AOSP Buildbot - LeaOS version Android 12"
echo "Executing in 5 seconds - CTRL-C to exit"
echo ""
sleep 5

if [ $# -lt 1 ]
then
    echo "Not enough arguments - exiting"
    echo ""
    exit 1
fi

MODE=${1}
NOSYNC=false
PERSONAL=false
ICEOWS=true
for var in "${@:2}"
do
    if [ ${var} == "nosync" ]
    then
        NOSYNC=true
    fi
done

echo "Building with NoSync : $NOSYNC - Mode : ${MODE}"



# Abort early on error
set -eE
trap '(\
echo;\
echo \!\!\! An error happened during script execution;\
echo \!\!\! Please check console output for bad sync,;\
echo \!\!\! failed patch application, etc.;\
echo\
)' ERR

START=`date +%s`
BUILD_DATE="$(date +%Y%m%d)"
WITHOUT_CHECK_API=true
ORIGIN_FOLDER="$(dirname "$(readlink -f -- "$0")")"
export OUT_DIR=/home/iceows/build/A12

repo init -u https://android.googlesource.com/platform/manifest -b android-12.1.0_r11

prep_build() {
	echo "Preparing local manifests"
	rm -rf .repo/local_manifests
	mkdir -p .repo/local_manifests
	cp ./aosp_build_leaos/local_manifests_leaos/*.xml .repo/local_manifests
	echo ""

	echo "Syncing repos"
	repo sync -j$(nproc --all) -c -q --force-sync --no-tags --no-clone-bundle --optimized-fetch --prune

	echo ""

	echo "Setting up build environment"
	source build/envsetup.sh &> /dev/null
	mkdir -p ~/build-output
	echo ""
}

apply_patches() {
    echo "Applying patch group ${1}"
    bash ./aosp_build_leaos/apply-patches.sh ./aosp_patches_leaos/patches/${1}
}

prep_device() {
    :
}

prep_treble() {
    :    
}

finalize_device() {
    :
}

finalize_treble() {
    rm -f device/*/sepolicy/common/private/genfs_contexts

    repo forall -r '.*opengapps.*' -c 'git lfs fetch && git lfs checkout'
    
    (cd device/phh/treble; git clean -fdx; bash generate.sh)
    (cd vendor/foss; git clean -fdx; bash update.sh)
    
    # only A12 build
    if grep -q lottie packages/apps/Launcher3/Android.bp;then
       (cd vendor/partner_gms; git am ../../aosp_build_leaos/0001-Fix-SearchLauncher-for-Android-12.1.patch || true)
    fi

    rm -f vendor/gapps/interfaces/wifi_ext/Android.bp
    
    #rm -rf vendor/gapps/partner_gms/product
    
}

build_device() {
	:
}

build_treble() {
    case "${1}" in
        ("64BGS") TARGET=treble_arm64_bgS;;  
        ("64BGN") TARGET=treble_arm64_bgN;;
        ("64BGZ") TARGET=treble_arm64_bgZ;;
        ("64BVS") TARGET=treble_arm64_bvS;;
        ("64BVN") TARGET=treble_arm64_bvN;;
        ("64BVZ") TARGET=treble_arm64_bvZ;;
        (*) echo "Invalid target - exiting"; exit 1;;
    esac
    lunch ${TARGET}-userdebug

    make RELAX_USES_LIBRARY_CHECK=true BUILD_NUMBER=$BUILD_DATE installclean
    make RELAX_USES_LIBRARY_CHECK=true BUILD_NUMBER=$BUILD_DATE -j$(nproc --all)  systemimage
    make RELAX_USES_LIBRARY_CHECK=true BUILD_NUMBER=$BUILD_DATE vndk-test-sepolicy


    mv $OUT/system.img ~/build-output/LeaOS-A12-$BUILD_DATE-${TARGET}.img
}

if ${NOSYNC}
then
    echo "ATTENTION: syncing/patching skipped!"
    echo ""
    echo "Setting up build environment"
    source build/envsetup.sh &> /dev/null
    echo ""
else
    prep_build
    echo "Applying patches"
    prep_treble
    
    apply_patches phh
    apply_patches iceows

    finalize_treble
    echo ""
fi

for var in "${@:2}"
do
    if [ ${var} == "nosync" ]
    then
        continue
    fi
    echo "Starting $(${PERSONAL} && echo "personal " || echo "")build for ${MODE} ${var}"
    build_${MODE} ${var}
done
ls ~/build-output | grep 'LeaOS' || true

END=`date +%s`
ELAPSEDM=$(($(($END-$START))/60))
ELAPSEDS=$(($(($END-$START))-$ELAPSEDM*60))
echo "Buildbot completed in $ELAPSEDM minutes and $ELAPSEDS seconds"
echo ""
