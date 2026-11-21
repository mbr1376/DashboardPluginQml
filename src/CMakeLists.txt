set(DASHBOARD_QML_BUILD_DIR
    "${CMAKE_CURRENT_BINARY_DIR}/qml/Dashboard"
)

set_source_files_properties(
    ../qml/Theme.qml
    PROPERTIES
        QT_RESOURCE_ALIAS Theme.qml
        QT_QML_SINGLETON_TYPE TRUE
)

qt_add_library(DashboardPlugin SHARED)

add_library(
    Dashboard::DashboardPlugin
    ALIAS DashboardPlugin
)

target_include_directories(DashboardPlugin
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/dashboard
        ${CMAKE_CURRENT_SOURCE_DIR}/chartmodels
        ${CMAKE_CURRENT_SOURCE_DIR}/report
)

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

target_compile_definitions(DashboardPlugin
    PRIVATE DASHBOARDPLUGIN_LIBRARY
)

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