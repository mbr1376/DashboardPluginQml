# Security Policy

## Supported Versions

Security updates are intended for the latest maintained version of Qt DynamicDashboard.

| Version | Security Support |
|---|---|
| Latest release | Supported |
| Older releases | Not guaranteed |

Users are encouraged to use the latest available version of the project.

## Reporting a Vulnerability

The security of Qt DynamicDashboard and applications using it is important.

If you discover a potential security vulnerability, please report it responsibly.

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, use GitHub's private vulnerability reporting feature for this repository, if it is enabled:

https://github.com/mbr1376/DashboardPluginQml/security/advisories/new

If private vulnerability reporting is unavailable, contact the repository maintainer through GitHub to arrange a private disclosure channel.

## What to Include

When reporting a security issue, please provide:

- A description of the vulnerability.
- The affected project version or commit.
- Steps to reproduce the issue.
- Potential security impact.
- A proof of concept, if available.
- Any suggested mitigation or fix.

Please avoid including real credentials, access tokens, private keys, or sensitive user data in reports.

## Response Process

After receiving a report, the maintainer will make reasonable efforts to:

1. Acknowledge receipt of the report.
2. Review and investigate the reported issue.
3. Determine the affected versions and potential impact.
4. Develop and test an appropriate fix.
5. Coordinate responsible disclosure with the reporter.
6. Publish relevant security information when appropriate.

Response and resolution times may vary depending on the complexity and severity of the issue.

## Security Considerations

Applications using Qt DynamicDashboard should follow secure development practices.

In particular:

- Validate data received from external sources.
- Use HTTPS for sensitive REST API communication.
- Avoid embedding credentials or API tokens in source code.
- Protect authentication tokens and sensitive configuration data.
- Validate JSON and CSV input before processing.
- Use appropriate access controls for database connections.
- Keep Qt and other dependencies updated.

## Scope

This policy covers security vulnerabilities in the Qt DynamicDashboard repository and its maintained components.

Issues originating exclusively from third-party dependencies should generally be reported to the maintainers of those dependencies as well.

## Disclosure

Please allow the maintainer reasonable time to investigate and address a reported vulnerability before publicly disclosing technical details.

We appreciate responsible security research and the effort required to improve the security of open-source software.

## Project

Repository:

https://github.com/mbr1376/DashboardPluginQml

License: MIT