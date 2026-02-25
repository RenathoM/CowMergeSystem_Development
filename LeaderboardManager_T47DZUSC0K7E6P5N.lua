-- SERVIDOR: LeaderboardManager.lua
local VERSION = "v1"
local RANK_KEY = "GlobalTop_" .. VERSION
local globalDS = Datastore:GetDatastore("GlobalData")

local environment = game:FindChild("Environment")
local banco = environment:FindChild("BancoDados")
local lbDataFolder = environment:FindChild("LeaderboardData")

-- Função para atualizar uma entrada
local function UpdateGlobalEntry(name, value)
    -- IMPORTANTE: Verifica se o DS carregou antes de tentar Get/Set
    if globalDS.Loading then return end

    globalDS:Get(RANK_KEY, function(data, success)
        if not success then return end
        
        local top = type(data) == "table" and data or {}
        top[name] = math.floor(value)
        
        local list = {}
        for n, v in pairs(top) do table.insert(list, {Name = n, Value = v}) end
        table.sort(list, function(a, b) return a.Value > b.Value end)
        
        local newTop = {}
        for i = 1, math.min(10, #list) do
            newTop[list[i].Name] = list[i].Value
        end
        
        globalDS:Set(RANK_KEY, newTop, function(s, err)
            if s then print("LOG: [SUCESSO] " .. name .. " enviado ao Global!") 
            else print("LOG: [ERRO DS] " .. tostring(err)) end
        end)
    end)
end

-- Loop de Sincronia
spawn(function()
    while true do
        -- Espera o DS carregar na primeira vez
        while globalDS.Loading do wait(5) end
        
        if banco then
            local children = banco:GetChildren()
            for _, conta in pairs(children) do
                if conta.Value > 0 then 
                    UpdateGlobalEntry(conta.Name, conta.Value) 
                    wait(5) -- Aumentei para 1 min para EVITAR Rate Limit na Web
                end
            end
        end
        
        -- Após tentar enviar, atualiza a pasta local para os clientes verem
        globalDS:Get(RANK_KEY, function(data, success)
            if success and data then
                local sorted = {}
                for n, v in pairs(data) do table.insert(sorted, {Name = n, Value = v}) end
                table.sort(sorted, function(a, b) return a.Value > b.Value end)

                for i = 1, 8 do
                    local node = lbDataFolder:FindChild("Rank"..i) or Instance.new("StringValue", lbDataFolder)
                    node.Name = "Rank"..i
                    node.Value = sorted[i] and (sorted[i].Name.."|"..sorted[i].Value) or "---|0"
                end
                
                local lu = lbDataFolder:FindChild("LastUpdate") or Instance.new("NumberValue", lbDataFolder)
                lu.Name = "LastUpdate"; lu.Value = os.time()
            end
        end)
        wait(30)
    end
end)