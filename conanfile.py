from conan import ConanFile
from conan.tools.cmake import cmake_layout
from conan.tools.cmake import CMake


class ConanBuild(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeDeps", "CMakeToolchain"

    def requirements(self):
        self.requires("grpc/1.69.0")
    
    def build_requirements(self):
        self.tool_requires("grpc/1.69.0")
        self.tool_requires("protobuf/5.27.0")
        self.tool_requires("cmake/3.31.6")

    def build(self):
        # bash -c "source ${build_folder}/Release/generators/conanbuild.sh"
        # cmake --preset conan-release
        # cmake --build --preset conan-release
        # bash -c "source ${build_folder}/Release/generators/deactivate_conanbuild.sh"
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def layout(self):
        cmake_layout(self,  build_folder=('build/' + self.settings.arch.value))