-- language: Lua (Luau) | executor: Real (compatível com Synapse X / KRNL / Fluxus)
-- target: Roblox "Steal an Egg" games | Windows 11
-- injeta, abre o menu automaticamente, arrasta pela topbar
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local RS           = game:GetService("ReplicatedStorage")
local lp   = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
-- ══════════════════════════════════════════════════════════
-- CONFIG
-- ══════════════════════════════════════════════════════════
local CFG = {
    AutoSteal   = false,
    ESP         = false,
    Teleport    = true,
    Delay       = 0.15,
    EggKeywords = {"Egg","egg","Ovo","ovo","Prize","prize"},
    Accent      = Color3.fromRGB(255, 140, 0),
    AccentDark  = Color3.fromRGB(180,  90, 0),
    BG          = Color3.fromRGB( 15,  15, 20),
    Surface     = Color3.fromRGB( 25,  25, 35),
    Surface2    = Color3.fromRGB( 35,  35, 50),
    TextPri     = Color3.fromRGB(240, 240, 245),
    TextSec     = Color3.fromRGB(140, 140, 160),
}
-- ══════════════════════════════════════════════════════════
-- HELPERS
-- ══════════════════════════════════════════════════════════
local function tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props):Play()
end
local function corner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end
local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color     = color or Color3.fromRGB(60,60,80)
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end
local function label(parent, text, size, color, font, xAlign)
    local l = Instance.new("TextLabel", parent)
    l.BackgroundTransparency = 1
    l.Text      = text
    l.TextSize  = size  or 14
    l.TextColor3= color or CFG.TextPri
    l.Font      = font  or Enum.Font.GothamMedium
    l.TextXAlignment = xAlign or Enum.TextXAlignment.Left
    l.Size      = UDim2.new(1, 0, 1, 0)
    return l
