
## Building PHH-based GSIs ##

To get started with building PHH AOSP, you'll need to get familiar with [Git and Repo](https://source.android.com/source/using-repo.html), and set up your environment by referring to [LineageOS Wiki](https://wiki.lineageos.org/devices/redfin/build) (mainly "Install the build packages") and [How to build a GSI](https://github.com/phhusson/treble_experimentations/wiki/How-to-build-a-GSI%3F).


First, open a new Terminal window, create a new working directory for your Aosp build (leaos-aosp for example) and navigate to it:

    mkdir leaos-aosp; cd leaos-aosp
    
Clone both this and the patches repos:

    git clone https://github.com/iceows/aosp_build_leaos aosp_build_leaos -b android-13
    git clone https://github.com/iceows/aosp_patches_leaos aosp_patches_leaos -b android-13

Finally, start the build script (Dynamic root , no google apps):

    bash aosp_build_leaos/build.sh treble 64BVZ
    

---

Specific vndklite targets for Huawei are generated from AB images instead of source-built - refer to [huawei-creator](https://github.com/iceows/huawei-creator).

	sudo bash ./run-huawei-ab-a13.sh "myimage.img" sudo bash ./run-huawei-ab-a13.sh /home/iceows/build-output/LeaOS-20.0-20230302-arm64_bgN.img "LeaOS" "ANE-LX1" "N"
 "LeaOS" "ANE-LX1" "N"


---

This script is also used to make builds without sync repo. To do so add nosync in the command build line.

    bash aosp_build_leaos/build.sh treble nosync 64BVZ


