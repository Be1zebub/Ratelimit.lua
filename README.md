# Ratelimit.lua

A ratelimit library that allow X times in Y time.  
Sliding window rate limiting - inspired by discord api.

eg allow 5 messages in 5 seconds

## Installation

1. Open your project folder
2. Run `apt install git && git clone git@github.com:Be1zebub/Ratelimit.lua.git deps/ratelimit`
3. Have fun ;)

## Examples

```lua
local newRatelimiter = require("ratelimit")

function channel:onReceiveMessage(msg)
	if self.rateLimiter == nil then
		self.rateLimiter = newRatelimiter(5, 5) -- allow 5 messages per 5 seconds (per channel)
	end

	if self.rateLimiter(msg.author.id) then
		self:pushMessage(msg) -- push message to channel if ratelimit not reached
	end
end
```

```lua
local rateLimiter = require("ratelimit")(60 * 60, 3) -- allow 3 bans per 1 hour

command.new("ban")
:SetPermission("admin")
:OnExecute(function(ply, target, length, reason)
	local success, banDuration = rateLimiter(ply:SteamID())

	if success then
		target:Ban(length, reason)
		chat.broadcast(ply:Name() .. " has banned " .. target:Name() .. " for " .. length .. " seconds. Reason: " .. reason)
	else
		chat.send(ply, "You are being rate limited. Please wait .. " .. math.Round(banDuration / 60) .. " minutes before banning again.")
	end
end)
```

#### Join to our developers community [gmod.one](https://discord.gmod.one)
[![thumb](https://i.imgur.com/LYGqTnx.png)](https://discord.gmod.one)
