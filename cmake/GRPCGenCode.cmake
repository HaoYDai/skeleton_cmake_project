# Copyright (c) 2025, DarYue Inc.
# All rights reserved.

find_package(gRPC CONFIG REQUIRED)
message(STATUS "Using gRPC ${gRPC_VERSION}")

find_program(_GRPC_CPP_PLUGIN grpc_cpp_plugin)
find_program(_PROTOC protoc)

# add target for gRPC gen code target for proto path
function(add_grpc_gencode_target_for_proto_path)
  cmake_parse_arguments(ARG "" "TARGET_NAME" "PROTO_PATH;GENCODE_PATH;OPTIONS" ${ARGN})

  if(NOT EXISTS ${ARG_GENCODE_PATH})
    file(MAKE_DIRECTORY ${ARG_GENCODE_PATH})
  endif()

  get_property(PROTOC_NAMESPACE GLOBAL PROPERTY PROTOC_NAMESPACE_PROPERTY)

  if(NOT PROTOC_NAMESPACE)
    set(CUR_PROTOC_NAMESPACE "gRPC")
  else()
    set(CUR_PROTOC_NAMESPACE ${PROTOC_NAMESPACE})
  endif()

  set(GEN_SRCS)
  set(GEN_HDRS)
  set(GRPC_SRCS)
  set(GRPC_HDRS)

  file(GLOB_RECURSE PROTO_FILES ${ARG_PROTO_PATH}/*.proto)
  foreach(PROTO_FILE ${PROTO_FILES})
    string(REGEX REPLACE ".+/(.+)\\..*" "\\1" PROTO_FILE_NAME ${PROTO_FILE})
    set(GEN_SRC "${ARG_GENCODE_PATH}/${PROTO_FILE_NAME}.pb.cc")
    set(GEN_HDR "${ARG_GENCODE_PATH}/${PROTO_FILE_NAME}.pb.h")
    set(GRPC_SRC "${ARG_GENCODE_PATH}/${PROTO_FILE_NAME}.grpc.pb.cc")
    set(GRPC_HDR "${ARG_GENCODE_PATH}/${PROTO_FILE_NAME}.grpc.pb.h")

    list(APPEND GEN_SRCS ${GEN_SRC})
    list(APPEND GEN_HDRS ${GEN_HDR})
    list(APPEND GRPC_SRCS ${GRPC_SRC})
    list(APPEND GRPC_HDRS ${GRPC_HDR})

    add_custom_command(
      OUTPUT ${GEN_SRC} ${GEN_HDR} ${GRPC_SRC} ${GRPC_HDR}
      COMMAND ${_PROTOC} ARGS ${ARG_OPTIONS} 
              --proto_path=${ARG_PROTO_PATH}
              --cpp_out=${ARG_GENCODE_PATH}
              --grpc_out=${ARG_GENCODE_PATH}
              --plugin=protoc-gen-grpc=${_GRPC_CPP_PLUGIN}
              ${PROTO_FILE}
      DEPENDS ${PROTO_FILE} ${_PROTOC} 
      COMMENT "Generating gRPC code for ${PROTO_FILE}"
      VERBATIM)
  endforeach()

  add_library(${ARG_TARGET_NAME} STATIC)

  target_sources(${ARG_TARGET_NAME} PRIVATE ${GEN_SRCS} ${GRPC_SRCS})
  target_sources(${ARG_TARGET_NAME} PUBLIC FILE_SET HEADERS BASE_DIRS ${ARG_GENCODE_PATH} FILES ${GEN_HDRS} ${GRPC_HDRS})
  target_include_directories(${ARG_TARGET_NAME} PUBLIC 
    $<BUILD_INTERFACE:${ARG_GENCODE_PATH}> 
    $<INSTALL_INTERFACE:include/${ARG_TARGET_NAME}>
    ${Protobuf_INCLUDE_DIRS})

  target_link_libraries(${ARG_TARGET_NAME} PUBLIC 
    gRPC::grpc++ 
    protobuf::libprotobuf 
    ${ALL_DEP_PROTO_TARGETS})

  set_target_properties(${ARG_TARGET_NAME} PROPERTIES PROTO_PATH ${ARG_PROTO_PATH})
  set_target_properties(${ARG_TARGET_NAME} PROPERTIES DEP_PROTO_TARGETS "${ALL_DEP_PROTO_TARGETS}")

endfunction()