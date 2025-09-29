local KeyLoader = {}
KeyLoader.__index = KeyLoader

function KeyLoader.new(config)
    local self = setmetatable({}, KeyLoader)
    
    self.config = {
        apiKey = config.apiKey,
        provider = config.provider,
        service = config.service,
        scriptUrl = config.scriptUrl,
        onSuccess = config.onSuccess,
    }
    
    self.JunkieKeySystem = nil
    self.ScreenGui = nil
    self.verificationLink = nil
    self.keyFileName = config.folder .. "_SavedKey.txt"
    
    return self
end

function KeyLoader:loadDependencies()
    self.JunkieKeySystem = loadstring(game:HttpGet("https://junkie-development.de/sdk/JunkieKeySystem.lua"))()
end

function KeyLoader:saveKey(key)
    pcall(function()
        writefile(self.keyFileName, key)
    end)
end

function KeyLoader:loadSavedKey()
    local success, key = pcall(function()
        if isfile(self.keyFileName) then
            return readfile(self.keyFileName)
        end
        return nil
    end)
    
    return success and key or nil
end

function KeyLoader:deleteSavedKey()
    pcall(function()
        if isfile(self.keyFileName) then
            delfile(self.keyFileName)
        end
    end)
end

function KeyLoader:generateLink()
    local success, result = pcall(function()
        return self.JunkieKeySystem.getLink(
            self.config.apiKey,
            self.config.provider,
            self.config.service
        )
    end)
    
    if success and result then
        self.verificationLink = result
        return true
    end
    
    return false
end

function KeyLoader:verifyKey(key)
    local success, result = pcall(function()
        return self.JunkieKeySystem.verifyKey(
            self.config.apiKey,
            key,
            self.config.service
        )
    end)
    
    return success and result
end

