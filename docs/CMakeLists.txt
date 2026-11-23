find_program(QDOC_EXECUTABLE
    NAMES qdoc
    HINTS
        "${QT_HOST_PATH}/bin"
        "${Qt6_DIR}/../../../bin"
)

if(NOT QDOC_EXECUTABLE)
    message(FATAL_ERROR
        "QDoc was not found. Install the Qt documentation tools or set QDOC_EXECUTABLE."
    )
endif()

set(DASHBOARD_DOC_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/html")

set(DASHBOARD_QDOC_INCLUDE_ARGS)
foreach(_qt_target IN ITEMS
        Qt6::Core
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::QuickDialogs2
        Qt6::Network
        Qt6::Sql
)
    get_target_property(_qt_includes "${_qt_target}" INTERFACE_INCLUDE_DIRECTORIES)
    foreach(_qt_include IN LISTS _qt_includes)
        if(IS_ABSOLUTE "${_qt_include}" AND EXISTS "${_qt_include}")
            list(APPEND DASHBOARD_QDOC_INCLUDE_ARGS "-I${_qt_include}")
        endif()
    endforeach()
endforeach()

list(APPEND DASHBOARD_QDOC_INCLUDE_ARGS
    "-I${PROJECT_SOURCE_DIR}/src"
    "-I${PROJECT_SOURCE_DIR}/src/dashboard"
    "-I${PROJECT_SOURCE_DIR}/src/chartmodels"
    "-I${PROJECT_SOURCE_DIR}/src/report"
)
list(REMOVE_DUPLICATES DASHBOARD_QDOC_INCLUDE_ARGS)

add_custom_target(DashboardDocumentation
    COMMAND
        "${QDOC_EXECUTABLE}"
        "${CMAKE_CURRENT_SOURCE_DIR}/dynamicdashboard.qdocconf"
        -outputdir "${DASHBOARD_DOC_OUTPUT_DIR}"
        ${DASHBOARD_QDOC_INCLUDE_ARGS}
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    COMMENT "Generating Qt DynamicDashboard documentation with QDoc"
    VERBATIM
)

message(STATUS "QDoc executable: ${QDOC_EXECUTABLE}")
message(STATUS "Documentation output: ${DASHBOARD_DOC_OUTPUT_DIR}")
