-- SERVIDOR: MergeManager.lua

local players = game:FindChild("Players")

local environment = game:FindChild("Environment")



-- MEUS MODELOS E PASTAS

local vModelosFolder = game:FindChild("Hidden"):FindChild("VModelos")

local vacasAtivas = environment:FindChild("VacasAtivas")

local comprasFolder = environment:FindChild("Compras")

local banco = environment:FindChild("BancoDados")

local areasFolder = environment:FindChild("AreasP") -- [NOVO] Pasta das áreas



-- ELEMENTOS VISUAIS

local elementosFolder = game:FindChild("Hidden"):FindChild("Elementos")

local particleTemplate = elementosFolder:FindChild("Particles")

local soundTemplate = elementosFolder:FindChild("Sucess")

local soundTemplateError = elementosFolder:FindChild("Error")



-- CONFIGURAÇÕES DE JOGO

local nextCowSerial = 1

local processandoFusao = {}

local cowCatalog = {}  

local PRECO_INICIAL = 50

local MULTIPLICADOR_CUSTO = 1.05

local SALDO_INICIAL = 200



-- CONFIGURAÇÕES DE SPAWN

local ocupacaoSlots = {} -- Tabela: [NomeJogador] = NumeroDoSlot (1 a 7)

local MAX_SLOTS = 7



local INCOME_PER_LEVEL = {

[1] = 2, [2] = 10, [3] = 30, [4] = 80, [5] = 200,

[6] = 450, [7] = 1000, [8] = 2200, [9] = 4800, [10] = 10000,

[11] = 22000, [12] = 48000, [13] = 100000, [14] = 210000, [15] = 450000,

[16] = 950000, [17] = 2000000, [18] = 4200000, [19] = 9000000, [20] = 20000000,

[21] = 45000000, [22] = 95000000, [23] = 200000000, [24] = 450000000, [25] = 1000000000,

[26] = 2200000000, [27] = 4800000000, [28] = 10000000000, [29] = 25000000000, [30] = 60000000000

}



-- 1. CARREGAR CATÁLOGO

if vModelosFolder then

for _, model in pairs(vModelosFolder:GetChildren()) do

local lvl = model.Name:match("%d+")

if lvl then cowCatalog[tonumber(lvl)] = model end

end

end



-- 2. FUNÇÕES AUXILIARES DE SLOT E POSIÇÃO [NOVO]

local function FindSafe(parent, targetName)

if not parent then return nil end



-- Busca direta primeiro

local found = parent:FindChild(targetName)

if found then return found end



-- Busca recursiva em todos os descendentes

for _, child in pairs(parent:GetChildren()) do

if child.Name == targetName then

return child

end

local subFound = FindSafe(child, targetName)

if subFound then return subFound end

end

return nil

end

-- Descobre os limites (Min/Max) baseados no bloco "Bolas Spawn"

local function GetSpawnBounds(part)

if not part then return nil end

local pos = part.Position

local size = part.Size

return {

minX = pos.X - (size.X / 2),

maxX = pos.X + (size.X / 2),

minZ = pos.Z - (size.Z / 2),

maxZ = pos.Z + (size.Z / 2)

}

end



-- Encontra um slot vazio (1 a 7)

local function AssignSlot(playerName)

-- Verifica se já tem slot

if ocupacaoSlots[playerName] then return ocupacaoSlots[playerName] end



-- Procura o primeiro livre

for i = 1, MAX_SLOTS do

local slotOcupado = false

for _, occupiedIndex in pairs(ocupacaoSlots) do

if occupiedIndex == i then slotOcupado = true break end

end



if not slotOcupado then

ocupacaoSlots[playerName] = i

print("LOG: Slot " .. i .. " atribuído para " .. playerName)

return i

end

end

return nil -- Servidor cheio

end



-- 3. SISTEMA DE SPAWN DINÂMICO [MODIFICADO]

function SpawnCow(level, pos, ownerName)

if not ownerName then return end



local template = cowCatalog[level]

if not template then return end



-- [MUDANÇA] Calcula posição baseada no slot do dono

local finalPos = pos and (pos + Vector3.new(0, 5, 0)) -- Se for fusão, usa a posição da fusão



if not finalPos then

-- Se for spawn novo (compra), busca a área do jogador

local slotIndex = ocupacaoSlots[ownerName]

if not slotIndex then

print("ERRO: Jogador " .. ownerName .. " sem slot atribuído!")

return

end



