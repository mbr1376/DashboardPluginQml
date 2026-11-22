# Qt DynamicDashboard

**A reusable, data-driven dashboard library for Qt Quick and QML.**

Qt DynamicDashboard is a reusable Qt Quick library that provides dashboard UI components, data-driven views, charts, tables, and customizable layouts for Qt applications.

The project combines **C++17** and **QML** and is built with **CMake**. It is designed to be integrated into other Qt Quick applications rather than being limited to a single standalone dashboard application.

## Features

- **Reusable QML module** — import the library using `import Dashboard`.
- **Dashboard components** — reusable dashboard views, widgets, cards, tables, and UI components.
- **Dynamic data handling** — work with application data and supported data sources.
- **JSON and CSV support** — load structured data into the dashboard.
- **REST API integration** — retrieve JSON data from HTTP endpoints.
- **C++ integration** — use C++ data models and application-side logic.
- **Charts and visualization** — display data through reusable chart components.
- **Customizable themes** — centralize dashboard appearance and colors.
- **Editable layouts** — customize dashboard widget arrangements.
- **Example applications** — explore different integration and data-loading scenarios.

## Requirements

| Dependency | Requirement |
|---|---|
| Qt | 6.8 or newer |
| CMake | 3.21 or newer |
| C++ standard | C++17 |
| Qt modules | Core, Qml, Quick, QuickControls2, QuickDialogs2, Network, Sql |

The project has been built and tested with Qt 6.10.1 on Linux (GCC 64-bit).

Other operating systems and Qt configurations should be tested before being advertised as officially supported.

## Project Structure

```text
Qt-DynamicDashboard/
├── CMakeLists.txt
├── LICENSE
├── README.md
│
├── cmake/
│   └── DashboardConfig.cmake.in
│
├── src/
│   ├── CMakeLists.txt
│   ├── dashboard/
│   │   ├── dashboard_data_model.h
│   │   ├── dashboard_data_source.h
│   │   ├── dashboard_runtime.h
│   │   ├── database_config.h
│   │   └── user_model.h
│   ├── chartmodels/
│   ├── report/
│   └── *.cpp
│
├── qml/
│   ├── qmldir
│   ├── Theme.qml
│   ├── DashboardBuilder.qml
│   ├── DashboardChart.qml
│   ├── DashboardView.qml
│   ├── DashboardWidget.qml
│   ├── components/
│   └── pages/
│
├── examples/
│   ├── BasicApp/
│   ├── JsonApp/
│   └── RestApiApp/
│
└── tests/
```

## Build the Project

### 1. Configure Qt

Make sure Qt 6.8 or newer and the required Qt modules are installed.

If CMake cannot locate your Qt installation, set `CMAKE_PREFIX_PATH` to the Qt installation directory.

For example, on Linux:

```bash
export CMAKE_PREFIX_PATH="$HOME/Qt/6.10.1/gcc_64"
```

Adjust the path to match your Qt installation.

### 2. Configure the project

From the repository root:

```bash
cmake -S . -B build \
  -DCMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH" \
  -DBUILD_EXAMPLES=ON
```

### 3. Build

```bash
cmake --build build --parallel
```

The project builds the library and, when `BUILD_EXAMPLES` is enabled, its example applications.

## Run the Examples

The repository includes three example applications.

### BasicApp

`examples/BasicApp`

Demonstrates a basic Qt Quick application using the dashboard library.

### JsonApp

`examples/JsonApp`

Demonstrates loading and displaying JSON data.

### RestApiApp

`examples/RestApiApp`

Demonstrates retrieving data from a REST API.

Build and run the example targets from the root build directory:

```bash
cmake --build build --target DashboardExample
cmake --build build --target DashboardJsonExample
cmake --build build --target DashboardRestApiExample
```

Run the generated executables from their build output directories, or launch the corresponding targets through Qt Creator.

## Use the Dashboard in a QML Application

The library exposes the QML module URI:

```qml
import Dashboard
```

A basic usage example:

```qml
import QtQuick
import Dashboard

Window {
    visible: true
    width: 1400
    height: 900

    DashboardView {
        anchors.fill: parent
    }
}
```

This example demonstrates embedding the dashboard view inside a host application's Qt Quick window.

For data loading, layout management, and application integration, refer to the example applications and the library's QML and C++ source files.

## Install and Integrate

The project provides CMake installation and package configuration support.

Configure the installation prefix:

```bash
cmake -S . -B build \
  -DCMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH" \
  -DCMAKE_INSTALL_PREFIX="$HOME/.local"
```

Build and install:

```bash
cmake --build build --parallel
cmake --install build
```

The exported CMake target is:

```cmake
Dashboard::DashboardPlugin
```

A consumer application can use the package configuration and exported target:

```cmake
find_package(Dashboard 1.0 CONFIG REQUIRED)

target_link_libraries(MyApp
    PRIVATE
        Dashboard::DashboardPlugin
)
```

The consumer must also be able to locate the installed QML module. The exact QML import path depends on the installation layout and the configured `CMAKE_INSTALL_LIBDIR`.

## Customization

The QML source tree contains the dashboard's reusable UI components, pages, and theme definitions.

Important locations include:

- `qml/Theme.qml` — shared theme definitions.
- `qml/components/` — reusable interface components.
- `qml/pages/` — dashboard pages.
- `qml/DashboardBuilder.qml` — dashboard building and layout functionality.
- `qml/DashboardChart.qml` — chart presentation.
- `qml/DashboardWidget.qml` — dashboard widget component.

You can use these files as a starting point when adapting the dashboard to your application's design and requirements.

## Contributing

Contributions, bug reports, and suggestions are welcome.

Before submitting a contribution:

1. Check existing issues and discussions.
2. Describe the problem or proposed improvement.
3. Keep changes focused and consistent with the project's architecture.
4. Build the project and test affected examples.
5. Submit a pull request with a clear description of the changes.

Please read `CONTRIBUTING.md` before contributing, once the contribution guidelines are available in the repository.

## License

Qt DynamicDashboard is distributed under the **MIT License**.

See the [LICENSE](LICENSE) file for details.

## Project

**Repository:**  
https://github.com/mbr1376/DashboardPluginQml

**Project name:** Qt DynamicDashboard

**License:** MIT

**Maintainer:** mbr