# `pko` - Package Overlay
![Build Status](https://github.com/RomainMuller/pko/workflows/Validation%20Build/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/0dd9c68d88c6d6a7c672/maintainability)](https://codeclimate.com/github/RomainMuller/pko/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/0dd9c68d88c6d6a7c672/test_coverage)](https://codeclimate.com/github/RomainMuller/pko/test_coverage)
[![npm package](https://img.shields.io/npm/v/pko/latest.svg)](https://www.npmjs.com/package/pko)

`pko` is a drop-in replacement for `npm` that uses local files instead of the standard `npm` registry for the packages
it has been set up with. If you're wondering why you would want to do such things, refer to the [use-cases](#Use-cases)
section of this document.

*npm is a registered trademark of npm, Inc.*

# Usage
## Adding a package to the `pko` overlay
Simply publish your packages using the `pko` command instead of the `npm` command (this cannot work for packages that
have `publishConfig` or `private: true` in their `package.json` file). No authentication is required.
* For a package you're developing:
  ```shell
  pko publish path/to/package
  ```
* For a package from your `npm` registry of choice:
  ```shell
  TGZ=$(npm pack package[@version]) # Download the package locally
  pko publish ${TGZ}              # Publish the downloaded package
  rm ${TGZ}                         # Clean-up after yourself
  ```

## Determine which packages you have in the `pko` overlay
The `ls-overrides` subcommand will list all packages present in the local overlay and output their name and (latest)
version number to `STDOUT`.
```shell
pko ls-overrides
```

## Install packages using the `pko` overlay
Simply replace invokations of `npm` with `pko`, using the exact same arguments:
```shell
pko install
pko install --save-dev @types/node
pko run build
```

## Overlay location
The overlay location is determined using the following procedure:
1. The environment variable `$PKO_REPOSITORY`
2. Walk up the tree from `$PWD` (the process' working directory) until:
    1. A `.pko` directory is found
    2. The root of the filesystem is reached
3. Walk up the tree from where `pko` is installed in until:
    1. A `.pko` directory is found
    2. The root of the filesystem is reached
4. Bail out in error.

## Debugging
Verbose logging can be enabled by setting the `PKO_VERBOSE` environment variable to a truthy value:
```shell
PKO_VERBOSE=1 pko install
```

# Use-cases
* Distributing private packages without having to set-up a full-fledged `npm` registry for private use.
  > Simply prepare an overlay locally, then distribute that overlay (for example, in a ZIP file) to interested users.
* Enable full offline usage of `npm`
  > Prepare an overlay with all the package versions that need to be available offline. No internet connectivity will
  > be required for using those.
* Replacing a dependency with customized code (for quick experimentations, ...)
  > Publish your custom version under the exact same name as the package you want to replace to your overlay, and
  > `pko` will use that instead of the version found in the public `npm` registry.

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="http://eladb.github.com/"><img src="https://avatars3.githubusercontent.com/u/598796?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Elad Ben-Israel</b></sub></a><br /><a href="https://github.com/RomainMuller/pko/commits?author=eladb" title="Code">💻</a> <a href="https://github.com/RomainMuller/pko/issues?q=author%3Aeladb" title="Bug reports">🐛</a> <a href="https://github.com/RomainMuller/pko/pulls?q=is%3Apr+reviewed-by%3Aeladb" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/RomainMuller/pko/commits?author=eladb" title="Tests">⚠️</a> <a href="#maintenance-eladb" title="Maintenance">🚧</a> <a href="#ideas-eladb" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="http://rix0r.nl/"><img src="https://avatars2.githubusercontent.com/u/524162?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Rico Huijbers</b></sub></a><br /><a href="https://github.com/RomainMuller/pko/commits?author=rix0rrr" title="Code">💻</a> <a href="https://github.com/RomainMuller/pko/issues?q=author%3Arix0rrr" title="Bug reports">🐛</a> <a href="https://github.com/RomainMuller/pko/pulls?q=is%3Apr+reviewed-by%3Arix0rrr" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/RomainMuller/pko/commits?author=rix0rrr" title="Tests">⚠️</a> <a href="#maintenance-rix0rrr" title="Maintenance">🚧</a> <a href="#ideas-rix0rrr" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="https://keybase.io/romainmuller"><img src="https://avatars2.githubusercontent.com/u/411689?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Romain Marcadier</b></sub></a><br /><a href="https://github.com/RomainMuller/pko/commits?author=RomainMuller" title="Code">💻</a> <a href="https://github.com/RomainMuller/pko/issues?q=author%3ARomainMuller" title="Bug reports">🐛</a> <a href="https://github.com/RomainMuller/pko/pulls?q=is%3Apr+reviewed-by%3ARomainMuller" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/RomainMuller/pko/commits?author=RomainMuller" title="Tests">⚠️</a> <a href="#maintenance-RomainMuller" title="Maintenance">🚧</a> <a href="#ideas-RomainMuller" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="https://github.com/apps/dependabot-preview"><img src="https://avatars3.githubusercontent.com/in/2141?v=4?s=100" width="100px;" alt=""/><br /><sub><b>dependabot-preview[bot]</b></sub></a><br /><a href="#maintenance-dependabot-preview[bot]" title="Maintenance">🚧</a></td>
    <td align="center"><a href="https://github.com/apps/dependabot"><img src="https://avatars0.githubusercontent.com/in/29110?v=4?s=100" width="100px;" alt=""/><br /><sub><b>dependabot[bot]</b></sub></a><br /><a href="#maintenance-dependabot[bot]" title="Maintenance">🚧</a></td>
    <td align="center"><a href="https://github.com/apps/greenkeeper"><img src="https://avatars3.githubusercontent.com/in/505?v=4?s=100" width="100px;" alt=""/><br /><sub><b>greenkeeper[bot]</b></sub></a><br /><a href="#maintenance-greenkeeper[bot]" title="Maintenance">🚧</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!

## License

This project is distributed under the [Apache-2.0] license.

[Apache-2.0]: https://spdx.org/licenses/Apache-2.0.html
