#!/bin/bash

# Just a basic script U can improvise lateron asper ur need xD 

MANIFEST="git://github.com/SHRP/manifest.git -b v3_11.0"

DT_PATH=device/xiaomi/olive
DT_LINK="https://github.com/Jprimero15/device_xiaomi_olive-shrp -b SHRP"

echo " ===+++ Setting up Build Environment +++==="
apt install openssh-server -y
apt update --fix-missing
apt install openssh-server -y
mkdir ~/twrp && cd ~/twrp
DEVICE=${DT_PATH##*\/}

echo " ===+++ Syncing Recovery Sources +++==="
repo init --depth=1 -u $MANIFEST
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
git clone --depth=1 $DT_LINK $DT_PATH

echo " ===+++ Building Recovery +++==="

. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
export LC_ALL="C"
lunch twrp_${DEVICE}-eng && mka recoveryimage

cd $OUT/recovery/root
./ldcheck -p system/lib64:vendor/lib64 -d system/bin/qseecomd
cd -

# Upload zips & boot.img (U can improvise lateron adding telegram support etc etc)
echo " ===+++ Uploading Recovery +++==="
version=$(cat bootable/recovery/variables.h | grep "define TW_MAIN_VERSION_STR" | cut -d \" -f2)
OUTFILE=TWRP-${version}-${DEVICE}-$(date "+%Y%m%d-%I%M").zip
cd out/target/product/$DEVICE
mv recovery.img ${OUTFILE%.zip}.img
zip -r9 $OUTFILE ${OUTFILE%.zip}.img

#curl -T $OUTFILE https://oshi.at
curl -sL $OUTFILE https://git.io/file-transfer | sh
./transfer wet *.zip
