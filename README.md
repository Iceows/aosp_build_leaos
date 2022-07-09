
## Building PHH-based LineageOS GSIs ##

To get started with building PHH AOSP, you'll need to get familiar with [Git and Repo](https://source.android.com/source/using-repo.html), and set up your environment by referring to [LineageOS Wiki](https://wiki.lineageos.org/devices/redfin/build) (mainly "Install the build packages") and [How to build a GSI](https://github.com/phhusson/treble_experimentations/wiki/How-to-build-a-GSI%3F).


First, open a new Terminal window, create a new working directory for your Aosp build (leaos-aosp for example) and navigate to it:

    mkdir leaos-aosp; cd leaos-aosp
    
Clone the modified treble_experimentations repo there:

    git clone https://github.com/iceows/treble_experimentations
    
Initialize your LineageOS workspace:

    repo init -u https://android.googlesource.com/platform/manifest -b android-11.0.0_r48

Clone both this and the patches repos for A11:

    git clone https://github.com/iceows/aosp_build_leaos aosp_build_leaos -b android-11
    git clone https://github.com/iceows/aosp_patches_leaos aosp_patches_leaos -b android-11

Finally, start the build script (Dynamic root):

    bash aosp_build_leaos/build.sh treble 64BVZ 
    

Be sure to update the cloned repos from time to time!

---

A-only targets for Huawei hi6250 re generated from AB images instead of source-built - refer to [huawei-creator](https://github.com/iceows/huawei-creator).

	sudo ./run-huawei-aonly.sh "myimage.img"  "LeaOS-PHH" "PRA-LX1" "Y" "N"

---

This script is also used to make builds without sync repo. To do so add nosync in the command build line.

    bash aosp_build_leaos/build.sh treble nosync 64BVZ


