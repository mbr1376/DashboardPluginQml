# Contributing to Qt DynamicDashboard

Thank you for your interest in contributing to Qt DynamicDashboard!

Contributions of all kinds are welcome, including bug reports, feature requests, documentation improvements, code contributions, and suggestions.

## Project Goals

Qt DynamicDashboard aims to provide a reusable, data-driven dashboard library for Qt Quick and QML applications.

Contributions should support the following goals:

- Maintain compatibility with supported Qt versions.
- Keep the library reusable and modular.
- Follow Qt and QML development conventions.
- Maintain a clear separation between C++, QML, and application-specific code.
- Provide useful examples and documentation.
- Keep the public API consistent and understandable.

## Before Contributing

Before starting significant work:

1. Check existing issues and pull requests.
2. Open an issue to discuss major changes or new features.
3. Make sure your proposed change fits the project's goals.
4. Avoid duplicating existing functionality.

For small documentation fixes and straightforward bug fixes, a discussion may not be necessary.

## Development Requirements

The project uses:

- Qt 6.8 or newer for the library.
- Qt 6.10 or newer for building all current examples.
- CMake 3.21 or newer.
- C++17.
- Qt Quick and QML.

Required Qt modules include:

- Qt Core
- Qt Qml
- Qt Quick
- Qt Quick Controls 2
- Qt Quick Dialogs 2
- Qt Network
- Qt Sql

## Building the Project

Clone the repository:

```bash
git clone https://github.com/mbr1376/DashboardPluginQml.git
cd DashboardPluginQml
```

Configure your Qt installation:

```bash
export CMAKE_PREFIX_PATH="$HOME/Qt/6.10.1/gcc_64"
```

Configure the project:

```bash
cmake -S . -B build \
  -DCMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH" \
  -DBUILD_EXAMPLES=ON
```

Build:

```bash
cmake --build build --parallel
```

Adjust the Qt installation path according to your environment.

## Code Guidelines

### C++

- Use C++17 features where appropriate.
- Follow Qt naming and coding conventions.
- Prefer Qt classes and APIs when they are suitable.
- Use clear and descriptive class, function, and variable names.
- Avoid unnecessary dependencies.
- Keep public headers focused and documented.
- Handle errors explicitly.

### QML

- Use clear and consistent component names.
- Prefer reusable components over duplicated UI code.
- Keep application-specific logic out of reusable library components.
- Use Qt Quick and Qt Quick Controls conventions.
- Keep visual styling consistent with the project's theme system.

### CMake

- Keep CMake configuration modular.
- Avoid unnecessary global configuration.
- Preserve the library's ability to be used independently of example applications.
- Document new build options and dependencies.

## Testing

Before submitting a pull request:

- Build the affected targets.
- Run the relevant example applications.
- Verify that existing dashboard functionality is not broken.
- Test new functionality where practical.
- Include test coverage for new behavior whenever possible.

If a test cannot be run, mention that clearly in your pull request.

## Pull Request Process

1. Fork the repository.
2. Create a feature branch.
3. Make your changes.
4. Build and test the affected parts.
5. Commit your changes with a clear message.
6. Push your branch to your fork.
7. Open a pull request against the main repository.

Suggested branch names:

```text
feature/add-widget-type
fix/json-loading
docs/update-installation-guide
refactor/dashboard-model
```

Suggested commit messages:

```text
feat: add new dashboard widget
fix: handle invalid JSON input
docs: improve installation instructions
refactor: simplify dashboard data model
```

## Pull Request Description

Please include:

- A short description of the change.
- The reason for the change.
- Related issue numbers, if applicable.
- Build and test results.
- Screenshots or recordings for visual QML changes, when useful.
- Any compatibility or API considerations.

## Reporting Bugs

When reporting a bug, include:

- Qt version.
- Operating system.
- Compiler version.
- Steps to reproduce the issue.
- Expected behavior.
- Actual behavior.
- Relevant error messages or logs.

A minimal reproducible example is especially helpful.

## Documentation Contributions

Documentation improvements are welcome.

Please keep documentation:

- Accurate and consistent with the actual implementation.
- Clear for developers who are new to Qt DynamicDashboard.
- Updated when public APIs or build instructions change.

## License

By submitting a contribution, you agree that your contribution will be distributed under the project's MIT License.

See the [LICENSE](LICENSE) file for details.

## Code of Conduct

All contributors are expected to follow our [Code of Conduct](CODE_OF_CONDUCT.md).

Thank you for helping improve Qt DynamicDashboard!

Repository: https://github.com/mbr1376/DashboardPluginQml