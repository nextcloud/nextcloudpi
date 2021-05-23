## 3.1.1 - 2021-01-27
### Changed
- Use new batch preview method

### Fixed
- Init filesystem for the users
- Handle unavailable storages more graceful

## 3.1.0 -2020-12-21
### Added
- Nextcloud 21 support

## 3.0.0 - 2020-08-31
### Added
- Nextcloud 20 support
- IBootstap support
- Listen to new events hence only initialize the FS if needed

### Removed
- Nextcloud <20 support

## 2.3.0 - 2020-04-03
### Added
- Nextcloud 19 support

## 2.2.0 - 2019-12-05
### Added
- Nextcloud 18 support

## 2.1.0 - 2019-03-05
### Added
- Nextcloud 16 support

## 2.0.0 - 2018-11-08

- PHP 7.x required
- Nextcloud 14 only
- Moved to migrations for DB handling
- Added path option to generate command (thanks to @adduxa)
- Nextcloud 15 compatible

## 1.0.9 - 2017-12-29

### Fixes

### Added
- Show timestamp in occ commands [#88](https://github.com/rullzer/previewgenerator/pull/88)
- Add Composer Classmap for file (NC13) [#90](https://github.com/rullzer/previewgenerator/pull/90)
- Respect .nomedia [#92](https://github.com/rullzer/previewgenerator/pull/92)
- Use PID to check for already running process [#93](https://github.com/rullzer/previewgenerator/pull/93)

## 1.0.8 - 2017-12-21

### Fixes
- Do not add file if it already is in the table [#86](https://github.com/rullzer/previewgenerator/pull/86)

### Added
- Allow to specify sizes to be generated [#87](https://github.com/rullzer/previewgenerator/pull/86)

## 1.0.7 - 2017-09-26

### Fixes
- Updated/Fixed README
  - [#55](https://github.com/rullzer/previewgenerator/pull/55) @Eeems
  - [#58](https://github.com/rullzer/previewgenerator/pull/58) @MichaIng
  - [#67](https://github.com/rullzer/previewgenerator/pull/67) @sndrr
- Avoid folder processing on pre-generate [#73](https://github.com/rullzer/previewgenerator/pull/73) @Seik

### Added
- Make NC13 Compatible [#63](https://github.com/rullzer/previewgenerator/pull/63)

## 1.0.6 - 2017-05-05

### Fixed
- Better preview error handling [#51](https://github.com/rullzer/previewgenerator/pull/51) @icewind1991 
- Travis test runs [#53](https://github.com/rullzer/previewgenerator/pull/53)

### Added
- README.md [#52](https://github.com/rullzer/previewgenerator/pull/52)
- CHANGELOG.md [#52](https://github.com/rullzer/previewgenerator/pull/52)

## 1.0.5 - 2017-03-17

### Added
- Generate more preview sizes
- Add --force command to break lock

## 1.0.4 - 2017-03-14

### Fixed
- Lock timeout was 30 hours instead of minutes

## 1.0.3 - 2017-03-14

### Added
- Do not use app with encryption
- Check for already running command

## 1.0.2 - 2017-03-08

### Added
- More verbose output of commands
- Hack around preview generation errors by not trying the file again in the next run

## 1.0.1 - 2016-12-08

### Fixed
- Pimp info.xml

## 1.0.0 – 2016-12-07
Initial release
