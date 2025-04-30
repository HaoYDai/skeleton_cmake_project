# Copyright (c) 2025, DarYue Inc.
# All rights reserved.

# Get the current folder name
string(REGEX REPLACE ".*/\(.*\)" "\\1" CUR_DIR ${CMAKE_CURRENT_SOURCE_DIR})

# Set namespace
set_namespace()

add_subdirectory(cmd_control_pb_rpc_client_app)
add_subdirectory(cmd_control_pb_rpc_server_app)