local mapFolder = areasFolder:FindChild("Map - P" .. slotIndex)

local spawnPart = mapFolder and mapFolder:FindChild("Bolas Spawn")



if spawnPart then

local sPos = spawnPart.Position

local sSize = spawnPart.Size



-- Usando minúsculas para garantir compatibilidade

local minX = sPos.x - (sSize.x / 2)

local maxX = sPos.x + (sSize.x / 2)

local minZ = sPos.z - (sSize.z / 2)

local maxZ = sPos.z + (sSize.z / 2)



local randomX = minX + math.random() * (maxX - minX)

local randomZ = minZ + math.random() * (maxZ - minZ)



finalPos = Vector3.new(randomX, 12.5, randomZ)

end

end



-- Criação da Vaca (Igual ao anterior)

local newCow = template:Clone()



local dono = Instance.new("StringValue", newCow)

dono.Name = "Owner"

dono.Value = ownerName



local idVal = Instance.new("NumberValue", newCow)

idVal.Name = "SerialID"

idVal.Value = nextCowSerial



local lvlVal = Instance.new("NumberValue", newCow)

lvlVal.Name = "Level"

lvlVal.Value = level



local mergeVal = Instance.new("BoolValue", newCow)

mergeVal.Name = "IsMerging"

mergeVal.Value = true



newCow.Name = "Vaca_" .. level

newCow.Parent = vacasAtivas

nextCowSerial = nextCowSerial + 1



for _, child in pairs(newCow:GetChildren()) do

if child.ClassName == "Part" or child.ClassName == "MeshPart" then

child.Position = finalPos

child.Anchored = false

child.CanCollide = true

end

end



spawn(function()

wait(0.3)

if newCow and newCow.Parent then

for _, child in pairs(newCow:GetChildren()) do

if child.ClassName == "Part" or child.ClassName == "MeshPart" then

child.Touched:Connect(function(other) OnCowTouched(child, other) end)

end

end

mergeVal.Value = false

end

end)

end



-- (Funções DispararEfeitosFusao e OnCowTouched continuam iguais ao seu script anterior...)

function DispararEfeitosFusao(posicao)

local anchor = Instance.new("Part")

anchor.Name = "EfeitoTemp"

anchor.Position = posicao

anchor.Anchored = true; anchor.CanCollide = false

anchor.Color = Color.FromHex("#FFFFFF00")

anchor.Parent = environment



if particleTemplate then

local p = particleTemplate:Clone()

p.Parent = anchor; p.Position = posicao

end

if soundTemplate then

local s = soundTemplate:Clone()

s.Parent = anchor; s.Position = posicao

s:Play()

end

spawn(function() wait(1); if anchor then anchor:Destroy() end end)

end



function OnCowTouched(part1, otherPart)

local cow1 = part1.Parent

local cow2 = otherPart.Parent

if not cow1 or not cow2 or cow1 == cow2 then return end



local idVal1 = cow1:FindChild("SerialID")

local idVal2 = cow2:FindChild("SerialID")

if not idVal1 or not idVal2 then return end



local id1, id2 = idVal1.Value, idVal2.Value

if processandoFusao[id1] or processandoFusao[id2] then return end



local lvl1 = cow1:FindChild("Level")

local lvl2 = cow2:FindChild("Level")

local owner1 = cow1:FindChild("Owner")

local owner2 = cow2:FindChild("Owner")



if lvl1 and lvl2 and lvl1.Value == lvl2.Value then

if owner1 and owner2 and owner1.Value == owner2.Value then

local m1 = cow1:FindChild("IsMerging")

local m2 = cow2:FindChild("IsMerging")



if m1 and m2 and not m1.Value and not m2.Value then

processandoFusao[id1] = true

processandoFusao[id2] = true

m1.Value = true; m2.Value = true



local spawnPos = (part1.Position + otherPart.Position) / 2

local nextLevel = lvl1.Value + 1

local donoNome = owner1.Value



DispararEfeitosFusao(spawnPos)

cow1:Destroy(); cow2:Destroy()

wait(0.1)

SpawnCow(nextLevel, spawnPos, donoNome)

wait(1)

processandoFusao[id1] = nil; processandoFusao[id2] = nil

end

end

end

end



-- 4. LOGICA DE PERSISTÊNCIA E JOGADOR (ATUALIZADA)

local storage = Datastore and Datastore:GetDatastore("PlayerData_v1") -- Usando Datastore moderno se disponível



local function TeleportPlayer(p, part)

