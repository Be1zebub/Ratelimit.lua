-- from gmod.one with <3
-- https://github.com/Be1zebub/Ratelimit.lua

-- Sliding window rate limiting lib
-- inspired by discord api rate limiting

local enableDebug = false

local function debugLog(msg, ...)
	if enableDebug == false then return end

	if ... then
		msg = msg:format(...)
	end

	print("[rate-limiter debug]: " .. msg)
end

return function(length, count, weak, getTime)
	assert(type(length) == "number" and length > 0, "length must be a positive number")
	assert(type(count) == "number" and count > 0, "count must be a positive number")

	getTime = getTime or CurTime or os.time
	local requests = weak and setmetatable({}, {__mode = "k"}) or {}
	local bans = weak and setmetatable({}, {__mode = "k"}) or {}

	local function rateLimiter(uid)
		local curTime = getTime()

		-- Check is currently banned
		if bans[uid] and bans[uid] > curTime then
			debugLog("%s is banned for %s seconds", uid, bans[uid] - curTime)
			return false, bans[uid] - curTime -- false = blocked, return remaining ban time
		end

		-- Clear expired ban
		if bans[uid] then
			debugLog("%s is unbanned", uid)
			bans[uid] = nil
		end

		-- Get or create request history
		local instance = requests[uid]
		if not instance then
			debugLog("%s has no request history, creating new one", uid)
			instance = {}
			requests[uid] = instance
		end

		-- Cleanup expired entries
		local validEntries = {}
		local threshold = curTime - length

		for _, timestamp in ipairs(instance) do
			if timestamp >= threshold then
				validEntries[#validEntries + 1] = timestamp
			end
		end
		requests[uid] = validEntries

		-- Check if rate limit is exceeded
		if #validEntries >= count then
			local oldestValid = validEntries[1] -- entries are naturally sorted by insertion time
			local banDuration = length - (curTime - oldestValid)

			bans[uid] = curTime + banDuration

			debugLog("%s is ratelimited for %s seconds", uid, banDuration)
			return false, banDuration -- false = blocked, return ban duration
		end

		-- Add current request to history
		validEntries[#validEntries + 1] = curTime

		debugLog("%s is allowed to request, requests window %s/%s", uid, #validEntries, count)
		return true, 0 -- true = allowed
	end

	local function cleanup()
		requests = weak and setmetatable({}, {__mode = "k"}) or {}
		bans = weak and setmetatable({}, {__mode = "k"}) or {}
	end

	local function cleanupBy(uid)
		requests[uid] = nil
		bans[uid] = nil
	end

	local function getRequests(uid)
		return requests[uid]
	end

	local function getBan(uid)
		return bans[uid]
	end

	return setmetatable({
		cleanup = cleanup,
		cleanupBy = cleanupBy,
		getRequests = getRequests,
		getBan = getBan
	}, {
		__call = function(_, uid)
			return rateLimiter(uid)
		end,
		__newindex = function() end
	})
end

--[[ usage example:
local newRatelimiter = require("ratelimit")

function channel:onReceiveMessage(msg)
	if self.rateLimiter == nil then
		self.rateLimiter = newRatelimiter(5, 5) -- allow 5 messages per 5 seconds (per channel)
	end

	if self.rateLimiter(msg.author.id) then
		self:pushMessage(msg) -- push message to channel if ratelimit not reached
	end
end
]]--

--[[ usage example 2:
local rateLimiter = require("ratelimit")(60 * 60, 3) -- allow 3 bans per 1 hour

command.new("ban")
:SetPermission("admin")
:OnExecute(function(user, target, length, reason)
	local success, banDuration = rateLimiter(user:UserID())

	if success then
		target:Ban(length, reason)
		chat.broadcast(user:Name() .. " has banned " .. target:Name() .. " for " .. length .. " seconds. Reason: " .. reason)
	else
		chat.send(user, "You are being rate limited. Please wait .. " .. math.Round(banDuration / 60, 2) .. " minutes before banning again.")
	end
end)
]]--
