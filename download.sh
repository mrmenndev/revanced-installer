#!/bin/bash
set -e

#--
TEMP_DIR="/tmp/revanced-installer"

#--
REVANCED_PATCHES_URL=\
"https://github.com/revanced/revanced-patches/releases/download/v1.2.0/revanced-patches-1.2.0.jar"
REVANCED_INTEGRATION_URL=\
"https://github.com/revanced/revanced-integrations/releases/download/v0.7.0/app-release-unsigned.apk"
REVANCED_CLI_URL=\
"https://github.com/mrmenndev/revanced-installer/releases/download/revanced-cli/revanced-cli-1.3.0-all.jar"
#--
ADB_URL=\
"https://dl.google.com/android/repository/platform-tools-latest-linux.zip"

adb_zip="$TEMP_DIR/platform-tools-latest-linux.zip"
adb_file="$TEMP_DIR/platform-tools/adb"

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
    printf "\033[1;31m%s\033[0m" "Error:"
    printf " %s\n" "$1"
    if [ "$2" != "" ];then
        printf "%s\n" "$2"
    fi
    exit 1
}

#--------------------------------------
# etc
#--------------------------------------

download(){
    wget -N --no-verbose --show-progress --directory-prefix "$TEMP_DIR" "$1"
}

#======================================
# Script
#======================================

#--------------------------------------
# adb
#--------------------------------------

echo_step "Download adb"
download "$ADB_URL"

echo_step "Extract adb"
pushd "$TEMP_DIR"
# extract using java jar
jar -xf "$adb_zip"
popd
# set permission
chmod +x "$adb_file"

#--------------------------------------
# revanced
#--------------------------------------

echo_step "Download revanced-cli"
download "$REVANCED_CLI_URL"

echo_step "Download revanced-patches"
download "$REVANCED_PATCHES_URL"

echo_step "Download revanced-integration"
download "$REVANCED_INTEGRATION_URL"

#--------------------------------------
# success
#--------------------------------------

printf "%s\n" "----------"
printf "\033[1;32m%s\033[0m" "==> "
printf "Download finished\n"
printf "Now run './install.sh [youtube.apk]'\n"
