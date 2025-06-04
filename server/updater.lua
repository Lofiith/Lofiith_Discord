local current_version = GetResourceMetadata(GetCurrentResourceName(), 'version', 0) or "1.0.0"
local GITHUB_REPO = "yourusername/Lofi_DiscordAPI"

-- Color codes embedded directly
local function Log(message, level)
    level = level or "info"
    local color = "^7"  -- white default
    
    if level == "warn" then color = "^3"     -- yellow
    elseif level == "error" then color = "^1" -- red
    elseif level == "debug" then color = "^5" -- light blue
    elseif level == "system" then color = "^4" -- blue
    end
    
    print(("[^5Lofi_discord^0] [%s%s^0] %s"):format(color, level:upper(), message))
end

local function CheckForUpdates()
    local version_url = "https://raw.githubusercontent.com/"..GITHUB_REPO.."/main/version.txt"
    
    PerformHttpRequest(version_url, function(status, latest_version, headers)
        if status == 200 then
            latest_version = latest_version:gsub("%s+", "")
            
            if current_version ~= latest_version then
                Log(("Update available! (Current: ^1%s^0 | Latest: ^2%s^0)"):format(current_version, latest_version), "warn")
                Log("Download: ^5https://github.com/"..GITHUB_REPO, "warn")
            else
                Log(("Resource is up to date (^2v%s^0)"):format(current_version), "info")
            end
        else
            Log(("Version check failed (Status: ^1%d^0)"):format(status), "debug")
        end
    end, "GET", "", {}, {}, 5000)  -- 5 second timeout
end

-- Run version check on resource start
Citizen.CreateThread(function()
    Wait(3000) 
    Log("Starting version check...", "system")
    CheckForUpdates()
    
    while true do
        Wait(21600000) -- 6 hours
        CheckForUpdates()
    end
end)
