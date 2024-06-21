# Ratelimit.lua

A ratelimit library that allow X times in Y time. 
like: allow 5 chat messages in 5 seconds (with same global ratelimit it much convenient for user than hard ratelimit) 

## Installation

1. Open your project folder
2. Run `apt install git && git clone git@github.com:Be1zebub/Ratelimit.lua.git deps/ratelimit`
3. Have fun ;)

## Examples

```lua
local rateLimit = require("ratelimit")

function channel:onReceiveMessage(msg)
	if self.rateLimiter == nil then
		self.rateLimiter = rateLimit(5, 5, true) -- allow 5 messages per 5 seconds per channel (ratelimiter storage is weak in this case)
	end

	if self.rateLimiter(msg.author.id) == false then
		self:pushMessage(msg) -- push message to channel if ratelimit not reached
	end
end
```

```lua
local rateLimiter = require("ratelimit")(60 * 60, 3) -- allow 3 bans per 1 hour

function canBan(admin, user)
	if rateLimiter(admin.id) == false then
		ban(admin, user)
	end
end
```
```lua
function Command:SetCooldown(length, count, weak)
	self.cooldown = ratelimit(length, count, weak)
	return self
end

function Command:testCooldown(msg)
	if self.cooldown then
		local cooldown, left = self.cooldown(msg.author.id) -- it can return time before cooldown ends
		if cooldown then
			msg:addReaction("🕖")
			numberReacts(msg, left)
			return true
		end
	end

	return false
end
```

#### Join to our developers community [incredible-gmod.ru](https://discord.incredible-gmod.ru)
[![thumb](https://i.imgur.com/LYGqTnx.png)](https://discord.incredible-gmod.ru)
