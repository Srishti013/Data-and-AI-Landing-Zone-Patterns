# Changelog

[[_TOC_]]

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- ## [Unreleased]
### Added
### Changed
### Removed -->

## [1.0.0.2] - 2026-06-12

### Added

- added the dynamic block `always_ready` under `azurerm_function_app_flex_consumption` function app.
- updated the life cycle `ignore_changes` under `azurerm_function_app_flex_consumption`

## [1.0.0.1] - 2026-04-15

### Added

- Security-hardening updates for App Service resources and selected slot scenarios.

### Changed

- Removed module inputs: `https_only` and `public_network_access_enabled`.
- Enforced hardened defaults in resource configuration:
	- `https_only = true`
	- `public_network_access_enabled = false`
- No resource, data source, output, or provider-constraint changes between `v1.0.0.0` and `v1.0.0.1`.

### Removed

- Input toggles for `https_only` and `public_network_access_enabled` from the module interface.

### Security

- Enforced HTTPS-only traffic across supported workloads.
- Enforced private-access-first posture by disabling public network access in module-managed resources.

## [1.0.0.0] - 2026-04-14 Initial Release

### Added

- Create App Service Terraform Module.
