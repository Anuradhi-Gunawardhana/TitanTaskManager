
cmake_minimum_required(VERSION 3.16)

project(TitanTaskManager VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Core)

qt_standard_project_setup()

qt_add_executable(titan-task-manager
    src/main.cpp
    src/systemmonitor.cpp
    src/thmstate.cpp
    src/thmmonitor.cpp

    include/systemmonitor.h
    include/thmstate.hpp
    include/thmmonitor.h
)

target_include_directories(titan-task-manager PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

qt_add_qml_module(titan-task-manager
    URI TitanTaskManager
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/MetricCard.qml
)

target_link_libraries(titan-task-manager
    PRIVATE
        Qt6::Quick
        Qt6::Core
)
