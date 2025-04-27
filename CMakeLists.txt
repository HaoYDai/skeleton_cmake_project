# Copyright (c) 2025, DarYue Inc.
# All rights reserved.

cmake_minimum_required(VERSION 3.24)

set(PRJ_NAME tmp)

project(${PRJ_NAME} LANGUAGES C CXX)

# Prevent variables from being reset by option
# This setting allows predefined variables to take precedence for FetchContent_MakeAvailable()
# See: https://cmake.org/cmake/help/latest/policy/CMP0077.htmlset(CMAKE_POLICY_DEFAULT_CMP0077 NEW)
set(CMAKE_POLICY_DEFAULT_CMP0077 NEW)

# Set cmake path
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(CMakeDependentOption)

# Some option
option(BUILD_WITH_GRPC "Build gRPC" ON)

cmake_dependent_option(BUILD_WITH_PROTOBUF "Build with protobuf" OFF "BUILD_WITH_GRPC" ON)

option(USE_LOCAL_PROTOC_COMPILER "use local protoc compiler." OFF)
option(USE_PROTOC_PYTHON "use protoc python." OFF)

# Some necessary settings
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Set default build type as Release
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

set(FETCHCONTENT_BASE_DIR ${CMAKE_SOURCE_DIR}/_deps)

# Include cmake module
include(NamespaceTool)

# include(GetProtobuf)
if(BUILD_WITH_GRPC)
    include(GetGRPC)
    include(GRPCGenCode)
endif()

if(BUILD_WITH_PROTOBUF)
    include(GetProtobuf)
    include(ProtobufGenCode)

    if(USE_LOCAL_PROTOC_COMPILER)
        if(NOT Protobuf_PROTOC_EXECUTABLE)
            find_program(PROTOC_EXECUTABLE protoc)
            if(NOT PROTOC_EXECUTABLE)
                message(FATAL_ERROR "USE_LOCAL_PROTOC_COMPILER is ON, but can not find protoc compiler, " #
                            "please install protoc and make it available in your PATH, or set Protobuf_PROTOC_EXECUTABLE to protoc path")
            endif()
            message(STATUS "Found local protoc compiler: ${PROTOC_EXECUTABLE}")
            set(Protobuf_PROTOC_EXECUTABLE
                ${PROTOC_EXECUTABLE}
                CACHE STRING "Path to local protoc compiler.")
        endif()

        add_executable(${PRJ_NAME}::protoc IMPORTED GLOBAL)
        set_target_properties(${PRJ_NAME}::protoc PROPERTIES IMPORTED_LOCATION ${Protobuf_PROTOC_EXECUTABLE})
        set_property(GLOBAL PROPERTY PROTOC_NAMESPACE_PROPERTY "${PRJ_NAME}")
    endif()

    if(USE_PROTOC_PYTHON)
        find_package(Python3 REQUIRED)
    endif()
endif()

add_subdirectory(src)

# Print all options
message("\n  ${PRJ_NAME} CMake Options/Info:")

list(
  APPEND
  ${PRJ_NAME}_vars
  BUILD_WITH_GRPC
  BUILD_WITH_PROTOBUF
  USE_LOCAL_PROTOC_COMPILER
  USE_PROTOC_PYTHON
)

foreach(var ${${PRJ_NAME}_vars})
  string(LENGTH ${var} var_length)
  math(EXPR padding_length "40 - ${var_length}")
  if(padding_length GREATER 0)
    string(REPEAT "." ${padding_length} padding)
  else()
    set(padding "")
  endif()
  message("         ${var}${padding}: ${${var}}")
endforeach()
