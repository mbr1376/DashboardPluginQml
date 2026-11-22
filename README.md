# Qt DynamicDashboard

**A reusable, data-driven dashboard library for Qt Quick and QML.**

Qt DynamicDashboard is a Qt Quick library that provides reusable dashboard views, widgets, charts, data tables, and configurable layouts for Qt applications.

The project combines C++17 and QML. Its QML module can be imported with `import Dashboard`, while its C++ classes provide data models, data loading, reporting, and application-side integration.

## Features

- **Reusable dashboard UI** — Embed `DashboardView` in an existing Qt Quick application.
- **QML module** — Import dashboard components using `import Dashboard`.
- **Dynamic data** — Display data supplied by a C++ model or directly through QML.
- **JSON support** — Load JSON arrays and objects containing `data` or `rows` arrays.
- **CSV support** — Load CSV data with a header row and quoted fields.
- **Local file loading** — Load local JSON and CSV files.
- **REST API support** — Retrieve JSON data from HTTP or HTTPS endpoints, with optional Bearer authentication.
- **Charts and tables** — Use line, bar, area, scatter, pie, donut, and table widgets.
- **Editable layouts** — Configure and restore dashboard widget layouts.
- **Reporting** — Analyze fields, apply filters, group records, and calculate aggregations.
- **Customizable appearance** — Use the shared theme definitions and QML components as a starting point for customization.
- **Example applications** — Explore basic integration, JSON loading, and REST API usage.

## Requirements

| Component | Requirement |
|---|---|
| CMake | 3.21 or newer |
| C++ | C++17 |
| Qt for the library | Qt 6.8 or newer |
| Qt for all three examples | Qt 6.10 or newer |

Required Qt modules:

- Core
- Qml
- Quick
- QuickControls2
- QuickDialogs2
- Network
- Sql

The project has been tested with **Qt 6.10.1 on Linux (GCC 64-bit)**.

**Note:** The root project accepts Qt 6.8, but `examples/BasicApp` explicitly requests Qt 6.10. To build the complete project with all examples, use Qt 6.10 or newer. To configure the library without the examples, set `BUILD_EXAMPLES=OFF`.

## Project Structure

```text
DashboardPluginQml/
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
│   │   ├── linechartitem.h
│   │   └── donutchartitem.h
│   ├── report/
│   │   └── report_engine.h
│   └── *.cpp
│
├── qml/
│   ├── qmldir
│   ├── Theme.qml
│   ├── DashboardView.qml
│   ├── DashboardBuilder.qml
│   ├── DashboardWidget.qml
│   ├── DashboardChart.qml
│   ├── components/
│   └── pages/
│
├── examples/
│   ├── BasicApp/
│   ├── JsonApp/
│   └── RestApiApp/
│
└── tests/
    ├── CMakeLists.txt
    └── tst_dynamicdashboard.qml
```

## Build from Source

### 1. Configure the Qt installation

Set `CMAKE_PREFIX_PATH` to your Qt installation directory.

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

To configure without the example applications:

```bash
cmake -S . -B build \
  -DCMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH" \
  -DBUILD_EXAMPLES=OFF
```

Then build:

```bash
cmake --build build --parallel
```

## Example Applications

The repository contains three example applications.

### BasicApp

Path: `examples/BasicApp`

Demonstrates:

- Embedding `DashboardView` in a Qt Quick application.
- Supplying data through the C++ `DashboardDataModel`.
- Registering a custom theme.
- Saving and restoring dashboard layouts using `QSettings`.

Build:

```bash
cmake --build build --target DashboardExample
```

Run on Linux:

```bash
./build/examples/BasicApp/bin/DashboardExample
```

### JsonApp

Path: `examples/JsonApp`

Demonstrates loading JSON data into the dashboard through the QML `loadJson()` function.

Build:

```bash
cmake --build build --target DashboardJsonExample
```

Run on Linux:

```bash
./build/examples/JsonApp/bin/DashboardJsonExample
```

### RestApiApp

Path: `examples/RestApiApp`

Demonstrates retrieving JSON data from an HTTP or HTTPS endpoint. The example includes an optional Bearer token field.

Build:

```bash
cmake --build build --target DashboardRestApiExample
```

Run on Linux:

```bash
./build/examples/RestApiApp/bin/DashboardRestApiExample
```

## Using the Dashboard in QML

The QML module URI is:

```qml
import Dashboard
```

A basic application can embed the dashboard as follows:

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

`DashboardView` provides sample data when no external model or data has been supplied.

### DashboardView API

The main QML component exposes the following properties:

| Property | Description |
|---|---|
| `dataModel` | Optional Qt item model used as the data source |
| `dashboardLayout` | Dashboard widget layout |
| `loading` | Indicates whether a data request is in progress |
| `dataRows` | Current dashboard data rows |

Available functions:

