# Copyright (c) 2025, DarYue Inc.
# All rights reserved.

set_namespace()

if(USE_LOCAL_GRPC_COMPILER)
    add_subdirectory(grpc)
endif()

if(BUILD_WITH_PROTOBUF)
    add_subdirectory(pb)
endif()


