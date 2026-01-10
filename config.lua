Config = {}

-- Framework selection: 'esx', 'qbcore', 'qbox', 'standalone'
Config.Framework = 'qbox'

-- Language selection: 'de', 'en'
Config.Language = 'en'

-- 'ox' ox_lib context menu
-- 'lation' Lation Scripts Modern UI
Config.MenuSystem = 'ox'

-- Automatically close menu after selection
Config.CloseMenuAfterSelection = false

-- Command to open the menu
Config.Command = 'vehiclemenu'

-- Keybind to open menu (only works if Config.UseRadial is false)
-- Set to false to disable keybind completely
Config.Keybind = 'F11'

-- Only the driver can use the menu
Config.OnlyDriver = true

-- Examples: 'admin', 'mechanic', 'police' nothing and everyone can use it
Config.RequiredJob = {}

-- Notification settings
Config.Notifications = {
    duration = 3000,
    position = 'top-right'
}

-- Radial Menu Settings
-- Enable radial menu integration (disables keybind when true)
Config.UseRadial = false

-- Use ox_lib radial menu (true) or qb-radialmenu (false)
-- Only works if Config.UseRadial is true
Config.OxRadial = false

-- Radial menu icon (FontAwesome icon name)
Config.RadialIcon = 'car'

-- Radial menu position/id for qb-radialmenu
Config.QBRadialId = 'vehiclecustomizer'

-- Custom Livery Names
-- You can rename liveries for specific vehicles here
-- Format: ['vehicleModelName'] = { [liveryIndex] = 'Custom Name' }
-- Livery index starts at 0
Config.CustomLiveryNames = {
    -- ['EXAMPLE'] = {
    --     [0] = 'Livery 1',
    --     [1] = 'Livery 2',
    --     [2] = 'Livery 3',
    --     [3] = 'Livery 4',
    --     [4] = 'Livery 5',
    -- },
}

-- Lation Modern UI Settings (only used if Config.MenuSystem = 'lation')
Config.LationUI = {
    header = 'Vehicle Customization',
    subheader = 'Customize your vehicle',
}