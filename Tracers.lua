local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    Enabled = false,
    Color = Color3.fromRGB(255, 255, 255),
    Thickness = 2,
    Transparency = 0.3,
}

local Tracers = {}

function Tracers.SetConfig(key, value)
    Config[key] = value
end

function Tracers.GetConfig()
    return Config
end

local function CreateTracer(player)
    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Thickness = Config.Thickness
    Tracer.Transparency = Config.Transparency
    Tracer.From = Vector2.new(0, 0)
    Tracer.To = Vector2.new(0, 0)
    Tracer.Color = Config.Color
    Tracer.ZIndex = 1
    Tracers[player] = {
        Tracer = Tracer,
        Position = Vector2.new(0, 0)
    }
end

local function UpdateTracers()
    if not Config.Enabled then
        for _, tracerData in pairs(Tracers) do
            tracerData.Tracer.Visible = false
        end
        return
    end

    local anyPlayersVisible = false
    for player, tracerData in pairs(Tracers) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local StartPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                anyPlayersVisible = true
                local EndPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                local NewPos = Vector2.new(StartPos.X, StartPos.Y)
                local OldPos = tracerData.Position
                tracerData.Position = NewPos:Lerp(OldPos, 0.5)
                tracerData.Tracer.From = tracerData.Position
                tracerData.Tracer.To = Vector2.new(EndPos.X, EndPos.Y)
                tracerData.Tracer.Visible = true
            else
                tracerData.Tracer.Visible = false
            end
        else
            tracerData.Tracer.Visible = false
        end
    end
    if not anyPlayersVisible then
        for _, tracerData in pairs(Tracers) do
            tracerData.Tracer.Visible = false
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    CreateTracer(player)
end)

Players.PlayerRemoving:Connect(function(player)
    Tracers[player].Tracer:Remove()
    Tracers[player] = nil
end)

for _, player in pairs(Players:GetPlayers()) do
    CreateTracer(player)
end

game:GetService("RunService").RenderStepped:Connect(function()
    UpdateTracers()
end)

return Tracers
