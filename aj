-- ULTIMATE UNIVERSAL BRAINROT SNIPER v16: AUTO-JOIN **OFF** (Manual Copy Only)
-- Zenith, Fluxus, Delta, Krnl, Volcano, Script-Ware – 100% Compatible
-- NO TELEPORT, JUST **COPY ID + F9 ALERTS**
-- PASTE → EXECUTE → **VAMOOOOOS!**

print("========================================")
print("v16: AUTO-JOIN **DISABLED**")
print("ID COPIED TO CLIPBOARD – PASTE & JOIN MANUALLY")
print("========================================")

local HttpService = game:GetService("HttpService")
local ws = nil
local connected = false

-- UNIVERSAL CONNECT FUNCTION
local function createWS()
    pcall(function()
        ws = nil

        if syn and syn.websocket and type(syn.websocket.connect) == "function" then
            ws = syn.websocket.connect("ws://127.0.0.1:1488")
            print("ZENITH MODE ACTIVE")

        elseif WebSocket and type(WebSocket.connect) == "function" then
            ws = WebSocket.connect("ws://127.0.0.1:1488")
            print("FLUXUS/DELTA/KRNL/VOLCANO MODE ACTIVE")

        elseif websocket and type(websocket.connect) == "function" then
            ws = websocket.connect("ws://127.0.0.1:1488")
            print("SCRIPT-WARE MODE ACTIVE")

        else
            print("NO WEBSOCKET SUPPORT – UPDATE EXECUTOR")
            return
        end

        if not ws then
            print("WS FAILED – RE-INJECT")
            return
        end

        print("WEBSOCKET READY – LISTENING...")

        pcall(function()
            if ws.OnOpen then
                ws.OnOpen:Connect(function()
                    connected = true
                    print("CONNECTED TO PYTHON! SNIPER LIVE")
                end)
            end

            if ws.OnMessage then
                ws.OnMessage:Connect(function(msg)
                    local success, data = pcall(HttpService.JSONDecode, HttpService, msg)
                    if not success then
                        print("BAD JSON: " .. tostring(msg))
                        return
                    end

                    local jobid = tostring(data.jobid or "")
                    if #jobid < 5 then
                        print("INVALID JOB – SKIPPED")
                        return
                    end

                    print("BRAINROT DETECTED!")
                    print("Name: " .. tostring(data.name or "???"))
                    print("Money: $" .. tostring(data.money or "0") .. "/sec")
                    print("ID: " .. jobid)

                    if setclipboard then
                        setclipboard(jobid)
                        print("ID COPIED TO CLIPBOARD! (Ctrl+V to join)")
                    end

                    -- AUTO-JOIN **DISABLED** – NO TELEPORT
                end)
            end

            if ws.OnClose then
                ws.OnClose:Connect(function()
                    print("DISCONNECTED – RECONNECTING...")
                    connected = false
                    task.wait(3)
                    createWS()
                end)
            end

            if ws.OnError then
                ws.OnError:Connect(function(err)
                    print("WS ERROR: " .. tostring(err))
                end)
            end
        end)
    end)
end

createWS()

-- STATUS
task.spawn(function()
    while true do
        task.wait(10)
        print(connected and "SNIPER ACTIVE – COPYING IDS!" or "CONNECTING...")
    end
end)

print("SCRIPT LOADED – PRESS F9")
print("AUTO-JOIN OFF – YOU CONTROL WHEN TO JOIN")
print("VAMOOOOOS!")
