# Aurora CLI

![picture](data/preview2.png)

[![aurora-cli](https://snapcraft.io/aurora-cli/badge.svg)](https://snapcraft.io/aurora-cli)

An application that combines different scripts that help an Aurora OS programmer in his daily work. You can use separate scripts - each of them is an atomic unit. Or install a CLI application (available in snap) and use all the scripts if necessary with a convenient interface.

[![picture](data/btn_youtube.png)](https://youtu.be/8PGj5qGYmcU)

## Install

[![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-black.svg)](https://snapcraft.io/aurora-cli)

```
sudo snap install aurora-cli --devmode
```

## Features

* psdk
  - install - Install Aurora Platform SDK version 4.0.2.303.
  - remove - Remove Aurora Platform SDK.
  - validate - Validate RPM packages.
  - sign - Sign (with re-sign) packages.
  - index - Select index key.
* flutter
  - versions-installed - Get list installed versions Flutter SDK.
  - versions-available - Get list available versions Flutter SDK.
  - install - Install version Flutter SDK.
  - remove - Remove Flutter SDK.
  - embedder-version - Get version installed Flutter embedder.
  - embedder-install - Install embedder from Flutter SDK.
* device
  - ssh-copy - Add ssh key to device.
  - command - Execute the command on the device.
  - upload - Upload files to Download directory device.
  - install - Install RPM package in device.
  - run - Run application in device.
  - firejail - Run application in device with firejail in container.
  - firejail-dbus - Firejail for Aurora OS 5.0.
  - index - Select index device.
  - all - Select all devices.

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
