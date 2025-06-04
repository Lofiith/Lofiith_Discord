-- Fully server-sided, modders cannot dump it.

Config = {
    bot_token = "PUT_BOT_TOKEN_HERE", -- Your Discord bot token
    guild_id = "PUT_GUILD_ID_HERE", -- Your Discord server (guild) ID
    debug = true, -- Set to false to disable debug messages in the console   
    timeout = 5, -- Timeout in seconds for Discord API requests
    kick_not_in_discord = true, -- Set to true to kick players not in the Discord server
    kick_message = "You must be in our Discord server to play!" -- Message sent to players who are kicked for not being in the Discord server
} 
