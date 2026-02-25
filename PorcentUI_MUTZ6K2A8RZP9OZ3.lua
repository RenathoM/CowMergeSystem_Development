-- CLIENTE: PorcentUI.lua
local label = script.Parent
local player = game:FindChild("Players").LocalPlayer
local environment = game:FindChild("Environment")
local banco = environment:FindChild("BancoDados")

-- CONFIGURAÇÕES (Devem ser iguais às do MergeManager)
local PRECO_INICIAL = 50
local MULTIPLICADOR = 1.05

-- 1. FUNÇÃO DE FORMATAÇÃO (Igual ao MoneyUI para manter o padrão)
local function Abbreviate(value)
    local units = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No"}
    local unitIndex = 1
    while value >= 1000 and unitIndex < #units do
        value = value / 1000
        unitIndex = unitIndex + 1
    end
    if unitIndex == 1 then return tostring(math.floor(value)) end
    local formatted = string.format("%.2f", value):gsub("%.?0+$", "")
    return formatted .. units[unitIndex]
end

-- 2. LÓGICA DE ATUALIZAÇÃO DO PREÇO
spawn(function()
    while true do
        wait(0.5) -- Atualiza a cada meio segundo
        
        if player and banco then
            local minhaConta = banco:FindChild(player.Name)
            
            if minhaConta then
                -- Procuramos o contador de compras que o servidor criou
                local totalCompras = minhaConta:FindChild("TotalCompras")
                local quantidade = 0
                
                if totalCompras then
                    quantidade = totalCompras.Value
                end
                
                -- Cálculo do preço: Inicial * (1.15 ^ quantidade)
                local precoAtual = math.floor(PRECO_INICIAL * (MULTIPLICADOR ^ quantidade))
                
                -- Atualiza o texto da Label
                label.Text = "Cost: $" .. Abbreviate(precoAtual)
            else
                label.Text = "Cost: $50"
            end
        end
    end
end)