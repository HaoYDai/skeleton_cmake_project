# Copyright (c) 2025, DarYue Inc.
# All rights reserved.

message(STATUS "get gRPC ...")

# Find gRPC installation
# Looks for gRPCConfig.cmae file installed by gRPC's cmake installation.
find_package(gRPC CONFIG REQUIRED)
message(STATUS "Using gRPC ${gRPC_VERSION}")


function(get_grpc)
  set(_GRPC_GRPCPP gRPC::grpc++)

  if(CMAKE_CROSSCOMPILING)
    find_program(_GRPC_CPP_PLUGIN_EXECUTABLE grpc_cpp_plugin)
  else()
    set(_GRPC_CPP_PLUGIN_EXECUTABLE $<TARGET_FILE:gRPC::grpc_cpp_plugin>)
  endif()

endfunction()

get_grpc()