get_filename_component(_sqlite3_root "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)

if(TARGET sqlite3)
    if(NOT TARGET SQLite::SQLite3)
        add_library(SQLite::SQLite3 ALIAS sqlite3)
    endif()

    set(SQLite3_FOUND TRUE)
    set(SQLite3_INCLUDE_DIR "${_sqlite3_root}")
    set(SQLite3_INCLUDE_DIRS "${_sqlite3_root}")
    set(SQLite3_LIBRARY SQLite::SQLite3)
    set(SQLite3_LIBRARIES SQLite::SQLite3)
    set(SQLite3_VERSION "3")

    return()
endif()

include("${CMAKE_ROOT}/Modules/FindSQLite3.cmake")