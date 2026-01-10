local resourceName = GetCurrentResourceName()

local Version = {
    current = '1.0.1',
    check = true,
    url = 'https://raw.githubusercontent.com/kt-scripts/KT-Version-Checks/main/Extra-Menu-Versioncheck.json',
    interval = 60
}
local function CompareVersions(current, latest)
    local currentParts = {}
    local latestParts = {}
    
    for part in string.gmatch(current, "[^%.]+") do
        table.insert(currentParts, tonumber(part) or 0)
    end
    
    for part in string.gmatch(latest, "[^%.]+") do
        table.insert(latestParts, tonumber(part) or 0)
    end
    
    for i = 1, math.max(#currentParts, #latestParts) do
        local c = currentParts[i] or 0
        local l = latestParts[i] or 0
        
        if c < l then
            return -1
        elseif c > l then
            return 1
        end
    end
    
    return 0
end

local function PrintLine()
    print('^4========================================^0')
end

local function CheckVersion()
    if not Version.check then
        return
    end
    
    if Version.url == '' then
        return
    end
    
    PerformHttpRequest(Version.url, function(statusCode, response, headers)
        if statusCode ~= 200 then
            print('^1' .. resourceName .. ' Version check currently disabled due to a GitHub issue^0')
            return
        end
        
        local data = json.decode(response)
        
        if not data or not data.version then
            print('^1' .. resourceName .. ' Version check failed: Invalid response from update server^0')
            return
        end
        
        local latestVersion = data.version
        local comparison = CompareVersions(Version.current, latestVersion)
        
        PrintLine()
        print('^4[' .. resourceName .. '] Version Check^0')
        PrintLine()
        
        if comparison == -1 then
            print('^1' .. resourceName .. ' UPDATE AVAILABLE!^0')
            print('^1' .. resourceName .. ' Current Version: ' .. Version.current .. '^0')
            print('^2' .. resourceName .. ' Latest Version: ' .. latestVersion .. '^0')
            
            if data.download then
                print('^3' .. resourceName .. ' Download: ' .. data.download .. '^0')
            end
            
            if data.changelog then
                print('^3' .. resourceName .. ' Changelog:^0')
                for _, change in ipairs(data.changelog) do
                    print('^3' .. resourceName .. '   - ' .. change .. '^0')
                end
            end
        elseif comparison == 0 then
            print('^2' .. resourceName .. ' You are running the latest version (' .. Version.current .. ')^0')
        else
            print('^3' .. resourceName .. ' You are running a newer version (' .. Version.current .. ') than released (' .. latestVersion .. ')^0')
        end
        
        PrintLine()
        
    end, 'GET', '', {['Content-Type'] = 'application/json'})
end

CreateThread(function()
    Wait(5000)
    CheckVersion()
    
    if Version.interval > 0 then
        while true do
            Wait(Version.interval * 60 * 1000)
            CheckVersion()
        end
    end
end)

exports('GetVersion', function()
    return Version.current
end)