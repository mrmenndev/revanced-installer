#!/usr/bin/env bash
set -e

#--
TEMP_DIR="/tmp/revanced-installer"

revanced_cli="$TEMP_DIR/revanced-cli-1.3.0-all.jar"
revanced_patches="$TEMP_DIR/revanced-patches-1.2.0.jar"
revanced_integration="$TEMP_DIR/app-release-unsigned.apk"
revanced_apk="$TEMP_DIR/revanced.apk"

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
# check
#--------------------------------------

check_input(){
    case "$1" in
    "")
        echo_error "Youtube APK is not defined."
        ;;
    *.apk)
        return
        ;;
    *)
        echo_error "'$1' is not an APK file" "Make sure to run './install.sh [youtube.apk]'"
    esac
}
check_file() {
    local file=$1

    if [ ! -e "$file" ]; then
        echo_error "'$file' not found." "Make sure to run './download' first"
    fi
}

#--------------------------------------
# etc
#--------------------------------------

select_device(){
    local -n list=$1

    select device in "${list[@]}";
    do
        if [ "$device" != "" ]; then
            break
        fi
    done

    printf "%s" "$device"
}

#======================================
# Script
#======================================

# check youtube apk
check_input "$1"
youtube_apk="$(realpath "$1")"

# check if revanced files are downloaded
check_file "$adb_file"
check_file "$revanced_cli"
check_file "$revanced_patches"
check_file "$revanced_integration"

#--------------------------------------
# adb
#--------------------------------------

echo_step "Find adb device"
# list
adb_output=$(adb devices | sed 's/List of devices attached//g'| awk '{
    if ($1 != "") print $1
}')
# create array
mapfile -t device_list < <(printf "%s" "$adb_output")

# get device number
device_count=${#device_list[@]}
case $device_count in
    "0")
        echo_error "no device found"
        ;;
    "1")
        device=${device_list[0]}
        ;;
    *)
        echo_step "Please select your device:"
        device=$(select_device device_list)
        ;;
esac

echo_step "Check device: '$device'"
adb shell exit

#--------------------------------------
# revanced
#--------------------------------------

echo_step "Install revanced"
java -jar "$revanced_cli" --clean --install \
    -b "$revanced_patches" \
    -m "$revanced_integration" \
    --temp-dir "$TEMP_DIR/cache" \
    --apk "$youtube_apk" \
    --out "$revanced_apk" \
    --deploy-on "$device"  \
    -i "microg-patch" \
    -i "minimized-playback" \
    -i "old-quality-layout" \
    -i "disable-create-button" \
    -i "shorts-button" \
    -i "general-ads" \
    -i "video-ads"
