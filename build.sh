#!/bin/bash
echo ""
echo "AOSP Buildbot - LeaOS version"
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

export WITHOUT_CHECK_API=true
export WITH_SU=true
export OUT_DIR=/home/iceows/build

repo init -u https://android.googlesource.com/platform/manifest -b android-11.0.0_r48

prep_build() {
	echo "Preparing local manifests"
	rm -rf .repo/local_manifests
	mkdir -p .repo/local_manifests
	cp ./aosp_build_leaos/local_manifests_leaos/*.xml .repo/local_manifests
	echo ""

	echo "Syncing repos"
	repo sync -j4 -c -q --force-sync --no-tags --no-clone-bundle --optimized-fetch --prune

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
    cd device/phh/treble
    git clean -fdx
    bash generate.sh
    cd ../../..
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
    make installclean
    make -j$(nproc --all) systemimage

    mv $OUT/system.img ~/build-output/LeaOS-PHH-$BUILD_DATE-${TARGET}.img
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
    
    apply_patches spl
    apply_patches phh
    apply_patches personal
    apply_patches others

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
