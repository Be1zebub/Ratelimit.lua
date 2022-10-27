# Ratelimit.lua

A ratelimit library that allow X times in X time.

## Installation

1. Open your project folder
2. Run `apt install git && git clone git@github.com:Be1zebub/Ratelimit.lua.git deps/ratelimit.lua`
3. Have fun ;)

## Examples

```lua
local rateLimit = require("ratelimit")

function channel:onReceiveMessage(msg)
	if self.rateLimiter == nil then
		self.rateLimiter = rateLimit(5, 5, true) -- allow 5 messages per 5 seconds per channel (ratelimiter storage is weak in this case)
	end

	if self.rateLimiter(msg.author.id) then
		self:pushMessage(msg) -- push message to channel if ratelimit not reached
	end
end
```

```lua
local rateLimiter = require("ratelimit")(60 * 60, 3) -- allow 3 bans per 1 hour

function canBan(admin, user)
	if rateLimiter(admin.id) then
		ban(admin, user)
	end
end
```

Join to our developers community [incredible-gmod.ru](https://discord.incredible-gmod.ru)
[![thumb](https://i.imgur.com/LYGqTnx.png)](https://discord.incredible-gmod.ru)
