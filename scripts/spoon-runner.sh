#!/bin/sh
TEST_APK_PATH=$1
APK_PATH=$2
TEST_REPORT_PATH=$3

usage="$(basename "$0") TEST_APK_PATH APK_PATH TEST_REPORT_PATH -- program to launch spoon runner tests on your apks

where:
    TEST_APK_PATH    the path to your test APK
    APK_PATH         the path to your APK
    TEST_REPORT_PATH the path where you want to store your report"

if [ "$#" != 3 ]; then
  echo "Usage: $usage"
  exit 0
fi
echo $TEST_APK_PATH $APK_PATH $TEST_REPORT_PATH

java -jar $SPOON_HOME/spoon-runner-2.0.0.jar $TEST_APK_PATH $APK_PATH --output  $TEST_REPORT_PATH --shard
