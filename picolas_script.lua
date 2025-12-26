-- 🔑 COPIAR LINK AUTOMÁTICAMENTE AL EJECUTAR
local KEY_LINK = "https://linkvertise.com/1289061/UjZGHK6gsLUQ?o=sharing"

pcall(function()
    if setclipboard then
        setclipboard(KEY_LINK)
    elseif toclipboard then
        toclipboard(KEY_LINK)
    end
end)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Picolas Script | Ultimate Edition V5.5",
   LoadingTitle = "Cargando Interfaz Avanzada...",
   LoadingSubtitle = "por Picolas",
   ConfigurationSaving = { Enabled = false },
   KeySystem = true,
   KeySettings = {
      Title = "Sistema de Llaves",
      Subtitle = "Link copiado automáticamente",
      Note = "Pegá el link en tu navegador para obtener la Key",
      FileName = "None",
      SaveKey = false,
      GrabKeyFromSite = false,
      Key = {"Key_Picolas_26_62913619916372696"},
   }
})

-- Notificación (opcional pero recomendable)
Rayfield:Notify({
    Title = "🔑 Key",
    Content = "El link para obtener la Key ya fue copiado al portapapeles",
    Duration = 5
})

-- // SERVICIOS //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- // VARIABLES DE ESTADO //
local AimbotEnabled = false
local AimPart = "Head"
local Sensitivity = 0.2
local ESPEnabled = false
local FlyEnabled = false
local FlySpeed = 50
local NoClipEnabled = false
local InfiniteJumpEnabled = false
local FullBrightEnabled = false
local MM2FarmEnabled = false
local SelectedPlayer = nil

-- // 1. LÓGICA DE ESP ROLES (MM2) //
local function GetPlayerRole(player)
    if player.Backpack:FindFirstChild("Knife") or (player.Character and player.Character:FindFirstChild("Knife")) then
        return "Murderer"
    elseif player.Backpack:FindFirstChild("Gun") or (player.Character and player.Character:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    return "Innocent"
end

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hl = player.Character:FindFirstChild("HighlightESP")
            if ESPEnabled then
                if not hl then
                    hl = Instance.new("Highlight", player.Character)
                    hl.Name = "HighlightESP"
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                local role = GetPlayerRole(player)
                if role == "Murderer" then hl.FillColor = Color3.fromRGB(255, 0, 0)
                elseif role == "Sheriff" then hl.FillColor = Color3.fromRGB(0, 0, 255)
                else hl.FillColor = Color3.fromRGB(0, 255, 0) end
            else
                if hl then hl:Destroy() end
            end
        end
    end
end
task.spawn(function() while true do task.wait(0.5) UpdateESP() end end)

-- // 2. LÓGICA DE MOVIMIENTO //
RunService.Stepped:Connect(function()
    if (NoClipEnabled or MM2FarmEnabled or FlyEnabled) and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

local function SetupFly()
    task.spawn(function()
        local root = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        while FlyEnabled and LocalPlayer.Character do
            local velocity = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then velocity = velocity + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then velocity = velocity - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then velocity = velocity - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then velocity = velocity + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then velocity = velocity + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then velocity = velocity - Vector3.new(0, 1, 0) end
            if velocity.Magnitude > 0 then root.CFrame = root.CFrame + (velocity * (FlySpeed / 50)) end
            root.Velocity = Vector3.new(0, 0.1, 0)
            RunService.RenderStepped:Wait()
        end
    end)
end

-- // 3. AIMBOT //
local function GetClosest()
    local dist, target = math.huge, nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(AimPart) then
            local pos, vis = Camera:WorldToScreenPoint(p.Character[AimPart].Position)
            if vis then
                local mDist = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if mDist < dist then dist = mDist target = p end
            end
        end
    end
    return target
end
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local t = GetClosest()
        if t then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Character[AimPart].Position), Sensitivity) end
    end
end)

-- // 4. LÓGICA MM2 FARM //
local function TweenToCoin(targetPart)
    if not targetPart or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local info = TweenInfo.new((root.Position - targetPart.Position).Magnitude / 22, Enum.EasingStyle.Linear) 
    local tween = TweenService:Create(root, info, {CFrame = targetPart.CFrame})
    tween:Play()
    return tween
end
task.spawn(function()
    while true do
        task.wait(0.5)
        if MM2FarmEnabled and LocalPlayer.Character then
            for _, obj in pairs(workspace:GetDescendants()) do
                if MM2FarmEnabled and (obj.Name == "Coin_Y" or obj.Name == "Coin_B") then
                    if obj:FindFirstChild("TouchInterest") then
                        local t = TweenToCoin(obj)
                        if t then t.Completed:Wait() end
                    end
                end
            end
        end
    end
end)