function KeyLoader:createUI()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "KeyLoaderUI"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 0.5
    Overlay.BorderSizePixel = 0
    Overlay.Parent = self.ScreenGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 450, 0, 320)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = self.ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = MainFrame
    
    local Glow = Instance.new("ImageLabel")
    Glow.Size = UDim2.new(1, 40, 1, 40)
    Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Glow.AnchorPoint = Vector2.new(0.5, 0.5)
    Glow.BackgroundTransparency = 1
    Glow.Image = "rbxassetid://5028857084"
    Glow.ImageColor3 = Color3.fromRGB(80, 140, 255)
    Glow.ImageTransparency = 0.7
    Glow.ScaleType = Enum.ScaleType.Slice
    Glow.SliceCenter = Rect.new(24, 24, 276, 276)
    Glow.Parent = MainFrame
    
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 60)
    TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 16)
    TopBarCorner.Parent = TopBar
    
    local TopBarCover = Instance.new("Frame")
    TopBarCover.Size = UDim2.new(1, 0, 0, 30)
    TopBarCover.Position = UDim2.new(0, 0, 1, -30)
    TopBarCover.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    TopBarCover.BorderSizePixel = 0
    TopBarCover.Parent = TopBar
    
    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.new(0, 32, 0, 32)
    Icon.Position = UDim2.new(0, 20, 0, 14)
    Icon.BackgroundTransparency = 1
    Icon.Image = "rbxassetid://11963352805"
    Icon.ImageColor3 = Color3.fromRGB(80, 140, 255)
    Icon.Parent = TopBar
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -120, 0, 60)
    Title.Position = UDim2.new(0, 60, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Key Verification"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, -40, 0, 30)
    Subtitle.Position = UDim2.new(0, 20, 0, 75)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Please verify your key to continue"
    Subtitle.TextColor3 = Color3.fromRGB(150, 150, 160)
    Subtitle.TextSize = 14
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = MainFrame
    
    local GetKeyButton = Instance.new("TextButton")
    GetKeyButton.Size = UDim2.new(1, -40, 0, 48)
    GetKeyButton.Position = UDim2.new(0, 20, 0, 120)
    GetKeyButton.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    GetKeyButton.BorderSizePixel = 0
    GetKeyButton.AutoButtonColor = false
    GetKeyButton.Text = "  📋  Get Key Link"
    GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyButton.TextSize = 16
    GetKeyButton.Font = Enum.Font.GothamBold
    GetKeyButton.Parent = MainFrame
    
    local GetKeyCorner = Instance.new("UICorner")
    GetKeyCorner.CornerRadius = UDim.new(0, 10)
    GetKeyCorner.Parent = GetKeyButton
    
    local GetKeyGradient = Instance.new("UIGradient")
    GetKeyGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 140, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 100, 200))
    }
    GetKeyGradient.Rotation = 90
    GetKeyGradient.Parent = GetKeyButton
    
    local KeyInputFrame = Instance.new("Frame")
    KeyInputFrame.Size = UDim2.new(1, -40, 0, 48)
    KeyInputFrame.Position = UDim2.new(0, 20, 0, 180)
    KeyInputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    KeyInputFrame.BorderSizePixel = 0
    KeyInputFrame.Parent = MainFrame
    
    local InputFrameCorner = Instance.new("UICorner")
    InputFrameCorner.CornerRadius = UDim.new(0, 10)
    InputFrameCorner.Parent = KeyInputFrame
    
    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = Color3.fromRGB(50, 50, 60)
    InputStroke.Thickness = 1
    InputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    InputStroke.Parent = KeyInputFrame
    
    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(1, -20, 1, 0)
    KeyInput.Position = UDim2.new(0, 10, 0, 0)
    KeyInput.BackgroundTransparency = 1
    KeyInput.PlaceholderText = "Enter your key here..."
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
    KeyInput.TextSize = 14
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.ClearTextOnFocus = false
    KeyInput.TextXAlignment = Enum.TextXAlignment.Left
    KeyInput.Parent = KeyInputFrame
    
    local VerifyButton = Instance.new("TextButton")
    VerifyButton.Size = UDim2.new(1, -40, 0, 48)
    VerifyButton.Position = UDim2.new(0, 20, 0, 240)
    VerifyButton.BackgroundColor3 = Color3.fromRGB(50, 200, 120)
    VerifyButton.BorderSizePixel = 0
    VerifyButton.AutoButtonColor = false
    VerifyButton.Text = "✓  Verify Key"
    VerifyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    VerifyButton.TextSize = 16
    VerifyButton.Font = Enum.Font.GothamBold
    VerifyButton.Parent = MainFrame
    
    local VerifyCorner = Instance.new("UICorner")
    VerifyCorner.CornerRadius = UDim.new(0, 10)
    VerifyCorner.Parent = VerifyButton
    
    local VerifyGradient = Instance.new("UIGradient")
    VerifyGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 200, 120)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 160, 100))
    }
    VerifyGradient.Rotation = 90
    VerifyGradient.Parent = VerifyButton
    
    MainFrame.Position = UDim2.new(0.5, 0, -0.5, 0)
    MainFrame:TweenPosition(
        UDim2.new(0.5, 0, 0.5, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Back,
        0.6,
        true
    )
    
    GetKeyButton.MouseEnter:Connect(function()
        TweenService:Create(GetKeyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 160, 255)}):Play()
    end)
    
    GetKeyButton.MouseLeave:Connect(function()
        TweenService:Create(GetKeyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 140, 255)}):Play()
    end)
    
    VerifyButton.MouseEnter:Connect(function()
        TweenService:Create(VerifyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 220, 140)}):Play()
    end)
    
    VerifyButton.MouseLeave:Connect(function()
        TweenService:Create(VerifyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 200, 120)}):Play()
    end)
    
    KeyInput.Focused:Connect(function()
        TweenService:Create(InputStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(80, 140, 255)}):Play()
    end)
    
    KeyInput.FocusLost:Connect(function()
        TweenService:Create(InputStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 60)}):Play()
    end)
    
    GetKeyButton.MouseButton1Click:Connect(function()
        if self.verificationLink then
            setclipboard(self.verificationLink)
            local originalText = GetKeyButton.Text
            GetKeyButton.Text = "✓  Link Copied!"
            TweenService:Create(GetKeyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 200, 120)}):Play()
            task.wait(2)
            GetKeyButton.Text = originalText
            TweenService:Create(GetKeyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 140, 255)}):Play()
        end
    end)
    
    VerifyButton.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        
        if key == "" then
            VerifyButton.Text = "✗  Enter a key!"
            TweenService:Create(VerifyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 80, 80)}):Play()
            task.wait(2)
            VerifyButton.Text = "✓  Verify Key"
            TweenService:Create(VerifyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 200, 120)}):Play()
            return
        end
        
        VerifyButton.Text = "⟳  Verifying..."
        VerifyButton.TextSize = 15
        
        local isValid = self:verifyKey(key)
        
        if isValid then
            self:saveKey(key)
            VerifyButton.Text = "✓  Success!"
            TweenService:Create(VerifyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 220, 120)}):Play()
            task.wait(1)
            
            MainFrame:TweenPosition(
                UDim2.new(0.5, 0, -0.5, 0),
                Enum.EasingDirection.In,
                Enum.EasingStyle.Back,
                0.4,
                true
            )
            
            TweenService:Create(Overlay, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
            
            task.wait(0.5)
            self:loadScript()
            self:destroy()
        else
            self:deleteSavedKey()
            VerifyButton.Text = "✗  Invalid Key!"
            VerifyButton.TextSize = 16
            TweenService:Create(VerifyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 80, 80)}):Play()
            
            TweenService:Create(MainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true), {
                Position = UDim2.new(0.5, 10, 0.5, 0)
            }):Play()
            
            task.wait(0.2)
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            
            task.wait(1.8)
            VerifyButton.Text = "✓  Verify Key"
            TweenService:Create(VerifyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 200, 120)}):Play()
        end
    end)
end

function KeyLoader:loadScript()
    if self.config.onSuccess then
        self.config.onSuccess()
    end
    
    if self.config.scriptUrl then
        loadstring(game:HttpGet(self.config.scriptUrl))()
    end
end

function KeyLoader:destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

function KeyLoader:initialize()
    self:loadDependencies()
    
    local savedKey = self:loadSavedKey()
    
    if savedKey and savedKey ~= "" then
        local isValid = self:verifyKey(savedKey)
        
        if isValid then
            self:loadScript()
            return
        else
            self:deleteSavedKey()
        end
    end
    
    self:generateLink()
    self:createUI()
end

return KeyLoader