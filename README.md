# sqlite3-cmake

一个给 SQLite3 amalgamation 源码提供 CMake 构建支持的小项目。

它可以方便地生成：

- `sqlite3.lib` / `libsqlite3.a`
- 可选的 `sqlite3.exe` / `sqlite3` 命令行工具
- CMake target：`SQLite::SQLite3`
- 安装后的 CMake package，支持 `find_package(SQLite3 CONFIG REQUIRED)`

> 本项目不是 SQLite 官方仓库，只是为 SQLite3 amalgamation 源码提供一个更方便的 CMake 包装。

---

## 功能

- 支持 Windows / Linux / macOS
- 支持 `add_subdirectory()` 方式集成
- 支持 `find_package(SQLite3 CONFIG REQUIRED)` 方式集成
- 支持可选构建 SQLite 命令行工具
- 默认关闭 SQLite load extension API
- 默认构建静态库

---

## 目录结构

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

## 作为子模块使用

把本项目放到你的工程中，例如：

```text
third_party/sqlite3-cmake
```

然后在你的 `CMakeLists.txt` 中：

```cmake
add_subdirectory(third_party/sqlite3-cmake)

target_link_libraries(your_app PRIVATE SQLite::SQLite3)
```

代码中直接包含：

```cpp
#include <sqlite3.h>
```

---

## 单独编译

默认只编译 SQLite 静态库：

```powershell
cmake -B build -S .
```

```powershell
cmake --build build --config Debug
```

---

## 构建 sqlite3 命令行工具

如果需要生成 `sqlite3.exe` / `sqlite3`：

```powershell
cmake -B build -S . -DSQLITE_BUILD_SHELL=ON
```

```powershell
cmake --build build --config Debug
```

Windows 下生成位置通常是：

```text
build/Debug/sqlite3.exe
```

Ninja 生成器下通常是：

```text
build/sqlite3.exe
```

运行测试：

```powershell
.\build\Debug\sqlite3.exe
```

进入 SQLite shell 后可以输入：

```sql
.exit
```

退出。

---

## 安装

可以安装到指定目录：

```powershell
cmake -B build -S . -DSQLITE_BUILD_SHELL=ON -DCMAKE_INSTALL_PREFIX=install
```

```powershell
cmake --build build --config Debug
```

```powershell
cmake --install build --config Debug
```

安装后目录结构类似：

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

## 使用 find_package 集成

安装后，其他 CMake 项目可以这样使用：

```cmake
find_package(SQLite3 CONFIG REQUIRED)

add_executable(app main.cpp)

target_link_libraries(app PRIVATE SQLite::SQLite3)
```

配置项目时指定安装路径：

```powershell
cmake -B build -S . -DCMAKE_PREFIX_PATH=D:/Project/sqlite3-cmake/install
```

---

## 测试代码

`main.cpp`：

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

## CMake 选项

| 选项                             |              默认值 | 说明                             |
| ------------------------------ | ---------------: | ------------------------------ |
| `SQLITE_BUILD_SHELL`           |            `OFF` | 是否构建 `sqlite3` 命令行工具           |
| `SQLITE_ENABLE_LOAD_EXTENSION` |            `OFF` | 是否启用 SQLite load extension API |
| `SQLITE_INSTALL`               |             `ON` | 是否安装库、头文件和工具                   |
| `SQLITE_INSTALL_PACKAGE`       |             `ON` | 是否安装 CMake package config      |
| `SQLITE_INSTALL_EXPORT_SET`    | `SQLite3Targets` | CMake export set 名称            |

---

## 示例：只构建库

```powershell
cmake -B build -S .
```

---

## 示例：构建库和 sqlite3.exe

```powershell
cmake -B build -S . -DSQLITE_BUILD_SHELL=ON
```

---

## 示例：安装并给其他项目 find_package 使用

```powershell
cmake -B build -S . -DSQLITE_BUILD_SHELL=ON -DCMAKE_INSTALL_PREFIX=install; cmake --build build --config Debug; cmake --install build --config Debug
```

其他项目：

```cmake
find_package(SQLite3 CONFIG REQUIRED)

target_link_libraries(app PRIVATE SQLite::SQLite3)
```

---

## 许可证

本项目中的 CMake 构建脚本、README、NOTICE 等包装代码使用 Apache License 2.0。

SQLite 源码文件，包括 `sqlite3.c`、`sqlite3.h`、`sqlite3ext.h`、`shell.c`，属于 Public Domain。

本项目不是 [SQLite](https://sqlite.org/) 官方仓库，也不修改 SQLite 源码，只是为 [SQLite3 amalgamation](https://sqlite.org/download.html) 源码提供 CMake 构建支持。