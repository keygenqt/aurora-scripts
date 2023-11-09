# Aurora CLI

![picture](data/preview2.png)

[![aurora-cli](https://snapcraft.io/aurora-cli/badge.svg)](https://snapcraft.io/aurora-cli)

An application that combines different scripts that help an Aurora OS programmer in his daily work. You can use separate scripts - each of them is an atomic unit. Or install a CLI application (available in snap) and use all the scripts if necessary with a convenient interface.

## Install

[![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-black.svg)](https://snapcraft.io/aurora-cli)

```
sudo snap install aurora-cli --devmode
```

or candidate

```
sudo snap install aurora-cli --channel=candidate --devmode
```

## Features

#### 1. Sign

Helps to sign (re-sign) packages located in a folder. Just go to your RPM packages folder and enter the command:

```
aurora-cli psdk --sign <KEY>
```

`<KEY>` - There are only 3 of them: `extended`, `regular`, `system`. 

Settings `~/snap/aurora-cli/common/configuration.yaml`:

```yaml
sign:
  extended:
    key: /path/to/key.pem
    cert: /path/to/cert.pem
```

### License

```
Copyright 2023 Vitaliy Zarubin

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
