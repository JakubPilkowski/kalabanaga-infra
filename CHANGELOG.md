## [1.2.6](https://github.com/JakubPilkowski/kalabanaga-infra/compare/v1.2.5...v1.2.6) (2025-09-09)


### Bug Fixes

* add missing .deploy.yml script change ([7aa6cac](https://github.com/JakubPilkowski/kalabanaga-infra/commit/7aa6cac391493de69644a377bf9712e6c85bcc6f))

## [1.2.5](https://github.com/JakubPilkowski/kalabanaga-infra/compare/v1.2.4...v1.2.5) (2025-09-09)


### Bug Fixes

* move release step after deploy succeed ([63f8a09](https://github.com/JakubPilkowski/kalabanaga-infra/commit/63f8a09effb7e8133a48d19567a200067d120bc1))

## [1.2.4](https://github.com/JakubPilkowski/kalabanaga-infra/compare/v1.2.3...v1.2.4) (2025-08-23)

## [1.2.3](https://github.com/JakubPilkowski/kalabanaga-infra/compare/v1.2.2...v1.2.3) (2025-08-23)

## [1.2.2](https://github.com/JakubPilkowski/kalabanaga-infra/compare/v1.2.1...v1.2.2) (2025-08-23)

## [1.2.1](https://github.com/JakubPilkowski/kalabanaga-infra/compare/v1.2.0...v1.2.1) (2025-08-23)

# [1.2.0](https://github.com/JakubPilkowski/kalabanaga-infra/compare/v1.1.1...v1.2.0) (2025-08-23)


### Features

* add CloudFront invalidation permission to deployment policy ([54fd28c](https://github.com/JakubPilkowski/kalabanaga-infra/commit/54fd28c6e6ad955280a19b54a97975250bdc67b7))

## [1.1.1](https://github.com/JakubPilkowski/kalabanaga-infra/compare/v1.1.0...v1.1.1) (2025-08-23)

# [1.1.0](https://github.com/JakubPilkowski/kalabanaga-infra/compare/v1.0.2...v1.1.0) (2025-08-23)


### Features

* add S3 management permissions to ProjectPreviewNextAppDeployPolicy ([e235cac](https://github.com/JakubPilkowski/kalabanaga-infra/commit/e235cac8e7319e034839b5c8aa8fa2c76d14253c))

## [1.0.2](https://github.com/JakubPilkowski/kalabanaga-infra/compare/v1.0.1...v1.0.2) (2025-08-23)

## [1.0.1](https://github.com/JakubPilkowski/kalabanaga-infra/compare/v1.0.0...v1.0.1) (2025-08-23)


### Bug Fixes

* add missing CloudFront and ELBv2 permissions for data source access ([3bf7b3c](https://github.com/JakubPilkowski/kalabanaga-infra/commit/3bf7b3c770f5897623228e2b84574197e42ac6a5))

# 1.0.0 (2025-08-21)


### Features

* initialize secure infrastructure as code repository ([fba12cf](https://github.com/JakubPilkowski/kalabanaga-infra/commit/fba12cf24c7fc50a1a791898d24b5548dac1117c))
* initialize secure infrastructure as code repository with semantic versioning ([33c60ae](https://github.com/JakubPilkowski/kalabanaga-infra/commit/33c60ae808b4d91b6d226fcbea4a7b549a3f2144))
* initialize secure infrastructure as code repository with semantic versioning ([4798938](https://github.com/JakubPilkowski/kalabanaga-infra/commit/47989385303a2f590b126f6f4e6e9ecad0a4700b))

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- S3 bucket key validation system with git hooks
- Infrastructure change detection for CI/CD
- Automatic semantic versioning and changelog generation
- Comprehensive documentation and setup scripts

### Changed

- Updated GitHub Actions workflow to include release and conditional deployment
- Enhanced deployment process with change detection

### Fixed

- S3 bucket key pattern validation to prevent state file conflicts
