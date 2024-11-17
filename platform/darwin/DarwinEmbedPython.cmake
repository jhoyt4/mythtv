#
# Copyright (C) 2022-2024 John Hoyt
#
# See the file LICENSE_FSF for licensing information.
#
if(NOT APPLE)
  return()
endif()

#
# Assume that if PYTHON_DOT_VERSION is not set, all other input PYTHON_X_X
# variables also need to be set.  Start by locating Python for embedding the 
# correct version from build time
# Assumes these are set before calling
#   PYTHON_ROOT_DIR
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


message(STATUS "Copying Python Resources")
#
# Resources/include
#
file(MAKE_DIRECTORY ${PYTHON_RSRC_INC_DIR}/${PYTHON_EXE})

# Copy pyconfig.h files into Resources/include/pythonX.x
file(COPY "${PYTHON_SOURCE_INC}/pyconfig.h" DESTINATION ${PYTHON_RSRC_INC_DIR}/${PYTHON_EXE})

#
# Resources/lib/
#
file(MAKE_DIRECTORY ${PYTHON_RSRC_LIB_DIR})


# Copy lib files into Resources/lib
file(COPY "${PYTHON_SOURCE_LIB}" DESTINATION ${PYTHON_RSRC_LIB_DIR}/
  PATTERN "pip" EXCLUDE
  PATTERN "py2app" EXCLUDE
  PATTERN "virtualenv" EXCLUDE
  PATTERN "yaml" EXCLUDE)

# If a virtual environment has been created, copy the bin and site-packages
# into the portable python-framework
if(NOT PYTHON_VENV_PATH STREQUAL "")
  file(COPY ${PYTHON_VENV_PATH}/lib/${PYTHON_EXE} DESTINATION ${PYTHON_RSRC_LIB_DIR}
    PATTERN "pip" EXCLUDE
    PATTERN "py2app" EXCLUDE
    PATTERN "virtualenv" EXCLUDE
    PATTERN "yaml" EXCLUDE)
endif()

# Create Resource symlinks
execute_process(
  COMMAND ${CMAKE_COMMAND} -E create_symlink "${PYTHON_EXE}" "${PYTHON_RSRC_LIB_DIR}/python")

#
# Framework (Framework/Python.framework)
#
message(STATUS "Creating the Framework")
# Create the initial Framework structure
file(MAKE_DIRECTORY ${PYTHON_FMWK_DIR} ${PYTHON_FMWK_ROOT} ${PYTHON_FMWK_ROOT}/Resources ${PYTHON_FMWK_INC_DIR}/${PYTHON_EXE})

# Copy the pyconfig.h files into the Python Framework's include dir
file(COPY ${PYTHON_ROOT_DIR}/include/${PYTHON_EXE}/pyconfig.h DESTINATION ${PYTHON_FMWK_INC_DIR}/${PYTHON_EXE}/)

# Copy the Info.plist into Python Framework Resources dir
file(COPY "${PYTHON_ROOT_DIR}/Resources/Info.plist" DESTINATION ${PYTHON_FMWK_ROOT}/Resources)

#
# NOTE: The actual Python library needs be copied after the target is created
#

# Create Framework symlinks
execute_process(
  COMMAND ${CMAKE_COMMAND} -E create_symlink "../../../../Resources/lib" "${PYTHON_FMWK_LIB_DIR}"
  COMMAND ${CMAKE_COMMAND} -E create_symlink "Versions/Current/Python" "${PYTHON_FMWK_DIR}/Python"
  COMMAND ${CMAKE_COMMAND} -E create_symlink "Versions/Current/Resources" "${PYTHON_FMWK_DIR}/Resources"
  COMMAND ${CMAKE_COMMAND} -E create_symlink "${PYTHON_DOT_VERSION}" "${PYTHON_FMWK_DIR}/Versions/Current")

message(STATUS "Copying Python executable")

#
# NOTE:The actual Python executable needs be copied after the target is created
#