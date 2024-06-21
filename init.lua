-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Ratelimit.lua

--[[ usage example:
local rateLimit = require("ratelimit")

function channel:onReceiveMessage(msg)
	if self.rateLimiter == nil then
		self.rateLimiter = rateLimit(5, 5, true) -- allow 5 messages per 5 seconds per channel (ratelimiter storage is weak in this case)
	end

	if self.rateLimiter(msg.author.id) then
		self:pushMessage(msg) -- push message to channel if ratelimit not reached
	end
end
]]--

--[[ usage example 2:
local rateLimiter = require("ratelimit")(60 * 60, 3) -- allow 3 bans per 1 hour

function canBan(admin, user)
	if rateLimiter(admin.id) then
		ban(admin, user)
	end
end
]]--

-- src:

return function(length, count, weak, getTime)
    getTime = getTime or CurTime or os.time

    local storage = weak and setmetatable({}, {__mode = "k"}) or {}
    local bans = weak and setmetatable({}, {__mode = "k"}) or {}

    return function(uid)
        local curTime = getTime()

        if bans[uid] then
            if bans[uid] > curTime then
                return true, bans[uid] - curTime
            end
            bans[uid] = nil
        end

        local instance = storage[uid]
        if instance == nil then
            instance = {}
            storage[uid] = instance
        end

        local i = 1
        while i <= #instance do
            if instance[i] < curTime - length then
                table.remove(instance, i)
            else
                i = i + 1
            end
        end

        if #instance >= count then
            local min = math.min(table.unpack(instance))
            local left = length - (curTime - min)
            bans[uid] = curTime + left
            return true, left
        end

        table.insert(instance, curTime)
        return false
    end, storage, bans
end
