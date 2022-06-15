#!/usr/bin/env bash
set -e

#--
TEMP_DIR="/tmp/revanced-installer"

revanced_integration="$TEMP_DIR/app-release-unsigned.apk"
revanced_patches="$TEMP_DIR/revanced-patches.jar"
revanced_cli="$TEMP_DIR/revanced-cli-all.jar"

#--revanced
REVANCED_INTEGRATION_URL=\
"https://github.com/revanced/revanced-integrations/releases/download/v0.8.0/app-release-unsigned.apk"
REVANCED_PATCHES_URL=\
"https://github.com/revanced/revanced-patches/releases/download/v1.3.0/revanced-patches-1.3.0.jar"
REVANCED_CLI_URL=\
"https://github.com/revanced/revanced-cli/releases/download/v1.4.1/revanced-cli-1.3.0-all.jar"

#--adb
platform=$(uname -s)
case "$platform" in
Darwin)
    ADB_URL="https://dl.google.com/android/repository/platform-tools-latest-darwin.zip"
    adb_zip="$TEMP_DIR/platform-tools-latest-darwin.zip"
    ;;
Linux)
    ADB_URL="https://dl.google.com/android/repository/platform-tools-latest-linux.zip"
    adb_zip="$TEMP_DIR/platform-tools-latest-linux.zip"
    ;;
*)
    echo_error "'$platform' not supported"
    ;;
esac

#======================================
# Functions
#======================================

#--------------------------------------
# echo
#--------------------------------------

echo_step(){
    printf "%s\n" "----------"
    printf "\033[1;33m%s\033[0m" "==> "
    printf "%s\n" "$1"
    if [ "$2" != "" ];then
        printf "%s\n" "$2"
    fi
    printf "%s\n" "----------"
}
echo_error(){
    printf "%s\n" "----------"
    printf "\033[1;31m%s\n\033[0m" "==> Error"
    printf "%s\n" "$1"
    if [ "$2" != "" ];then
        printf "%s\n" "$2"
    fi
    exit 1
}

#--------------------------------------
# etc
#--------------------------------------

download(){
    local url="$1"
    local file="$2"
    
    wget --no-verbose --show-progress -O "$file" "$url" 
}

#======================================
# Script
#======================================

# prepare
mkdir -p "$TEMP_DIR"
rm -rf "$TEMP_DIR/platform-tools"

#--------------------------------------
# adb
#--------------------------------------

echo_step "[1/4] Download adb"
download "$ADB_URL" "$adb_zip"

echo_step "Extract adb"
pushd "$TEMP_DIR"
# extract
jar -xf "$adb_zip"
# set permission
chmod +x "$TEMP_DIR/platform-tools/adb"
popd

#--------------------------------------
# revanced
#--------------------------------------

echo_step "[2/4] Download revanced-integration"
download "$REVANCED_INTEGRATION_URL" "$revanced_integration"

echo_step "[3/4] Download revanced-patches"
download "$REVANCED_PATCHES_URL" "$revanced_patches"

echo_step "[4/4] Download revanced-cli"
download "$REVANCED_CLI_URL" "$revanced_cli"

#--------------------------------------
# success
#--------------------------------------

printf "%s\n" "----------"
printf "\033[1;32m%s\033[0m" "==> "
printf "Download finished\n"
printf "Now run './install.sh [youtube.apk]'\n"