if not p or not part then return end



-- No Polytoria, as propriedades de Vector3 às vezes são minúsculas (x, y, z)

-- Vamos pegar a posição da Part de destino

local targetPos = part.Position



-- Criamos um novo Vector3 com a altura desejada (3.5)

-- Tentamos minúsculo se o maiúsculo falhar internamente

local sucess, err = pcall(function()

p.Position = Vector3.new(targetPos.x, 3.5, targetPos.z)

end)



if not sucess then

-- Se falhar, tenta a sintaxe alternativa

p.Position = Vector3.new(targetPos.X, 3.5, targetPos.Z)

end

end



-- [CORREÇÃO] No PlayerAdded

game["Players"].PlayerAdded:Connect(function(p)

wait(3)



local slot = AssignSlot(p.Name)

if slot then

local mapFolder = areasFolder:FindChild("Map - P" .. slot)

if mapFolder then

local playerSpawnPart = FindSafe(mapFolder, "Player Spawn")



if playerSpawnPart then

TeleportPlayer(p, playerSpawnPart)

print("LOG: " .. p.Name .. " teleportado para Slot " .. slot)

else

print("ERRO: Player Spawn não encontrado no slot " .. slot)

end

end

end



-- 2. SETUP DE DADOS (Conta, Feedback...)

local f = Instance.new("StringValue", p); f.Name = "Feedback"; f.Value = ""



local conta = banco:FindChild(p.Name)

if not conta then

conta = Instance.new("NumberValue", banco)

conta.Name = p.Name; conta.Value = SALDO_INICIAL

end



local totalCompras = conta:FindChild("TotalCompras") or Instance.new("NumberValue", conta)

totalCompras.Name = "TotalCompras"

local mult = conta:FindChild("ProfitMult") or Instance.new("NumberValue", conta)

mult.Name = "ProfitMult"; if mult.Value <= 0 then mult.Value = 1.0 end



-- 3. CARREGAR DADOS (Adaptado para seu sistema atual de Persistence/Datastore)

if Persistence then

local s1, mVal = pcall(function() return Persistence:Get(p, "Money") end)

if s1 and mVal and mVal ~= "" then conta.Value = tonumber(mVal) end



local s3, compras = pcall(function() return Persistence:Get(p, "TotalCompras") end)

if s3 and compras and compras ~= "" then totalCompras.Value = tonumber(compras) end



-- Carregar Vacas (Ajustado para usar SpawnCow com a nova lógica)

local s4, vacasStr = pcall(function() return Persistence:Get(p, "MinhasVacas") end)

if s4 and vacasStr and vacasStr ~= "" then

local lista = string.split(vacasStr, ";")

for _, dados in pairs(lista) do

local info = string.split(dados, "|")

if #info >= 2 then

local lvl = tonumber(info[1])

local coords = string.split(info[2], ",")

if #coords >= 3 then

local pos = Vector3.new(tonumber(coords[1]), tonumber(coords[2]), tonumber(coords[3]))

-- O SpawnCow agora cuida de verificar se a posição é válida ou se deve gerar nova

SpawnCow(lvl, pos, p.Name)

end

end

end

end

end



-- 4. COMANDO DE CHAT

p.Chatted:Connect(function(msg)

if not msg then return end

local msgLower = string.lower(msg)

if string.find(msgLower, "/money me") == 1 then

local valorStr = string.sub(msgLower, 11):gsub(" ", "")

local valor = tonumber(valorStr)

if valor and valor > 0 then

conta.Value = conta.Value + valor

if f then f.Value = "Money" end

end

end

end)

end)



game["Players"].PlayerRemoved:Connect(function(p)

-- Remove as vacas desse jogador para limpar o slot

for _, v in pairs(vacasAtivas:GetChildren()) do

local dono = v:FindChild("Owner")

if dono and dono.Value == p.Name then v:Destroy() end

end

ocupacaoSlots[p.Name] = nil



-- Salvar Dados (Mantido igual)

if Persistence and conta then

Persistence:Set(p, "Money", tostring(math.floor(conta.Value)))

local c = conta:FindChild("TotalCompras")

if c then Persistence:Set(p, "TotalCompras", tostring(c.Value)) end



-- Salvar Vacas

local stringVacas = ""

for _, v in pairs(vacasAtivas:GetChildren()) do

local dono = v:FindChild("Owner")

if v.Name:find("Vaca") and dono and dono.Value == p.Name then

local lvl = tonumber(v.Name:match("%d+")) or 1

local pPart = v:FindChild("Torso") or v:FindChild("HumanoidRootPart") or v

if pPart and pPart:IsA("BasePart") then

local pos = pPart.Position

stringVacas = stringVacas .. lvl .. "|" .. math.floor(pos.X) .. "," .. math.floor(pos.Y) .. "," .. math.floor(pos.Z) .. ";"

end

-- [IMPORTANTE] Destrói a vaca ao sair para liberar lag

v:Destroy()

end

end

if stringVacas ~= "" then Persistence:Set(p, "MinhasVacas", stringVacas) end

end



-- [NOVO] Liberar Slot

ocupacaoSlots[p.Name] = nil

print("LOG: Slot liberado para " .. p.Name)

end)



