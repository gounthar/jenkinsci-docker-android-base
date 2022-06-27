#!/usr/bin/bash -ex

path=$APK_PATH

echo analyzing apk file...

echo apk file-size!
/usr/local/android-sdk-linux/tools/bin/apkanalyzer -h apk file-size $path

echo apk summary!
/usr/local/android-sdk-linux/tools/bin/apkanalyzer -h apk summary $path

echo files list!
/usr/local/android-sdk-linux/tools/bin/apkanalyzer -h files list $path

echo manifest min-sdk!
/usr/local/android-sdk-linux/tools/bin/apkanalyzer -h manifest min-sdk $path

echo manifest target-sdk!
/usr/local/android-sdk-linux/tools/bin/apkanalyzer -h manifest target-sdk $path

echo manifest permissions!
/usr/local/android-sdk-linux/tools/bin/apkanalyzer -h manifest permissions $path

echo dex list!
/usr/local/android-sdk-linux/tools/bin/apkanalyzer -h dex list $path

echo resources packages!
/usr/local/android-sdk-linux/tools/bin/apkanalyzer -h resources packages $path