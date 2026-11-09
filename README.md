# Android GUI for HiddenWG

This repository is a [fork](https://github.com/WireGuard/wireguard-android/) that adds obfuscation to the standard [WireGuard](https://www.wireguard.com/) protocol.

## Download &amp; Install

[Releases](https://github.com/mustaddon/wireguard-android/releases) &ndash; Select the latest version of the APK file.

## Building

```
$ git clone --recurse-submodules https://github.com/mustaddon/wireguard-android.git
$ cd wireguard-android
$ ./gradlew assembleRelease
```

macOS users may need [flock(1)](https://github.com/discoteq/flock).
