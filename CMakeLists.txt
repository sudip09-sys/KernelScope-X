cmake_minimum_required(VERSION 3.21)
project(KernelScopeX VERSION 0.2.0 LANGUAGES CXX)

if(NOT WIN32)
    message(FATAL_ERROR "KernelScope X Phase 1 targets native Windows. Build with MSVC on Windows, not in WSL.")
endif()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)
qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(KernelScopeX WIN32
    app/main.cpp
    src/core/Snapshot.h
    src/core/MonitorController.h
    src/core/MonitorController.cpp
    src/platform/windows/WindowsCollector.h
    src/platform/windows/WindowsCollector.cpp
    src/models/ProcessModel.h
    src/models/ProcessModel.cpp
    src/models/ProcessFilterModel.h
    src/models/ProcessFilterModel.cpp
    src/oslab/SchedulingSimulator.h
    src/oslab/SchedulingSimulator.cpp
)

set_target_properties(KernelScopeX PROPERTIES
    OUTPUT_NAME "KernelScopeX"
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE FALSE
)

# Resource aliases make files loadable as qrc:/qt/qml/KernelScopeX/Main.qml
set_source_files_properties(app/qml/Main.qml PROPERTIES QT_RESOURCE_ALIAS "Main.qml")
foreach(component MetricCard NavigationTab SectionHeader PageScroll)
    set_source_files_properties(app/qml/components/${component}.qml
        PROPERTIES QT_RESOURCE_ALIAS "components/${component}.qml")
endforeach()
foreach(page OverviewPage ProcessesPage DiagnosticsPage OsLabPage)
    set_source_files_properties(app/qml/pages/${page}.qml
        PROPERTIES QT_RESOURCE_ALIAS "pages/${page}.qml")
endforeach()

qt_add_qml_module(KernelScopeX
    URI KernelScopeX
    VERSION 1.0
    QML_FILES
        app/qml/Main.qml
        app/qml/components/MetricCard.qml
        app/qml/components/NavigationTab.qml
        app/qml/components/SectionHeader.qml
        app/qml/components/PageScroll.qml
        app/qml/pages/OverviewPage.qml
        app/qml/pages/ProcessesPage.qml
        app/qml/pages/DiagnosticsPage.qml
        app/qml/pages/OsLabPage.qml
)

target_include_directories(KernelScopeX PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_link_libraries(KernelScopeX PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2
    psapi
)

target_compile_definitions(KernelScopeX PRIVATE
    UNICODE _UNICODE WIN32_LEAN_AND_MEAN NOMINMAX
)
if(MSVC)
    target_compile_options(KernelScopeX PRIVATE /W4 /permissive- /EHsc /utf-8)
endif()

include(CTest)
if(BUILD_TESTING)
    find_package(Qt6 REQUIRED COMPONENTS Test)
    qt_add_executable(KernelScopeTests
        tests/tst_scheduling.cpp
        src/oslab/SchedulingSimulator.h
        src/oslab/SchedulingSimulator.cpp
    )
    target_include_directories(KernelScopeTests PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)
    target_link_libraries(KernelScopeTests PRIVATE Qt6::Core Qt6::Test)
    add_test(NAME SchedulingAlgorithms COMMAND KernelScopeTests)

    qt_add_executable(KernelScopeProcessTests
        tests/tst_processmodel.cpp
        src/models/ProcessModel.h
        src/models/ProcessModel.cpp
        src/models/ProcessFilterModel.h
        src/models/ProcessFilterModel.cpp
    )
    target_include_directories(KernelScopeProcessTests PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)
    target_link_libraries(KernelScopeProcessTests PRIVATE Qt6::Core Qt6::Test)
    add_test(NAME ProcessModels COMMAND KernelScopeProcessTests)
endif()
