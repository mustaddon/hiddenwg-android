#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE}")" &> /dev/null && pwd)
cd "$SCRIPT_DIR" || exit 1

LOCAL_PROPS="$SCRIPT_DIR/local.properties"

if [ -f "$LOCAL_PROPS" ]; then
    SDK_DIR=$(grep '^sdk.dir=' "$LOCAL_PROPS" | cut -d'=' -f2 | tr -d '\r' | sed 's/\\:/:/g; s/\\\\/\\/g')
else
    if [ -n "$ANDROID_HOME" ] && [ -d "$ANDROID_HOME" ]; then
        SDK_DIR="$ANDROID_HOME"
    elif [ -d "$HOME/Android/Sdk" ]; then
        SDK_DIR="$HOME/Android/Sdk"
    elif [ -d "$HOME/Library/Android/sdk" ]; then
        SDK_DIR="$HOME/Library/Android/sdk"
    else
        echo "Error: Android SDK not found!"
        exit 1
    fi

    echo "sdk.dir=$SDK_DIR" > "$LOCAL_PROPS"
fi

if [ -n "$1" ]; then
    if [ ! -f "$1" ]; then
        echo "Error: Signkey '$1' not found."
        exit 1
    fi
    APK_KEY="$1"
else 
    APK_KEY="$SCRIPT_DIR/build.jks"
fi

if ! ./gradlew assembleRelease; then
    echo "Error: Gradle build failed!"
    exit 1
fi

APK_UNSIGN="$SCRIPT_DIR/ui/build/outputs/apk/release/ui-release-unsigned.apk"
APK_ALIGN="$SCRIPT_DIR/ui/build/outputs/apk/release/ui-release-unsigned-aligned.apk"
APK_SIGN="$SCRIPT_DIR/build.apk"

if [ ! -f "$APK_KEY" ]; then
    echo "Creating signkey..."

    if command -v keytool &> /dev/null; then
        KEYTOOL_BIN="keytool"
    elif [ -n "$JAVA_HOME" ] && [ -x "$JAVA_HOME/bin/keytool" ]; then
        KEYTOOL_BIN="$JAVA_HOME/bin/keytool"
    elif [ -x "$HOME/android-studio/jbr/bin/keytool" ]; then
        KEYTOOL_BIN="$HOME/android-studio/jbr/bin/keytool"
    elif [ -x "/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool" ]; then
        KEYTOOL_BIN="/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool"
    else
        echo "Error: 'keytool' not found."
        exit 1
    fi

    if ! "$KEYTOOL_BIN" -genkey -v \
        -keystore "$APK_KEY" \
        -keyalg RSA \
        -keysize 2048 \
        -validity 20000 \
        -alias apk; then
        echo "Error: Failed to generate keystore."
        exit 1
    fi
fi

if [ ! -f "$APK_UNSIGN" ]; then
    echo "Error: File '$APK_UNSIGN' does not exist."
    exit 1
fi

rm -f "$APK_ALIGN" "$APK_SIGN"

ZIPALIGN=$(ls -1vd "$SDK_DIR"/build-tools/*/zipalign 2>/dev/null | tail -n 1)

if [ -z "$ZIPALIGN" ]; then
    echo "Error: 'zipalign' not found in '$SDK_DIR/build-tools/'"
    exit 1
fi

if ! "$ZIPALIGN" -v -p 4 "$APK_UNSIGN" "$APK_ALIGN"; then
    echo "Error: zipalign failed."
    exit 1
fi

APKSIGNER=$(ls -1vd "$SDK_DIR"/build-tools/*/apksigner 2>/dev/null | tail -n 1)

if [ -z "$APKSIGNER" ]; then
    echo "Error: 'apksigner' not found in '$SDK_DIR/build-tools/'"
    exit 1
fi

if "$APKSIGNER" sign --ks "$APK_KEY" --out "$APK_SIGN" "$APK_ALIGN"; then
    rm -f "$APK_ALIGN"
    echo "SUCCESS: $APK_SIGN"
fi
