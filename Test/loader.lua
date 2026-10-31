local HttpService = game:GetService("HttpService")

local API = "https://easyauth-production.up.railway.app/v1/load"
local SCRIPT = "main"
local LIBRARY = "https://raw.githubusercontent.com/omerkasd/EasySoftware/refs/heads/main/EasyLibrary/"

local function deviceId()
	local ok, id = pcall(function()
		return gethwid and gethwid()
	end)
	if ok and type(id) == "string" and id ~= "" then
		return id
	end
	return game:GetService("RbxAnalyticsService"):GetClientId()
end

local hwid = deviceId()
local source

local function check(key)
	local url = API .. "?key=" .. HttpService:UrlEncode(key) .. "&hwid=" .. HttpService:UrlEncode(hwid) .. "&script=" .. SCRIPT
	local okGet, raw = pcall(game.HttpGet, game, url)
	if not okGet then
		return false, "Couldn't reach the key server, try again."
	end
	local okJson, data = pcall(HttpService.JSONDecode, HttpService, raw)
	if not okJson or type(data) ~= "table" then
		return false, "Unexpected answer from the key server."
	end
	if data.ok and type(data.script) == "string" then
		source = data.script
		shared.EasyAuth = { key = key, kind = data.kind, plan = data.plan, expiresAt = data.expiresAt }
		return true
	end
	return false, data.message or "Invalid key."
end

local KeyUI = loadstring(game:HttpGet(LIBRARY .. "key_ui.lua"))()
local key = KeyUI.new({
	Title = "EasyCheatz",
	Subtitle = "Enter your key",
	KeyLink = "https://work.ink/2FLz/easycheatz",
	Validate = check,
}):Wait()

if not key or not source then
	return
end

local run = loadstring(source)
if run then
	run()
end
