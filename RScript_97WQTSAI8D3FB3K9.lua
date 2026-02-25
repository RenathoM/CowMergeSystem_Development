local Players = game["Players"]
local LocalPlayer = Players.LocalPlayer
local environment = game:FindChild("Environment")
local banco = environment:FindChild("BancoDados")

-- Calibração de Posição (Mantido seu padrão original)
local FIXED_X = 0.87 
local POSITIONS = {0.9, 0.842, 0.783, 0.724, 0.666, 0.607, 0.548}

-- Função para formatar números (ex: 1.000)
local function FormatNumber(value)
    local formatted = tostring(value)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
        if (k == 0) then break end
    end
    return formatted
end

-- Pega o dinheiro do BancoDados baseado no nome do jogador
local function GetMoney(player)
    local moneyValue = 0
    pcall(function()
        local valObj = banco:FindChild(player.Name)
        if valObj then
            moneyValue = valObj.Value
        end
    end)
    return moneyValue
end

local function UpdateLeaderboard()
    local container = script.Parent -- A UIView que contém as UILabels
    local allPlayers = Players:GetPlayers()
    
    -- Ordena os jogadores pelo dinheiro no BancoDados
    table.sort(allPlayers, function(a, b)
        return GetMoney(a) > GetMoney(b)
    end)

    for i = 1, 7 do
        local labelName = "P" .. i
        -- No Polytoria usamos FindChild para evitar erros
        local label = container:FindChild(labelName)
        
        if label and label.ClassName == "UILabel" then
            local p = allPlayers[i]
            
            if p then
                label.Visible = true
                local money = GetMoney(p)
                
                -- Texto formatado para o tema de Vacas/Money
                label.Text = i .. ". " .. p.Name .. ": $" .. FormatNumber(math.floor(money))
                
                -- Ajuste de posição conforme sua tabela POSITIONS
                local targetY = POSITIONS[i] or 0
                pcall(function()
                    -- Nota: No Polytoria, verifique se usa .Position ou .PositionRelative
                    label.Position = Vector2.new(FIXED_X, targetY)
                end)
                
                -- Cor de destaque para o próprio jogador (Amarelo)
                if p == LocalPlayer then
                    label.TextColor = Color.new(1, 1, 0)
                else
                    label.TextColor = Color.new(1, 1, 1)
                end
            else
                -- Se houver menos de 7 jogadores, esconde as labels restantes
                label.Visible = false
            end
        end
    end
end

-- Loop de atualização
while true do
    UpdateLeaderboard()
    wait(2) -- Atualiza a cada 2 segundos para não pesar
end