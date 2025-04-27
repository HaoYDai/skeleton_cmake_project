# Copyright (c) 2025, DarYue Inc.
# All rights reserved.

set_namespace()

if(BUILD_WITH_GRPC)
    add_subdirectory(grpc)
endif()

if(BUILD_WITH_PROTOBUF)
    add_subdirectory(pb)
endif()


