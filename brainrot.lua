-- Executor-Friendly Brainrot Detector + Discord + Server Hop + Emojis + Auto Queue-on-Teleport

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- === CONFIG ===
local PLACE_ID = 109983668079237
local WEBHOOK_URL = "https://discord.com/api/webhooks/1414016306637701120/KKFWvt28JIT2kAz0r486d0POxCQ4w6BcxuY8ESngCTSK9XLrVGM4uvbNov5nMqGKhdbc"
local TEST_THRESHOLD = 1
local HOP_INTERVAL = 2 -- fast testing

local detected = {}

-- === QUEUE SCRIPT ON TELEPORT (XENO/Synapse compatible) ===
if syn and syn.queue_on_teleport then
    syn.queue_on_teleport('loadstring(game:HttpGet("YOUR_SCRIPT_URL"))()')
end

-- Executor HTTP function
local requestFunction = syn and syn.request or http_request or fluxus and fluxus.request
if not requestFunction then
    warn("No executor HTTP function found! Discord and server hop will not work.")
end

-- Send brainrot info to Discord with emojis
local function sendToDiscord(brainrotName, value)
    if not requestFunction then return end

    local playerCount = #Players:GetPlayers()
    local jobId = game.JobId

    local message = "**🚨 Brainrot Detected!**\n" ..
                    "🧠 **Name:** "..brainrotName.."\n" ..
                    "💰 **Value/sec:** "..value.."\n" ..
                    "👥 **Players in Server:** "..playerCount.."\n" ..
                    "🆔 **Server Job ID:** "..jobId

    requestFunction({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({content = message})
    })
end

-- Detect a brainrot
local function detectBrainrot(brainrot)
    for _, val in ipairs(brainrot:GetChildren()) do
        if val:IsA("NumberValue") or val:IsA("IntValue") then
            if val.Value >= TEST_THRESHOLD and not detected[brainrot] then
                detected[brainrot] = true
                sendToDiscord(brainrot.Name, val.Value)
                print("Detected brainrot:", brainrot.Name, val.Value)
            end
        end
    end
end

-- Recursive brainrots folder detection
local function findBrainrotsFolder(parent)
    for _, child in ipairs(parent:GetChildren()) do
        for _, sub in ipairs(child:GetChildren()) do
            if sub:IsA("NumberValue") or sub:IsA("IntValue") then
                print("Brainrots folder detected:", child:GetFullName())
                return child
            end
        end
        local result = findBrainrotsFolder(child)
        if result then return result end
    end
    return nil
end

local brainrotsFolder = findBrainrotsFolder(Workspace)
if not brainrotsFolder then
    warn("No brainrots folder detected!")
    return
end

-- Detect existing brainrots immediately
for _, brainrot in ipairs(brainrotsFolder:GetChildren()) do
    detectBrainrot(brainrot)
end

-- Detect new brainrots
brainrotsFolder.ChildAdded:Connect(detectBrainrot)

-- === SERVER HOP USING PUBLIC SERVERS API ===
local function hopToAnotherServer()
    if not requestFunction then return end

    local url = "https://games.roblox.com/v1/games/"..PLACE_ID.."/servers/Public?sortOrder=Asc&limit=100"
    local success, response = pcall(function()
        return requestFunction({Url = url, Method = "GET"})
    end)

    if success and response.Body then
        local data = HttpService:JSONDecode(response.Body)
        if data and data.data then
            local servers = data.data

            -- Shuffle servers
            for i = #servers, 2, -1 do
                local j = math.random(1, i)
                servers[i], servers[j] = servers[j], servers[i]
            end

            for _, server in ipairs(servers) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(PLACE_ID, server.id, LocalPlayer)
                    print("Server hop to:", server.id)
                    return
                end
            end
        end
    else
        warn("Failed to fetch server list")
    end
end

-- Automatic server hopping loop
spawn(function()
    while wait(HOP_INTERVAL) do
        hopToAnotherServer()
    end
end)

print("Executor brainrot detector running! Brainrots folder:", brainrotsFolder:GetFullName())
