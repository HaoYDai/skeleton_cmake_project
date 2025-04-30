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
option(BUILD_WITH_PROTOBUF "Build with protobuf" ON)

option(BUILD_INSTALL "Enable installation" ON)
option(BUILD_EXAMPLES "Build examples" ON)

option(USE_LOCAL_GRPC_COMPILER "use local protoc compiler." ON)
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

set(INSTALL_CONFIG_NAME ${PROJECT_NAME}-config)

# Master project configuration
if(NOT DEFINED MASTER_PROJECT)
  set(MASTER_PROJECT OFF)
  if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    set(MASTER_PROJECT ON)
  endif()
endif()

if(MASTER_PROJECT)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

  set(FETCHCONTENT_BASE_DIR ${CMAKE_SOURCE_DIR}/_deps)
  set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install)

  set(BUILD_SHARED_LIBS OFF)
  set(CMAKE_C_VISIBILITY_PRESET hidden)
  set(CMAKE_C_VISIBILITY_INLINES_HIDDEN ON)
  set(CMAKE_CXX_VISIBILITY_PRESET hidden)
  set(CMAKE_CXX_VISIBILITY_INLINES_HIDDEN ON)

  if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    if(BUILD_TESTS)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --coverage")
      set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --coverage")
    endif()
  endif()

  set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
elseif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
  add_compile_options(/utf-8 /wd4819)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Zc:__cplusplus")
endif()

# Include cmake module
include(NamespaceTool)

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

  if(USE_LOCAL_GRPC_COMPILER)
      include(GetGRPC)
      include(GRPCGenCode)
  endif()
endif()

add_subdirectory(src)

if(BUILD_INSTALL)
  # Install
  install(
    DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/cmake
    DESTINATION ./
    FILES_MATCHING
    PATTERN "*.cmake")

  install(EXPORT ${INSTALL_CONFIG_NAME} DESTINATION lib/cmake/${PROJECT_NAME})
endif()

# Print all options
message("\n  ${PRJ_NAME} CMake Options/Info:")

list(
  APPEND
  ${PRJ_NAME}_vars
  BUILD_WITH_PROTOBUF
  BUILD_INSTALL
  BUILD_EXAMPLES
  USE_LOCAL_PROTOC_COMPILER
  USE_LOCAL_GRPC_COMPILER
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