end
-- ══════════════════════════════════════════════════════════
-- SCREENUI ROOT
-- ══════════════════════════════════════════════════════════
local SG = Instance.new("ScreenGui")
SG.Name           = "EggHack_UI"
SG.ResetOnSpawn   = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder   = 999
pcall(function() SG.Parent = game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent = lp:WaitForChild("PlayerGui") end
-- ══════════════════════════════════════════════════════════
-- JANELA PRINCIPAL
-- ══════════════════════════════════════════════════════════
local WIN_W, WIN_H = 420, 480
local Window = Instance.new("Frame", SG)
Window.Name              = "Window"
Window.Size              = UDim2.new(0, WIN_W, 0, WIN_H)
Window.Position          = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
Window.BackgroundColor3  = CFG.BG
Window.BorderSizePixel   = 0
Window.ClipsDescendants  = true
corner(Window, 14)
stroke(Window, Color3.fromRGB(50, 50, 70), 1.5)
-- sombra
local Shadow = Instance.new("ImageLabel", Window)
Shadow.Name                  = "Shadow"
Shadow.BackgroundTransparency = 1
Shadow.Image                 = "rbxassetid://6015897843"
Shadow.ImageColor3           = Color3.fromRGB(0,0,0)
Shadow.ImageTransparency     = 0.4
Shadow.Size                  = UDim2.new(1, 60, 1, 60)
Shadow.Position              = UDim2.new(0, -30, 0, -30)
Shadow.ZIndex                = -1
Shadow.ScaleType             = Enum.ScaleType.Slice
Shadow.SliceCenter           = Rect.new(49, 49, 450, 450)
-- entrada animada
Window.Size = UDim2.new(0, WIN_W, 0, 0)
Window.BackgroundTransparency = 1
tween(Window, {Size = UDim2.new(0, WIN_W, 0, WIN_H), BackgroundTransparency = 0}, 0.35, Enum.EasingStyle.Back)
-- ══════════════════════════════════════════════════════════
-- TOPBAR
-- ══════════════════════════════════════════════════════════
local TopBar = Instance.new("Frame", Window)
TopBar.Name             = "TopBar"
TopBar.Size             = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = CFG.Surface
TopBar.BorderSizePixel  = 0
corner(TopBar, 14)
-- cobre canto inferior do topbar
local TopFix = Instance.new("Frame", TopBar)
TopFix.Size             = UDim2.new(1, 0, 0, 14)
TopFix.Position         = UDim2.new(0, 0, 1, -14)
TopFix.BackgroundColor3 = CFG.Surface
TopFix.BorderSizePixel  = 0
-- ícone / título
local TitleIcon = Instance.new("Frame", TopBar)
TitleIcon.Size             = UDim2.new(0, 8, 0, 28)
TitleIcon.Position         = UDim2.new(0, 16, 0.5, -14)
TitleIcon.BackgroundColor3 = CFG.Accent
TitleIcon.BorderSizePixel  = 0
corner(TitleIcon, 4)
local TitleLbl = Instance.new("TextLabel", TopBar)
TitleLbl.Size             = UDim2.new(0, 200, 1, 0)
TitleLbl.Position         = UDim2.new(0, 32, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text             = "Egg Stealer"
TitleLbl.TextColor3       = CFG.TextPri
TitleLbl.Font             = Enum.Font.GothamBold
TitleLbl.TextSize         = 17
TitleLbl.TextXAlignment   = Enum.TextXAlignment.Left
local SubLbl = Instance.new("TextLabel", TopBar)
SubLbl.Size             = UDim2.new(0, 200, 0.4, 0)
SubLbl.Position         = UDim2.new(0, 32, 0.5, 2)
SubLbl.BackgroundTransparency = 1
SubLbl.Text             = "Real Executor  •  v2.0"
SubLbl.TextColor3       = CFG.TextSec
SubLbl.Font             = Enum.Font.Gotham
SubLbl.TextSize         = 11
SubLbl.TextXAlignment   = Enum.TextXAlignment.Left
-- botão fechar
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size             = UDim2.new(0, 30, 0, 30)
CloseBtn.Position         = UDim2.new(1, -42, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Text             = "✕"
CloseBtn.TextColor3       = Color3.fromRGB(255,255,255)
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.TextSize         = 14
corner(CloseBtn, 8)
-- botão minimizar
local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size             = UDim2.new(0, 30, 0, 30)
MinBtn.Position         = UDim2.new(1, -78, 0.5, -15)
MinBtn.BackgroundColor3 = CFG.Surface2
MinBtn.Text             = "−"
MinBtn.TextColor3       = CFG.TextPri
MinBtn.Font             = Enum.Font.GothamBold
MinBtn.TextSize         = 18
corner(MinBtn, 8)
-- draggable
do
    local dragging, dragStart, startPos = false, nil, nil
    TopBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = i.Position
            startPos  = Window.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            Window.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end
-- minimizar
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    tween(Window,
        {Size = minimized and UDim2.new(0, WIN_W, 0, 50) or UDim2.new(0, WIN_W, 0, WIN_H)},
        0.3, Enum.EasingStyle.Quart)
    MinBtn.Text = minimized and "+" or "−"
end)
CloseBtn.MouseButton1Click:Connect(function()
    tween(Window, {Size = UDim2.new(0, WIN_W, 0, 0), BackgroundTransparency = 1}, 0.25)
    task.delay(0.3, function() SG:Destroy() end)
end)
-- ══════════════════════════════════════════════════════════
-- TAB BAR
-- ══════════════════════════════════════════════════════════
local TabBar = Instance.new("Frame", Window)
TabBar.Size             = UDim2.new(1, -24, 0, 36)
TabBar.Position         = UDim2.new(0, 12, 0, 58)
TabBar.BackgroundColor3 = CFG.Surface2
TabBar.BorderSizePixel  = 0
corner(TabBar, 10)
local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection  = Enum.FillDirection.Horizontal
TabLayout.Padding        = UDim.new(0, 4)
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
local TabPad = Instance.new("UIPadding", TabBar)
TabPad.PaddingLeft  = UDim.new(0, 4)
TabPad.PaddingRight = UDim.new(0, 4)
-- ══════════════════════════════════════════════════════════
-- CONTENT AREA
-- ══════════════════════════════════════════════════════════
local Content = Instance.new("Frame", Window)
Content.Name            = "Content"
Content.Size            = UDim2.new(1, -24, 1, -108)
Content.Position        = UDim2.new(0, 12, 0, 102)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
-- ══════════════════════════════════════════════════════════
-- COMPONENTES UI
-- ══════════════════════════════════════════════════════════
-- Toggle Switch
local function makeToggle(parent, yOffset, titleText, desc, initial, onChange)
    local Row = Instance.new("Frame", parent)
    Row.Size             = UDim2.new(1, 0, 0, 58)
    Row.Position         = UDim2.new(0, 0, 0, yOffset)
    Row.BackgroundColor3 = CFG.Surface
    Row.BorderSizePixel  = 0
    corner(Row, 10)
    local TitleL = Instance.new("TextLabel", Row)
    TitleL.Size              = UDim2.new(1, -70, 0, 20)
    TitleL.Position          = UDim2.new(0, 14, 0, 10)
    TitleL.BackgroundTransparency = 1
    TitleL.Text              = titleText
    TitleL.TextColor3        = CFG.TextPri
    TitleL.Font              = Enum.Font.GothamMedium
    TitleL.TextSize          = 14
    TitleL.TextXAlignment    = Enum.TextXAlignment.Left
    local DescL = Instance.new("TextLabel", Row)
    DescL.Size              = UDim2.new(1, -70, 0, 16)
    DescL.Position          = UDim2.new(0, 14, 0, 31)
    DescL.BackgroundTransparency = 1
    DescL.Text              = desc
    DescL.TextColor3        = CFG.TextSec
    DescL.Font              = Enum.Font.Gotham
    DescL.TextSize          = 11
    DescL.TextXAlignment    = Enum.TextXAlignment.Left
    -- trilho
    local Track = Instance.new("Frame", Row)
    Track.Size             = UDim2.new(0, 44, 0, 24)
    Track.Position         = UDim2.new(1, -58, 0.5, -12)
    Track.BackgroundColor3 = CFG.Surface2
    Track.BorderSizePixel  = 0
    corner(Track, 12)
    local Knob = Instance.new("Frame", Track)
    Knob.Size             = UDim2.new(0, 18, 0, 18)
    Knob.Position         = UDim2.new(0, 3, 0.5, -9)
    Knob.BackgroundColor3 = CFG.TextSec
    Knob.BorderSizePixel  = 0
    corner(Knob, 9)
    local state = initial or false
    local function refresh()
        tween(Track, {BackgroundColor3 = state and CFG.Accent or CFG.Surface2}, 0.2)
        tween(Knob,  {Position = state
            and UDim2.new(0, 23, 0.5, -9)
            or  UDim2.new(0, 3,  0.5, -9)}, 0.2)
        tween(Knob,  {BackgroundColor3 = state and Color3.fromRGB(255,255,255) or CFG.TextSec}, 0.2)
    end
    refresh()
    local Btn = Instance.new("TextButton", Row)
    Btn.Size             = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text             = ""
    Btn.MouseButton1Click:Connect(function()
        state = not state
        refresh()
        onChange(state)
    end)
    -- hover
    Btn.MouseEnter:Connect(function()
        tween(Row, {BackgroundColor3 = CFG.Surface2}, 0.15)
    end)
    Btn.MouseLeave:Connect(function()
        tween(Row, {BackgroundColor3 = CFG.Surface}, 0.15)
    end)
    return Row
end
-- Slider
local function makeSlider(parent, yOffset, titleText, min, max, initial, fmt, onChange)
    local Row = Instance.new("Frame", parent)
    Row.Size             = UDim2.new(1, 0, 0, 64)
    Row.Position         = UDim2.new(0, 0, 0, yOffset)
    Row.BackgroundColor3 = CFG.Surface
    Row.BorderSizePixel  = 0
    corner(Row, 10)
    local TitleL = Instance.new("TextLabel", Row)
    TitleL.Size              = UDim2.new(0.7, 0, 0, 20)
    TitleL.Position          = UDim2.new(0, 14, 0, 8)
    TitleL.BackgroundTransparency = 1
    TitleL.Text              = titleText
    TitleL.TextColor3        = CFG.TextPri
    TitleL.Font              = Enum.Font.GothamMedium
    TitleL.TextSize          = 14
    TitleL.TextXAlignment    = Enum.TextXAlignment.Left
    local ValLbl = Instance.new("TextLabel", Row)
    ValLbl.Size              = UDim2.new(0.28, 0, 0, 20)
    ValLbl.Position          = UDim2.new(0.72, 0, 0, 8)
    ValLbl.BackgroundTransparency = 1
    ValLbl.TextColor3        = CFG.Accent
    ValLbl.Font              = Enum.Font.GothamBold
    ValLbl.TextSize          = 13
    ValLbl.TextXAlignment    = Enum.TextXAlignment.Right
    local Track = Instance.new("Frame", Row)
    Track.Size             = UDim2.new(1, -28, 0, 6)
    Track.Position         = UDim2.new(0, 14, 0, 40)
    Track.BackgroundColor3 = CFG.Surface2
    Track.BorderSizePixel  = 0
    corner(Track, 3)
    local Fill = Instance.new("Frame", Track)
    Fill.Size             = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = CFG.Accent
    Fill.BorderSizePixel  = 0
    corner(Fill, 3)
    local Thumb = Instance.new("Frame", Track)
    Thumb.Size             = UDim2.new(0, 14, 0, 14)
    Thumb.AnchorPoint      = Vector2.new(0.5, 0.5)
    Thumb.Position         = UDim2.new(0, 0, 0.5, 0)
    Thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Thumb.BorderSizePixel  = 0
    corner(Thumb, 7)
    local value = initial
    local dragging = false
    local function setVal(v)
        value = math.clamp(math.round(v * 100) / 100, min, max)
        local pct = (value - min) / (max - min)
        Fill.Size     = UDim2.new(pct, 0, 1, 0)
        Thumb.Position = UDim2.new(pct, 0, 0.5, 0)
        ValLbl.Text   = string.format(fmt or "%.2f", value)
        onChange(value)
    end
    setVal(initial)
    local SliderBtn = Instance.new("TextButton", Track)
    SliderBtn.Size             = UDim2.new(1, 0, 0, 20)
    SliderBtn.Position         = UDim2.new(0, 0, 0.5, -10)
    SliderBtn.BackgroundTransparency = 1
    SliderBtn.Text             = ""
    SliderBtn.MouseButton1Down:Connect(function()  dragging = true end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local absPos  = Track.AbsolutePosition.X
            local absSize = Track.AbsoluteSize.X
            local pct     = math.clamp((i.Position.X - absPos) / absSize, 0, 1)
            setVal(min + (max - min) * pct)
        end
    end)
    return Row
end
-- Botão
local function makeButton(parent, yOffset, btnText, desc, onClick)
    local Row = Instance.new("Frame", parent)
    Row.Size             = UDim2.new(1, 0, 0, 50)
    Row.Position         = UDim2.new(0, 0, 0, yOffset)
    Row.BackgroundColor3 = CFG.Surface
    Row.BorderSizePixel  = 0
    corner(Row, 10)
    local Btn = Instance.new("TextButton", Row)
    Btn.Size             = UDim2.new(0, 110, 0, 30)
    Btn.Position         = UDim2.new(1, -124, 0.5, -15)
    Btn.BackgroundColor3 = CFG.Accent
    Btn.Text             = btnText
    Btn.TextColor3       = Color3.fromRGB(255,255,255)
    Btn.Font             = Enum.Font.GothamBold
    Btn.TextSize         = 13
    corner(Btn, 8)
    local DescL = Instance.new("TextLabel", Row)
    DescL.Size              = UDim2.new(0.6, 0, 1, 0)
    DescL.Position          = UDim2.new(0, 14, 0, 0)
    DescL.BackgroundTransparency = 1
    DescL.Text              = desc
    DescL.TextColor3        = CFG.TextSec
    DescL.Font              = Enum.Font.Gotham
    DescL.TextSize          = 12
    DescL.TextXAlignment    = Enum.TextXAlignment.Left
    Btn.MouseButton1Click:Connect(function()
        tween(Btn, {BackgroundColor3 = CFG.AccentDark}, 0.1)
        task.delay(0.15, function()
            tween(Btn, {BackgroundColor3 = CFG.Accent}, 0.15)
        end)
        onClick()
    end)
    Btn.MouseEnter:Connect(function() tween(Btn, {BackgroundColor3 = CFG.AccentDark}, 0.15) end)
    Btn.MouseLeave:Connect(function() tween(Btn, {BackgroundColor3 = CFG.Accent}, 0.15) end)
    return Row
end
-- ══════════════════════════════════════════════════════════
-- SISTEMA DE TABS
-- ══════════════════════════════════════════════════════════
local tabs       = {}
local pages      = {}
local activePage = nil
local function makeTab(icon, name)
    local Btn = Instance.new("TextButton", TabBar)
    Btn.Size             = UDim2.new(0, 90, 1, -8)
    Btn.BackgroundColor3 = CFG.Surface
    Btn.Text             = icon .. "  " .. name
    Btn.TextColor3       = CFG.TextSec
    Btn.Font             = Enum.Font.GothamMedium
    Btn.TextSize         = 13
    corner(Btn, 8)
    local Page = Instance.new("ScrollingFrame", Content)
    Page.Name                = name
    Page.Size                = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness  = 3
    Page.ScrollBarImageColor3 = CFG.Accent
    Page.BorderSizePixel     = 0
    Page.Visible             = false
    Page.CanvasSize          = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local Pad = Instance.new("UIPadding", Page)
    Pad.PaddingTop   = UDim.new(0, 4)
    Pad.PaddingBottom = UDim.new(0, 12)
    local List = Instance.new("UIListLayout", Page)
    List.Padding        = UDim.new(0, 6)
    List.SortOrder      = Enum.SortOrder.LayoutOrder
    List.FillDirection  = Enum.FillDirection.Vertical
    tabs[name]  = Btn
    pages[name] = Page
    Btn.MouseButton1Click:Connect(function()
        for n, b in pairs(tabs) do
            tween(b, {BackgroundColor3 = n == name and CFG.Accent or CFG.Surface,
                       TextColor3      = n == name and Color3.fromRGB(255,255,255) or CFG.TextSec}, 0.2)
        end
        for n, p in pairs(pages) do
            p.Visible = (n == name)
        end
        activePage = name
    end)
    return Page
end
-- ══════════════════════════════════════════════════════════
-- LÓGICA DO HACK
-- ══════════════════════════════════════════════════════════
local espCache = {}
local function isEgg(obj)
    for _, kw in ipairs(CFG.EggKeywords) do
        if obj.Name:find(kw) then return true end
    end
    return false
end
local function getHRP()
    char = lp.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end
local function addESP(obj)
    if espCache[obj] then return end
    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
    if not part then return end
    local bb = Instance.new("BillboardGui", part)
    bb.Size        = UDim2.new(0, 90, 0, 32)
    bb.StudsOffset = Vector3.new(0, 4, 0)
    bb.AlwaysOnTop = true
    local lbl = Instance.new("TextLabel", bb)
    lbl.Size                = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundColor3    = CFG.Accent
    lbl.BackgroundTransparency = 0.25
    lbl.TextColor3          = Color3.fromRGB(255,255,255)
    lbl.Text                = "🥚 " .. obj.Name
    lbl.TextScaled          = true
    lbl.Font                = Enum.Font.GothamBold
    corner(lbl, 6)
    local hl = Instance.new("SelectionBox", part)
    hl.Adornee           = part
    hl.Color3            = CFG.Accent
    hl.LineThickness     = 0.06
    hl.SurfaceTransparency = 0.75
    hl.SurfaceColor3     = CFG.Accent
    espCache[obj] = {bb = bb, hl = hl}
    obj.AncestryChanged:Connect(function()
        if espCache[obj] then
            pcall(bb.Destroy, bb)
            pcall(hl.Destroy, hl)
            espCache[obj] = nil
        end
    end)
end
local function clearESP()
    for obj, v in pairs(espCache) do
        pcall(v.bb.Destroy, v.bb)
        pcall(v.hl.Destroy, v.hl)
        espCache[obj] = nil
    end
end
local function getEggs()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isEgg(obj) and (not char or not obj:IsDescendantOf(char)) then
            table.insert(list, obj)
            if CFG.ESP then addESP(obj) end
        end
    end
    return list
end
local function tryCollect(egg)
    local part = egg:IsA("BasePart") and egg or egg:FindFirstChildWhichIsA("BasePart")
    if part and CFG.Teleport then
        local hrp = getHRP()
        if hrp then hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 4, 0)) end
        task.wait(0.05)
    end
    -- ClickDetector
    local cd = egg:FindFirstChildWhichIsA("ClickDetector")
        or (egg.Parent and egg.Parent:FindFirstChildWhichIsA("ClickDetector"))
    if cd then pcall(fireclickdetector, cd) end
    -- ProximityPrompt
    local pp = egg:FindFirstChildWhichIsA("ProximityPrompt")
        or (egg.Parent and egg.Parent:FindFirstChildWhichIsA("ProximityPrompt"))
    if pp then pcall(fireproximityprompt, pp) end
    -- RemoteEvents comuns
    for _, name in ipairs({"CollectEgg","StealEgg","ClaimEgg","PickupEgg","GrabEgg","TakeEgg","Collect","Steal"}) do
        local re = RS:FindFirstChild(name, true) or workspace:FindFirstChild(name, true)
        if re and re:IsA("RemoteEvent") then
            pcall(re.FireServer, re, egg)
            pcall(re.FireServer, re, egg, lp)
        end
    end
