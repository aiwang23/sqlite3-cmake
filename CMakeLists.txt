cmake_minimum_required(VERSION 3.20)

project(sqlite3-cmake
        VERSION 3.53.1
        LANGUAGES C
)

# ============================================================
# Options
# ============================================================

# 是否构建 sqlite3 命令行工具，也就是 sqlite3.exe
option(SQLITE_BUILD_SHELL "Build sqlite3 command line shell" OFF)

# 是否启用 SQLite load extension API
# 默认关闭，更安全，也避免 shell.c 和 sqlite3.c 宏不一致导致链接错误
option(SQLITE_ENABLE_LOAD_EXTENSION "Enable SQLite load extension API" OFF)

# 是否安装 sqlite3 库、头文件、命令行工具
option(SQLITE_INSTALL "Install sqlite3 library, headers and tools" ON)

# 是否安装 CMake package config 文件，用于 find_package(SQLite3 CONFIG REQUIRED)
option(SQLITE_INSTALL_PACKAGE "Install SQLite3 CMake package config files" ON)

# 导出 target set 名字
# 普通独立使用默认 SQLite3Targets
# 如果嵌入 sqlite_orm，并且需要放入同一个 export set，可以在父项目里覆盖它
set(SQLITE_INSTALL_EXPORT_SET "SQLite3Targets" CACHE STRING "SQLite install export set name")


# ============================================================
# Library: sqlite3
# ============================================================

add_library(sqlite3 STATIC
        sqlite3.c
)

# 提供标准 CMake target 名字
# 其他项目可以直接 target_link_libraries(xxx PRIVATE SQLite::SQLite3)
add_library(SQLite::SQLite3 ALIAS sqlite3)

# 安装导出后，target 名字变成 SQLite::SQLite3
set_target_properties(sqlite3 PROPERTIES
        EXPORT_NAME SQLite3
)

target_include_directories(sqlite3 PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}>
        $<INSTALL_INTERFACE:include>
)

target_compile_definitions(sqlite3 PRIVATE
        SQLITE_THREADSAFE=1
)

if(NOT SQLITE_ENABLE_LOAD_EXTENSION)
        target_compile_definitions(sqlite3 PRIVATE
                SQLITE_OMIT_LOAD_EXTENSION
        )
endif()

if(UNIX AND NOT APPLE)
        find_package(Threads REQUIRED)
        target_link_libraries(sqlite3 PUBLIC Threads::Threads)
endif()


# ============================================================
# Executable: sqlite3 command line shell
# ============================================================

if(SQLITE_BUILD_SHELL)
        add_executable(sqlite3_cli
                shell.c
        )

        target_link_libraries(sqlite3_cli PRIVATE
                sqlite3
        )

        target_include_directories(sqlite3_cli PRIVATE
                ${CMAKE_CURRENT_LIST_DIR}
        )

        # shell.c 和 sqlite3.c 必须保持这个宏一致
        # 否则会出现 sqlite3_load_extension / sqlite3_enable_load_extension 链接错误
        if(NOT SQLITE_ENABLE_LOAD_EXTENSION)
                target_compile_definitions(sqlite3_cli PRIVATE
                        SQLITE_OMIT_LOAD_EXTENSION
                )
        endif()

        # target 名字叫 sqlite3_cli，避免和 sqlite3 library 冲突
        # 但最终输出文件名叫 sqlite3.exe / sqlite3
        set_target_properties(sqlite3_cli PROPERTIES
                OUTPUT_NAME sqlite3
        )
endif()


# ============================================================
# Install
# ============================================================

include(GNUInstallDirs)

if(SQLITE_INSTALL)
        install(TARGETS sqlite3
                EXPORT ${SQLITE_INSTALL_EXPORT_SET}
                ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
                LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
                RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        )

        if(SQLITE_BUILD_SHELL)
                install(TARGETS sqlite3_cli
                        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
                )
        endif()

        install(FILES
                sqlite3.h
                sqlite3ext.h
                DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        )
endif()


# ============================================================
# CMake package config
# Enables:
#   find_package(SQLite3 CONFIG REQUIRED)
#   target_link_libraries(app PRIVATE SQLite::SQLite3)
# ============================================================

if(SQLITE_INSTALL AND SQLITE_INSTALL_PACKAGE)
        include(CMakePackageConfigHelpers)

        set(SQLITE_CMAKE_CONFIG_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/SQLite3")

        configure_package_config_file(
                "${CMAKE_CURRENT_LIST_DIR}/cmake/SQLite3Config.cmake.in"
                "${CMAKE_CURRENT_BINARY_DIR}/SQLite3Config.cmake"
                INSTALL_DESTINATION "${SQLITE_CMAKE_CONFIG_DIR}"
        )

        write_basic_package_version_file(
                "${CMAKE_CURRENT_BINARY_DIR}/SQLite3ConfigVersion.cmake"
                VERSION ${PROJECT_VERSION}
                COMPATIBILITY SameMajorVersion
        )

        install(EXPORT ${SQLITE_INSTALL_EXPORT_SET}
                FILE SQLite3Targets.cmake
                NAMESPACE SQLite::
                DESTINATION "${SQLITE_CMAKE_CONFIG_DIR}"
        )

        install(FILES
                "${CMAKE_CURRENT_BINARY_DIR}/SQLite3Config.cmake"
                "${CMAKE_CURRENT_BINARY_DIR}/SQLite3ConfigVersion.cmake"
                DESTINATION "${SQLITE_CMAKE_CONFIG_DIR}"
        )
endif()


# ============================================================
# FindSQLite3.cmake support
# Allows parent projects to use custom cmake/FindSQLite3.cmake
# ============================================================

list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

if(NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
        set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)
endif()