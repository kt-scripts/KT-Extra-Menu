local Framework = nil
local PlayerData = nil
local Lang = Locales[Config.Language] or Locales['en']
local isRadialAdded = false
local currentVehicle = nil

CreateThread(function()
    if Config.Framework == 'esx' then
        Framework = exports['es_extended']:getSharedObject()
        while Framework.GetPlayerData() == nil do
            Wait(100)
        end
        PlayerData = Framework.GetPlayerData()
        
        RegisterNetEvent('esx:setJob', function(job)
            PlayerData.job = job
        end)
        
    elseif Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        Framework = exports['qb-core']:GetCoreObject()
        while Framework.Functions.GetPlayerData() == nil do
            Wait(100)
        end
        PlayerData = Framework.Functions.GetPlayerData()
        
        RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
            PlayerData = Framework.Functions.GetPlayerData()
        end)
        
        RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
            PlayerData.job = JobInfo
        end)
    end
end)

local function HasPermission()
    if #Config.RequiredJob == 0 then
        return true
    end
    
    local job = nil
    
    if Config.Framework == 'esx' then
        job = PlayerData.job.name
    elseif Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        job = PlayerData.job.name
    else
        return true
    end
    
    for _, allowedJob in ipairs(Config.RequiredJob) do
        if job == allowedJob then
            return true
        end
    end
    
    return false
end

local function Notify(msg, type)
    if Config.MenuSystem == 'lation' then
        exports.modernui:notify({
            title = Lang.notification_title,
            message = msg,
            type = type or 'info',
            duration = Config.Notifications.duration
        })
    else
        lib.notify({
            title = Lang.notification_title,
            description = msg,
            type = type or 'inform',
            duration = Config.Notifications.duration,
            position = Config.Notifications.position
        })
    end
end

local function GetPlayerVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle == 0 then
        return nil, nil
    end
    
    local isDriver = GetPedInVehicleSeat(vehicle, -1) == ped
    
    return vehicle, isDriver
end

local function GetVehicleModelName(vehicle)
    local hash = GetEntityModel(vehicle)
    return GetDisplayNameFromVehicleModel(hash):lower()
end

local function GetCustomLiveryName(vehicle, liveryIndex)
    local modelName = GetVehicleModelName(vehicle)
    
    if Config.CustomLiveryNames[modelName] then
        if Config.CustomLiveryNames[modelName][liveryIndex] then
            return Config.CustomLiveryNames[modelName][liveryIndex]
        end
    end
    
    local gameLiveryName = GetLiveryName(vehicle, liveryIndex)
    if gameLiveryName and gameLiveryName ~= '' then
        return gameLiveryName
    end
    
    return 'Livery ' .. (liveryIndex + 1)
end

local function GetVehicleLiveryCountCustom(vehicle)
    local count = GetVehicleLiveryCount(vehicle)
    if count <= 0 then
        count = GetNumVehicleMods(vehicle, 48)
    end
    return count
end

local function GetCurrentLivery(vehicle)
    local livery = GetVehicleLivery(vehicle)
    if livery < 0 then
        livery = GetVehicleMod(vehicle, 48)
    end
    return livery
end

local function SetVehicleLiveryCustom(vehicle, liveryIndex)
    if GetVehicleLiveryCount(vehicle) > 0 then
        SetVehicleLivery(vehicle, liveryIndex)
    else
        SetVehicleMod(vehicle, 48, liveryIndex, false)
    end
end

local function IsExtraOn(vehicle, extraId)
    return IsVehicleExtraTurnedOn(vehicle, extraId)
end

local function ToggleExtra(vehicle, extraId)
    local isOn = IsExtraOn(vehicle, extraId)
    SetVehicleExtra(vehicle, extraId, isOn)
    return not isOn
end

local function GetAvailableExtras(vehicle)
    local extras = {}
    for i = 0, 20 do
        if DoesExtraExist(vehicle, i) then
            table.insert(extras, {
                id = i,
                enabled = IsExtraOn(vehicle, i)
            })
        end
    end
    return extras
