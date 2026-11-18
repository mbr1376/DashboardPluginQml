find_package(Qt6 REQUIRED COMPONENTS Quick Test)

qt_add_executable(tst_dynamicdashboard
    tst_dynamicdashboard.cpp
)

target_link_libraries(tst_dynamicdashboard
    PRIVATE
        Qt6::Quick
        Qt6::Test
)

add_test(NAME tst_dynamicdashboard COMMAND tst_dynamicdashboard)