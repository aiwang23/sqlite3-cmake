# sqlite3-cmake

[English](./README.md) | [中文](./README_CN.md)

A small CMake wrapper project for the SQLite3 amalgamation source code.

It provides a convenient way to build:

- `sqlite3.lib` / `libsqlite3.a`
- optional `sqlite3.exe` / `sqlite3` command-line shell
- CMake target: `SQLite::SQLite3`
- installable CMake package with `find_package(SQLite3 CONFIG REQUIRED)` support

> This project is not the official SQLite repository. It only provides a convenient CMake wrapper for the SQLite3 amalgamation source code.

---

## Features

- Supports Windows / Linux / macOS
- Supports integration via `add_subdirectory()`
- Supports integration via `find_package(SQLite3 CONFIG REQUIRED)`
- Supports optional SQLite command-line shell build
- Disables the SQLite load extension API by default
- Builds a static library by default

---

## Directory Structure

```text
sqlite3-cmake/
├── CMakeLists.txt
├── sqlite3.c
├── sqlite3.h
├── sqlite3ext.h
├── shell.c
└── cmake/
    ├── FindSQLite3.cmake
    └── SQLite3Config.cmake.in
```

---

## Using as a Submodule

Place this project inside your project, for example:

```text
third_party/sqlite3-cmake
```

Then add it in your `CMakeLists.txt`:

```cmake
add_subdirectory(third_party/sqlite3-cmake)

target_link_libraries(your_app PRIVATE SQLite::SQLite3)
```

Include SQLite directly in your source code:

```cpp
#include <sqlite3.h>
```

---

## Standalone Build

By default, only the SQLite static library is built:

```powershell
cmake -B build -S .
```

```powershell
cmake --build build --config Debug
```

---

## Building the sqlite3 Command-Line Shell

To build `sqlite3.exe` / `sqlite3`:

```powershell
cmake -B build -S . -DSQLITE_BUILD_SHELL=ON
```

```powershell
cmake --build build --config Debug
```

On Windows, the output is usually located at:

```text
build/Debug/sqlite3.exe
```

With the Ninja generator, the output is usually located at:

```text
build/sqlite3.exe
```

Run it for testing:

```powershell
.\build\Debug\sqlite3.exe
```

After entering the SQLite shell, type:

```sql
.exit
```

to exit.

---

## Installation

You can install the library to a specified directory:

```powershell
cmake -B build -S . -DSQLITE_BUILD_SHELL=ON -DCMAKE_INSTALL_PREFIX=install
```

```powershell
cmake --build build --config Debug
```

```powershell
cmake --install build --config Debug
```

The installed directory will look like this:

```text
install/
├── bin/
│   └── sqlite3.exe
├── include/
│   ├── sqlite3.h
│   └── sqlite3ext.h
└── lib/
    ├── sqlite3.lib
    └── cmake/
        └── SQLite3/
            ├── SQLite3Config.cmake
            ├── SQLite3ConfigVersion.cmake
            └── SQLite3Targets.cmake
```

---

## Using with find_package

After installation, other CMake projects can use it like this:

```cmake
find_package(SQLite3 CONFIG REQUIRED)

add_executable(app main.cpp)

target_link_libraries(app PRIVATE SQLite::SQLite3)
```

Configure the project with the install path:

```powershell
cmake -B build -S . -DCMAKE_PREFIX_PATH=D:/Project/sqlite3-cmake/install
```

---

## Test Code

`main.cpp`:

```cpp
#include <sqlite3.h>

int main()
{
    sqlite3* db = nullptr;

    if (sqlite3_open(":memory:", &db) != SQLITE_OK) {
        return 1;
    }

    sqlite3_close(db);
    return 0;
}
```

---

## CMake Options

| Option                         |          Default | Description                             |
| ------------------------------ | ---------------: | --------------------------------------- |
| `SQLITE_BUILD_SHELL`           |            `OFF` | Build the `sqlite3` command-line shell  |
| `SQLITE_ENABLE_LOAD_EXTENSION` |            `OFF` | Enable the SQLite load extension API    |
| `SQLITE_INSTALL`               |             `ON` | Install the library, headers, and tools |
| `SQLITE_INSTALL_PACKAGE`       |             `ON` | Install the CMake package config files  |
| `SQLITE_INSTALL_EXPORT_SET`    | `SQLite3Targets` | CMake export set name                   |

---

## Example: Build Library Only

```powershell
cmake -B build -S .
```

---

## Example: Build Library and sqlite3.exe

```powershell
cmake -B build -S . -DSQLITE_BUILD_SHELL=ON
```

---

## Example: Install and Use with find_package

```powershell
cmake -B build -S . -DSQLITE_BUILD_SHELL=ON -DCMAKE_INSTALL_PREFIX=install; cmake --build build --config Debug; cmake --install build --config Debug
```

In another project:

```cmake
find_package(SQLite3 CONFIG REQUIRED)

target_link_libraries(app PRIVATE SQLite::SQLite3)
```

---

## License

The CMake build scripts, README, NOTICE, and other wrapper files in this project are licensed under the Apache License 2.0.

The SQLite source files, including `sqlite3.c`, `sqlite3.h`, `sqlite3ext.h`, and `shell.c`, are in the Public Domain.

This project is not the official [SQLite](https://sqlite.org/) repository and does not modify the SQLite source code. It only provides CMake build support for the [SQLite Amalgamation](https://sqlite.org/download.html) source code.
