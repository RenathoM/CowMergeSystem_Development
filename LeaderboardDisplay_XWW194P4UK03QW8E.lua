-- CLIENTE: LeaderboardDisplay.lua
local leaderboardFolder = script.Parent
local environment = game:FindChild("Environment")
local leaderboardData = nil

local timeLeft = 65
local lastDetectedUpdate = 0
local dots = ""


-- AGUARDAR PASTA (Manual, já que não tem WaitForChild)
while not leaderboardData do
    leaderboardData = environment:FindChild("LeaderboardData")
    if not leaderboardData then
        print("LOG: Aguardando LeaderboardData...")
        wait(60)
    end
end

local timerLabel = nil
while not timerLabel do
    timerLabel = leaderboardFolder:FindChild("Timer")
    wait(60)
end

-- 1. FUNÇÃO DE FORMATAÇÃO
local function Abbreviate(value)
    local val = tonumber(value) or 0
    local units = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No"}
    local unitIndex = 1
    while val >= 1000 and unitIndex < #units do
        val = val / 1000
        unitIndex = unitIndex + 1
    end
    if unitIndex == 1 then return tostring(math.floor(val)) end
    return string.format("%.1f", val):gsub("%.?0+$", "") .. units[unitIndex]
end

-- 2. ANIMAÇÃO DOS PONTINHOS (Independente)
spawn(function()
    while true do
        if dots == "..." then dots = "" else dots = dots .. "." end
        wait(0.5)
    end
end)

-- 3. CRONÔMETRO VISUAL (Independente - 1 em 1 segundo)
spawn(function()
    while true do
        if timeLeft > 0 then
            timeLeft = timeLeft - 1
            if timerLabel then
                timerLabel.Text = "Updating in " .. timeLeft .. "s"
            end
        else
            if timerLabel then
                timerLabel.Text = "Updating..."
            end
        end
        wait(1)
    end
end)

-- 4. ATUALIZAÇÃO DOS JOGADORES E SINCRONIA (A cada 0.5s)
spawn(function()
    while true do
        if leaderboardData then
            -- Sincroniza o Timer com o Servidor
            local updateNode = leaderboardData:FindChild("LastUpdate")
            if updateNode and updateNode.Value ~= lastDetectedUpdate then
                lastDetectedUpdate = updateNode.Value
                timeLeft = 65 -- Reinicia o cronômetro visual
            end

            -- Atualiza as Labels P1 até P8
            local totalRanks = #leaderboardData:GetChildren()
            for i = 1, 8 do
                local label = leaderboardFolder:FindChild("P" .. i)
                if label then
                    local dataNode = leaderboardData:FindChild("Rank" .. i)
                    
                    if dataNode then
                        -- TEM JOGADOR (Final FF = Visível)
                        local info = string.split(dataNode.Value, "|")
                        label.Text = i .. ". " .. info[1] .. " - $" .. Abbreviate(info[2])
                        label.Color = Color.FromHex("#FEFEFE02")
                    else
                        -- NÃO TEM JOGADOR
                        if totalRanks <= 1 then -- Só tem o LastUpdate ou nada
                            label.Text = "Loading" .. dots
                            label.Color = Color.FromHex("#FEFEFE02") -- 70% Visível
                        else
                            -- VAGA VAZIA (Final 00 = Invisível)
                            label.Text = ""
                            label.Color = Color.FromHex("#FFFFFF00")
                        end
                    end
                end
            end
        end
        wait(0.5)
    end
end)