#
# Copyright (C) 2022-2024 John Hoyt
#
# See the file LICENSE_FSF for licensing information.
#
if(NOT APPLE)
  return()
endif()

if(DARWIN_SIGNING_ID STREQUAL "")
  return()
endif()

set(APP ${CPACK_TEMPORARY_INSTALL_DIRECTORY}/${CPACK_PACKAGING_INSTALL_PREFIX})

message(STATUS "Signing the Application")
execute_process(
  COMMAND zsh -c "${CMAKE_CURRENT_LIST_DIR}/codesignApp.zsh ${APP} \"${CPACK_DARWIN_SIGNING_ID}\" ${CPACK_ENTITLEMENTS_PLIST}"
  RESULT_VARIABLE CS_OUT)

if(NOT CS_OUT EQUAL 0)
  set(APP_SIGN_FAILURE TRUE)
  message(FATAL_ERROR "App Code Signing Failure")
endif()

if(NOT DARWIN_NOTARIZATION_KEYCHAIN STREQUAL "")
  message(STATUS "Notarizing the Application")
  execute_process(
    COMMAND zsh -c "${CMAKE_CURRENT_LIST_DIR}/notarizeFiles.zsh ${APP} ${CPACK_DARWIN_NOTARIZATION_KEYCHAIN}"
    RESULT_VARIABLE NOTA_OUT)
endif()

if(NOT NOTA_OUT EQUAL 0)
  set(APP_NOTARIZATION_FAILURE TRUE)
  message(FATAL_ERROR "App Notarization Signing Failure")
endif()