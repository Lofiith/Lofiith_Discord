local PlayerDiscordData = {}
local config = Config 
local resource_name = GetCurrentResourceName()

-- Embedded color codes directly in log function
local function Log(message, level)
    level = level or "info"
    local color = "^7"  -- white default
    
    if level == "warn" then color = "^3"     -- yellow
    elseif level == "error" then color = "^1" -- red
    elseif level == "debug" then color = "^5" -- light blue
    elseif level == "system" then color = "^4" -- blue
    end
    
    print(("[^5%s^0] [^6DISCORD API^0] [%s%s^0]: %s"):format(
        resource_name, color, level:upper(), message
    ))
end

-- Error handling for missing config
if not config.bot_token or config.bot_token == "YOUR_BOT_TOKEN_HERE" then
    Log("^1MISSING BOT TOKEN IN CONFIG.LUA!^0", "error")
    return
end

if not config.guild_id or config.guild_id == "YOUR_GUILD_ID_HERE" then
    Log("^1MISSING GUILD ID IN CONFIG.LUA!^0", "error")
    return
end

-- Get player identifiers
local function GetSafeIdentifiers(playerId)
    local identifiers = GetPlayerIdentifiers(playerId)
    local valid = {}
    
    for _, v in pairs(identifiers) do
        if string.match(v, "discord:") then
            valid.discord = v
        elseif string.match(v, "steam:") then
            valid.steam = v
        elseif string.match(v, "license:") then
            valid.license = v
        end
    end
    
    return valid
end

-- Fetch Discord data
local function FetchDiscordData(playerId, discordId)
    discordId = discordId:gsub("discord:", "")
    local url = ("https://discord.com/api/guilds/%s/members/%s"):format(config.guild_id, discordId)
    local headers = {
        ["Authorization"] = "Bot " .. config.bot_token,
        ["Content-Type"] = "application/json"
    }
    
    PerformHttpRequest(url, function(statusCode, data)
        if statusCode == 200 then
            local memberData = json.decode(data)
            local roles = memberData.roles or {}
            local avatar = memberData.user.avatar and 
                ("https://cdn.discordapp.com/avatars/%s/%s.png"):format(discordId, memberData.user.avatar) or nil
            
            PlayerDiscordData[playerId] = {
                username = memberData.user.username,
                discriminator = memberData.user.discriminator,
                roles = roles,
                avatar = avatar
            }
            
            Log(("Player ^5%s^0 (ID: ^5%d^0) connected | Discord: ^5%s#%s^0 | Roles: ^2%d^0 | Avatar: ^5%s^0"):format(
                GetPlayerName(playerId),
                playerId,
                PlayerDiscordData[playerId].username,
                PlayerDiscordData[playerId].discriminator,
                #roles,
                avatar and "Loaded" or "Default"
            ), "info")
        else
            if statusCode == 404 and config.kick_not_in_discord then
                DropPlayer(playerId, config.kick_message)
                Log(("Kicked ^5%s^0 (ID: ^5%d^0) - Not in Discord server"):format(
                    GetPlayerName(playerId), playerId), "info")
            elseif config.debug then
                Log(("Status ^1%d^0 for player ^5%d^0"):format(statusCode, playerId), "debug")
            end
        end
    end, "GET", "", headers, {}, config.timeout * 1000)
end

-- Player connection handler
AddEventHandler("playerJoining", function()
    local playerId = source
    local ids = GetSafeIdentifiers(playerId)
    
    if not ids.discord then
        if config.kick_not_in_discord then
            DropPlayer(playerId, "Discord not detected. Please make sure Discord is running.")
            Log(("Kicked ^5%s^0 (ID: ^5%d^0) - Discord not detected"):format(
                GetPlayerName(playerId), playerId), "info")
        elseif config.debug then
            Log(("Player ^5%d^0 has no Discord identifier"):format(playerId), "debug")
        end
        return
    end
    
    FetchDiscordData(playerId, ids.discord)
end)

-- Cleanup on disconnect
AddEventHandler("playerDropped", function(reason)
    local playerId = source
    if PlayerDiscordData[playerId] then
        Log(("^5%s^0 (ID: ^5%d^0) disconnected | Reason: ^1%s^0"):format(
            GetPlayerName(playerId), playerId, reason), "info")
        PlayerDiscordData[playerId] = nil
    end
end)

-- API Exports
local function ValidatePlayer(playerId)
    if not playerId or not PlayerDiscordData[playerId] then
        if config.debug then
            Log(("Invalid player ID: ^1%s^0"):format(playerId), "debug")
        end
        return false
    end
    return true
end

-- Get Discord Avatar URL
exports("GetDiscordAvatar", function(playerId)
    if not ValidatePlayer(playerId) then return nil end
    return PlayerDiscordData[playerId].avatar
end)

-- Get Discord Roles
exports("GetDiscordRoles", function(playerId)
    if not ValidatePlayer(playerId) then return {} end
    return PlayerDiscordData[playerId].roles
end)

-- Get Discord Username
exports("GetDiscordUsername", function(playerId)
    if not ValidatePlayer(playerId) then return nil end
    return PlayerDiscordData[playerId].username .. "#" .. PlayerDiscordData[playerId].discriminator
end)

-- Check if player has role
exports("HasDiscordRole", function(playerId, roleId)
    if not ValidatePlayer(playerId) then return false end
    for _, id in ipairs(PlayerDiscordData[playerId].roles) do
        if tostring(id) == tostring(roleId) then
            return true
        end
    end
    return false
end)

-- Startup message
CreateThread(function()
    Wait(1000)
    Log("API initialized successfully", "system")
    Log(("Guild ID: ^5%s^0"):format(config.guild_id), "system")
end)