#!/bin/zsh
#
# Copyright (C) 2022-2024 John Hoyt
#
# See the file LICENSE_FSF for licensing information.
#

APP=$1
CODESIGN_ID=$2
ENTITLEMENT=$3

if [[ -z $APP ]]; then
  echo "No Application specified."
  exit 2
fi

if [[ -z $CODESIGN_ID ]]; then
  echo "No code signing ID specified.\n"
  echo "The name usually takes the form:"
  echo "    Developer ID Application: [Name]"
  echo " or"
  echo "    3rd Party Mac Developer Application: [Name]\n"
  echo "The Developer ID/Certificate can be obtained at https://developer.apple.com/"
  echo "(Account -> Certificates, IDs & Profiles -> Certificates -> + -> Developer ID Application)"
  exit 2
fi

if [[ -z $ENTITLEMENT ]]; then
  echo "No entitlement file specified."
  exit 2
fi

if [[ ! "$APP" = /* ]]; then
    echo "relative path structure used"
    APP=$(pwd)/$APP
fi

# Per the Apple developer notes, you must codesign from the inside out roughly meaning
# start dylibs then frameworks then executables.  In reality, as long as the codesign
# timestamps are relavtively close, no need to trace the recursive tree from excutables
# down to dylibs
for DIRECTORY in Resources PlugIns Frameworks; do
  echo "Codesigning Libraries in $DIRECTORY"
  for file in $APP/Contents/$DIRECTORY/**/*(.); do 
  	case $file in
        *.dylib|*.so|Qt*|Python)
           /usr/bin/codesign --force -s "${CODESIGN_ID}" -v --deep --timestamp -o runtime --entitlements $ENTITLEMENT --continue "$file"
        ;;
    esac
  done
done

# Sign the Executables
echo "Codesigning Executables in MacOS"
for file in $APP/Contents/MacOS/**/*(.); do
  /usr/bin/codesign --force -s "${CODESIGN_ID}" -v --deep --timestamp -o runtime --entitlements $ENTITLEMENT --continue "$file"
done

# Sign the Frameworks Directories
echo "Codesigning Frameworks"
/usr/bin/codesign --force -s "${CODESIGN_ID}" -v --deep --timestamp -o runtime --entitlements $ENTITLEMENT --continue $APP/Contents/Frameworks/*.framework

# Finally sign the application
echo "Codesigning Application"
/usr/bin/codesign --force -s "${CODESIGN_ID}" -v --deep --timestamp -o runtime --entitlements $ENTITLEMENT --continue $APP

# verify that the codesigning took
echo "Verifying code signatures"
CS_STATUS=$(/usr/bin/codesign --verify -vv --deep $APP)

echo $CS_STATUS

case $CS_STATUS in
  "")
    echo "+++++ ${APP} Signing Success"
    exit 0
    ;;
  *)
    echo "----- ${APP} Signing Failue"
    exit 1
esac