#!/bin/zsh
#
# Copyright (C) 2022-2024 John Hoyt
#
# See the file LICENSE_FSF for licensing information.
#

#This application finds dylibs that macdeploy misses correcting their dylib linkes
# to point internally to the APP Bundle.

APP_BUNDLE=$1
PKGMGR_PREFIX=$2
MYTHTV_INSTALL_PREFIX=$3

APP_FMWK_DIR=$APP_BUNDLE/Contents/Frameworks
APP_PLUGIN_DIR=$APP_BUNDLE/Contents/PlugIns

installLibs(){
  binFile=$1

  loopCTR=0
  # find all externally-linked libs and loop over them
  pathDepList=$(/usr/bin/otool -L "$binFile"|grep -e "$PKGMGR_PREFIX" -e "$MYTHTV_INSTALL_PREFIX")
  pathDepList=$(echo "$pathDepList"| sed 's^(.*^^')
  while read -r dep; do
    if [ "$loopCTR" = 0 ]; then
      echo '\033[0;36m'"    installLibs: Parsing $binFile for linked libraries"'\033[m'
    fi
    loopCTR=$loopCTR+1
    lib=${dep##*/}

    # Parse the lib if it isn't null
    if [ -n "$lib" ]; then
      #check if it is already installed in the framewrk, if so
      #update the link
      needsCopy=false
      IN_APP_LIB=$(find "$APP_BUNDLE" -name "$lib" -print -quit)
      case $IN_APP_LIB in
        *Contents/Frameworks*)
          newLink="@executable_path/../Frameworks/$lib"
        ;;
        *Contents/PlugIns*)
          newLink="@executable_path/../PlugIns/$lib"
        ;;
        *)
          newLink="@executable_path/../Frameworks/$lib"
          needsCopy=true
        ;;
      esac

      # Copy in any missing files
      if $needsCopy; then
        echo '\033[0;34m'"      +++installLibs: Installing $lib into app"'\033[m'
        sourcePath=$(find "$MYTHTV_INSTALL_PREFIX" "$PKGMGR_PREFIX" -name "$lib" -print -quit)
        destinPath="$APP_FMWK_DIR"
        cp -RHn "$sourcePath" "$destinPath/$lib"
        needRPATHFix=$(/usr/bin/otool -l "$destinPath/$lib"|grep -e "@loader_path/../lib")
        if [ -n "$needRPATHFix" ]; then
          NAME_TOOL_CMD="install_name_tool -rpath \"@loader_path/../lib\" \"@loader_path/../Frameworks\" $destinPath/$lib"
          eval "${NAME_TOOL_CMD}"
        fi
        # this will need to be done recursively
        recurse=true
      fi
      # update the link in the app/executable to the new interal Framework
      echo '\033[0;34m'"      ---installLibs: Updating $binFileName $lib link to internal lib"'\033[m'
      # it should now be in the App Bundle Frameworks, we just need to update the link
      NAME_TOOL_CMD="install_name_tool -change $dep $newLink $binFile"
      eval "${NAME_TOOL_CMD}"
      # If a new lib was copied in, recursively check it
      if  $needsCopy && $recurse ; then
        echo '\033[0;34m'"      ^^^installLibs: Recursively install $lib"'\033[m'
        installLibs "$destinPath/$lib"
      fi
    fi
  done <<< "$pathDepList"
}

# Look over all dylibs in the APP Bundle and correct any dylib path's that macdeployqt misses.
for DIRECTORY in Resources PlugIns Frameworks; do
  for file in $APP_BUNDLE/Contents/$DIRECTORY/**/*(.); do 
    case $file in
        *.dylib)
          pathDepList=$(/usr/bin/otool -L "$file"|grep -e "$PKGMGR_PREFIX" -e "$MYTHTV_INSTALL_PREFIX")
          if [ -n "$pathDepList" ] ; then
            installLibs "$file"
          fi
        ;;
    esac
  done
done