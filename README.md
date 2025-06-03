## Installation

1. Download and place the `Lofi_discord` folder in your resources directory
2. Add `ensure Lofi_discord` to your server.cfg
3. Configure your Discord bot token and guild ID in `server/config.lua`

## Configuration

Edit `server/config.lua`:
- `BotToken`: Your Discord bot token
- `GuildId`: Your Discord server ID
- `EnableAntiCheat`: Enable rate limiting and security features (optional)
- `RequireDiscord`: Kick players without Discord linked (optional)

## Bot Setup

1. Go to https://discord.com/developers/applications
2. Create a new application
3. Go to "Bot" section and create a bot
4. Copy the bot token to your config
5. Invite the bot to your Discord server with appropriate permissions

## Usage Examples

All exports are server-side for security. Use callbacks for async operations:

```lua
-- Get Discord avatar
exports['Lofi_discord']:GetDiscordAvatar(source, function(avatarUrl)
    -- Use avatarUrl here
end)

-- Check for role
exports['Lofi_discord']:HasDiscordRole(source, "roleId", function(hasRole)
    if hasRole then
        -- Player has the role
    end
end)
```

## Features

- ✅ Lightweight and fast
- ✅ Built-in rate limiting
- ✅ Data caching
- ✅ Security against modders
- ✅ Easy to use exports
- ✅ Automatic connection logging
- ✅ Error handling
