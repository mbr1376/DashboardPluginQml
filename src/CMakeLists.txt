
set(DASHBOARD_QML_BUILD_DIR
    "${CMAKE_CURRENT_BINARY_DIR}/qml/Dashboard"
)

# --------------------------------------------------
# QML Resource Aliases
# --------------------------------------------------

set_source_files_properties(
    ../qml/Theme.qml
    PROPERTIES
        QT_RESOURCE_ALIAS Theme.qml
        QT_QML_SINGLETON_TYPE TRUE
)

set_source_files_properties(
    ../qml/DashboardView.qml
    PROPERTIES QT_RESOURCE_ALIAS DashboardView.qml
)

set_source_files_properties(
    ../qml/DashboardBuilder.qml
    PROPERTIES QT_RESOURCE_ALIAS DashboardBuilder.qml
)

set_source_files_properties(
    ../qml/DashboardWidget.qml
    PROPERTIES QT_RESOURCE_ALIAS DashboardWidget.qml
)

set_source_files_properties(
    ../qml/DashboardChart.qml
    PROPERTIES QT_RESOURCE_ALIAS DashboardChart.qml
)

set_source_files_properties(
    ../qml/components/Sidebar.qml
    PROPERTIES QT_RESOURCE_ALIAS components/Sidebar.qml
)

set_source_files_properties(
    ../qml/components/TopBar.qml
    PROPERTIES QT_RESOURCE_ALIAS components/TopBar.qml
)

set_source_files_properties(
    ../qml/components/StatCard.qml
    PROPERTIES QT_RESOURCE_ALIAS components/StatCard.qml
)

set_source_files_properties(
    ../qml/components/DataTable.qml
    PROPERTIES QT_RESOURCE_ALIAS components/DataTable.qml
)

set_source_files_properties(
    ../qml/components/SettingsDialog.qml
    PROPERTIES QT_RESOURCE_ALIAS components/SettingsDialog.qml
)

set_source_files_properties(
    ../qml/pages/DashboardPage.qml
    PROPERTIES QT_RESOURCE_ALIAS pages/DashboardPage.qml
)

set_source_files_properties(
    ../qml/pages/AnalyticsPage.qml
    PROPERTIES QT_RESOURCE_ALIAS pages/AnalyticsPage.qml
)

set_source_files_properties(
    ../qml/pages/ReportsPage.qml
    PROPERTIES QT_RESOURCE_ALIAS pages/ReportsPage.qml
)

set_source_files_properties(
    ../qml/pages/UsersPage.qml
    PROPERTIES QT_RESOURCE_ALIAS pages/UsersPage.qml
)

# --------------------------------------------------
# Dashboard Plugin Library
# --------------------------------------------------

qt_add_library(DashboardPlugin SHARED)

add_library(
    Dashboard::DashboardPlugin
    ALIAS DashboardPlugin
)

# --------------------------------------------------
# Include Directories
# --------------------------------------------------

target_include_directories(DashboardPlugin
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>

    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/dashboard
        ${CMAKE_CURRENT_SOURCE_DIR}/chartmodels
        ${CMAKE_CURRENT_SOURCE_DIR}/report
)

# --------------------------------------------------
# QML Module
# --------------------------------------------------

qt_add_qml_module(DashboardPlugin
    URI Dashboard
    VERSION 1.0

    OUTPUT_DIRECTORY
        "${DASHBOARD_QML_BUILD_DIR}"

    SOURCES
    dashboard/dashboard_data_model.h
        dashboard_data_model.cpp

        dashboard/dashboard_data_source.h
        dashboard_data_source.cpp

        dashboard/user_model.h
        user_model.cpp

        dashboard/database_config.h
        database_config.cpp

        dashboard/dashboard_runtime.h
        dashboard_runtime.cpp

        report/report_engine.h
        report/report_engine.cpp

        chartmodels/linechartitem.h
        chartmodels/linechartitem.cpp

        chartmodels/donutchartitem.h
        chartmodels/donutchartitem.cpp
    QML_FILES
        ../qml/Theme.qml

        ../qml/DashboardView.qml
        ../qml/DashboardBuilder.qml
        ../qml/DashboardWidget.qml
        ../qml/DashboardChart.qml

        ../qml/components/Sidebar.qml
        ../qml/components/TopBar.qml
        ../qml/components/StatCard.qml
        ../qml/components/DataTable.qml
        ../qml/components/SettingsDialog.qml

        ../qml/pages/DashboardPage.qml
        ../qml/pages/AnalyticsPage.qml
        ../qml/pages/ReportsPage.qml
        ../qml/pages/UsersPage.qml
)

# --------------------------------------------------
# Link Libraries
# --------------------------------------------------

target_link_libraries(DashboardPlugin
    PUBLIC
        Qt6::Core
        Qt6::Qml
        Qt6::Quick

    PRIVATE
        Qt6::QuickControls2
        Qt6::QuickDialogs2
        Qt6::Network
        Qt6::Sql
)

target_compile_definitions(DashboardPlugin
    PRIVATE
        DASHBOARDPLUGIN_LIBRARY
)