end
local loopRunning = false
local loopThread
local function startLoop()
    if loopRunning then return end
    loopRunning = true
    loopThread  = task.spawn(function()
        while loopRunning do
            local eggs = getEggs()
            for _, egg in ipairs(eggs) do
                if not loopRunning then break end
                pcall(tryCollect, egg)
                task.wait(CFG.Delay)
            end
            task.wait(0.5)
        end
    end)
end
local function stopLoop()
    loopRunning = false
end
-- ══════════════════════════════════════════════════════════
-- POPULA TABS
-- ══════════════════════════════════════════════════════════
-- ── TAB 1: STEAL ──────────────────────────────────────────
local PageSteal = makeTab("🥚", "Steal")
makeToggle(PageSteal, 0, "Auto Steal", "Coleta ovos automaticamente", false,
    function(v)
        CFG.AutoSteal = v
        if v then startLoop() else stopLoop() end
    end)
makeToggle(PageSteal, 64, "Teleport to Egg", "Teleporta até o ovo antes de coletar", true,
    function(v) CFG.Teleport = v end)
makeSlider(PageSteal, 134, "Delay entre coletas", 0.05, 2.0, 0.15, "%.2fs",
    function(v) CFG.Delay = v end)
makeButton(PageSteal, 210, "▶ Coletar Agora", "Executa uma rodada manual",
    function()
        task.spawn(function()
            for _, egg in ipairs(getEggs()) do
                pcall(tryCollect, egg)
                task.wait(CFG.Delay)
            end
        end)
    end)
