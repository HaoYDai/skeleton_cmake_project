#include <grpcpp/grpcpp.h>
#include "CmdControl.grpc.pb.h"

using grpc::Server;
using grpc::ServerBuilder;
using grpc::ServerContext;
using grpc::Status;

class CmdControlServiceImpl final : public CmdControl::Service {
    Status Cmd(ServerContext* context, const CmdRequest* request,
               CmdResponse* response) override {

        // 处理命令逻辑
        switch(request->cmd()) {
            case CmdRequest::REBOOT:
                std::cout << "Received REBOOT command from: " 
                          << request->source_id() << std::endl;
                // 这里添加实际重启逻辑
                response->set_status(CmdResponse::SUCCESS);
                break;

            case CmdRequest::SHUTDOWN:
                std::cout << "Received SHUTDOWN command from: " 
                          << request->source_id() << std::endl;
                // 这里添加实际关机逻辑
                response->set_status(CmdResponse::SUCCESS);
                break;

            default:
                response->set_status(CmdResponse::FAIL);
                std::cerr << "Unknown command received" << std::endl;
        }

        response->set_node_id("server_node_001");
        return Status::OK;
    }
};

void RunServer() {
    std::string server_address("0.0.0.0:50051");
    CmdControlServiceImpl service;

    ServerBuilder builder;
    builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());
    builder.RegisterService(&service);

    std::unique_ptr<Server> server(builder.BuildAndStart());
    std::cout << "Server listening on " << server_address << std::endl;
    server->Wait();
}

int main() {
    RunServer();
    return 0;
}