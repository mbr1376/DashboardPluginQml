cmake_minimum_required(VERSION 3.21)

project(AdvancedControls
    VERSION 1.0.0
    LANGUAGES CXX
)

find_package(Qt6  REQUIRED COMPONENTS
    Quick
    Qml
)

qt_standard_project_setup(REQUIRES 6.8)

add_subdirectory(src/)
add_subdirectory(examples/advancedcontrols)