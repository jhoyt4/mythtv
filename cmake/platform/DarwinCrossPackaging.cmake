#
# Copyright (C) 2022-2024 John Hoyt
#
# See the file LICENSE_FSF for licensing information.
#

if(NOT CMAKE_SYSTEM_NAME MATCHES "Windows" OR NOT CMAKE_CROSSCOMPILING)
  return()
endif()

#
# Load needed functions
#

if(NOT MACOSX_BUNDLE)
  return()
endif()

set(MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION_MAJOR}.${MYTHTV_BINARY_CHANGED})
set(MACOSX_BUNDLE_LONG_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${MYTHTV_BINARY_CHANGED})
set(MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR})


#configure_file(Info.plist.in Info.plist

set(CPACK_BUNDLE_NAME "mythfrontend.app")
set(CPACK_BUNDLE_ICON "programs/mythfrontend/mythfrontend.icns")
set(CPACK_BUNDLE_PLIST "files/darwin/Info.plist.in")
set(CPACK_BUNDLE_APPLE_ENTITLEMENTS "files/darwin/entitlement.plist.in")
set(CPACK_GENERATOR "BUNDLE")

#set(CPACK_BUNDLE_STARTUP_COMMAND mythfrontend.sh)
#set(CPACK_BUNDLE_APPLE_CERT_APP "")
#set(CPACK_BUNDLE_APPLE_CODESIGN_FILES "")
#set(CPACK_BUNDLE_APPLE_CODESIGN_PARAMETER)

include(CPack)
