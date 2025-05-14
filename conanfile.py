from conan import ConanFile
from conan.tools.cmake import cmake_layout


class ConanBuild(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeDeps", "CMakeToolchain"

    def requirements(self):
        self.requires("grpc/1.69.0")
    
    def build_requirements(self):
        self.tool_requires("grpc/1.69.0")
        self.tool_requires("protobuf/5.27.0")
        self.tool_requires("cmake/3.31.6")

    def layout(self):
        cmake_layout(self,  build_folder=('build/' + self.settings.arch.value))