SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
LOCAL_PROPS="$SCRIPT_DIR/local.properties"

if [ -f "$LOCAL_PROPS" ]; then
    SDK_DIR=$(grep '^sdk.dir=' "$LOCAL_PROPS" | cut -d'=' -f2 | tr -d '\r')
else
    if [ -n "$ANDROID_HOME" ] && [ -d "$ANDROID_HOME" ]; then
        SDK_DIR="$ANDROID_HOME"
    elif [ -d "$HOME/Android/Sdk" ]; then
        SDK_DIR="$HOME/Android/Sdk"
    else
        echo "Error: Android SDK not found! "
        exit 1
    fi

    echo "sdk.dir=$SDK_DIR" > "$LOCAL_PROPS"
fi

./gradlew assembleRelease

APK_UNSIGN="$SCRIPT_DIR/ui/build/outputs/apk/release/ui-release-unsigned.apk"
APK_ALIGN="$SCRIPT_DIR/ui/build/outputs/apk/release/ui-release-unsigned-aligned.apk"
APK_SIGN="$SCRIPT_DIR/build.apk"

if [ -f "$APK_ALIGN" ]; then
    rm "$APK_ALIGN"
fi

if [ ! -f "$APK_UNSIGN" ]; then
    echo "Error: File '$APK_UNSIGN' does not exist."
    exit 1
fi

ZIPALIGN=$(ls -1d "$SDK_DIR"/build-tools/*/zipalign 2>/dev/null | tail -n 1)

if [ -z "$ZIPALIGN" ]; then
    echo "Error: 'zipalign' not found in '$SDK_DIR/build-tools/'"
    exit 1
fi

"$ZIPALIGN" -v -p 4 "$APK_UNSIGN" "$APK_ALIGN"

if [ ! -f "$APK_ALIGN" ]; then
    echo "Error: File '$APK_ALIGN' does not exist."
    exit 1
fi

APKSIGNER=$(ls -1d "$SDK_DIR"/build-tools/*/apksigner 2>/dev/null | tail -n 1)

if [ -z "$APKSIGNER" ]; then
    echo "Error: 'apksigner' not found in '$SDK_DIR/build-tools/'"
    exit 1
fi

"$APKSIGNER" sign --ks "$SCRIPT_DIR/build.key" --out "$APK_SIGN" "$APK_ALIGN"

if [ $? -eq 0 ]; then
    echo "SUCCESS: $APK_SIGN"
fi