end

local function OpenLiveryMenuOx(vehicle)
    local liveryCount = GetVehicleLiveryCountCustom(vehicle)
    
    if liveryCount <= 0 then
        Notify(Lang.no_liveries, 'error')
        return
    end
    
    local currentLivery = GetCurrentLivery(vehicle)
    local options = {}
    
    for i = 0, liveryCount - 1 do
        local liveryName = GetCustomLiveryName(vehicle, i)
        local isCurrent = i == currentLivery
        
        table.insert(options, {
            title = liveryName,
            description = isCurrent and Lang.current or string.format(Lang.select_livery, (i + 1)),
            icon = isCurrent and 'check' or 'spray-can',
            disabled = isCurrent,
            onSelect = function()
                SetVehicleLiveryCustom(vehicle, i)
                Notify(string.format(Lang.livery_changed, liveryName), 'success')
                
                if not Config.CloseMenuAfterSelection then
                    OpenLiveryMenuOx(vehicle)
                end
            end
        })
    end
    
    lib.registerContext({
        id = 'livery_menu',
        title = Lang.livery_menu_title,
        menu = 'vehicle_main_menu',
        options = options
    })
    
    lib.showContext('livery_menu')
end

local function OpenExtrasMenuOx(vehicle)
    local extras = GetAvailableExtras(vehicle)
    
    if #extras == 0 then
        Notify(Lang.no_extras, 'error')
        return
    end
    
    local options = {}
    
    for _, extra in ipairs(extras) do
        local statusText = extra.enabled and Lang.extra_on or Lang.extra_off
        local statusIcon = extra.enabled and 'circle-check' or 'circle-xmark'
        local statusColor = extra.enabled and 'green' or 'red'
        
        table.insert(options, {
            title = 'Extra ' .. extra.id,
            description = statusText,
            icon = statusIcon,
            iconColor = statusColor,
            metadata = {
                {label = Lang.status, value = statusText}
            },
            onSelect = function()
                local newState = ToggleExtra(vehicle, extra.id)
                if newState then
                    Notify(string.format(Lang.extra_enabled, extra.id), 'success')
                else
                    Notify(string.format(Lang.extra_disabled, extra.id), 'info')
                end
                
                if not Config.CloseMenuAfterSelection then
                    OpenExtrasMenuOx(vehicle)
                end
            end
        })
    end
    
    lib.registerContext({
        id = 'extras_menu',
        title = Lang.extras_menu_title,
        menu = 'vehicle_main_menu',
        options = options
    })
    
    lib.showContext('extras_menu')
end