-- 5. LOOPS (Ganho Passivo e Loja) - Corrigido

spawn(function()

while true do

wait(3)

local GAMEPASS_2X_ID = 100337 -- Seu ID de Gamepass



for _, mVal in pairs(banco:GetChildren()) do

local income = 0

local playerName = mVal.Name

local playerObj = players:FindChild(playerName)



-- Multiplicador base (1x)

local finalMultiplier = 1.0



-- Pega o multiplicador de upgrade se existir

local profitMult = mVal:FindChild("ProfitMult")

if profitMult then finalMultiplier = profitMult.Value end



-- [CORREÇÃO AQUI] VERIFICAÇÃO DE GAMEPASS (2x Earns)

if playerObj then

-- Alterado de UserOwnsAsset para HasAsset

local sucesso, possuiGamepass = pcall(function()

return Purchases:HasAsset(playerObj, GAMEPASS_2X_ID)

end)



if sucesso then

if possuiGamepass == true then

finalMultiplier = finalMultiplier * 2

-- print("LOG: Bônus 2x aplicado para " .. playerName) -- Opcional para debug

end

else

-- Se HasAsset ainda falhar, tentamos a sintaxe alternativa que alguns motores usam

local sucesso2, possui2 = pcall(function() return playerObj:HasAsset(GAMEPASS_2X_ID) end)

if sucesso2 and possui2 then

finalMultiplier = finalMultiplier * 2

end

end

end



-- Cálculo das vacas

for _, v in pairs(vacasAtivas:GetChildren()) do

local dono = v:FindChild("Owner")

if v.Name:find("Vaca") and dono and dono.Value == playerName then

local lvl = tonumber(v.Name:match("%d+"))

if lvl then income = income + (INCOME_PER_LEVEL[lvl] or 0) end

end

end



-- Aplica o lucro dobrado se o jogador tiver a Gamepass

if income > 0 then

mVal.Value = mVal.Value + (income * finalMultiplier)

end

end

end

end)



spawn(function()

print("LOG: Loja Iniciada.")

while true do

wait(0.5)

if comprasFolder then

for _, ticket in pairs(comprasFolder:GetChildren()) do

local playerName = ticket.Name

if not playerName:find("_") and playerName ~= "BotaoCompra" then

local conta = banco:FindChild(playerName)

local playerObj = players:FindChild(playerName)



if conta and playerObj then

-- [NOVO] Verifica se tem slot antes de processar compra

if ocupacaoSlots[playerName] then

local preco = PRECO_INICIAL

local compras = conta:FindChild("TotalCompras")

if compras then

preco = math.floor(PRECO_INICIAL * (MULTIPLICADOR_CUSTO ^ compras.Value))

end



if conta.Value >= preco then

conta.Value = conta.Value - preco

if compras then compras.Value = compras.Value + 1 end



-- Spawn sem posição (nil) para o sistema calcular dentro da área do slot

SpawnCow(1, nil, playerName)



local f = playerObj:FindChild("Feedback")

if f then f.Value = "Success" end

else

-- Falha (Som de Erro)

local anchor = Instance.new("Part")

anchor.Position = playerObj.Position

anchor.Anchored = true; anchor.CanCollide = false

anchor.Color = Color.FromHex("#FF000000")

anchor.Parent = environment

if soundTemplateError then

local s = soundTemplateError:Clone()

s.Position = anchor.Position

s.Parent = anchor; s:Play()

end

local f = playerObj:FindChild("Feedback")

if f then f.Value = "Error" end

spawn(function() wait(1); if anchor then anchor:Destroy() end end)

end

else

print("AVISO: Compra cancelada, jogador sem slot.")

end

end

ticket:Destroy()

end

end

end

end

end)