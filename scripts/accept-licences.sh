#!/usr/bin/expect -f
# taken from https://raw.githubusercontent.com/journeyapps/android-sdk-installer/version-2/accept-licenses
# Usage example:
#  ./accept-licenses "android update sdk --no-ui --all --filter build-tools" "android-sdk-license-bcbbd656|intel-android-sysimage-license-1ea702d1"

set timeout 1800
set cmd [lindex $argv 0]
set licenses [lindex $argv 1]

spawn {*}$cmd
expect {
  -regexp "Do you accept the license '($licenses)'.*" {
        exp_send "y\r"
        exp_continue
  }
  "Do you accept the license '*-license-*'*" {
        exp_send "n\r"
        exp_continue
  }
  eof
}
