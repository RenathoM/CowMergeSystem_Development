-- CLIENTE: BotãoBuyGamepass
local botao = script.Parent
local netEvent = game:FindChild("Environment"):FindChild("GamepassEvent")
local jaPossui = false -- Variável de controle

if netEvent then
    -- 1. Ao iniciar o botão, pergunta ao servidor se já possui a gamepass
    local checkMsg = NetMessage.New()
    checkMsg:AddString("Type", "CheckGamepassOwned")
    netEvent:InvokeServer(checkMsg)
    
    -- 2. Fica escutando a resposta do servidor
    netEvent.InvokedClient:Connect(function(sender, message)
        local msgType = message:GetString("Type")
        
        if msgType == "GamepassOwnedResult" then
            local isOwned = message:GetString("IsOwned")
            
            if isOwned == "true" then
                jaPossui = true
                botao.Text = "Owned"
                -- Opcional: muda a cor do botão (exemplo: verde) para ficar visualmente claro
                -- botao.Color = Color.FromHex("#4CAF50FF") 
                print("LOG: [CLIENTE] Status atualizado: Owned")
            end
        end
    end)
end

-- 3. Lógica ao clicar no botão
botao.Clicked:Connect(function()
    -- Se já possuir a gamepass, ignora o clique e não abre a loja
    if jaPossui == true then
        print("LOG: [CLIENTE] Você já possui esta gamepass.")
        return 
    end

    if netEvent then
        local message = NetMessage.New()
        message:AddString("Type", "PromptGamepassUnica")
        
        netEvent:InvokeServer(message)
        print("LOG: [CLIENTE] Mensagem enviada solicitando a compra.")
    else
        print("ERRO: Objeto 'GamepassEvent' não encontrado no Environment!")
    end
end)