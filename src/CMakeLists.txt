# Copyright (c) 2025, DarYue Inc.
# All rights reserved.

set_root_namespace("${PRJ_NAME}")

add_subdirectory(protocols)

if(BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()