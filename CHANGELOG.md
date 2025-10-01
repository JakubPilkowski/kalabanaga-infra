## [1.2.12](https://github.com/JakubPilkowski/kalabanaga-infra/compare/v1.2.11...v1.2.12) (2025-10-01)


### Bug Fixes

* missing preview react app deploy policies ([d55579c](https://github.com/JakubPilkowski/kalabanaga-infra/commit/d55579c4c1fa02684fbf9e908199e9350651f641))

## [1.2.11](https://github.com/JakubPilkowski/kalabanaga-infra/compare/v1.2.10...v1.2.11) (2025-10-01)


### Bug Fixes

* missing preview react app deploy policies ([ca5c932](https://github.com/JakubPilkowski/kalabanaga-infra/commit/ca5c932159aa33c368f20ea04ce92ff68762f9a0))

## [1.2.10](https://github.com/JakubPilkowski/kalabanaga-infra/compare/v1.2.9...v1.2.10) (2025-09-28)


### Bug Fixes

* missing preview react app deploy policies ([25b1876](https://github.com/JakubPilkowski/kalabanaga-infra/commit/25b1876c2b2246bdc2f5f8e0e96f858bc2f133a1))

## [1.2.9](https://github.com/JakubPilkowski/kalabanaga-infra/compare/v1.2.8...v1.2.9) (2025-09-28)


### Bug Fixes

* missing preview react app deploy policies ([ea8dae0](https://github.com/JakubPilkowski/kalabanaga-infra/commit/ea8dae0f3a9b262df49aff941fffc576a0e4bd8b))

## [1.2.8](https://github.com/JakubPilkowski/kalabanaga-infra/compare/v1.2.7...v1.2.8) (2025-09-09)


### Bug Fixes

* missing permissions in react app infr ([18c69dd](https://github.com/JakubPilkowski/kalabanaga-infra/commit/18c69dd7b928be143b14c9df27da7b70303d66ac))

## [1.2.7](https://github.com/JakubPilkowski/kalabanaga-infra/compare/v1.2.6...v1.2.7) (2025-09-09)


### Bug Fixes

* add elbv2 data access for react app deploy ([5d78e70](https://github.com/JakubPilkowski/kalabanaga-infra/commit/5d78e703c4fecfe884789a84f219794d48b50ba0))

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
