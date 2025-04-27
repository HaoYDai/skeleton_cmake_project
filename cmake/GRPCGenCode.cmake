# Copyright (c) 2025, DarYue Inc.
# All rights reserved.

# add target for gRPC gen code target for proto path
function(add_grpc_gencode_target_for_proto_path)
  cmake_parse_arguments(ARG "" "TARGET_NAME" "PROTO_PATH;GENCODE_PATH;OPTIONS" ${ARGN})

  if(NOT EXISTS ${ARG_GENCODE_PATH})
    file(MAKE_DIRECTORY ${ARG_GENCODE_PATH})
  endif()

  get_property(PROTOC_NAMESPACE GLOBAL PROPERTY PROTOC_NAMESPACE_PROPERTY)

  if(NOT PROTOC_NAMESPACE)
    set(CUR_PROTOC_NAMESPACE "protobuf")
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

    # Check if gRPC::grpc_cpp_plugin target exists
    if(NOT TARGET gRPC::grpc_cpp_plugin)
      # Fallback to manually specifying the path to grpc_cpp_plugin
      set(GRPC_CPP_PLUGIN_PATH "${FETCHCONTENT_BASE_DIR}/grpc-build/grpc_cpp_plugin")
      if(NOT EXISTS ${GRPC_CPP_PLUGIN_PATH})
        message(FATAL_ERROR "grpc_cpp_plugin not found at ${GRPC_CPP_PLUGIN_PATH}. Ensure gRPC is built correctly.")
      endif()
      set(GRPC_CPP_PLUGIN ${GRPC_CPP_PLUGIN_PATH})
    else()
      set(GRPC_CPP_PLUGIN $<TARGET_FILE:gRPC::grpc_cpp_plugin>)
    endif()

    add_custom_command(
      OUTPUT ${GEN_SRC} ${GEN_HDR} ${GRPC_SRC} ${GRPC_HDR}
      COMMAND ${CUR_PROTOC_NAMESPACE}::protoc ARGS ${ARG_OPTIONS} 
              --proto_path=${ARG_PROTO_PATH}
              --cpp_out=${ARG_GENCODE_PATH}
              --grpc_out=${ARG_GENCODE_PATH}
              --plugin=protoc-gen-grpc=${GRPC_CPP_PLUGIN}
              ${PROTO_FILE}
      DEPENDS ${PROTO_FILE} ${CUR_PROTOC_NAMESPACE}::protoc
      COMMENT "Generating gRPC code for ${PROTO_FILE}"
      VERBATIM)
  endforeach()

  add_library(${ARG_TARGET_NAME} STATIC)

  target_sources(${ARG_TARGET_NAME} PRIVATE ${GEN_SRCS} ${GRPC_SRCS})
  target_sources(${ARG_TARGET_NAME} PUBLIC FILE_SET HEADERS BASE_DIRS ${ARG_GENCODE_PATH} FILES ${GEN_HDRS} ${GRPC_HDRS})
  target_include_directories(${ARG_TARGET_NAME} PUBLIC 
    $<BUILD_INTERFACE:${ARG_GENCODE_PATH}> 
    $<INSTALL_INTERFACE:include/${ARG_TARGET_NAME}>)

  target_link_libraries(${ARG_TARGET_NAME} PUBLIC 
    protobuf::libprotobuf 
    ${ALL_DEP_PROTO_TARGETS})

  set_target_properties(${ARG_TARGET_NAME} PROPERTIES PROTO_PATH ${ARG_PROTO_PATH})
  set_target_properties(${ARG_TARGET_NAME} PROPERTIES DEP_PROTO_TARGETS "${ALL_DEP_PROTO_TARGETS}")

endfunction()