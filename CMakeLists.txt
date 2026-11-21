
cmake_minimum_required(VERSION 3.21)

project(DynamicDashboard
    VERSION 1.0.0
    DESCRIPTION "Reusable Qt Quick Dashboard Library"
    LANGUAGES CXX
)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
include(CTest)

find_package(Qt6 6.8 REQUIRED COMPONENTS
    Core
    Qml
    Quick
    QuickControls2
    QuickDialogs2
    Network
    Sql
)

qt_standard_project_setup(REQUIRES 6.8)

if(COMMAND qt_policy)
    qt_policy(SET QTP0001 NEW)
endif()

option(BUILD_EXAMPLES "Build example applications" ON)

add_subdirectory(src)

if(BUILD_EXAMPLES)
    add_subdirectory(examples/BasicApp)
    add_subdirectory(examples/JsonApp)
    add_subdirectory(examples/RestApiApp)
endif()

# QML import path for build-tree examples
set(DASHBOARD_QML_IMPORT_PATH
    "${CMAKE_BINARY_DIR}/src/qml"
    CACHE PATH "Dashboard QML import path"
)

# Package configuration
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/DashboardConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/DashboardConfig.cmake"
    INSTALL_DESTINATION
        "${CMAKE_INSTALL_LIBDIR}/cmake/Dashboard"
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/DashboardConfigVersion.cmake"
    VERSION "${PROJECT_VERSION}"
    COMPATIBILITY SameMajorVersion
)

install(
    FILES
        "${CMAKE_CURRENT_BINARY_DIR}/DashboardConfig.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/DashboardConfigVersion.cmake"
    DESTINATION
        "${CMAKE_INSTALL_LIBDIR}/cmake/Dashboard"
)