local function OpenMainMenuOx()
    local vehicle, isDriver = GetPlayerVehicle()
    
    if not vehicle then
        Notify(Lang.not_in_vehicle, 'error')
        return
    end
    
    if Config.OnlyDriver and not isDriver then
        Notify(Lang.not_driver, 'error')
        return
    end
    
    if not HasPermission() then
        Notify(Lang.no_permission, 'error')
        return
    end
    
    SetVehicleModKit(vehicle, 0)
    
    local liveryCount = GetVehicleLiveryCountCustom(vehicle)
    local extras = GetAvailableExtras(vehicle)
    
    local options = {}
    
    table.insert(options, {
        title = Lang.livery_menu,
        description = Lang.livery_desc,
        icon = 'spray-can',
        arrow = true,
        metadata = {
            {label = Lang.available, value = liveryCount > 0 and string.format(Lang.liveries_count, liveryCount) or Lang.none}
        },
        onSelect = function()
            OpenLiveryMenuOx(vehicle)
        end
    })
    
    table.insert(options, {
        title = Lang.extras_menu,
        description = Lang.extras_desc,
        icon = 'gear',
        arrow = true,
        metadata = {
            {label = Lang.available, value = #extras > 0 and string.format(Lang.extras_count, #extras) or Lang.none}
        },
        onSelect = function()
            OpenExtrasMenuOx(vehicle)
        end
    })
    
    lib.registerContext({
        id = 'vehicle_main_menu',
        title = Lang.menu_title,
        options = options
    })
    
    lib.showContext('vehicle_main_menu')
end

local function OpenLiveryMenuLation(vehicle)
    local liveryCount = GetVehicleLiveryCountCustom(vehicle)
    
    if liveryCount <= 0 then
        Notify(Lang.no_liveries, 'error')
        return
    end
    
    local currentLivery = GetCurrentLivery(vehicle)
    local options = {}
    
    for i = 0, liveryCount - 1 do
        local liveryName = GetCustomLiveryName(vehicle, i)
        local isCurrent = i == currentLivery
        
        table.insert(options, {
            title = liveryName,
            description = isCurrent and Lang.current or string.format(Lang.select_livery, (i + 1)),
            icon = isCurrent and 'fas fa-check' or 'fas fa-spray-can',
            disabled = isCurrent,
            action = function()
                SetVehicleLiveryCustom(vehicle, i)
                Notify(string.format(Lang.livery_changed, liveryName), 'success')
                
                if not Config.CloseMenuAfterSelection then
                    OpenLiveryMenuLation(vehicle)
                end
            end
        })
    end
    
    table.insert(options, {
        title = Lang.back,
        description = '',
        icon = 'fas fa-arrow-left',
        action = function()
            OpenMainMenuLation()
        end
    })
    
    exports.modernui:openMenu({
        header = Config.LationUI.header,
        subheader = Lang.livery_menu_title,
        options = options
    })
end

local function OpenExtrasMenuLation(vehicle)
    local extras = GetAvailableExtras(vehicle)
    
    if #extras == 0 then
        Notify(Lang.no_extras, 'error')
        return
    end
    
    local options = {}
    
    for _, extra in ipairs(extras) do
        local statusText = extra.enabled and Lang.extra_on or Lang.extra_off
        local statusIcon = extra.enabled and 'fas fa-check-circle' or 'fas fa-times-circle'
        
        table.insert(options, {
            title = 'Extra ' .. extra.id,
            description = statusText,
            icon = statusIcon,
            action = function()
                local newState = ToggleExtra(vehicle, extra.id)
                if newState then
                    Notify(string.format(Lang.extra_enabled, extra.id), 'success')
                else
                    Notify(string.format(Lang.extra_disabled, extra.id), 'info')
                end
                
                if not Config.CloseMenuAfterSelection then
                    OpenExtrasMenuLation(vehicle)
                end
            end
        })
    end
    
    table.insert(options, {
        title = Lang.back,
        description = '',
        icon = 'fas fa-arrow-left',
        action = function()
            OpenMainMenuLation()
        end
    })
    
    exports.modernui:openMenu({
        header = Config.LationUI.header,
        subheader = Lang.extras_menu_title,
        options = options
    })
end

local function OpenMainMenuLation()
    local vehicle, isDriver = GetPlayerVehicle()
    
    if not vehicle then
        Notify(Lang.not_in_vehicle, 'error')
        return
    end
    
    if Config.OnlyDriver and not isDriver then
        Notify(Lang.not_driver, 'error')
        return
    end
    
    if not HasPermission() then
        Notify(Lang.no_permission, 'error')
        return
    end
    
    SetVehicleModKit(vehicle, 0)
    currentVehicle = vehicle
    
    local liveryCount = GetVehicleLiveryCountCustom(vehicle)
    local extras = GetAvailableExtras(vehicle)
    
    local options = {}
    
    table.insert(options, {
        title = Lang.livery_menu,
        description = liveryCount > 0 and string.format(Lang.liveries_count, liveryCount) or Lang.none,
        icon = 'fas fa-spray-can',
        action = function()
            OpenLiveryMenuLation(vehicle)
        end
    })
    
    table.insert(options, {
        title = Lang.extras_menu,
        description = #extras > 0 and string.format(Lang.extras_count, #extras) or Lang.none,
        icon = 'fas fa-cog',
        action = function()
            OpenExtrasMenuLation(vehicle)
        end
    })
    
    table.insert(options, {
        title = Lang.close,
        description = '',
        icon = 'fas fa-times',
        action = function()
            exports.modernui:closeMenu()
        end
    })
    
    exports.modernui:openMenu({
        header = Config.LationUI.header,
        subheader = Config.LationUI.subheader,
        options = options
    })
end

local function OpenMainMenu()
    if Config.MenuSystem == 'lation' then
        OpenMainMenuLation()
    else
        OpenMainMenuOx()
    end
end

local function OpenLiveryMenu(vehicle)
    if Config.MenuSystem == 'lation' then
        OpenLiveryMenuLation(vehicle)
    else
        OpenLiveryMenuOx(vehicle)
    end
end

local function OpenExtrasMenu(vehicle)
    if Config.MenuSystem == 'lation' then
        OpenExtrasMenuLation(vehicle)
    else
        OpenExtrasMenuOx(vehicle)
    end
end

local function AddOxRadial()
    lib.addRadialItem({
        id = 'vehicle_customizer',
        icon = Config.RadialIcon,
        label = Lang.radial_label,
        onSelect = function()
            OpenMainMenu()
        end
    })
end

local function RemoveOxRadial()
    lib.removeRadialItem('vehicle_customizer')
end

local function AddQBRadial()
    exports['qb-radialmenu']:AddOption({
        id = Config.QBRadialId,
        title = Lang.radial_label,
        icon = Config.RadialIcon,
        type = 'client',
        event = 'vehicle_customizer:openMenu',
        shouldClose = true
    }, Config.QBRadialId)
end

local function RemoveQBRadial()
    exports['qb-radialmenu']:RemoveOption(Config.QBRadialId)
end

RegisterNetEvent('vehicle_customizer:openMenu', function()
    OpenMainMenu()
end)

if Config.UseRadial then
    if Config.OxRadial then
        CreateThread(function()
            while true do
                Wait(500)
                local vehicle, isDriver = GetPlayerVehicle()
                local shouldShow = vehicle ~= nil
                
                if Config.OnlyDriver then
                    shouldShow = shouldShow and isDriver
                end
                
                if shouldShow and HasPermission() then
                    if not isRadialAdded then
                        AddOxRadial()
                        isRadialAdded = true
                    end
                else
                    if isRadialAdded then
                        RemoveOxRadial()
                        isRadialAdded = false
                    end
                end
            end
        end)
    else
        CreateThread(function()
            while true do
                Wait(500)
                local vehicle, isDriver = GetPlayerVehicle()
                local shouldShow = vehicle ~= nil
                
                if Config.OnlyDriver then
                    shouldShow = shouldShow and isDriver
                end
                
                if shouldShow and HasPermission() then
                    if not isRadialAdded then
                        AddQBRadial()
                        isRadialAdded = true
                    end
                else
                    if isRadialAdded then
                        RemoveQBRadial()
                        isRadialAdded = false
                    end
                end
            end
        end)
    end
end

RegisterCommand(Config.Command, function()
    OpenMainMenu()
end, false)

if not Config.UseRadial and Config.Keybind then
    RegisterKeyMapping(Config.Command, 'Open Vehicle Customization', 'keyboard', Config.Keybind)
end

exports('OpenVehicleMenu', OpenMainMenu)
exports('OpenLiveryMenu', function()
    local vehicle = GetPlayerVehicle()
    if vehicle then
        OpenLiveryMenu(vehicle)
    end
end)
exports('OpenExtrasMenu', function()
    local vehicle = GetPlayerVehicle()
    if vehicle then
        OpenExtrasMenu(vehicle)
    end
end)