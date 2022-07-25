# Revanced Installer

A script to install the [ReVanced](https://github.com/revanced/) app.

Tested on `Linux` and on `MacOS`

# Prerequisites

-   `YouTube 17.28.34` as **apk** (not as **bundle**). Can be found on [apkmirror.com](https://www.apkmirror.com/apk/google-inc/youtube/youtube-17-28-34-release/youtube-17-28-34-2-android-apk-download/)

-   USB Debugging enabled on your phone

-   `JDK 17` or higher. Recommend to download and install [temurin](https://adoptium.net/de/temurin/releases)

# Linux and MacOS

## Download

1. Download `./install.sh`

```
curl -L "https://raw.githubusercontent.com/mrmenndev/revanced-installer/master/install.sh" > install.sh
```

2. Make script executable

```
chmod +x install.sh
```

## Usage

Run `./install.sh [youtube apk]` to download all required files and install ReVanced

Example:

```
./install.sh $HOME/Downloads/youtube_17.28.34.apk
```

## Options

`-i [apk]` or `--install [apk]`

-   Only install ReVanced (Files need to be downloaded first)

`-d` or `--download`

-   Only download required files

`-v` or `--version`

-   Show script version

`-h` or `--help`

-   Show command usage

# Windows

coming soon
