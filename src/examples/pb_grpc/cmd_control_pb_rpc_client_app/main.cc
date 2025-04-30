#include <grpcpp/grpcpp.h>
#include "CmdControl.grpc.pb.h"

using grpc::Channel;
using grpc::ClientContext;
using grpc::Status;

class CmdControlClient {
public:
    CmdControlClient(std::shared_ptr<Channel> channel)
        : stub_(CmdControl::NewStub(channel)) {}

    CmdResponse SendCommand(CmdRequest::Cmd cmd, const std::string& source_id) {
        CmdRequest request;
        request.set_cmd(cmd);
        request.set_source_id(source_id);

        CmdResponse response;
        ClientContext context;

        Status status = stub_->Cmd(&context, request, &response);

        if (status.ok()) {
            std::cout << "Command executed successfully. Node: " 
                      << response.node_id() 
                      << ", Status: " << response.status() 
                      << std::endl;
        } else {
            std::cerr << "RPC failed: " << status.error_message() << std::endl;
        }
        return response;
    }

private:
    std::unique_ptr<CmdControl::Stub> stub_;
};

int main() {
    std::string target_address("localhost:50051");
    CmdControlClient client(
        grpc::CreateChannel(target_address, grpc::InsecureChannelCredentials())
    );

    // 发送示例命令
    auto response = client.SendCommand(
        CmdRequest::REBOOT, 
        "client_001"
    );

    return 0;
}