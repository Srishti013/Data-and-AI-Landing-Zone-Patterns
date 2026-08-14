# Changelog

[[_TOC_]]

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- ## [Unreleased]
### Added
### Changed
### Removed -->

## [1.0.0.1] - 2026-04-16

### Changed

- Updated module for enterprise standards.

### Fixed

- `azurerm_storage_data_lake_gen2_path` now depends on `azurerm_storage_data_lake_gen2_filesystem`, preventing "404 The specified filesystem does not exist" when a managed filesystem and its paths are created in the same apply.

## [1.0.0.0] - Initial Release

### Added

- Create Azure Storage Account Terraform Module.
- Support for blob containers, queues, tables, and file shares.
- Customer-managed key encryption support.
- Private endpoint integration.
- Diagnostic settings support.
- Management policy configuration.
- Role assignments support.
# Changelog

[[_TOC_]]

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- ## [Unreleased]
### Added
### Changed
### Removed -->

## [1.0.0.1] - 2026-04-16

### Changed

- Updated module for enterprise standards.

## [1.0.0.0] - Initial Release

### Added

- Create Azure Storage Account Terraform Module.
- Support for blob containers, queues, tables, and file shares.
- Customer managed key (CMK) encryption support.
- Private endpoint integration.
- Data Lake Gen2 filesystem support.
- Diagnostic settings support.
- Management policy lifecycle rules.
- Management locks and role assignments.
- Telemetry integration.
