#
# Copyright (C) 2022-2024 John Hoyt
#
# See the file LICENSE_FSF for licensing information.
# Enable the App Bundle Process and set the application name

if(NOT APPLE)
  return()
endif()

if(NOT DARWIN_BACKEND_BUNDLE AND NOT DARWIN_FRONTEND_BUNDLE)
  return()
endif()

# activate generation of the app bundle and point the application's
# rpath to the frameworks where all dylibs must be stored
set_target_properties(${APP_NAME} PROPERTIES 
  MACOSX_BUNDLE TRUE
  INSTALL_RPATH @executable_path/../Frameworks)

# Extract the year for the copyright
string(TIMESTAMP YEARSTAMP "%Y")

# Set required app bundle version variables
set(MACOSX_BUNDLE_BUNDLE_NAME ${APP_NAME})
set(MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION_MAJOR}.${MYTHTV_BINARY_CHANGED})
set(MACOSX_BUNDLE_COPYRIGHT "Copyright 2023-${YEARSTAMP} MythTV Dev Team")
set(MACOSX_BUNDLE_GUI_IDENTIFIER "org.mythtv.${APP_NAME}")
set(MACOSX_BUNDLE_ICON_FILE "application.icns")
set(MACOSX_BUNDLE_LONG_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${MYTHTV_BINARY_CHANGED})
set(MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR})

install(
  TARGETS ${APP_NAME}
  BUNDLE DESTINATION ${CMAKE_INSTALL_PREFIX} COMPONENT Runtime)

# add the runtime liibraries to the app bundle's Framworks folder
install (
  DIRECTORY ${CMAKE_INSTALL_PREFIX}/lib/
  DESTINATION ${CMAKE_INSTALL_PREFIX}/${APP_NAME}.app/Contents/Frameworks
  FILES_MATCHING PATTERN "*.dylib") 

# add mythtv's shared resources to the app bundle's Resources folder
install(
  DIRECTORY ${CMAKE_INSTALL_PREFIX}/share
  DESTINATION  ${CMAKE_INSTALL_PREFIX}/${APP_NAME}.app/Contents/Resources)

# Add the icon file (set above) to the app bundle's Resources folder
install(
  FILES ${APP_NAME}.icns
  DESTINATION ${CMAKE_INSTALL_PREFIX}/${APP_NAME}.app/Contents/Resources
  RENAME application.icns)
