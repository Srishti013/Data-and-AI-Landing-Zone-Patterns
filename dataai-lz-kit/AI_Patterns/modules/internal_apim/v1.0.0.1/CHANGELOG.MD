# Changelog

[[_TOC_]]

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- ## [Unreleased]
### Added
### Changed
### Removed -->

## [1.0.0.1] - 2026-04-15

### Added

- Added `global_policy_vars` input for internal APIM global policy variable handling.

### Changed

- Updated module interface to use `global_policy_vars` for global policy configuration.
- No resource, data source, output, or provider-constraint changes between `v1.0.0.0` and `v1.0.0.1`.
- Global policy.xml mandation at global scope

### Removed

- Removed input: `protocols`.

### Security

- TLS 1.2+ enforcement.
- HTTPS-only enforcement capabilities.

## [1.0.0.0] - 2026-04-14 Initial Release

### Added

- Create Internal APIM Terraform Module.
