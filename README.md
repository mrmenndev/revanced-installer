# Revanced Installer

A (hopefully) simpler way to install the ReVanced app.

Tested on `Linux` and on `MacOS`

---

## Prerequisites

-   `JDK 17` or higher. Recommend to download and install [temurin](https://adoptium.net/de/temurin/releases)

-   `wget` if not preinstalled

-   `YouTube 17.22.36` as **apk** (not as **bundle**). Can be found on [apkmirror.com](https://www.apkmirror.com/apk/google-inc/youtube/youtube-17-22-36-release/youtube-17-22-36-2-android-apk-download/)

-   USB Debugging enabled on your phone

# Linux and MacOS

## Download

1. Download `./download.sh` and `./install.sh`

```
wget "https://raw.githubusercontent.com/mrmenndev/revanced-installer/master/download.sh" && wget "https://raw.githubusercontent.com/mrmenndev/revanced-installer/master/install.sh"
```

2. Make both scripts executable

```
chmod +x download.sh install.sh
```

## Usage

1.  Run `./download.sh` to download a local adb copy and files from revanced
2.  Run `./install.sh [youtube apk]` to actually install `ReVanced`

    Example:

```
./install.sh $HOME/Downloads/youtube_17.22.36.apk
```

# Windows

coming soon