| Function | Description |
|---|---|
| `setData(rows)` | Set dashboard data directly |
| `setDataModel(model)` | Set a Qt item model as the source |
| `loadJson(json)` | Load JSON data |
| `loadCsv(csv)` | Load CSV data |
| `loadFile(url)` | Load a local JSON or CSV file |
| `loadRest(url, bearerToken)` | Retrieve JSON data from an HTTP or HTTPS endpoint |
| `setLayout(layout)` | Apply a dashboard layout |

Available signals include:

- `layoutChanged(layout)`
- `saveLayoutRequested(layout)`
- `dataLoadFailed(message)`
- `reportGenerated(report)`
- `reportExportRequested(fileName, csv)`

## Data Sources

### JSON

JSON input can be either an array of objects:

```json
[
    { "category": "Online", "sales": 240 },
    { "category": "Retail", "sales": 185 }
]
```

Or an object containing a `data` or `rows` array:

```json
{
    "data": [
        { "category": "Online", "sales": 240 },
        { "category": "Retail", "sales": 185 }
    ]
}
```

Each row must be a JSON object.

### CSV

CSV input must contain a header row followed by at least one data row.

```csv
category,sales,orders
Online,240,120
Retail,185,94
Wholesale,310,61
```

Quoted fields are supported.

### REST API

The dashboard can retrieve JSON data from HTTP and HTTPS endpoints. The response must contain a JSON array or an object with a `data` or `rows` array.

Example:

```qml
DashboardView {
    id: dashboard

    Component.onCompleted: {
        dashboard.loadRest(
            "https://example.com/api/data",
            ""
        )
    }

    onDataLoadFailed: function(message) {
        console.log("Data loading failed:", message)
    }
}
```

The second argument is an optional Bearer token.

### C++ Data Model

The library provides `DashboardDataModel`, a C++ `QAbstractListModel` implementation.

Header:

```cpp
#include <dashboard/dashboard_data_model.h>
```

Example:

```cpp
DashboardDataModel dashboardModel;

dashboardModel.setRows({
    QVariantMap{
        {"category", "Online"},
        {"sales", 240}
    },
    QVariantMap{
        {"category", "Retail"},
        {"sales", 185}
    }
});
```

The model provides these operations:

- `setRows(rows)`
- `appendRow(row)`
- `updateRow(row, values)`
- `removeRow(row)`
- `clear()`
- `rowAt(row)`

It also exposes `count` and `rows` properties.

To provide the model to QML:

```cpp
engine.rootContext()->setContextProperty(
    "dashboardModel",
    &dashboardModel
);
```

Then:

```qml
DashboardView {
    dataModel: dashboardModel
}
```

For a complete working example, see `examples/BasicApp`.

## Reporting and Analysis

The project includes a C++ `ReportEngine` QML type used by the reporting interface.

Its capabilities include:

- Detecting text, numeric, date, and Boolean fields.
- Applying filters to records.
- Grouping records by a selected field.
- Calculating sum, average, count, minimum, and maximum aggregations.
- Generating report data.

The reporting interface is implemented in:

```text
qml/pages/ReportsPage.qml
```

The corresponding C++ implementation is in:

```text
src/report/report_engine.h
src/report/report_engine.cpp
```

## Customization

The QML source files can be adapted to match the visual design and requirements of a host application.

Useful locations:

| Path | Purpose |
|---|---|
| `qml/Theme.qml` | Shared theme definitions |
| `qml/components/` | Reusable interface components |
| `qml/pages/` | Dashboard pages |
| `qml/DashboardView.qml` | Main embeddable dashboard component |
| `qml/DashboardBuilder.qml` | Dashboard layout and widget management |
| `qml/DashboardWidget.qml` | Individual dashboard widget |
| `qml/DashboardChart.qml` | Chart presentation |

The `BasicApp` example also contains `MyTheme.qml`, demonstrating how an application can provide a custom theme.

## Packaging Status

The current source tree contains an initial CMake package configuration, but the installation and exported-target setup is not yet complete.

In particular, the package configuration references `DashboardTargets.cmake`, while the current build scripts do not yet generate and install that exported target file.

For this reason, the installed-package workflow using:

```cmake
find_package(Dashboard 1.0 CONFIG REQUIRED)
```

should not yet be considered a supported integration method.

For now, build and use the library through the repository's CMake project and example applications.

## Testing

The repository contains a QML test file at:

```text
tests/tst_dynamicdashboard.qml
```

It covers data loading, CSV and JSON parsing, model updates, dashboard layouts, analytics, and report generation.

The test CMake configuration currently needs to be completed before this test suite can be built and run through the root project.

## Contributing

Contributions, bug reports, and suggestions are welcome.

When submitting changes:

1. Describe the problem or proposed improvement.
2. Keep changes focused and consistent with the project architecture.
3. Build the project with the supported Qt version.
4. Test the affected example applications.
5. Include a clear description with your pull request.

## License

Qt DynamicDashboard is distributed under the **MIT License**.

See the [LICENSE](LICENSE) file for details.

## Project Information

- **Project:** Qt DynamicDashboard
- **Repository:** https://github.com/mbr1376/DashboardPluginQml
- **License:** MIT
- **Maintainer:** mbr
