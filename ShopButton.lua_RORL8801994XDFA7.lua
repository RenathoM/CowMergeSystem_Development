-- CLIENTE: ShopButton.lua
local btn = script.Parent
local players = game:FindChild("Players")
local player = players.LocalPlayer
local environment = game:FindChild("Environment")
local banco = environment:FindChild("BancoDados")
local cd = false

btn.Clicked:Connect(function()
    if cd then return end
    
    local comprasFolder = environment:FindChild("Compras")
    
    if comprasFolder and player and banco then
        -- 1. Verificação Local de Saldo para o Log
        local minhaConta = banco:FindChild(player.Name)
        
        -- Aqui você define o preço atual (mesma lógica do servidor)
        -- Se você tiver a função GetCurrentPrice no cliente, use-a. 
        -- Por enquanto, usaremos uma estimativa ou apenas checaremos se a conta existe.
        
        if minhaConta then
            cd = true
            
            -- Criamos o ticket
            local ticket = Instance.new("Part")
            ticket.Name = player.Name 
            ticket.Color = Color.FromHex('#ffffff00')
            ticket.Parent = comprasFolder
            
            -- O Log de sucesso no envio do ticket
            print("LOG: [LOJA] Ticket enviado para: " .. player.Name)
            
            wait(0.5)
            cd = false
        else
            -- LOG que você solicitou quando não houver conta ou saldo
            print("LOG: [LOJA] Jogador: " .. player.Name .. " Sem saldo ou conta não encontrada")
        end
    else
        print("LOG: [LOJA] Erro: Pasta Compras ou Banco não encontrados.")
    end
end)