#
# Copyright (C) 2022-2024 John Hoyt
#
# See the file LICENSE_FSF for licensing information.
#
if(NOT APPLE)
  return()
endif()

#
# Assumes these are set before calling
#   APP_NAME
#   MYTHTV_INSTALL_PREFIX
#   RSRC_DIR
#   PYTHON_ROOT_DIR
#   PYTHON_VERSION
#   PYTHON_DOT_FULLPATH_EXE
#   PYTHON_VERSION
#   PYTHON_DOT_VERSION
#   PYTHON_EXE
#   PYTHON_FMWK_DIR
#   PYTHON_FMWK_ROOT
#   PYTHON_RSRC_INC_DIR
#   PYTHON_RSRC_LIB_DIR
#   PYTHON_FMWK_INC_DIR
#   PYTHON_FMWK_LIB_DIR
#   PYTHON_DEST_EXE
#   PYTHON_FMWK_FULL_DYLIB
#   PYTHON_VENV_PATH
#   PYTHON_SOURCE_EXE
#   PYTHON_SOURCE_INC
#   PYTHON_SOURCE_LIB
#   PYTHON_SOURCE_DYLIB

message(STATUS "Create Python file structure")

# create the necessary file structure
file(MAKE_DIRECTORY ${PYTHON_RSRC_INC_DIR}/${PYTHON_EXE} ${PYTHON_RSRC_LIB_DIR})
file(MAKE_DIRECTORY ${PYTHON_FMWK_DIR} ${PYTHON_FMWK_ROOT} ${PYTHON_FMWK_ROOT}/Resources ${PYTHON_FMWK_INC_DIR}/)

#
# Resources/include
# Copy pyconfig.h files into Resources/include/pythonX.X
file(COPY "${PYTHON_SOURCE_INC}/pyconfig.h" DESTINATION ${PYTHON_RSRC_INC_DIR}/${PYTHON_EXE})

#
# Resources/lib/
#

# not all python files are required in the app bundle.  This list is meant to
# prune known unnecessary files to keep the app bundle size down.
list(APPEND PYTHON_EXCLUDES
  PATTERN "*dist-info*" EXCLUDE
  PATTERN "*ansible*" EXCLUDE
  PATTERN "*lint*" EXCLUDE
  PATTERN "*mark*" EXCLUDE
  PATTERN "*Mark*" EXCLUDE
  PATTERN "*mesonbuild*" EXCLUDE
  PATTERN "*pip*" EXCLUDE
  PATTERN "*py2app*" EXCLUDE
  PATTERN "*rust*" EXCLUDE
  PATTERN "*test*" EXCLUDE
  PATTERN "*venv*" EXCLUDE
  PATTERN "*virtualenv*" EXCLUDE
  PATTERN "*YAML*" EXCLUDE
  PATTERN "*yaml*" EXCLUDE)

if(MACPORTS)
  file(COPY "${PYTHON_SOURCE_LIB}/" DESTINATION ${PYTHON_RSRC_LIB_DIR}
    ${PYTHON_EXCLUDES})
elseif(HOMEBREW)
  # Homebrew symlinks the sites-packages so we need to use shell commands to
  # perform the copy replacing symlinks with real files
  file(COPY "${PYTHON_SOURCE_LIB}/" DESTINATION ${PYTHON_RSRC_LIB_DIR}
    PATTERN "*site-packages*" EXCLUDE
    ${PYTHON_EXCLUDES})
  file(REMOVE ${PYTHON_RSRC_LIB_DIR}/site-packages)
  execute_process(
    COMMAND zsh -c "cp -LRn ${HOMEBREW_PREFIX}/lib/${PYTHON_EXE}/site-packages ${PYTHON_RSRC_LIB_DIR}/site-packages")
endif()

execute_process(
  COMMAND ${CMAKE_COMMAND} -E create_symlink "${PYTHON_EXE}" "${RSRC_DIR}/lib/python"
  COMMAND ${CMAKE_COMMAND} -E create_symlink "${PYTHON_EXE}" "${RSRC_DIR}/lib/python3")

# If a virtual environment has been created, copy the bin and site-packages
# into the portable python-framework
if(PYTHON_VENV_PATH AND NOT PYTHON_VENV_PATH STREQUAL "")
  file(COPY ${PYTHON_VENV_PATH}/ DESTINATION ${PYTHON_RSRC_LIB_DIR}
    ${PYTHON_EXCLUDES})
endif()

# find python .so files located in the Resources directory
execute_process(
    COMMAND zsh -c "find ${PYTHON_RSRC_LIB_DIR} -name \"*.so\""
    OUTPUT_VARIABLE PYTHON_SOS_FOUND
    OUTPUT_STRIP_TRAILING_WHITESPACE)
string(REPLACE "\n" ";" PYTHON_SOS_FOUND ${PYTHON_SOS_FOUND})
list(TRANSFORM PYTHON_SOS_FOUND STRIP)
list(REMOVE_DUPLICATES PYTHON_SOS_FOUND)

#
# Framework (Framework/Python.framework)
#
message(STATUS "Creating the Framework")
# Copy the pyconfig.h files into the Python Framework's include dir
file(COPY ${PYTHON_ROOT_DIR}/include/${PYTHON_EXE}/pyconfig.h DESTINATION ${PYTHON_FMWK_INC_DIR}/)

# Copy the Info.plist into Python Framework Resources dir
file(COPY "${PYTHON_ROOT_DIR}/Resources/Info.plist" DESTINATION ${PYTHON_FMWK_ROOT}/Resources)

# Create Framework symlinks
execute_process(
  COMMAND ${CMAKE_COMMAND} -E create_symlink "../../../../Resources/lib" "${PYTHON_FMWK_LIB_DIR}"
  COMMAND ${CMAKE_COMMAND} -E create_symlink "Versions/Current/Python" "${PYTHON_FMWK_DIR}/Python"
  COMMAND ${CMAKE_COMMAND} -E create_symlink "Versions/Current/Resources" "${PYTHON_FMWK_DIR}/Resources"
  COMMAND ${CMAKE_COMMAND} -E create_symlink "${PYTHON_DOT_VERSION}" "${PYTHON_FMWK_DIR}/Versions/Current")

#
# Copy in the python library and executables
# NOTE: The actual Python library and executable need be copied post_build
#
add_custom_command(
  TARGET ${APP_NAME} POST_BUILD
  COMMENT "Copying in python library and executable"
  COMMAND ${CMAKE_COMMAND} -E copy_if_different "${PYTHON_SOURCE_DYLIB}" "${PYTHON_FMWK_FULL_DYLIB}"
  COMMAND ${CMAKE_COMMAND} -E copy_if_different "${PYTHON_SOURCE_EXE}" "${PYTHON_DEST_EXE}")


# The python executable needs its linked libraries updated to the embedded framework
# use otool to find the old links and install_name_tool to update them
execute_process(
  COMMAND zsh -c "otool -L \"${PYTHON_SOURCE_EXE}\" | grep -e 'Python (' | sed 's@\ (.*@@'"
    OUTPUT_VARIABLE OTOOL_OUT
    OUTPUT_STRIP_TRAILING_WHITESPACE)
string(REPLACE "\t" "" OTOOL_OUT ${OTOOL_OUT})
add_custom_command(
  TARGET ${APP_NAME} POST_BUILD
  COMMENT "Update the python executable to use the embedded framework"
  COMMAND install_name_tool -change ${OTOOL_OUT} "@executable_path/../Frameworks/Python.framework/Versions/${PYTHON_DOT_VERSION}/Python" ${PYTHON_DEST_EXE})
