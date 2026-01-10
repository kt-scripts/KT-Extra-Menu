```markdown
# Vehicle Extra Menu

A lightweight FiveM script for customizing vehicle liveries and extras. Features ox_lib and Lation Modern UI support, radial menu integration (ox_lib/qb-radialmenu), multi-framework compatibility (ESX/QBCore/QBox), custom livery naming, multi-language support (EN/DE), and automatic version checking.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![FiveM](https://img.shields.io/badge/FiveM-ready-orange.svg)

## Features

- **Multi-Framework Support** - Works with ESX, QBCore, QBox, and Standalone
- **Multiple Menu Systems** - ox_lib Context Menu or Lation Modern UI
- **Radial Menu Integration** - ox_lib Radial Menu or qb-radialmenu
- **Custom Livery Names** - Rename liveries for specific vehicles
- **Multi-Language** - English and German included
- **Job Restrictions** - Limit access to specific jobs
- **Version Checking** - Automatic update notifications
- **Lightweight** - Optimized performance

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib) (required)
- [modernui](https://github.com/lationscripts/modernui) (optional - for Lation UI)

## Installation

1. Download the latest release
2. Extract to your `resources` folder
3. Rename folder to `vehicle_extra_menu`
4. Add `ensure vehicle_extra_menu` to your `server.cfg`
5. Configure `config.lua` to your needs
6. Restart your server

```cfg
ensure ox_lib
ensure vehicle_extra_menu
```

## Configuration

### Basic Settings

```lua
Config = {}

-- Framework: 'esx', 'qbcore', 'qbox', 'standalone'
Config.Framework = 'esx'

-- Language: 'de', 'en'
Config.Language = 'en'

-- Menu System: 'ox', 'lation'
Config.MenuSystem = 'ox'

-- Close menu after selection
Config.CloseMenuAfterSelection = false

-- Command to open menu
Config.Command = 'vehiclemenu'

-- Keybind (only works if UseRadial is false)
Config.Keybind = 'F11'

-- Only driver can use menu
Config.OnlyDriver = true

-- Required jobs (empty = everyone)
Config.RequiredJob = {}
```

### Radial Menu Settings

```lua
-- Enable radial menu (disables keybind)
Config.UseRadial = true

-- Use ox_lib radial (true) or qb-radialmenu (false)
Config.OxRadial = true

-- Radial menu icon
Config.RadialIcon = 'car'

-- qb-radialmenu ID
Config.QBRadialId = 'vehiclecustomizer'
```

### Custom Livery Names

You can rename liveries for specific vehicles:

```lua
Config.CustomLiveryNames = {
    ['police'] = {
        [0] = 'LSPD Black/White',
        [1] = 'LSPD Slicktop',
        [2] = 'Sheriff',
    },
    ['ambulance'] = {
        [0] = 'Los Santos Medical',
        [1] = 'Fire Department',
    },
    -- Add more vehicles as needed
    -- ['modelname'] = {
    --     [0] = 'First Livery',
    --     [1] = 'Second Livery',
    -- },
}
```

> **Note:** Livery index starts at 0. Model names must be lowercase.

### Notification Settings

```lua
Config.Notifications = {
    duration = 3000,
    position = 'top-right'
}
```

### Lation Modern UI Settings

```lua
Config.LationUI = {
    header = 'Vehicle Customization',
    subheader = 'Customize your vehicle',
}
```

## Version Check

The version check is configured in `version.lua`:

```lua
local Version = {
    current = '1.0.0',
    check = true,
    url = 'https://raw.githubusercontent.com/USERNAME/REPO/main/version.json',
    interval = 60
}
```

| Option | Description |
|--------|-------------|
| `current` | Current script version |
| `check` | Enable/disable version check |
| `url` | URL to version.json file |
| `interval` | Check interval in minutes (0 = only on start) |

### Disable Version Check

```lua
local Version = {
    current = '1.0.0',
    check = false,
    url = '',
    interval = 0
}
```

## Exports

```lua

## Commands

| Command | Description |
|---------|-------------|
| `/vehiclemenu` | Open the vehicle customization menu |

## Usage Examples

### Restrict to Mechanics Only

```lua
Config.RequiredJob = {'mechanic'}
```

### Restrict to Multiple Jobs

```lua
Config.RequiredJob = {'mechanic', 'police', 'ambulance'}
```

### Use Only Keybind (No Radial)

```lua
Config.UseRadial = false
Config.Keybind = 'F11'
```

### Use Only Command (No Keybind, No Radial)

```lua
Config.UseRadial = false
Config.Keybind = false
```

### Use qb-radialmenu Instead of ox_lib

```lua
Config.UseRadial = true
Config.OxRadial = false
```

### Use Lation Modern UI

```lua
Config.MenuSystem = 'lation'
Config.LationUI = {
    header = 'Vehicle Customization',
    subheader = 'Customize your vehicle',
}
```


## Screenshots

*Coming soon*

## Changelog

### v1.0.0
- Initial release
- Livery customization
- Extras toggle
- Multi-framework support
- ox_lib and Lation UI support
- Radial menu integration
- Custom livery naming
- Multi-language support
- Version checking

## Support

If you encounter any issues or have suggestions:

1. Check the [Issues](https://github.com/USERNAME/vehicle_extra_menu/issues) page
2. Create a new issue with detailed information
3. Include your server configuration and error logs

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

- [ox_lib](https://github.com/overextended/ox_lib) - Menu and notification system
- [Lation Scripts](https://github.com/lationscripts) - Modern UI support

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



Made with ❤️ by Fabian
