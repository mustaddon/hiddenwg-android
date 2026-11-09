./gradlew assembleRelease

TOOLS_DIR=~/Android/Sdk/build-tools/37.0.0
APK_UNSIGN=./ui/build/outputs/apk/release/ui-release-unsigned.apk
APK_ALIGN=./ui/build/outputs/apk/release/ui-release-unsigned-aligned.apk
APK_SIGN=./ui/build/outputs/apk/release/ui-release.apk

if [ ! -f "$APK_UNSIGN" ]; then
    echo "Error: File '$APK_UNSIGN' does not exist."
    exit 1
fi

if [ -f "$APK_ALIGN" ]; then
    rm "$APK_ALIGN"
fi

"$TOOLS_DIR/zipalign" -v -p 4 "$APK_UNSIGN" "$APK_ALIGN"

if [ ! -f "$APK_ALIGN" ]; then
    echo "Error: File '$APK_ALIGN' does not exist."
    exit 1
fi

"$TOOLS_DIR/apksigner" sign --ks "./build.key" --out "$APK_SIGN" "$APK_ALIGN"