-- CLIENTE: MoneyUI.lua
local label = script.Parent
local player = game:FindChild("Players").LocalPlayer
local environment = game:FindChild("Environment")
local banco = environment:FindChild("BancoDados")

-- Localização dos sons (Protegida)
local elementos = game:FindChild("Hidden"):FindChild("Elementos")
local soundSuccess = elementos elementos:FindChild("Sucess")
local somDinheiro = elementos elementos:FindChild("Money") 
local soundTemplateError = elementos elementos:FindChild("Error")

-- 1. FUNÇÃO DE FORMATAÇÃO
local function Abbreviate(value)
    if value == nil or type(value) ~= "number" then return "0" end
    local units = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No"}
    local unitIndex = 1
    local val = math.floor(value)
    while val >= 1000 and unitIndex < #units do
        val = val / 1000
        unitIndex = unitIndex + 1
    end
    if unitIndex == 1 then return tostring(math.floor(val)) end
    return string.format("%.2f", val):gsub("%.?0+$", "") .. units[unitIndex]
end

-- 2. LOOP DE ATUALIZAÇÃO (Roda sempre, sem travar)
spawn(function()
    while true do
        if banco then
            local myMoney = banco:FindChild(player.Name)
            if myMoney then
                label.Text = "$" .. Abbreviate(myMoney.Value)
            else
                label.Text = "$0" -- Se a conta ainda não foi criada
            end
        end
        wait(0.5)
    end
end)

-- 3. LOGICA DE FEEDBACK (Em paralelo para não bloquear o script)
spawn(function()
    local feedbackObj = player:FindChild("Feedback")
    while not feedbackObj do 
        wait(1) 
        feedbackObj = player:FindChild("Feedback")
    end

    feedbackObj.Changed:Connect(function(val)
        if val == "Success" then
            label.TextColor = Color.New(0, 1, 0, 1)
            if soundSuccess then soundSuccess:Play() end
            wait(0.5)
            label.TextColor = Color.New(1, 1, 1, 1)
        elseif val == "Money" then
            if somDinheiro then somDinheiro:Play() end
            label.TextColor = Color.New(0.8, 1, 0.8, 0.8) 
            wait(0.2)
            label.TextColor = Color.New(1, 1, 1, 1)
        elseif val == "Error" then
            label.TextColor = Color.New(1, 0, 0, 1)
            if soundTemplateError then soundTemplateError:Play() end
            wait(0.5)
            label.TextColor = Color.New(1, 1, 1, 1)
        end
        if val ~= "" then feedbackObj.Value = "" end
    end)
end)