-- ── TAB 2: ESP ────────────────────────────────────────────
local PageESP = makeTab("👁", "ESP")
makeToggle(PageESP, 0, "Egg ESP", "Destaca todos os ovos no mapa", false,
    function(v)
        CFG.ESP = v
        if not v then clearESP() end
    end)
makeButton(PageESP, 64, "🔄 Refresh ESP", "Re-escaneia o workspace",
    function()
        clearESP()
        if CFG.ESP then getEggs() end
    end)
-- ── TAB 3: CONFIG ─────────────────────────────────────────
local PageCfg = makeTab("⚙", "Config")
makeSlider(PageCfg, 0, "Egg Search Depth", 1, 10, 5, "%.0f níveis",
    function(_) end)  -- extensível
makeButton(PageCfg, 74, "🧹 Limpar ESP", "Remove todos os highlights",
    function() clearESP() end)
makeButton(PageCfg, 130, "⛔ Parar Tudo", "Para todos os loops",
    function()
        stopLoop()
        clearESP()
        CFG.AutoSteal = false
    end)
-- ── ativa primeira tab ─────────────────────────────────────
tabs["Steal"]:MouseButton1Click:Fire()
-- ══════════════════════════════════════════════════════════
-- KEYBIND — INSERT para mostrar/ocultar
-- ══════════════════════════════════════════════════════════
UIS.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == Enum.KeyCode.Insert then
        Window.Visible = not Window.Visible
    end
end)