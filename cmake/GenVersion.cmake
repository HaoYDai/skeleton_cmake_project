# Copyright (c) 2025, DarYue Inc.
# All rights reserved.

# Get the current date/time
string(TIMESTAMP BUILD_TIME "%Y-%m-%d %H:%M:%S")

# Replace dashes, spaces, and colons
string(REPLACE "-" "" BUILD_TIME_SAFE ${BUILD_TIME})  # Removes dashes
string(REPLACE " " "" BUILD_TIME_SAFE ${BUILD_TIME_SAFE})  # Removes spaces
string(REPLACE ":" "" BUILD_TIME_SAFE ${BUILD_TIME_SAFE})  # Removes colons

find_package(Git REQUIRED)
if(GIT_FOUND AND EXISTS "${CMAKE_SOURCE_DIR}/.git")
    # Get the latest Git commit hash
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-parse --short=8 HEAD
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_COMMIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # Get the latest tag name
    execute_process(
        COMMAND ${GIT_EXECUTABLE} describe --tags --abbrev=0
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
        RESULT_VARIABLE result
    )
    if (NOT result EQUAL 0)
        set(VERSION "unknown")
    endif()
else()
    set(GIT_COMMIT_HASH "unknown")
    set(VERSION "unknown")
endif()

# Configure a header file to pass the version information to the source code
configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/version.h.in
    ${CMAKE_BINARY_DIR}/generated/version.h
)
