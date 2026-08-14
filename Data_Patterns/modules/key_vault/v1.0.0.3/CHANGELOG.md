# Changelog

[[_TOC_]]

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- ## [Unreleased]
### Added
### Changed
### Removed -->

## [1.0.0.3] - 2026-07-06

### Added

- Added Key Output Names in the Key Module.

## [1.0.0.2] - 2026-04-14

### Added

- No new inputs, resources, data sources, or outputs were introduced in this version.

### Changed

- Updated interface behavior so purge protection is no longer controlled through module input.
- Updated module implementation to set `purge_protection_enabled = true` directly in resource configuration.
- No resource, data source, output, or provider-constraint changes between `v1.0.0.1` and `v1.0.0.2`.

### Removed

- Removed input: `purge_protection_enabled`.

### Security

- Purge protection handling is no longer exposed as a module input and is controlled by module implementation.

## [1.0.0.1] - 2026-04-14

### Added

- Added inputs: `experiment_phase`, `integration_id`, `last_vm_accessed`, `maintenance_window`, `os`, `patch_policy`, `retention`, `sandbox_type`, and `service`.

### Changed

- Updated module interface toward governance and lifecycle metadata alignment.
- No resource, data source, output, or provider-constraint changes between `v1.0.0.0` and `v1.0.0.1`.

### Removed

- Removed inputs: `app_support`, `country`, and `product_version`.

## [1.0.0.0] - 2026-04-14 Initial Release

### Added

- Create Key Vault Terraform Module.