-- // INTERFAZ //
local CombatTab = Window:CreateTab("Combate", 4483362458)
local VisualsTab = Window:CreateTab("Visuales", 4483362458)
local MM2Tab = Window:CreateTab("MM2 Farm", 4483362458)
local PlayerTab = Window:CreateTab("Jugador", 4483362458)
local MiscTab = Window:CreateTab("Misc/Troll", 4483362458)

-- COMBATE
CombatTab:CreateToggle({ Name = "Aimbot", CurrentValue = false, Callback = function(v) AimbotEnabled = v end })
CombatTab:CreateSlider({ Name = "Suavizado", Range = {0.1, 1}, Increment = 0.1, CurrentValue = 0.2, Callback = function(v) Sensitivity = v end })

-- VISUALES
VisualsTab:CreateToggle({ Name = "ESP Roles MM2", CurrentValue = false, Callback = function(v) ESPEnabled = v UpdateESP() end })
VisualsTab:CreateToggle({ Name = "Fullbright", CurrentValue = false, Callback = function(v)
    FullBrightEnabled = v
    if v then Lighting.Brightness = 2 Lighting.ClockTime = 14 Lighting.GlobalShadows = false else Lighting.Brightness = 1 Lighting.GlobalShadows = true end
end })

-- MM2 FARM
MM2Tab:CreateToggle({ Name = "Auto-Farm Monedas", CurrentValue = false, Callback = function(v) MM2FarmEnabled = v end })

-- JUGADOR
PlayerTab:CreateSlider({ Name = "Velocidad", Range = {16, 300}, Increment = 1, CurrentValue = 16, Callback = function(v) if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = v end end })
PlayerTab:CreateSlider({ Name = "Salto", Range = {50, 500}, Increment = 1, CurrentValue = 50, Callback = function(v) if LocalPlayer.Character then LocalPlayer.Character.Humanoid.JumpPower = v end end })
PlayerTab:CreateToggle({ Name = "Salto Infinito", CurrentValue = false, Callback = function(v) InfiniteJumpEnabled = v end })
PlayerTab:CreateToggle({ Name = "Volar (Fly)", CurrentValue = false, Callback = function(v) FlyEnabled = v if v then SetupFly() end end })
PlayerTab:CreateSlider({ Name = "Velocidad Vuelo", Range = {10, 300}, Increment = 10, CurrentValue = 50, Callback = function(v) FlySpeed = v end })
PlayerTab:CreateButton({
    Name = "Ser Mini (R15/R6)",
    Callback = function()
        local char = LocalPlayer.Character
        if char:FindFirstChild("Humanoid") then
            for _, v in pairs(char.Humanoid:GetChildren()) do if v:IsA("NumberValue") then v.Value = 0.3 end end
            Rayfield:Notify({Title = "Mini Yo", Content = "Ahora sos chiquito.", Duration = 3})
        end
    end
})

-- TELEPORT & TROLL
local function GetPlayerNames()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(names, p.Name) end end
    return names
end
local TPDropdown = MiscTab:CreateDropdown({
    Name = "Seleccionar Jugador",
    Options = GetPlayerNames(),
    CurrentOption = {"Selecciona"},
    Callback = function(opt) SelectedPlayer = Players:FindFirstChild(opt[1]) end
})
Players.PlayerAdded:Connect(function() TPDropdown:Refresh(GetPlayerNames()) end)
Players.PlayerRemoving:Connect(function() TPDropdown:Refresh(GetPlayerNames()) end)

MiscTab:CreateButton({ Name = "TP al Jugador", Callback = function() if SelectedPlayer and SelectedPlayer.Character then LocalPlayer.Character.HumanoidRootPart.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame end end })
MiscTab:CreateButton({ Name = "Hacer Bang", Callback = function()
    if SelectedPlayer and SelectedPlayer.Character then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://148840337"
        local load = LocalPlayer.Character.Humanoid:LoadAnimation(anim)
        load:Play()
        LocalPlayer.Character.HumanoidRootPart.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
    end
end })
MiscTab:CreateButton({ Name = "SitHead", Callback = function()
    if SelectedPlayer and SelectedPlayer.Character then
        LocalPlayer.Character.Humanoid.Sit = true
        task.spawn(function()
            while LocalPlayer.Character.Humanoid.Sit do
                task.wait()
                if not (SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("Head")) then break end
                LocalPlayer.Character.HumanoidRootPart.CFrame = SelectedPlayer.Character.Head.CFrame * CFrame.new(0, 1, 0)
            end
        end)
    end
end })

-- ANTI-AFK
LocalPlayer.Idled:Connect(function()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.I, false, game)
    task.wait(0.2)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.I, false, game)
end)

Rayfield:Notify({ Title = "Picolas Script V5.5", Content = "Key Estricta y Funciones Full.", Duration = 5 })
