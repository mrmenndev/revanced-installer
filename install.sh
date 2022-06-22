#!/usr/bin/env bash
set -e

VERSION="0.2.3"
TEMP_DIR="/tmp/revanced-installer"

#--------------------------------------
# revanced
#--------------------------------------

REVANCED_INTEGRATION_URL=\
"https://github.com/revanced/revanced-integrations/releases/download/v0.11.0/app-release-unsigned.apk"
REVANCED_PATCHES_URL=\
"https://github.com/revanced/revanced-patches/releases/download/v1.9.1/revanced-patches-1.9.1.jar"
REVANCED_CLI_URL=\
"https://github.com/revanced/revanced-cli/releases/download/v1.7.0/revanced-cli-1.7.0-all.jar"

REVANCED_INTEGRATION="$TEMP_DIR/app-release-unsigned.apk"
REVANCED_PATCHES="$TEMP_DIR/revanced-patches.jar"
REVANCED_CLI="$TEMP_DIR/revanced-cli-all.jar"
REVANCED_OUTPUT="$TEMP_DIR/revanced.apk"

#--------------------------------------
# adb
#--------------------------------------

ADB_ZIP="$TEMP_DIR/platform-tools.zip"
ADB_EXE="$TEMP_DIR/platform-tools/adb"
adb_device=""
platform=$(uname -s)

case "$platform" in
"Darwin")
    ADB_URL="https://dl.google.com/android/repository/platform-tools-latest-darwin.zip"
    ;;
"Linux")
    ADB_URL="https://dl.google.com/android/repository/platform-tools-latest-linux.zip"
    ;;
*)
    echo_error "Platform '$platform' is not supported"
    ;;
esac

#======================================
# Functions
#======================================

#--------------------------------------
# echo
#--------------------------------------

echo_usage() {
    printf "Usage:\n"
    printf "    ./install.sh [apk] : Download and install ReVanced\n"
    printf "Options:\n"
    printf " -i | --install  [apk] : Only install ReVanced\n"
    printf "                         (Files need to be downloaded first)\n"
    printf " -d | --download       : Only download required files\n"
    printf " -v | --version        : Show script version\n"
    printf " -h | --help           : Show command usage\n"
    exit 0
}

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
    printf "\033[1;31m%s\033[0m\n" "----------Error----------"  >&2
    printf "%s\n" "$1"  >&2
    if [ "$2" != "" ];then
        printf "%s\n" "$2"  >&2
    fi
    if [ "$3" != "" ];then
        printf "%s\n" "$3"  >&2
    fi
    exit 1
}

#--------------------------------------
# check
#--------------------------------------

# input func
check_file() {
    local file="$1"

    if [ ! -e "$file" ]; then
        echo_error "'$file' not found" \
        "Make sure to run './install.sh --download' first" \
        "or run './install.sh [apk]'"
    fi
}

# input + return func
check_apk(){
    local path="$1"

    if [ ! -e "$path" ]; then
        echo_error "'$path' not found"
    fi

    if [[ "$path" != *.apk ]]; then
        echo_error "'$path' is not a valid APK"
    fi

    printf "%s" "$path"
}

#--------------------------------------
# helper
#--------------------------------------

# input func
download(){
    local url="$1"
    local file="$2"
    
    wget --no-verbose --show-progress -O "$file" "$url" 
}

# input + return func
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

#--------------------------------------
# download
#--------------------------------------

start_download(){
    # prepare
    mkdir -p "$TEMP_DIR"
    rm -rf "$TEMP_DIR/platform-tools"

    echo_step "[1/4] Download adb"
    download "$ADB_URL" "$ADB_ZIP"

    echo_step "Extract adb"
    pushd "$TEMP_DIR"
    # extract
    jar -xf "$ADB_ZIP"
    # set permission
    chmod +x "$ADB_EXE"
    popd

    echo_step "[2/4] Download revanced-integration"
    download "$REVANCED_INTEGRATION_URL" "$REVANCED_INTEGRATION"

    echo_step "[3/4] Download revanced-patches"
    download "$REVANCED_PATCHES_URL" "$REVANCED_PATCHES"

    echo_step "[4/4] Download revanced-cli"
    download "$REVANCED_CLI_URL" "$REVANCED_CLI"
}

#--------------------------------------
# install
#--------------------------------------

check_install(){
    check_file "$ADB_EXE"
    check_file "$REVANCED_INTEGRATION"
    check_file "$REVANCED_PATCHES"
    check_file "$REVANCED_CLI"
}

fetch_device(){
    local adb_output
    local device_list
    local device_count
    local device

    echo_step "Start adb"
    "$ADB_EXE" kill-server || true
    "$ADB_EXE" start-server

    echo_step "Find device"
     # list devices
    adb_output=$("$ADB_EXE" devices | sed 's/List of devices attached//g'| awk '{
        if ($1 != "") print $1
    }')
    # create device list
    mapfile -t device_list < <(printf "%s" "$adb_output")
    # get device number
    device_count=${#device_list[@]}
    case $device_count in
        0)
            echo_error "No device found" \
                "Please connect your device and run:" \
                "./install.sh --install $youtube_apk"
            ;;
        1)
            device=${device_list[0]}
            ;;
        *)
            echo_step "Please select a device"
            device=$(select_device device_list)
            ;;
    esac

    echo_step "Check device: $device"
    "$ADB_EXE" -s "$device" shell exit

    adb_device="$device"
}

# input func
start_revanced(){
    local apk="$1"
    local device="$2"
    
    echo_step "Install revanced"
    java -jar "$REVANCED_CLI" --clean \
        -b "$REVANCED_PATCHES" \
        -m "$REVANCED_INTEGRATION" \
        --out "$REVANCED_OUTPUT" \
        --temp-dir "$TEMP_DIR/cache" \
        --apk "$apk" \
        --deploy-on "$device"  \
        -e "amoled" \
        -e "premium-heading"
}

#======================================
# Script
#======================================

case "$1" in
"" | "-h" | "--help")
    echo_usage
    ;;
"-v" | "--version")
    printf "revanced-installer v%s\n" "$VERSION"
    printf "Platform: %s\n" "$platform"
    ;;
"-d" | "--download")
    start_download
    ;;
"-i" | "--install")
    youtube_apk=$(check_apk "$2")
    check_install
    fetch_device
    start_revanced "$youtube_apk" "$adb_device"
    ;;
-*)
    echo_usage
    ;;
*)  
    youtube_apk=$(check_apk "$1")
    start_download
    check_install
    fetch_device
    start_revanced "$youtube_apk" "$adb_device"
    ;;
esac