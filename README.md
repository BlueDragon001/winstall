## Overview

`winstall` is a user-friendly, command-line wrapper around winget, designed to simplify and enhance Windows package management. With a more intuitive syntax and advanced features, Winstall allows users to easily search, install, uninstall, and list installed packages.

## Usage



The script supports the following actions:
- `install`
- `uninstall`
- `list`
- `search`

### Parameters

- `Action` (string): The action to perform. Valid values are `install`, `uninstall`, `list`, and `search`.
- `PackageName` (string): The name of the package to install or uninstall. Required for `install`, `uninstall`, and `search` actions.
- `Category` (string): The category of the package. Optional, used only for the `install` action.
- `CustomPath` (string): A custom installation path. Optional, used only for the `install` action.

### Examples

#### Install a Package

```sh
winstall.ps1 -Action install -PackageName <PackageName> -Category <Category> -CustomPath <CustomPath>
### Notes
- Modify winstall_conifg to add custom Download Location
- Point System's PATH to winstall cloned directory
