-- SERVIDOR: GamepassHandler.lua
local ID_DA_GAMEPASS = 100337 -- COLOQUE O SEU ID REAL AQUI
local netEvent = game:FindChild("Environment"):FindChild("GamepassEvent")

if netEvent then
    netEvent.InvokedServer:Connect(function(player, message)
        local msgType = message:GetString("Type")
        
        -- 1. Cliente pedindo para checar se já possui a gamepass ao entrar no jogo
        if msgType == "CheckGamepassOwned" then
            local temGamepass = false
            pcall(function() 
                temGamepass = Purchases:UserOwnsAsset(player, ID_DA_GAMEPASS) 
            end)
            
            -- Envia a resposta de volta ao cliente
            local reply = NetMessage.New()
            reply:AddString("Type", "GamepassOwnedResult")
            if temGamepass == true then
                reply:AddString("IsOwned", "true")
            else
                reply:AddString("IsOwned", "false")
            end
            netEvent:InvokeClient(reply, player)
        end
        
        -- 2. Cliente clicou em comprar
        if msgType == "PromptGamepassUnica" then
            print("LOG: [SERVIDOR] Abrindo prompt para " .. player.Name)
            
            Purchases:Prompt(player, ID_DA_GAMEPASS, function(success, error)
                -- Corrigido para "success == true"
                if success == true then
                    print("LOG: [SUCESSO] " .. player.Name .. " comprou a Gamepass!")
                    
                    -- Se ele comprou agora, avisa o cliente para mudar o botão para "Owned" instantaneamente
                    local reply = NetMessage.New()
                    reply:AddString("Type", "GamepassOwnedResult")
                    reply:AddString("IsOwned", "true")
                    netEvent:InvokeClient(reply, player)
                else
                    print("LOG: [AVISO] Compra cancelada ou erro: " .. tostring(error))
                end
            end)
        end
    end)
else
    print("ERRO CRÍTICO: GamepassEvent não encontrado para o Servidor!")
end