task.spawn(function()  
  
-- ============================================================
-- WindUI (https://github.com/Footagesus/WindUI)
-- ============================================================
if not game:IsLoaded() then game.Loaded:Wait() end

local WindUI
do
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua"))()
    end)
    if not ok or type(lib) ~= "table" then
        lib = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end
    WindUI = lib
end

-- Thin adapter: keeps the original create_category/create_tab/create_group/
-- create_toggle/create_slider/create_dropdown calls working on top of WindUI.
local UI = {}
do
    local TabIcons = { Combat = "swords", Visual = "eye" }

    local function resolveIcon(title, icon)
        if TabIcons[title] then return TabIcons[title] end
        if type(icon) == "number" or (type(icon) == "string" and icon:match("^%d+$")) then
            return "rbxassetid://" .. tostring(icon)
        end
        return icon
    end

    local function safe(fn, ...)
        if type(fn) ~= "function" then return end
        local ok, err = pcall(fn, ...)
        if not ok then warn("[VIREX UI] " .. tostring(err)) end
    end

    local function make_group(section)
        local group = {}

        function group:create_toggle(flag, o)
            o = o or {}
            return section:Toggle({
                Flag = tostring(flag),
                Title = o.title or tostring(flag),
                Value = o.default == true,
                Callback = function(state) safe(o.callback, state) end,
            })
        end

        function group:create_slider(flag, o)
            o = o or {}
            local min = o.minimum or 0
            return section:Slider({
                Flag = tostring(flag),
                Title = o.title or tostring(flag),
                Value = { Min = min, Max = o.maximum or 100, Default = o.default or min },
                Step = o.rounding and 1 or 0.01,
                Callback = function(value) safe(o.callback, value) end,
            })
        end

        function group:create_dropdown(flag, o)
            o = o or {}
            return section:Dropdown({
                Flag = tostring(flag),
                Title = o.title or tostring(flag),
                Values = o.options or {},
                Value = o.default,
                Callback = function(selected) safe(o.callback, selected) end,
            })
        end

        function group:create_button(flag, o)
            if type(flag) == "table" then o = flag; flag = nil end
            o = o or {}
            return section:Button({
                Title = o.title or tostring(flag or "Button"),
                Callback = function() safe(o.callback) end,
            })
        end

        function group:create_textbox(flag, o)
            if type(flag) == "table" then o = flag; flag = nil end
            o = o or {}
            return section:Input({
                Title = o.title or tostring(flag or "Input"),
                Value = o.default or "",
                Placeholder = o.placeholder,
                Callback = function(text) safe(o.callback, text) end,
            })
        end

        return group
    end

    function UI:create_category(name)
        local window = WindUI:CreateWindow({
            Title = tostring(name),
            Author = "by VIREX",
            Icon = "shield",
            Folder = "VIREX",
            Size = UDim2.fromOffset(580, 460),
            Theme = "Dark",
            ToggleKey = Enum.KeyCode.Insert,
        })

        local category = { window = window }

        function category:create_tab(title, icon)
            local tab = window:Tab({
                Title = tostring(title),
                Icon = resolveIcon(title, icon),
            })

            local tabObj = { tab = tab }

            function tabObj:create_group(groupTitle, side)
                local section = tab:Section({
                    Title = tostring(groupTitle),
                    Box = true,
                    BoxBorder = true,
                    Opened = true,
                })
                return make_group(section)
            end

            return tabObj
        end

        return category
    end
end
  
repeat task.wait(0.5) until game:IsLoaded()  
  
local Players           = cloneref(game:GetService('Players'))  
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))  
local UserInputService  = cloneref(game:GetService('UserInputService'))  
local RunService        = cloneref(game:GetService('RunService'))  
local TweenService      = cloneref(game:GetService('TweenService'))  
local Stats             = cloneref(game:GetService('Stats'))  
local Debris            = cloneref(game:GetService('Debris'))  
local CoreGui           = cloneref(game:GetService('CoreGui'))  
local HttpService       = cloneref(game:GetService('HttpService'))  
local Workspace         = cloneref(game:GetService('Workspace'))  
  
local LocalPlayer = Players.LocalPlayer  
local Mouse = LocalPlayer:GetMouse()  
  
if not LocalPlayer.Character then  
    LocalPlayer.CharacterAdded:Wait()  
end  
  
local Alive   = Workspace:FindFirstChild("Alive") or Workspace:WaitForChild("Alive")  
local Runtime = Workspace.Runtime  
  
local function detectMobile()  
    local touch = UserInputService.TouchEnabled  
    local mouse = UserInputService.MouseEnabled  
    local keyboard = UserInputService.KeyboardEnabled  
    if touch and not keyboard then return true end  
    if touch and not mouse then return true end  
    return false  
end  
  
local function Notify(title, content, duration)
    pcall(function()
        WindUI:Notify({
            Title = tostring(title),
            Content = tostring(content or ""),
            Duration = duration or 2,
            Icon = "bell",
        })
    end)
end
  
local System = {  
    __properties = {  
        __autoparry_enabled = false,  
        __triggerbot_enabled = false,  
        __manual_spam_enabled = false,  
        __auto_spam_enabled = false,  
        __play_animation = false,  
        __accuracy = 50,  
        __divisor_multiplier = 1.1,  
        __parried = false,  
        __training_parried = false,  
        __spam_threshold = 1.5,  
        __parries = 0,  
        __parry_key = nil,  
        __grab_animation = nil,  
        __tornado_time = tick(),  
        __first_parry_done = false,  
        __connections = {},  
        __reverted_remotes = {},  
        __spam_accumulator = 0,  
        __spam_rate = 340,  
        __infinity_active = false,  
        __deathslash_active = false,  
        __timehole_active = false,  
        __slashesoffury_active = false,  
        __slashesoffury_count = 0,  
        __is_mobile = detectMobile(),  
        __mobile_guis = {},  
        __randomized_accuracy_enabled = false,  
        __speed_display_enabled = false,  
        __auto_jump_enabled = false,  
        __ball_speed = 0,  
        __peak_ball_speed = 0,  
        __headless_enabled = false,  
        __korblox_enabled = false,  
        __thunder_dash_enabled = false  
    },  
    __config = {  
        __detections = {  
            __infinity=false,__deathslash=false,  
            __timehole=false,__slashesoffury=false,__phantom=false  
        }  
    },  
    __triggerbot = {  
        __enabled=false,__is_parrying=false,  
        __parries=0,__max_parries=10000,__parry_delay=0.05  
    }  
}  
  
local function update_divisor()  
    System.__properties.__divisor_multiplier = 0.7 + (System.__properties.__accuracy - 1) * (0.9/99)  
end  
  
local function update_randomized_accuracy()  
    if not System.__properties.__randomized_accuracy_enabled then return end  
    local ping_str = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()  
    local ping = tonumber(ping_str:match("%d+")) or 0  
    local new_accuracy  
    if ping >= 90 then new_accuracy = 4  
    elseif ping <= 50 then new_accuracy = math.random(70, 100)  
    else new_accuracy = System.__properties.__accuracy end  
    if new_accuracy then System.__properties.__accuracy = new_accuracy; update_divisor() end  
end  
  
task.spawn(function()  
    while task.wait(1) do  
        if System.__properties.__randomized_accuracy_enabled then update_randomized_accuracy() end  
    end  
end)  
  
local replicated_storage = cloneref(game:GetService('ReplicatedStorage'))  
local workspace = cloneref(game:GetService('Workspace'))  
  
local _token  
local _tokenFound = false  
  
for _, Function in getgc(true) do  
    if type(Function) ~= 'function' or not debug.info(Function, 's'):find('PRY', 1, true) then  
        continue  
    end  
    for _, value in debug.getupvalues(Function) do  
        if type(value) == 'function' then  
            _token = value  
            _tokenFound = true  
            break  
        end  
    end  
    if _token then break end  
end  
  
if not _tokenFound then  
    Notify("VIREX", "Remote not found! Re-inject vÃ  cháº¡y láº¡i.", 5)  
    return  
end  
  
function _tokenize(_remote_uid)  
    local time = tostring(math.floor(workspace:GetServerTimeNow() * 100))  
    local key = _token(_remote_uid, 'TIME')  
    local characters = table.create(#time)  
    for index = 1, #time do  
        characters[index] = string.char(bit32.bxor(  
            (string.byte(time, index ) + index) % 256,  
            string.byte(key, (index - 1) % #key + 1)  
        ))  
    end  
    return table.concat(characters)  
end  
  
local _reverted = {}  
local _original = {}  
local _captured = nil  
local _capturedRemote = nil  
local _capturedArgs = nil  
  
function _is_valid(args)  
    if not args or #args < 8 then return false end  
    return true  
end  
  
function _hook(remote)  
    if not remote then return end  
    if _reverted[remote] then return end  
    if _original[getrawmetatable(remote)] then return end  
  
    _original[getrawmetatable(remote)] = true  
    local _meta = getrawmetatable(remote)  
    setreadonly(_meta, false)  
  
    local _old = _meta.__index  
    _meta.__index = function(self, key)  
        if (key == 'FireServer' and self:IsA('RemoteEvent')) or  
           (key == 'InvokeServer' and self:IsA('RemoteFunction')) then  
            return function(_, ...)  
                local _arguments = {...}  
                if _is_valid(_arguments) then  
                    if not _reverted[self] then  
                        _reverted[self] = _arguments  
                        _captured = { remote = self, args = _arguments }  
                        _capturedRemote = self  
                        _capturedArgs = _arguments  
                    end  
                end  
                return _old(self, key)(_, unpack(_arguments))  
            end  
        end  
        return _old(self, key)  
    end  
    setreadonly(_meta, true)  
end  
  
for _iterator, _remote in pairs(replicated_storage:GetDescendants()) do  
    if _remote:IsA('RemoteEvent') or _remote:IsA('RemoteFunction') then  
        _hook(_remote)  
    end  
end  
  
task.wait(5)  
  
task.spawn(function()  
    while not _capturedRemote do  
        task.wait(1)  
    end  
    if _capturedRemote then  
        Notify("VIREX", "Anti-cheat Bypassed", 3)  
    end  
end)  
  
local function fireParryRemote(curveCF)  
    if not _capturedRemote or not _capturedArgs then  
        return false  
    end  
  
    local cam = Workspace.CurrentCamera  
    local is_mobile = System.__properties.__is_mobile  
    local aim_target  
  
    if is_mobile then  
        local vp = cam.ViewportSize  
        aim_target = {math.floor(vp.X / 2), math.floor(vp.Y / 2)}  
    else  
        local ok, mouse = pcall(function() return UserInputService:GetMouseLocation() end)  
        if ok and mouse then  
            aim_target = {math.floor(mouse.X), math.floor(mouse.Y)}  
        else  
            local vp = cam.ViewportSize  
            aim_target = {math.floor(vp.X / 2), math.floor(vp.Y / 2)}  
        end  
    end  
  
    local event_data = {}  
    if Alive then  
        for _, entity in pairs(Alive:GetChildren()) do  
            if entity.PrimaryPart then  
                local ok, sp = pcall(function() return cam:WorldToScreenPoint(entity.PrimaryPart.Position) end)  
                if ok then event_data[entity.Name] = sp end  
            end  
        end  
    end  
  
    local packet = {  
        _capturedArgs[1],  
        _capturedArgs[2],  
        _tokenize(_capturedArgs[2]),  
        0.5,  
        curveCF or cam.CFrame,  
        event_data,  
        aim_target,  
        false  
    }  
  
    pcall(function()  
        if _capturedRemote:IsA('RemoteEvent') then  
            _capturedRemote:FireServer(unpack(packet))  
        elseif _capturedRemote:IsA('RemoteFunction') then  
            _capturedRemote:InvokeServer(unpack(packet))  
        end  
    end)  
    return true  
end  
  
System.animation = {}  
  
local SwordAPI = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SwordAPI")  
local LastPlayedd = 0  
local Sword_CP = false  
local Sword_Spped = 1  
local Grab_Parry = nil  
local AnimFix_Cache = {}  
  
local function GetParryAnimation(swordName)  
    if not swordName or swordName == "" then  
        return SwordAPI.Collection.Default:FindFirstChild("GrabParry")  
    end  
    if AnimFix_Cache[swordName] then return AnimFix_Cache[swordName] end  
    local ok, swordData = pcall(function()  
        return ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(swordName)  
    end)  
    if not ok or not swordData or type(swordData) ~= "table" or not swordData.AnimationType then  
        AnimFix_Cache[swordName] = SwordAPI.Collection.Default:FindFirstChild("GrabParry")  
        return AnimFix_Cache[swordName]  
    end  
    for _, obj in pairs(SwordAPI.Collection:GetChildren()) do  
        if obj.Name == swordData.AnimationType then  
            local anim = obj:FindFirstChild("GrabParry") or obj:FindFirstChild("Grab")  
            if anim then  
                AnimFix_Cache[swordName] = anim  
                return anim  
            end  
        end  
    end  
    AnimFix_Cache[swordName] = SwordAPI.Collection.Default:FindFirstChild("GrabParry")  
    return AnimFix_Cache[swordName]  
end  
  
local function GrabParryPlay(track)  
    if not track then return end  
    pcall(function()  
        track:Play(  
            track:GetAttribute("PlayFadeTime") or 0,  
            track:GetAttribute("PlayWeight") or 1,  
            track:GetAttribute("PlaySpeed") or 1  
        )  
    end)  
end  
  
local function GrabParryStop(track)  
    if not track then return end  
    pcall(function()  
        track:Stop(track:GetAttribute("StopFadeTime") or 0.1)  
    end)  
end  
  
function System.animation.play_grab_parry()  
    if not System.__properties.__play_animation then return end  
    if not ((os.clock() - LastPlayedd) >= (Sword_Spped - 0.8) or Sword_CP) then return end  
    LastPlayedd = os.clock()  
    Sword_CP = false  
    local char = LocalPlayer.Character  
    if not char then return end  
    local humanoid = char:FindFirstChildOfClass("Humanoid")  
    if not humanoid then return end  
    local currentSword  
    if getgenv().skinChanger then  
        currentSword = (getgenv().swordAnimations ~= "" and getgenv().swordAnimations)  
                    or (getgenv().swordModel ~= "" and getgenv().swordModel)  
                    or char:GetAttribute("CurrentlyEquippedSword")  
    else  
        currentSword = char:GetAttribute("CurrentlyEquippedSword")  
    end  
    local animation = GetParryAnimation(currentSword)  
    if not animation then return end  
    for _, track in pairs(humanoid.Animator:GetPlayingAnimationTracks()) do  
        if track.Name == "GrabParry" or track.Name == "Grab" then  
            track.TimePosition = 0  
            GrabParryStop(track)  
        elseif track.Name == "SuccessParry" or track.Name == "Success" then  
            GrabParryStop(track)  
        end  
    end  
    Grab_Parry = humanoid.Animator:LoadAnimation(animation)  
    GrabParryPlay(Grab_Parry)  
end  
  
pcall(function()  
    ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function()  
        Sword_CP = true  
        local char = LocalPlayer.Character  
        if not char then return end  
        local humanoid = char:FindFirstChildOfClass("Humanoid")  
        if not humanoid then return end  
        for _, track in pairs(humanoid.Animator:GetPlayingAnimationTracks()) do  
            if track.Name == "GrabParry" or track.Name == "Grab" then  
                GrabParryStop(track)  
            end  
        end  
    end)  
end)  
  
System.ball = {}  
function System.ball.get()  
    local balls=Workspace:FindFirstChild('Balls'); if not balls then return nil end  
    for _,ball in pairs(balls:GetChildren()) do  
        if ball:GetAttribute('realBall') then ball.CanCollide=false; return ball end  
    end; return nil  
end  
function System.ball.get_all()  
    local balls_table={}; local balls=Workspace:FindFirstChild('Balls')  
    if not balls then return balls_table end  
    for _,ball in pairs(balls:GetChildren()) do  
        if ball:GetAttribute('realBall') then ball.CanCollide=false; table.insert(balls_table,ball) end  
    end; return balls_table  
end  
  
System.player = {}  
local Closest_Entity=nil; local last_closest_check=0  
function System.player.get_closest()  
    local now=tick()  
    if now-last_closest_check < 0.1 then return Closest_Entity end  
    last_closest_check=now  
    local max_distance=math.huge; local closest_entity=nil  
    if not Alive then return nil end  
    for _,entity in pairs(Alive:GetChildren()) do  
        if entity ~= LocalPlayer.Character and entity.PrimaryPart then  
            local distance=LocalPlayer:DistanceFromCharacter(entity.PrimaryPart.Position)  
            if distance < max_distance then max_distance=distance; closest_entity=entity end  
        end  
    end  
    Closest_Entity=closest_entity; return closest_entity  
end  
  
local CURVE_NAMES = {"Camera","Random","Accelerated","Backwards","Slow","High","Normal","Speed","Down","Left","Right"}  
local Selected_Parry_Type = "Camera"  
local CurveType = "Camera"  
  
System.curve = {}  
function System.curve.get_cframe()  
    local Camera = Workspace.CurrentCamera  
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")  
    local root_pos = root and root.Position or Camera.CFrame.Position  
  
    local targetPart  
    do  
        local bestDist = math.huge  
        local mouseLoc = not System.__properties.__is_mobile and UserInputService:GetMouseLocation() or nil  
        if Alive then  
            for _, v in pairs(Alive:GetChildren()) do  
                if v ~= LocalPlayer.Character and v.PrimaryPart then  
                    local screenPos, onScreen = Camera:WorldToScreenPoint(v.PrimaryPart.Position)  
                    if onScreen then  
                        local dist  
                        if mouseLoc then  
                            dist = (Vector2.new(screenPos.X, screenPos.Y) - mouseLoc).Magnitude  
                        else  
                            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)  
                            dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude  
                        end  
                        if dist < bestDist then bestDist = dist; targetPart = v.PrimaryPart end  
                    end  
                end  
            end  
        end  
    end  
    local target_pos = targetPart and targetPart.Position or (root_pos + Camera.CFrame.LookVector * 100)  
  
    local Parry_Type = Selected_Parry_Type  
    local cf  
  
    if Parry_Type == "Camera" then  
        cf = Camera.CFrame  
    elseif Parry_Type == "Random" then  
        local direction = (target_pos - root_pos).Unit  
        local random_offset  
        local attempts = 0  
        repeat  
            random_offset = Vector3.new(math.random(-4000,4000), math.random(-4000,4000), math.random(-4000,4000))  
            local curve_dir = (target_pos + random_offset - root_pos).Unit  
            local dot = direction:Dot(curve_dir)  
            attempts = attempts + 1  
        until dot < 0.95 or attempts > 10  
        cf = CFrame.new(root_pos, target_pos + random_offset)  
    elseif Parry_Type == "Accelerated" then  
        cf = CFrame.new(root_pos, target_pos + Vector3.new(0, 5, 0))  
    elseif Parry_Type == "Backwards" then  
        local direction = (root_pos - target_pos).Unit  
        local backwards_pos = root_pos + direction * 10000 + Vector3.new(0, 1000, 0)  
        cf = CFrame.new(Camera.CFrame.Position, backwards_pos)  
    elseif Parry_Type == "Slow" then  
        cf = CFrame.new(root_pos, target_pos + Vector3.new(0, -9e18, 0))  
    elseif Parry_Type == "High" then  
        cf = CFrame.new(root_pos, target_pos + Vector3.new(0, 9e18, 0))  
    elseif Parry_Type == "Normal" then  
        cf = CFrame.new(root_pos, root_pos + (root and root.CFrame.LookVector or Camera.CFrame.LookVector))  
    elseif Parry_Type == "Speed" then  
        cf = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + Camera.CFrame.UpVector * 5)  
    elseif Parry_Type == "Down" then  
        cf = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + Camera.CFrame.UpVector * -9e9)  
    elseif Parry_Type == "Left" then  
        cf = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position - Camera.CFrame.RightVector * 9e9)  
    elseif Parry_Type == "Right" then  
        cf = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + Camera.CFrame.RightVector * 9e9)  
    else  
        cf = Camera.CFrame  
    end  
  
    return cf  
end  
  
System.parry = {}  
function System.parry.execute()  
    if System.__properties.__parries > 10000 or not LocalPlayer.Character then return end  
    fireParryRemote(System.curve.get_cframe())  
    if System.__properties.__parries > 10000 then return end  
    System.__properties.__parries=System.__properties.__parries+1  
    task.delay(0.5,function() if System.__properties.__parries > 0 then System.__properties.__parries=System.__properties.__parries-1 end end)  
end  
  
function System.parry.keypress()  
    if System.__properties.__parries > 10000 or not LocalPlayer.Character then return end  
    fireParryRemote(System.curve.get_cframe())  
    if System.__properties.__parries > 10000 then return end  
    System.__properties.__parries=System.__properties.__parries+1  
    task.delay(0.5,function() if System.__properties.__parries > 0 then System.__properties.__parries=System.__properties.__parries-1 end end)  
end  
  
function System.parry.execute_action()  
    System.animation.play_grab_parry(); System.parry.execute()  
end  
  
local function linear_predict(a,b,t) return a+(b-a)*t end  
  
System.detection = {  
    __ball_properties = {__aerodynamic_time=tick(),__last_warping=tick(),__lerp_radians=0,__curving=tick()}  
}  
  
function System.detection.is_curved()  
    local props=System.detection.__ball_properties  
    local ball=System.ball.get(); if not ball then return false end  
    local zoomies=ball:FindFirstChild("zoomies"); if not zoomies then return false end  
    local velocity=zoomies.VectorVelocity; local speed=velocity.Magnitude  
    if speed < 1 then return false end  
    local ball_dir=velocity.Unit; local char=LocalPlayer.Character  
    if not char or not char.PrimaryPart then return false end  
    local pos=char.PrimaryPart.Position; local direction=(pos-ball.Position).Unit  
    local dot=direction:Dot(ball_dir)  
    local ping=Stats.Network.ServerStatsItem["Data Ping"]:GetValue()/1000  
    local distance=(pos-ball.Position).Magnitude; local reach_time=distance/speed-ping  
    local dot_threshold=math.clamp(0.55-(ping*0.75),-1,0.45)  
    local speed_threshold=math.min(speed/100,45)  
    local ball_distance_threshold=15-math.min(distance/1000,15)+speed_threshold  
    local clamped_dot=math.clamp(dot,-1,1); local radians=math.asin(clamped_dot)  
    props.__lerp_radians=linear_predict(props.__lerp_radians,radians,0.85)  
    if props.__lerp_radians < 0.016 then props.__last_warping=tick() end  
    if distance < (ball_distance_threshold*0.85) then return false end  
    if (tick()-props.__last_warping) < (reach_time/1.4) then return true end  
    if (tick()-props.__curving) < (reach_time/1.1) then return true end  
    return dot < dot_threshold  
end  
  
ReplicatedStorage.Remotes.DeathBall.OnClientEvent:Connect(function(c,d)  
    System.__properties.__deathslash_active = d or false  
end)  
ReplicatedStorage.Remotes.InfinityBall.OnClientEvent:Connect(function(a,b)  
    System.__properties.__infinity_active = b or false  
end)  
  
ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/TimeHoleActivate"].OnClientEvent:Connect(function(...)  
    local args={...}; local player=args[1]  
    if player==LocalPlayer or player==LocalPlayer.Name or (player and player.Name==LocalPlayer.Name) then  
        System.__properties.__timehole_active=true  
    end  
end)  
ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/TimeHoleDeactivate"].OnClientEvent:Connect(function()  
    System.__properties.__timehole_active=false  
end)  
  
local maxParryCount=36; local parryDelay=0.05  
  
ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/SlashesOfFuryActivate"].OnClientEvent:Connect(function(...)  
    local args={...}; local player=args[1]  
    if player==LocalPlayer or player==LocalPlayer.Name or (player and player.Name==LocalPlayer.Name) then  
        System.__properties.__slashesoffury_active=true; System.__properties.__slashesoffury_count=0  
    end  
end)  
ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/SlashesOfFuryEnd"].OnClientEvent:Connect(function()  
    System.__properties.__slashesoffury_active=false; System.__properties.__slashesoffury_count=0  
end)  
ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/SlashesOfFuryParry"].OnClientEvent:Connect(function()  
    System.__properties.__slashesoffury_count=System.__properties.__slashesoffury_count+1  
end)  
ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/SlashesOfFuryCatch"].OnClientEvent:Connect(function()  
    spawn(function()  
        while System.__properties.__slashesoffury_active and System.__properties.__slashesoffury_count < maxParryCount do  
            if System.__config.__detections.__slashesoffury then System.parry.execute(); task.wait(parryDelay)  
            else break end  
        end  
    end)  
end)  
  
Runtime.ChildAdded:Connect(function(Object)  
    if System.__config.__detections.__phantom then  
        if Object.Name=="maxTransmission" or Object.Name=="transmissionpart" then  
            local Weld=Object:FindFirstChildWhichIsA("WeldConstraint")  
            if Weld then  
                local Character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()  
                if Character and Weld.Part1==Character.HumanoidRootPart then  
                    local CurrentBall=System.ball.get(); Weld:Destroy()  
                    if CurrentBall then  
                        local FocusConnection  
                        FocusConnection=RunService.RenderStepped:Connect(function()  
                            local Highlighted=CurrentBall:GetAttribute("highlighted")  
                            if Highlighted==true then  
                                ReplicatedStorage.Remotes.AbilityButtonPress:Fire()  
                                System.__properties.__parried=true  
                                task.delay(1,function() System.__properties.__parried=false end)  
                            elseif Highlighted==false then FocusConnection:Disconnect() end  
                        end)  
                        task.delay(3,function() if FocusConnection and FocusConnection.Connected then FocusConnection:Disconnect() end end)  
                    end  
                end  
            end  
        end  
    end  
end)  
  
ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(_,root)  
    if root.Parent and root.Parent ~= LocalPlayer.Character then  
        if not Alive or root.Parent.Parent ~= Alive then return end  
    end  
    local closest=System.player.get_closest(); local ball=System.ball.get()  
    if not ball or not closest then return end  
    local target_distance=(LocalPlayer.Character.PrimaryPart.Position-closest.PrimaryPart.Position).Magnitude  
    local distance=(LocalPlayer.Character.PrimaryPart.Position-ball.Position).Magnitude  
    local direction=(LocalPlayer.Character.PrimaryPart.Position-ball.Position).Unit  
    local dot=direction:Dot(ball.AssemblyLinearVelocity.Unit)  
    local curve_detected=System.detection.is_curved()  
    if target_distance < 15 and distance < 15 and dot > -0.25 then  
        if curve_detected then System.parry.execute_action() end  
    end  
    if System.__properties.__grab_animation then System.__properties.__grab_animation:Stop() end  
end)  
  
ReplicatedStorage.Remotes.ParrySuccess.OnClientEvent:Connect(function()  
    if not Alive or LocalPlayer.Character.Parent ~= Alive then return end  
    if System.__properties.__grab_animation then System.__properties.__grab_animation:Stop() end  
end)  
  
ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(a,b)  
    local Primary_Part=LocalPlayer.Character.PrimaryPart  
    local Ball=System.ball.get(); if not Ball then return end  
    local Zoomies=Ball:FindFirstChild('zoomies'); if not Zoomies then return end  
    local Speed=Zoomies.VectorVelocity.Magnitude  
    local Distance=(LocalPlayer.Character.PrimaryPart.Position-Ball.Position).Magnitude  
    local Velocity=Zoomies.VectorVelocity; local Ball_Direction=Velocity.Unit  
    local Direction=(LocalPlayer.Character.PrimaryPart.Position-Ball.Position).Unit  
    local Dot=Direction:Dot(Ball_Direction)  
    local Pings=Stats.Network.ServerStatsItem['Data Ping']:GetValue()  
    local Speed_Threshold=math.min(Speed/100,40)  
    local Reach_Time=Distance/Speed-(Pings/1000)  
    local Enough_Speed=Speed > 1  
    local Ball_Distance_Threshold=15-math.min(Distance/1000,15)+Speed_Threshold  
    if Enough_Speed and Reach_Time > Pings/10 then  
        Ball_Distance_Threshold=math.max(Ball_Distance_Threshold-15,15)  
    end  
    if b ~= Primary_Part and Distance > Ball_Distance_Threshold then  
        System.detection.__ball_properties.__curving=tick()  
    end  
end)  
  
System.triggerbot = {}  
local triggerbotCooldown = false  
  
function System.triggerbot.trigger(ball)  
    if triggerbotCooldown then return end  
    if System.__triggerbot.__is_parrying then return end  
    if System.__triggerbot.__parries > System.__triggerbot.__max_parries then return end  
    if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and  
       LocalPlayer.Character.PrimaryPart:FindFirstChild('SingularityCape') then return end  
  
    triggerbotCooldown = true  
    System.__triggerbot.__is_parrying=true  
    System.__triggerbot.__parries=System.__triggerbot.__parries+1  
  
    System.parry.execute()  
  
    if System.__properties.__play_animation then  
        System.animation.play_grab_parry()  
    end  
  
    task.delay(0.2,function()  
        triggerbotCooldown = false  
        if System.__triggerbot.__parries > 0 then  
            System.__triggerbot.__parries=System.__triggerbot.__parries-1  
        end  
    end)  
  
    task.spawn(function()  
        local start_time=tick()  
        repeat RunService.Heartbeat:Wait()  
        until (tick()-start_time >= 0.15 or not System.__triggerbot.__is_parrying)  
        System.__triggerbot.__is_parrying=false  
    end)  
end  
  
function System.triggerbot.loop()  
    if not System.__triggerbot.__enabled then return end  
    if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and  
       LocalPlayer.Character.PrimaryPart:FindFirstChild('SingularityCape') then return end  
    local balls=Workspace:FindFirstChild('Balls'); if not balls then return end  
    for _,ball in pairs(balls:GetChildren()) do  
        if ball:IsA('BasePart') and ball:GetAttribute('target')==LocalPlayer.Name then  
            System.triggerbot.trigger(ball)  
            break  
        end  
    end  
end  
  
function System.triggerbot.enable(enabled)  
    System.__triggerbot.__enabled=enabled  
    if enabled then  
        if not System.__properties.__connections.__triggerbot then  
            System.__properties.__connections.__triggerbot=RunService.Heartbeat:Connect(System.triggerbot.loop)  
        end  
    else  
        if System.__properties.__connections.__triggerbot then  
            System.__properties.__connections.__triggerbot:Disconnect()  
            System.__properties.__connections.__triggerbot=nil  
        end  
        System.__triggerbot.__is_parrying=false  
        System.__triggerbot.__parries=0  
        triggerbotCooldown = false  
    end  
end  
  
System.manual_spam = {}  
local manualSpamThread=nil  
local macroSpamActive=false  
local macroFrameFireCount=0; local macroFrameTime=0; local macroRealCPS=0; local macroAnimFix=true  
  
function System.manual_spam.start()  
    System.manual_spam.stop()  
    System.__properties.__manual_spam_enabled=true; macroSpamActive=true  
    local parry_keypress=System.parry.keypress; local parry_execute=System.parry.execute  
    local play_animation=System.animation.play_grab_parry; local threshold=0.015  
    manualSpamThread=coroutine.create(function()  
        local last_spam=0  
        while System.__properties.__manual_spam_enabled do  
            local now=os.clock()  
            if now-last_spam >= threshold then  
                last_spam=now  
                if getgenv().ManualSpamMode=="Keypress" then parry_keypress()  
                else parry_execute(); if getgenv().ManualSpamAnimationFix then play_animation() end end  
            end  
            coroutine.yield()  
        end  
    end)  
    task.spawn(function()  
        while System.__properties.__manual_spam_enabled and manualSpamThread  
              and coroutine.status(manualSpamThread) ~= "dead" do  
            coroutine.resume(manualSpamThread); task.wait()  
        end  
    end)  
end  
  
function System.manual_spam.stop()  
    System.__properties.__manual_spam_enabled=false; macroSpamActive=false; manualSpamThread=nil  
end  
  
RunService.Heartbeat:Connect(function(dt)  
    macroFrameTime=macroFrameTime+dt  
    if macroFrameTime >= 0.1 then  
        if macroSpamActive then macroRealCPS=math.floor(macroFrameFireCount/macroFrameTime) end  
        macroFrameFireCount=0; macroFrameTime=0  
    end  
    if macroSpamActive and _capturedRemote then  
        pcall(function() fireParryRemote(System.curve.get_cframe()); macroFrameFireCount=macroFrameFireCount+1 end)  
        if macroAnimFix then System.animation.play_grab_parry() end  
    end  
end)  
  
System.auto_spam = {}  
  
function System.auto_spam:get_entity_properties()  
    System.player.get_closest()  
    if not Closest_Entity or not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart or not Closest_Entity.PrimaryPart then return false end  
    local entity_velocity = Closest_Entity.PrimaryPart.AssemblyLinearVelocity  
    local entity_direction = (LocalPlayer.Character.PrimaryPart.Position - Closest_Entity.PrimaryPart.Position).Unit  
    local entity_distance = (LocalPlayer.Character.PrimaryPart.Position - Closest_Entity.PrimaryPart.Position).Magnitude  
    return {Velocity = entity_velocity, Direction = entity_direction, Distance = entity_distance}  
end  
  
function System.auto_spam:get_ball_properties()  
    local ball = System.ball.get()  
    if not ball or not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return false end  
    local ball_velocity = ball.AssemblyLinearVelocity  
    local ball_direction = (LocalPlayer.Character.PrimaryPart.Position - ball.Position).Unit  
    local ball_distance = (LocalPlayer.Character.PrimaryPart.Position - ball.Position).Magnitude  
    local ball_dot = ball_velocity.Magnitude > 0 and ball_direction:Dot(ball_velocity.Unit) or 0  
    return {Velocity = ball_velocity, Direction = ball_direction, Distance = ball_distance, Dot = ball_dot}  
end  
  
function System.auto_spam.spam_service(self)  
    local ball = System.ball.get()  
    local entity = System.player.get_closest()  
    if not ball or not entity or not entity.PrimaryPart or not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return 0 end  
    local velocity = ball.AssemblyLinearVelocity  
    local speed = velocity.Magnitude  
    local direction = (LocalPlayer.Character.PrimaryPart.Position - ball.Position).Unit  
    local dot = speed > 0 and direction:Dot(velocity.Unit) or 0  
    local target_distance = LocalPlayer:DistanceFromCharacter(entity.PrimaryPart.Position)  
    local maximum_spam_distance = self.Ping + math.min(speed / 6, 255)  
    if self.Entity_Properties.Distance > maximum_spam_distance or self.Ball_Properties.Distance > maximum_spam_distance or target_distance > maximum_spam_distance then return 0 end  
    local maximum_speed = 5 - math.min(speed / 5, 5)  
    local maximum_dot = math.clamp(dot, -1, 0) * maximum_speed  
    return maximum_spam_distance - maximum_dot  
end  
  
function System.auto_spam.start()  
    if System.__properties.__connections.__auto_spam then  
        System.__properties.__connections.__auto_spam:Disconnect()  
    end  
    System.__properties.__auto_spam_enabled = true  
    System.__properties.__connections.__auto_spam = RunService.PreSimulation:Connect(function()  
        if not System.__properties.__auto_spam_enabled then return end  
        local ball = System.ball.get()  
        if not ball or System.__properties.__slashesoffury_active then return end  
        local zoomies = ball:FindFirstChild("zoomies")  
        if not zoomies then return end  
        System.player.get_closest()  
        local ball_properties = System.auto_spam:get_ball_properties()  
        local entity_properties = System.auto_spam:get_entity_properties()  
        if not ball_properties or not entity_properties or not Closest_Entity or not Closest_Entity.PrimaryPart then return end  
        local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()  
        local ping_threshold = math.clamp(ping / 10, 1, 16)  
        local spam_accuracy = System.auto_spam.spam_service({  
            Ball_Properties = ball_properties,  
            Entity_Properties = entity_properties,  
            Ping = ping_threshold  
        })  
        local target_distance = LocalPlayer:DistanceFromCharacter(Closest_Entity.PrimaryPart.Position)  
        local direction = (LocalPlayer.Character.PrimaryPart.Position - ball.Position).Unit  
        local ball_direction = zoomies.VectorVelocity.Magnitude > 0 and zoomies.VectorVelocity.Unit or Vector3.zero  
        local dot = ball_direction.Magnitude > 0 and direction:Dot(ball_direction) or 0  
        local distance = LocalPlayer:DistanceFromCharacter(ball.Position)  
        local ball_target = ball:GetAttribute("target")  
        if not ball_target or target_distance > spam_accuracy or distance > spam_accuracy then return end  
        if LocalPlayer.Character:GetAttribute("Pulsed") then return end  
        if ball_target == LocalPlayer.Name and target_distance > 30 and distance > 30 then return end  
        if distance <= spam_accuracy and System.__properties.__parries > System.__properties.__spam_threshold then  
            if getgenv().AutoSpamMode == "Keypress" then  
                if PF then PF() end  
            else  
                System.parry.execute()  
                if getgenv().AutoSpamAnimationFix and PF then PF() end  
            end  
        end  
    end)  
end  
  
function System.auto_spam.stop()  
    System.__properties.__auto_spam_enabled = false  
    if System.__properties.__connections.__auto_spam then  
        System.__properties.__connections.__auto_spam:Disconnect()  
        System.__properties.__connections.__auto_spam = nil  
    end  
end  
  
System.autoparry = {}  
function System.autoparry.start()  
    if System.__properties.__connections.__autoparry then  
        System.__properties.__connections.__autoparry:Disconnect()  
    end  
    System.__properties.__connections.__autoparry=RunService.PreSimulation:Connect(function()  
        if getgenv().ExperimentalParryEnabled or not System.__properties.__autoparry_enabled or not LocalPlayer.Character or  
           not LocalPlayer.Character.PrimaryPart then return end  
        local balls=System.ball.get_all(); local one_ball=System.ball.get()  
        local training_ball=nil  
        if Workspace:FindFirstChild("TrainingBalls") then  
            for _,Instance in pairs(Workspace.TrainingBalls:GetChildren()) do  
                if Instance:GetAttribute("realBall") then training_ball=Instance; break end  
            end  
        end  
        for _,ball in pairs(balls) do  
            if System.__triggerbot.__enabled then return end  
            if getgenv().BallVelocityAbove800 then return end  
            if not ball then continue end  
            local zoomies=ball:FindFirstChild('zoomies'); if not zoomies then continue end  
            ball:GetAttributeChangedSignal('target'):Once(function() System.__properties.__parried=false end)  
            if System.__properties.__parried then continue end  
            local ball_target=ball:GetAttribute('target')  
            local velocity=zoomies.VectorVelocity  
            local distance=(LocalPlayer.Character.PrimaryPart.Position-ball.Position).Magnitude  
            local ping=Stats.Network.ServerStatsItem['Data Ping']:GetValue()/10  
            local ping_threshold=math.clamp(ping/10,5,17); local speed=velocity.Magnitude  
            local capped_speed_diff=math.min(math.max(speed-9.5,0),650)  
            local speed_divisor=(2.4+capped_speed_diff*0.002)*System.__properties.__divisor_multiplier  
            local parry_accuracy=ping_threshold+math.max(speed/speed_divisor,9.5)  
            local curved=System.detection.is_curved()  
            if ball:FindFirstChild('AeroDynamicSlashVFX') then  
                ball.AeroDynamicSlashVFX:Destroy(); System.__properties.__tornado_time=tick()  
            end  
            if Runtime:FindFirstChild('Tornado') then  
                if (tick()-System.__properties.__tornado_time) <  
                   (Runtime.Tornado:GetAttribute('TornadoTime') or 1)+0.314159 then continue end  
            end  
            if one_ball and one_ball:GetAttribute('target')==LocalPlayer.Name and curved then continue end  
            if ball:FindFirstChild('ComboCounter') then continue end  
            if LocalPlayer.Character.PrimaryPart:FindFirstChild('SingularityCape') then continue end  
            if System.__config.__detections.__infinity and System.__properties.__infinity_active then continue end  
            if System.__config.__detections.__deathslash and System.__properties.__deathslash_active then continue end  
            if System.__config.__detections.__timehole and System.__properties.__timehole_active then continue end  
            if System.__config.__detections.__slashesoffury and System.__properties.__slashesoffury_active then continue end  
            if ball_target==LocalPlayer.Name and distance <= parry_accuracy then  
                if getgenv().AutoAbility then  
                    local AbilityCD=LocalPlayer.PlayerGui.Hotbar.Ability.UIGradient  
                    if AbilityCD and AbilityCD.Offset.Y==0.5 then  
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Abilities") then  
                            local abilities=LocalPlayer.Character.Abilities  
                            if (abilities:FindFirstChild("Raging Deflection") and abilities["Raging Deflection"].Enabled) or  
                               (abilities:FindFirstChild("Rapture") and abilities["Rapture"].Enabled) or  
                               (abilities:FindFirstChild("Calming Deflection") and abilities["Calming Deflection"].Enabled) or  
                               (abilities:FindFirstChild("Aerodynamic Slash") and abilities["Aerodynamic Slash"].Enabled) or  
                               (abilities:FindFirstChild("Fracture") and abilities["Fracture"].Enabled) or  
                               (abilities:FindFirstChild("Death Slash") and abilities["Death Slash"].Enabled) then  
                                System.__properties.__parried=true  
                                ReplicatedStorage.Remotes.AbilityButtonPress:Fire()  
                                task.wait(2.432)  
                                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DeathSlashShootActivation"):FireServer(true)  
                                continue  
                            end  
                        end  
                    end  
                end  
            end  
            if ball_target==LocalPlayer.Name and distance <= parry_accuracy then  
                if getgenv().AutoParryMode=="Keypress" then System.parry.keypress()  
                else System.parry.execute_action() end  
                System.__properties.__parried=true  
            end  
            local last_parrys=tick()  
            repeat RunService.Stepped:Wait()  
            until (tick()-last_parrys) >= 1 or not System.__properties.__parried  
            System.__properties.__parried=false  
        end  
        if training_ball then  
            local zoomies=training_ball:FindFirstChild('zoomies')  
            if zoomies then  
                training_ball:GetAttributeChangedSignal('target'):Once(function() System.__properties.__training_parried=false end)  
                if not System.__properties.__training_parried then  
                    local ball_target=training_ball:GetAttribute('target')  
                    local velocity=zoomies.VectorVelocity  
                    local distance=LocalPlayer:DistanceFromCharacter(training_ball.Position)  
                    local speed=velocity.Magnitude  
                    local ping=Stats.Network.ServerStatsItem['Data Ping']:GetValue()/10  
                    local ping_threshold=math.clamp(ping/10,5,17)  
                    local capped_speed_diff=math.min(math.max(speed-9.5,0),650)  
                    local speed_divisor=(2.4+capped_speed_diff*0.002)*System.__properties.__divisor_multiplier  
                    local parry_accuracy=ping_threshold+math.max(speed/speed_divisor,9.5)  
                    if ball_target==LocalPlayer.Name and distance <= parry_accuracy then  
                        if getgenv().AutoParryMode=="Keypress" then System.parry.keypress()  
                        else System.parry.execute_action() end  
                        System.__properties.__training_parried=true  
                        local last_parrys=tick()  
                        repeat RunService.Stepped:Wait()  
                        until (tick()-last_parrys) >= 1 or not System.__properties.__training_parried  
                        System.__properties.__training_parried=false  
                    end  
                end  
            end  
        end  
    end)  
end  
  
function System.autoparry.stop()  
    if System.__properties.__connections.__autoparry then  
        System.__properties.__connections.__autoparry:Disconnect()  
        System.__properties.__connections.__autoparry=nil  
    end  
end  
  
-- ============================================================
-- Experimental Parry: физическая модель "время до контакта"
-- Вход: позиция/скорость мяча, моя позиция/скорость, пинг, хитбоксы.
-- Парри срабатывает, когда предсказанное время контакта <= задержка.
-- ============================================================
System.exp_parry = {
    cfg = { reach = 8, safety = 0.015, debug = false, antimiss = true },
    states = {},
    ping = 0,
    inst = 0,
    jitter = 0,
    conn = nil,
}

do
    local EP = System.exp_parry

    local TAU_V      = 0.04   -- сглаживание скорости, с
    local TAU_A      = 0.12   -- сглаживание ускорения, с
    local TAU_TURN   = 0.15   -- сглаживание угловой скорости, с
    local TAU_PING   = 0.5    -- сглаживание пинга, с
    local ACC_MAX    = 500    -- предел ускорения мяча, студ/с^2
    local STOP_SPEED = 2      -- ниже этой скорости мяч считается остановившимся
    local CURVE_COS  = 0.965  -- угол скорость/направление-на-игрока > ~15 градусов => curved
    local CURVE_TURN = 1.0    -- либо угловая скорость доворота > 1 рад/с => curved
    local MIN_TURN   = 8.0    -- минимальная скорость доворота мяча к цели в симуляции, рад/с
    local SIM_STEP   = 1 / 90
    local SIM_MAX    = 1.5
    local REARM_TIME = 1.0
    local MAX_TRIES  = 3     -- первое парри + до двух повторов, пока мяч всё ещё целится в нас

    local function alpha(dt, tau)
        return 1 - math.exp(-dt / tau)
    end

    -- ---------- пинг: среднее + разброс (джиттер) ----------
    local function update_ping(dt)
        local ok, ms = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
        end)
        if not ok then return end
        EP.inst = ms
        local a = alpha(dt, TAU_PING)
        local dev = math.abs(ms - EP.ping)
        if EP.ping == 0 then
            EP.ping = ms
        else
            EP.ping = EP.ping + (ms - EP.ping) * a
            EP.jitter = EP.jitter + (dev - EP.jitter) * a
        end
    end

    -- ---------- состояние мяча ----------
    local function drop_state(ball)
        local st = EP.states[ball]
        if not st then return end
        if st.c1 then st.c1:Disconnect() end
        if st.c2 then st.c2:Disconnect() end
        EP.states[ball] = nil
    end

    local function get_state(ball)
        local st = EP.states[ball]
        if st then return st end
        st = {
            v = nil, v_raw = nil, t_change = 0,
            acc = Vector3.zero, turn = 0,
            armed = true, last_fire = 0, tries = 0, retry_at = 0,
        }
        EP.states[ball] = st
        st.c1 = ball:GetAttributeChangedSignal("target"):Connect(function()
            st.armed = true
            st.tries = 0
        end)
        st.c2 = ball.AncestryChanged:Connect(function(_, parent)
            if not parent then drop_state(ball) end
        end)
        return st
    end

    -- zoomies.VectorVelocity обновляется по репликации, а не каждый кадр, поэтому
    -- ускорение и поворот считаем только в момент смены значения (иначе будут всплески).
    local function update_state(st, v, dt, now)
        if not st.v then
            st.v, st.v_raw, st.t_change = v, v, now
            return
        end
        if (v - st.v_raw).Magnitude > 1e-3 then
            local te = math.max(now - st.t_change, 1 / 240)
            local acc_inst = (v - st.v_raw) / te
            if acc_inst.Magnitude > ACC_MAX * 4 then acc_inst = Vector3.zero end
            st.acc = st.acc + (acc_inst - st.acc) * alpha(te, TAU_A)

            local s0, s1 = st.v_raw.Magnitude, v.Magnitude
            if s0 > STOP_SPEED and s1 > STOP_SPEED then
                local d = math.clamp((st.v_raw / s0):Dot(v / s1), -1, 1)
                local w = math.acos(d) / te
                st.turn = st.turn + (w - st.turn) * alpha(te, TAU_TURN)
            else
                st.turn = st.turn * (1 - alpha(te, TAU_TURN))
            end
            st.v_raw, st.t_change = v, now
        end
        st.v = st.v + (v - st.v) * alpha(dt, TAU_V)
    end

    -- ---------- решатель: 0.5*a*t^2 + c*t = g (наименьший t > 0) ----------
    local function solve_gap(g, c, a)
        if g <= 0 then return 0 end
        if math.abs(a) < 1e-3 then
            if c <= 1e-3 then return math.huge end
            return g / c
        end
        local disc = c * c + 2 * a * g
        if disc < 0 then return math.huge end
        local sq = math.sqrt(disc)
        local best = math.huge
        local t1 = (-c + sq) / a
        local t2 = (-c - sq) / a
        if t1 > 0 and t1 < best then best = t1 end
        if t2 > 0 and t2 < best then best = t2 end
        return best
    end

    -- ---------- прямой мяч: аналитика с ускорением и остановкой ----------
    local function straight_time(v, acc, g, u, vp)
        if g <= 0 then return 0 end
        local speed = v.Magnitude
        local vdir = (speed > 1e-3) and (v / speed) or u
        local a_s = math.clamp(acc:Dot(vdir), -ACC_MAX, ACC_MAX) -- изменение модуля скорости
        local a_c = math.clamp(acc:Dot(u), -ACC_MAX, ACC_MAX)    -- ускорение вдоль линии мяч->игрок
        local c = (v - vp):Dot(u)                                -- скорость сближения

        if a_s < -1e-3 and speed > STOP_SPEED then
            local t_stop = speed / -a_s
            local t = solve_gap(g, c, a_c)
            if t <= t_stop then return t end
            -- мяч остановится раньше контакта: дальше сближаемся только за счёт моего движения
            local covered = c * t_stop + 0.5 * a_c * t_stop * t_stop
            local g2 = g - covered
            if g2 <= 0 then return t_stop end
            local c2 = -vp:Dot(u)
            if c2 <= 1e-3 then return math.huge end
            return t_stop + g2 / c2
        end
        return solve_gap(g, c, a_c)
    end

    -- ---------- curved мяч: пошаговая симуляция доворота к цели ----------
    local function curved_time(st, B, P, vp, Dc)
        local v = st.v
        local speed = v.Magnitude
        if speed < 1e-3 then return math.huge end
        local dir = v / speed
        local a_s = math.clamp(st.acc:Dot(dir), -ACC_MAX, ACC_MAX)
        local omega = math.max(st.turn, MIN_TURN)
        local pos, me, t = B, P, 0

        while t < SIM_MAX do
            local to_me = me - pos
            local dist = to_me.Magnitude
            if dist <= Dc then return t end
            local want = to_me / dist
            local ang = math.acos(math.clamp(dir:Dot(want), -1, 1))
            if ang > 1e-4 then
                local k = math.min(1, (omega * SIM_STEP) / ang)
                local nd = dir:Lerp(want, k)
                if nd.Magnitude > 1e-4 then dir = nd.Unit end
            end
            speed = math.max(speed + a_s * SIM_STEP, 0)
            pos = pos + dir * speed * SIM_STEP
            me = me + vp * SIM_STEP
            t = t + SIM_STEP
        end
        return math.huge
    end

    -- ---------- хитбокс игрока ----------
    local radius_cache = { char = nil, value = 1.5, t = 0 }
    local function my_radius(char, now)
        if radius_cache.char ~= char or now - radius_cache.t > 1 then
            radius_cache.char, radius_cache.t = char, now
            local ok, size = pcall(function() return char:GetExtentsSize() end)
            if ok and size then radius_cache.value = math.max(size.X, size.Z) * 0.5 end
        end
        return radius_cache.value
    end

    -- ---------- те же защитные проверки, что и у обычного автопарри ----------
    local function blocked(ball)
        if System.__triggerbot and System.__triggerbot.__enabled then return true end
        if getgenv().BallVelocityAbove800 then return true end
        local vfx = ball:FindFirstChild("AeroDynamicSlashVFX")
        if vfx then
            vfx:Destroy()
            System.__properties.__tornado_time = tick()
        end
        local tornado = Runtime:FindFirstChild("Tornado")
        if tornado then
            local since = tick() - (System.__properties.__tornado_time or 0)
            if since < (tornado:GetAttribute("TornadoTime") or 1) + 0.314159 then return true end
        end
        if ball:FindFirstChild("ComboCounter") then return true end
        local char = LocalPlayer.Character
        if char and char.PrimaryPart and char.PrimaryPart:FindFirstChild("SingularityCape") then return true end
        local d = System.__config.__detections
        local p = System.__properties
        if d.__infinity and p.__infinity_active then return true end
        if d.__deathslash and p.__deathslash_active then return true end
        if d.__timehole and p.__timehole_active then return true end
        if d.__slashesoffury and p.__slashesoffury_active then return true end
        return false
    end

    local function fire(st, now, t_hit, lead, curved, dist, speed)
        st.armed = false
        st.last_fire = now
        st.tries = st.tries + 1
        st.retry_at = now + EP.ping + 0.12
        if getgenv().AutoParryMode == "Keypress" then
            System.parry.keypress()
        else
            System.parry.execute_action()
        end
        if EP.cfg.debug then
            print(string.format("[ExpParry] t=%.3f lead=%.3f curved=%s dist=%.1f speed=%.0f ping=%.0fms",
                t_hit, lead, tostring(curved), dist, speed, EP.ping * 1000))
        end
    end

    -- ---------- основной шаг ----------
    function EP.step(dt)
        local char = LocalPlayer.Character
        local root = char and char.PrimaryPart
        if not root then return end
        local balls_folder = Workspace:FindFirstChild("Balls")
        if not balls_folder then return end

        dt = math.clamp(dt, 1 / 240, 0.1)
        update_ping(dt)
        local now = os.clock()

        local P = root.Position
        local vp = root.AssemblyLinearVelocity
        local base_reach = my_radius(char, now) + EP.cfg.reach
        local spike = math.max(EP.inst - EP.ping, 0) * 0.5      -- всплеск пинга: добавляем запас
        local lead = EP.ping + EP.jitter * 1.5 + spike + EP.cfg.safety + dt * 0.5

        local best = nil
        for _, ball in ipairs(balls_folder:GetChildren()) do
            if ball:GetAttribute("realBall") then
                local zoomies = ball:FindFirstChild("zoomies")
                if zoomies then
                    local st = get_state(ball)
                    update_state(st, zoomies.VectorVelocity, dt, now)
                    if not st.armed then
                        if EP.cfg.antimiss and st.tries < MAX_TRIES and now >= st.retry_at then
                            st.armed = true -- мяч всё ещё целится в нас: второй шанс
                        elseif now - st.last_fire > REARM_TIME then
                            st.armed = true
                            st.tries = 0
                        end
                    end

                    if st.armed and ball:GetAttribute("target") == LocalPlayer.Name and not blocked(ball) then
                        local B = ball.Position
                        local to_me = P - B
                        local dist = to_me.Magnitude
                        local Dc = base_reach + ball.Size.X * 0.5
                        local speed = st.v.Magnitude
                        local t, curved

                        if dist < 1e-3 then
                            t, curved = 0, false
                        else
                            local u = to_me / dist
                            curved = speed > STOP_SPEED
                                and ((st.v / speed):Dot(u) < CURVE_COS or st.turn > CURVE_TURN)
                            if curved then
                                t = curved_time(st, B, P, vp, Dc)
                                if t == math.huge then
                                    -- симуляция не нашла контакта: страхуемся прямой оценкой
                                    t = straight_time(st.v, st.acc, dist - Dc, u, vp)
                                end
                            else
                                t = straight_time(st.v, st.acc, dist - Dc, u, vp)
                                if EP.cfg.antimiss and t > lead then
                                    -- страховка: модель говорит "мяч встанет/замедлится", но по текущей
                                    -- скорости он уже на подлёте -> лучше лишнее парри, чем промах
                                    local c = (st.v - vp):Dot(u)
                                    if c > 1 then
                                        local t_const = (dist - Dc) / c
                                        if t_const <= lead * 0.5 then t = t_const end
                                    end
                                end
                            end
                        end

                        if not best or t < best.t then
                            best = { t = t, st = st, curved = curved, dist = dist, speed = speed }
                        end
                    end
                end
            end
        end

        if best and best.t <= lead then
            fire(best.st, now, best.t, lead, best.curved, best.dist, best.speed)
        end
    end

    function EP.start()
        EP.stop()
        getgenv().ExperimentalParryEnabled = true
        EP.conn = RunService.PreSimulation:Connect(function(dt)
            local ok, err = pcall(EP.step, dt)
            if not ok and EP.cfg.debug then warn("[ExpParry] " .. tostring(err)) end
        end)
    end

    function EP.stop()
        getgenv().ExperimentalParryEnabled = false
        if EP.conn then EP.conn:Disconnect(); EP.conn = nil end
        for ball in pairs(EP.states) do drop_state(ball) end
    end
end

local ManualSpamGui = nil  
local ManualSpamConnections = {}  
local TriggerGui = nil  
local TriggerConnections = {}  
local CurveGui = nil  
local CurveConnections = {}  
local KeyboardGui = nil  
local KeyboardConnections = {}  
local KeyboardKeyConnections = {}  
local KeyboardCapture = nil  
local KeyboardCaptureConsumed = false  
  
local KeyboardSettings = {  
    AutoParry = Enum.KeyCode.T,  
    AutoSpam = Enum.KeyCode.V,  
    ManualSpam = Enum.KeyCode.F,  
    ManualSpamMode = "Hold to Spam"  
}  
  
local function keyName(keyCode)  
    return keyCode == Enum.KeyCode.Unknown and "None" or keyCode.Name  
end  
  
local function isKeyboardInput(input)  
    return input.UserInputType == Enum.UserInputType.Keyboard  
        and input.KeyCode ~= Enum.KeyCode.Unknown  
end  
  
local function stopManualKeyboardSpam()  
    if KeyboardSettings.ManualSpamMode == "Hold to Spam" and System.__properties.__manual_spam_enabled then  
        _G.manualSpamEnabled = false  
        if _G.VIREX then _G.VIREX.manualSpamEnabled = false end  
        System.manual_spam.stop()  
        macroSpamActive = false  
    end  
end  
  
local function toggleManualKeyboardSpam()  
    local state = not System.__properties.__manual_spam_enabled  
    _G.manualSpamEnabled = state  
    _G.VIREX = _G.VIREX or {}  
    _G.VIREX.manualSpamEnabled = state  
    System.__properties.__manual_spam_enabled = state  
    macroSpamActive = state  
    if state then  
        System.manual_spam.start()  
    else  
        System.manual_spam.stop()  
    end  
end  
  
local function SetKeyboardKey(name, keyCode)  
    KeyboardSettings[name] = keyCode  
end  
  
local DisconnectConnections  
  
local function CreateKeyboardUI()  
    if KeyboardGui and KeyboardGui.Parent then  
        KeyboardGui.Enabled = true  
        return  
    end  
  
    local gui = Instance.new("ScreenGui")  
    gui.Name = "VIREX_KeyboardUI"  
    gui.ResetOnSpawn = false  
    gui.IgnoreGuiInset = true  
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling  
    gui.Parent = CoreGui  
    KeyboardGui = gui  
  
    local Main = Instance.new("Frame")  
    Main.Name = "Keyboard"  
    Main.Size = UDim2.fromOffset(260, 126)  
    Main.Position = UDim2.new(0.5, -130, 0.5, -63)  
    Main.BackgroundColor3 = Color3.fromRGB(16, 16, 16)  
    Main.BorderSizePixel = 0  
    Main.Active = true  
    Main.ZIndex = 2500  
    Main.Parent = gui  
  
    local Corner = Instance.new("UICorner")  
    Corner.CornerRadius = UDim.new(0, 13)  
    Corner.Parent = Main  
  
    local Stroke = Instance.new("UIStroke")  
    Stroke.Thickness = 1.5  
    Stroke.Color = Color3.fromRGB(70, 70, 70)  
    Stroke.Transparency = 0.25  
    Stroke.Parent = Main  
  
    local Title = Instance.new("TextLabel")  
    Title.Size = UDim2.new(1, -20, 0, 32)  
    Title.Position = UDim2.fromOffset(10, 5)  
    Title.BackgroundTransparency = 1  
    Title.Text = "Keyboard"  
    Title.TextColor3 = Color3.fromRGB(245, 245, 245)  
    Title.TextSize = 15  
    Title.Font = Enum.Font.GothamBold  
    Title.TextXAlignment = Enum.TextXAlignment.Center  
    Title.ZIndex = 2502  
    Title.Parent = Main  
  
    local Divider = Instance.new("Frame")  
    Divider.Size = UDim2.new(1, 0, 0, 1)  
    Divider.Position = UDim2.fromOffset(0, 40)  
    Divider.BackgroundColor3 = Color3.fromRGB(34, 34, 34)  
    Divider.BorderSizePixel = 0  
    Divider.ZIndex = 2501  
    Divider.Parent = Main  
  
    local Rows = Instance.new("Frame")  
    Rows.Size = UDim2.new(1, -20, 0, 76)  
    Rows.Position = UDim2.fromOffset(10, 47)  
    Rows.BackgroundTransparency = 1  
    Rows.ZIndex = 2502  
    Rows.Parent = Main  
  
    local layout = Instance.new("UIListLayout")  
    layout.Padding = UDim.new(0, 4)  
    layout.FillDirection = Enum.FillDirection.Vertical  
    layout.Parent = Rows  
  
    local modeOpen = false  
    local modePanel = Instance.new("Frame")  
    modePanel.Size = UDim2.new(1, -20, 0, 46)  
    modePanel.Position = UDim2.fromOffset(10, 123)  
    modePanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)  
    modePanel.BorderSizePixel = 0  
    modePanel.Visible = false  
    modePanel.ZIndex = 2510  
    modePanel.Parent = Main  
  
    local modeCorner = Instance.new("UICorner")  
    modeCorner.CornerRadius = UDim.new(0, 9)  
    modeCorner.Parent = modePanel  
  
    local modeStroke = Instance.new("UIStroke")  
    modeStroke.Thickness = 1  
    modeStroke.Color = Color3.fromRGB(55, 55, 55)  
    modeStroke.Parent = modePanel  
  
    local function makeButton(parent, textValue, widthScale, xScale)  
        local button = Instance.new("TextButton")  
        button.Size = UDim2.new(widthScale, -4, 1, 0)  
        button.Position = UDim2.new(xScale, 2, 0, 0)  
        button.BackgroundColor3 = Color3.fromRGB(24, 24, 24)  
        button.BorderSizePixel = 0  
        button.Text = textValue  
        button.TextColor3 = Color3.fromRGB(245, 245, 245)  
        button.TextSize = 12  
        button.Font = Enum.Font.GothamSemibold  
        button.AutoButtonColor = false  
        button.ZIndex = 2512  
        button.Parent = parent  
        local c = Instance.new("UICorner")  
        c.CornerRadius = UDim.new(0, 7)  
        c.Parent = button  
        local st = Instance.new("UIStroke")  
        st.Thickness = 1  
        st.Color = Color3.fromRGB(55, 55, 55)  
        st.Parent = button  
        return button  
    end  
  
    local function makeRow(label, settingName)  
        local row = Instance.new("Frame")  
        row.Size = UDim2.new(1, 0, 0, 22)  
        row.BackgroundTransparency = 1  
        row.ZIndex = 2503  
        row.Parent = Rows  
  
        local text = Instance.new("TextLabel")  
        text.Size = UDim2.new(0.58, 0, 1, 0)  
        text.BackgroundTransparency = 1  
        text.Text = label  
        text.TextColor3 = Color3.fromRGB(230, 230, 230)  
        text.TextSize = 13  
        text.Font = Enum.Font.GothamMedium  
        text.TextXAlignment = Enum.TextXAlignment.Left  
        text.ZIndex = 2504  
        text.Parent = row  
  
        local button = makeButton(row, keyName(KeyboardSettings[settingName]), 0.42, 0.58)  
        return button  
    end  
  
    local autoParryButton = makeRow("Auto Parry", "AutoParry")  
    local autoSpamButton = makeRow("Auto Spam", "AutoSpam")  
  
    local manualRow = Instance.new("Frame")  
    manualRow.Size = UDim2.new(1, 0, 0, 22)  
    manualRow.BackgroundTransparency = 1  
    manualRow.ZIndex = 2503  
    manualRow.Parent = Rows  
  
    local manualText = Instance.new("TextLabel")  
    manualText.Size = UDim2.new(0.34, 0, 1, 0)  
    manualText.BackgroundTransparency = 1  
    manualText.Text = "Manual Spam"  
    manualText.TextColor3 = Color3.fromRGB(230, 230, 230)  
    manualText.TextSize = 13  
    manualText.Font = Enum.Font.GothamMedium  
    manualText.TextXAlignment = Enum.TextXAlignment.Left  
    manualText.ZIndex = 2504  
    manualText.Parent = manualRow  
  
    local manualKeyButton = makeButton(manualRow, keyName(KeyboardSettings.ManualSpam), 0.28, 0.34)  
    local manualModeButton = makeButton(manualRow, KeyboardSettings.ManualSpamMode, 0.38, 0.62)  
  
    local function animateMode(open)  
        modeOpen = open  
        if open then  
            modePanel.Visible = true  
            modePanel.Size = UDim2.new(1, -20, 0, 0)  
            modePanel.Position = UDim2.fromOffset(10, 123)  
            TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {  
                Size = UDim2.fromOffset(260, 180)  
            }):Play()  
            TweenService:Create(modePanel, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {  
                Size = UDim2.new(1, -20, 0, 46)  
            }):Play()  
        else  
            local tween = TweenService:Create(modePanel, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {  
                Size = UDim2.new(1, -20, 0, 0)  
            })  
            tween:Play()  
            TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {  
                Size = UDim2.fromOffset(260, 126)  
            }):Play()  
            tween.Completed:Connect(function()  
                if not modeOpen then modePanel.Visible = false end  
            end)  
        end  
    end  
  
    local holdOption = makeButton(modePanel, "Hold to Spam", 0.5, 0)  
    local onceOption = makeButton(modePanel, "Press Once to Spam", 0.5, 0.5)  
  
    local function selectMode(mode)  
        KeyboardSettings.ManualSpamMode = mode  
        manualModeButton.Text = mode  
        animateMode(false)  
    end  
  
    manualModeButton.MouseButton1Click:Connect(function()  
        animateMode(not modeOpen)  
    end)  
    holdOption.MouseButton1Click:Connect(function()  
        selectMode("Hold to Spam")  
    end)  
    onceOption.MouseButton1Click:Connect(function()  
        selectMode("Press Once to Spam")  
    end)  
  
    local function beginKeyCapture(settingName, button)  
        if KeyboardCapture then return end  
        KeyboardCapture = settingName  
        button.Text = "Press a key..."  
        task.spawn(function()  
            local timeout = os.clock() + 8  
            while KeyboardCapture == settingName and os.clock() < timeout do  
                task.wait()  
            end  
            if KeyboardCapture == settingName then  
                KeyboardCapture = nil  
                button.Text = keyName(KeyboardSettings[settingName])  
            end  
        end)  
    end  
  
    autoParryButton.MouseButton1Click:Connect(function()  
        beginKeyCapture("AutoParry", autoParryButton)  
    end)  
    autoSpamButton.MouseButton1Click:Connect(function()  
        beginKeyCapture("AutoSpam", autoSpamButton)  
    end)  
    manualKeyButton.MouseButton1Click:Connect(function()  
        beginKeyCapture("ManualSpam", manualKeyButton)  
    end)  
  
    KeyboardConnections.capture = UserInputService.InputBegan:Connect(function(input, processed)  
        if not isKeyboardInput(input) then return end  
        if KeyboardCapture then  
            local name = KeyboardCapture  
            KeyboardCapture = nil  
            KeyboardCaptureConsumed = true  
            SetKeyboardKey(name, input.KeyCode)  
            local button = name == "AutoParry" and autoParryButton or name == "AutoSpam" and autoSpamButton or manualKeyButton  
            button.Text = keyName(input.KeyCode)  
            return  
        end  
    end)  
  
    KeyboardConnections.inputBegan = UserInputService.InputBegan:Connect(function(input, processed)  
        if KeyboardCaptureConsumed then  
            KeyboardCaptureConsumed = false  
            return  
        end  
        if processed or not isKeyboardInput(input) or KeyboardCapture then return end  
        if input.KeyCode == KeyboardSettings.AutoParry then  
            local state = not System.__properties.__autoparry_enabled  
            System.__properties.__autoparry_enabled = state  
            System.__properties.__play_animation = state  
            if state then System.autoparry.start() else System.autoparry.stop() end  
        elseif input.KeyCode == KeyboardSettings.AutoSpam then  
            local state = not System.__properties.__auto_spam_enabled  
            System.__properties.__auto_spam_enabled = state  
            if state then System.auto_spam.start() else System.auto_spam.stop() end  
        elseif input.KeyCode == KeyboardSettings.ManualSpam then  
            if KeyboardSettings.ManualSpamMode == "Press Once to Spam" then  
                toggleManualKeyboardSpam()  
            else  
                if not System.__properties.__manual_spam_enabled then  
                    _G.manualSpamEnabled = true  
                    _G.VIREX = _G.VIREX or {}  
                    _G.VIREX.manualSpamEnabled = true  
                    System.manual_spam.start()  
                end  
            end  
        end  
    end)  
  
    KeyboardConnections.inputEnded = UserInputService.InputEnded:Connect(function(input)  
        if not isKeyboardInput(input) or KeyboardCapture then return end  
        if input.KeyCode == KeyboardSettings.ManualSpam and KeyboardSettings.ManualSpamMode == "Hold to Spam" then  
            stopManualKeyboardSpam()  
        end  
    end)  
  
    local dragging = false  
    local dragStart  
    local startPos  
    KeyboardConnections.dragBegan = Main.InputBegan:Connect(function(input)  
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end  
        dragging = true  
        dragStart = input.Position  
        startPos = Main.Position  
    end)  
    KeyboardConnections.dragChanged = UserInputService.InputChanged:Connect(function(input)  
        if not dragging then return end  
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end  
        local delta = input.Position - dragStart  
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)  
    end)  
    KeyboardConnections.dragEnded = UserInputService.InputEnded:Connect(function(input)  
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
            dragging = false  
        end  
    end)  
end  
  
local function DestroyKeyboardUI()  
    KeyboardCapture = nil  
    DisconnectConnections(KeyboardConnections)  
    if KeyboardGui then  
        KeyboardGui:Destroy()  
        KeyboardGui = nil  
    end  
end  
  
DisconnectConnections = function(tbl)  
    for _, connection in pairs(tbl) do  
        pcall(function() connection:Disconnect() end)  
    end  
    table.clear(tbl)  
end  
  
local function CreateSmallActionUI(kind)  
    local isTrigger = (kind == "Trigger")  
    local existing = isTrigger and TriggerGui or ManualSpamGui  
    local connections = isTrigger and TriggerConnections or ManualSpamConnections  
  
    if existing and existing.Parent then  
        existing.Enabled = true  
        return  
    end  
  
    local gui = Instance.new("ScreenGui")  
    gui.Name = isTrigger and "VIREX_TriggerUI" or "VIREX_SpamUI"  
    gui.ResetOnSpawn = false  
    gui.IgnoreGuiInset = true  
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling  
    gui.Parent = CoreGui  
  
    if isTrigger then  
        TriggerGui = gui  
    else  
        ManualSpamGui = gui  
        _G.manualSpamEnabled = false  
        _G.VIREX = _G.VIREX or {}  
        _G.VIREX.manualSpamEnabled = false  
    end  
  
    local Main = Instance.new("Frame")  
    Main.Size = UDim2.fromOffset(180, 60)  
    Main.Position = UDim2.new(0.5, -90, 0.5, -30)  
    Main.BackgroundColor3 = Color3.fromRGB(128, 128, 128)  
    Main.BorderSizePixel = 0  
    Main.Active = true  
    Main.ZIndex = 999  
    Main.Parent = gui  
  
    local UICorner = Instance.new("UICorner")  
    UICorner.CornerRadius = UDim.new(0, 13)  
    UICorner.Parent = Main  
  
    local Stroke = Instance.new("UIStroke")  
    Stroke.Thickness = 2  
    Stroke.Color = Color3.fromRGB(255, 255, 255)  
    Stroke.Transparency = 0.35  
    Stroke.Parent = Main  
  
    local Gradient = Instance.new("UIGradient")  
    Gradient.Rotation = 90  
    Gradient.Color = ColorSequence.new({  
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),  
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(170, 170, 170)),  
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(60, 60, 60)),  
        ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 5))  
    })  
    Gradient.Parent = Main  
  
    local Button = Instance.new("TextButton")  
    Button.Size = UDim2.new(1, 0, 1, 0)  
    Button.BackgroundTransparency = 1  
    Button.Text = isTrigger and "TRIGGER" or "SPAM"  
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)  
    Button.TextSize = 18  
    Button.Font = Enum.Font.GothamBold  
    Button.AutoButtonColor = false  
    Button.ZIndex = 1000  
    Button.Parent = Main  
  
    local dragging = false  
    local dragStart  
    local startPos  
    local dragThreshold = 6  
    local dragInput = nil  
    local dragCandidate = false  
  
    local function isOnBorder(inputPosition)  
        local absolutePosition = Main.AbsolutePosition  
        local absoluteSize = Main.AbsoluteSize  
        local x = inputPosition.X - absolutePosition.X  
        local y = inputPosition.Y - absolutePosition.Y  
        local border = 10  
        return x >= 0 and x <= absoluteSize.X  
            and y >= 0 and y <= absoluteSize.Y  
            and (x <= border or x >= absoluteSize.X - border  
                or y <= border or y >= absoluteSize.Y - border)  
    end  
  
    if isTrigger then  
        connections.button = Button.MouseButton1Click:Connect(function()  
            local state = not System.__properties.__triggerbot_enabled  
            System.__properties.__triggerbot_enabled = state  
            System.triggerbot.enable(state)  
            Button.Text = state and "OFF" or "TRIGGER"  
            Notify("Trigger", state and "ON" or "OFF", 2)  
        end)  
    else  
        connections.button = Button.MouseButton1Click:Connect(function()  
            local state = not _G.manualSpamEnabled  
            _G.manualSpamEnabled = state  
            _G.VIREX.manualSpamEnabled = state  
            System.__properties.__manual_spam_enabled = state  
            macroSpamActive = state  
            if state then  
                System.manual_spam.start()  
                Button.Text = "OFF"  
                Notify("Manual Spam", "ON", 2)  
            else  
                System.manual_spam.stop()  
                Button.Text = "SPAM"  
                Notify("Manual Spam", "OFF", 2)  
            end  
        end)  
    end  
  
    connections.inputBegan = UserInputService.InputBegan:Connect(function(input)  
        if input.UserInputType ~= Enum.UserInputType.MouseButton1  
            and input.UserInputType ~= Enum.UserInputType.Touch then return end  
        if not isOnBorder(input.Position) then  
            dragCandidate = false  
            return  
        end  
        dragCandidate = true  
        dragging = false  
        dragInput = input  
        dragStart = input.Position  
        startPos = Main.Position  
    end)  
  
    connections.inputChanged = UserInputService.InputChanged:Connect(function(input)  
        if not dragCandidate then return end  
        if input.UserInputType ~= Enum.UserInputType.MouseMovement  
            and input.UserInputType ~= Enum.UserInputType.Touch then return end  
        local delta = input.Position - dragStart  
        if not dragging then  
            if math.abs(delta.X) < dragThreshold and math.abs(delta.Y) < dragThreshold then return end  
            dragging = true  
        end  
        Main.Position = UDim2.new(  
            startPos.X.Scale, startPos.X.Offset + delta.X,  
            startPos.Y.Scale, startPos.Y.Offset + delta.Y  
        )  
    end)  
  
    connections.inputEnded = UserInputService.InputEnded:Connect(function(input)  
        if input == dragInput  
            or input.UserInputType == Enum.UserInputType.MouseButton1  
            or input.UserInputType == Enum.UserInputType.Touch then  
            dragging = false  
            dragCandidate = false  
            dragInput = nil  
        end  
    end)  
end  
  
  
local function CreateCurveUI()  
    if CurveGui and CurveGui.Parent then  
        CurveGui.Enabled = true  
        return  
    end  
  
    local gui = Instance.new("ScreenGui")  
    gui.Name = "VIREX_CurveUI"  
    gui.ResetOnSpawn = false  
    gui.IgnoreGuiInset = true  
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling  
    gui.Parent = CoreGui  
    CurveGui = gui  
  
    local Main = Instance.new("Frame")  
    Main.Name = "CurveUI"  
    Main.AnchorPoint = Vector2.new(0.5, 0)  
    Main.Size = UDim2.fromOffset(118, 42)  
    Main.Position = UDim2.new(0.5, 0, 0, 16)  
    Main.BackgroundColor3 = Color3.fromRGB(128, 128, 128)  
    Main.BackgroundTransparency = 0.04  
    Main.BorderSizePixel = 0  
    Main.ClipsDescendants = true  
    Main.Active = true  
    Main.ZIndex = 2000  
    Main.Parent = gui  
  
    local Corner = Instance.new("UICorner")  
    Corner.CornerRadius = UDim.new(0, 14)  
    Corner.Parent = Main  
  
    local Gradient = Instance.new("UIGradient")  
    Gradient.Rotation = 0  
    Gradient.Color = ColorSequence.new({  
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),  
        ColorSequenceKeypoint.new(0.48, Color3.fromRGB(155, 155, 155)),  
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))  
    })  
    Gradient.Parent = Main  
  
    local Stroke = Instance.new("UIStroke")  
    Stroke.Thickness = 1.5  
    Stroke.Color = Color3.fromRGB(255, 255, 255)  
    Stroke.Transparency = 0.3  
    Stroke.Parent = Main  
  
    local Header = Instance.new("TextButton")  
    Header.Name = "Header"  
    Header.Size = UDim2.new(1, -10, 0, 42)  
    Header.Position = UDim2.fromOffset(5, 0)  
    Header.BackgroundTransparency = 1  
    Header.Text = tostring(Selected_Parry_Type or "Camera")  
    Header.TextColor3 = Color3.fromRGB(255, 255, 255)  
    Header.TextSize = 14  
    Header.Font = Enum.Font.GothamBold  
    Header.AutoButtonColor = false  
    Header.ZIndex = 2002  
    Header.Parent = Main  
  
    local OptionsHolder = Instance.new("Frame")  
    OptionsHolder.Name = "Options"  
    OptionsHolder.Position = UDim2.fromOffset(8, 50)  
    OptionsHolder.Size = UDim2.new(1, -16, 1, -58)  
    OptionsHolder.BackgroundTransparency = 1  
    OptionsHolder.Visible = false  
    OptionsHolder.ZIndex = 2002  
    OptionsHolder.Parent = Main  
  
    local Grid = Instance.new("UIGridLayout")  
    Grid.CellSize = UDim2.fromOffset(136, 29)  
    Grid.CellPadding = UDim2.fromOffset(8, 5)  
    Grid.HorizontalAlignment = Enum.HorizontalAlignment.Center  
    Grid.VerticalAlignment = Enum.VerticalAlignment.Top  
    Grid.Parent = OptionsHolder  
  
    local expanded = false  
    local current = Selected_Parry_Type or "Camera"  
    local CLOSED_WIDTH = 118  
    local OPEN_WIDTH = 296  
    local OPEN_HEIGHT = 268  
  
    local function setHeader()  
        Header.Text = tostring(current)  
    end  
  
    local function closeUI()  
        expanded = false  
        OptionsHolder.Visible = false  
        local heightTween = TweenService:Create(Main, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {  
            Size = UDim2.fromOffset(OPEN_WIDTH, 42)  
        })  
        heightTween:Play()  
        heightTween.Completed:Wait()  
        TweenService:Create(Main, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {  
            Size = UDim2.fromOffset(CLOSED_WIDTH, 42)  
        }):Play()  
    end  
  
    local function setSelected(value)  
        current = value  
        Selected_Parry_Type = value  
        CurveType = value  
        setHeader()  
        closeUI()  
    end  
  
    for _, name in ipairs(CURVE_NAMES) do  
        local Option = Instance.new("TextButton")  
        Option.Name = name  
        Option.Size = UDim2.fromOffset(136, 29)  
        Option.BackgroundColor3 = Color3.fromRGB(115, 115, 115)  
        Option.BackgroundTransparency = 0.18  
        Option.BorderSizePixel = 0  
        Option.Text = name  
        Option.TextColor3 = Color3.fromRGB(255, 255, 255)  
        Option.TextSize = 12  
        Option.Font = Enum.Font.GothamSemibold  
        Option.AutoButtonColor = false  
        Option.ZIndex = 2003  
        Option.Parent = OptionsHolder  
  
        local OptionCorner = Instance.new("UICorner")  
        OptionCorner.CornerRadius = UDim.new(0, 9)  
        OptionCorner.Parent = Option  
  
        local OptionGradient = Instance.new("UIGradient")  
        OptionGradient.Color = ColorSequence.new({  
            ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 235, 235)),  
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 120, 120)),  
            ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))  
        })  
        OptionGradient.Parent = Option  
  
        CurveConnections["option_" .. name] = Option.MouseButton1Click:Connect(function()  
            setSelected(name)  
        end)  
    end  
  
    CurveConnections.selected = Header.MouseButton1Click:Connect(function()  
        if expanded then  
            closeUI()  
            return  
        end  
  
        expanded = true  
        Header.Text = tostring(current)  
        TweenService:Create(Main, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {  
            Size = UDim2.fromOffset(OPEN_WIDTH, 42)  
        }):Play()  
  
        task.wait(0.32)  
        if not expanded then return end  
  
        OptionsHolder.Visible = true  
        TweenService:Create(Main, TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {  
            Size = UDim2.fromOffset(OPEN_WIDTH, OPEN_HEIGHT)  
        }):Play()  
    end)  
  
    local dragging = false  
    local dragStart  
    local startPos  
    local dragInput  
  
    CurveConnections.inputBegan = UserInputService.InputBegan:Connect(function(input)  
        if input.UserInputType ~= Enum.UserInputType.MouseButton1  
            and input.UserInputType ~= Enum.UserInputType.Touch then return end  
  
        local p = input.Position  
        local pos = Main.AbsolutePosition  
        local size = Main.AbsoluteSize  
        if p.X < pos.X or p.X > pos.X + size.X or p.Y < pos.Y or p.Y > pos.Y + size.Y then  
            return  
        end  
  
        if expanded and p.Y >= pos.Y + 45 then return end  
  
        dragging = true  
        dragInput = input  
        dragStart = p  
        startPos = Main.Position  
    end)  
  
    CurveConnections.inputChanged = UserInputService.InputChanged:Connect(function(input)  
        if not dragging then return end  
        if input.UserInputType ~= Enum.UserInputType.MouseMovement  
            and input.UserInputType ~= Enum.UserInputType.Touch then return end  
  
        local delta = input.Position - dragStart  
        Main.Position = UDim2.new(  
            startPos.X.Scale, startPos.X.Offset + delta.X,  
            startPos.Y.Scale, startPos.Y.Offset + delta.Y  
        )  
    end)  
  
    CurveConnections.inputEnded = UserInputService.InputEnded:Connect(function(input)  
        if input == dragInput  
            or input.UserInputType == Enum.UserInputType.MouseButton1  
            or input.UserInputType == Enum.UserInputType.Touch then  
            dragging = false  
            dragInput = nil  
        end  
    end)  
end  
  
local function DestroyCurveUI()  
    DisconnectConnections(CurveConnections)  
    if CurveGui then  
        CurveGui:Destroy()  
        CurveGui = nil  
    end  
end  
  
local function CreateSpamUI()  
    CreateSmallActionUI("Spam")  
end  
  
local function CreateTriggerUI()  
    CreateSmallActionUI("Trigger")  
end  
  
local function DestroySpamUI()  
    _G.manualSpamEnabled = false  
    if _G.VIREX then _G.VIREX.manualSpamEnabled = false end  
    System.__properties.__manual_spam_enabled = false  
    macroSpamActive = false  
    System.manual_spam.stop()  
    DisconnectConnections(ManualSpamConnections)  
    if ManualSpamGui then  
        ManualSpamGui:Destroy()  
        ManualSpamGui = nil  
    end  
end  
  
local function DestroyTriggerUI()  
    System.__properties.__triggerbot_enabled = false  
    System.triggerbot.enable(false)  
    DisconnectConnections(TriggerConnections)  
    if TriggerGui then  
        TriggerGui:Destroy()  
        TriggerGui = nil  
    end  
end  
  
  
local function CharacterBackendApply()  
    if not getgenv().CharacterModifierEnabled then return end  
  
    local char = LocalPlayer.Character  
    if not char then return end  
  
    local humanoid = char:FindFirstChildOfClass("Humanoid")  
    local root = char:FindFirstChild("HumanoidRootPart")  
  
    if humanoid then  
        if not getgenv().OriginalValues or getgenv().OriginalValues.Character ~= char then  
            getgenv().OriginalValues = {  
                Character = char,  
                WalkSpeed = humanoid.WalkSpeed,  
                JumpPower = humanoid.JumpPower,  
                JumpHeight = humanoid.JumpHeight,  
                HipHeight = humanoid.HipHeight,  
                AutoRotate = humanoid.AutoRotate  
            }  
        end  
  
        if getgenv().WalkspeedCheckboxEnabled then  
            humanoid.WalkSpeed = tonumber(getgenv().CustomWalkSpeed) or 36  
        end  
  
        if getgenv().JumpPowerCheckboxEnabled then  
            if humanoid.UseJumpPower then  
                humanoid.JumpPower = tonumber(getgenv().CustomJumpPower) or 50  
            else  
                humanoid.JumpHeight = tonumber(getgenv().CustomJumpHeight) or 7.2  
            end  
        end  
  
        if getgenv().HipHeightCheckboxEnabled then  
            humanoid.HipHeight = tonumber(getgenv().CustomHipHeight) or 0  
        end  
  
        if getgenv().SpinbotCheckboxEnabled and root then  
            humanoid.AutoRotate = false  
            getgenv().spinAngle = ((getgenv().spinAngle or 0) + (tonumber(getgenv().CustomSpinSpeed) or 5)) % 360  
            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(getgenv().spinAngle), 0)  
        elseif getgenv().OriginalValues.AutoRotate ~= nil then  
            humanoid.AutoRotate = getgenv().OriginalValues.AutoRotate  
        end  
    end  
  
    if getgenv().GravityCheckboxEnabled then  
        workspace.Gravity = tonumber(getgenv().CustomGravity) or 196.2  
    end  
end  
  
local function CharacterBackendRestore()  
    local char = LocalPlayer.Character  
    local original = getgenv().OriginalValues  
  
    if char and original and original.Character == char then  
        local humanoid = char:FindFirstChildOfClass("Humanoid")  
        if humanoid then  
            if original.WalkSpeed ~= nil then humanoid.WalkSpeed = original.WalkSpeed end  
            if humanoid.UseJumpPower then  
                if original.JumpPower ~= nil then humanoid.JumpPower = original.JumpPower end  
            elseif original.JumpHeight ~= nil then  
                humanoid.JumpHeight = original.JumpHeight  
            end  
            if original.HipHeight ~= nil then humanoid.HipHeight = original.HipHeight end  
            if original.AutoRotate ~= nil then humanoid.AutoRotate = original.AutoRotate end  
        end  
    end  
  
    workspace.Gravity = 196.2  
end  
  
local function CharacterBackendSetInfiniteJump(enabled)  
    getgenv().InfiniteJumpCheckboxEnabled = enabled  
  
    if enabled and getgenv().CharacterModifierEnabled then  
        if not getgenv().InfiniteJumpConnection then  
            getgenv().InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()  
                if not getgenv().CharacterModifierEnabled or not getgenv().InfiniteJumpCheckboxEnabled then return end  
                local char = LocalPlayer.Character  
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")  
                if humanoid then  
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)  
                end  
            end)  
        end  
    elseif getgenv().InfiniteJumpConnection then  
        getgenv().InfiniteJumpConnection:Disconnect()  
        getgenv().InfiniteJumpConnection = nil  
    end  
end  
  
local function CharacterBackendSetEnabled(value)  
    getgenv().CharacterModifierEnabled = value  
  
    if value then  
        getgenv().spinAngle = getgenv().spinAngle or 0  
  
        if not getgenv().CharacterConnection then  
            getgenv().CharacterConnection = RunService.Heartbeat:Connect(function()  
                pcall(CharacterBackendApply)  
            end)  
        end  
  
        if not getgenv().CharacterAddedConnection then  
            getgenv().CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(character)  
                task.spawn(function()  
                    character:WaitForChild("Humanoid", 5)  
                    character:WaitForChild("HumanoidRootPart", 5)  
                    task.wait(0.1)  
                    if getgenv().CharacterModifierEnabled then  
                        getgenv().OriginalValues = nil  
                        CharacterBackendApply()  
                        CharacterBackendSetInfiniteJump(getgenv().InfiniteJumpCheckboxEnabled == true)  
                    end  
                end)  
            end)  
        end  
  
        CharacterBackendApply()  
        CharacterBackendSetInfiniteJump(getgenv().InfiniteJumpCheckboxEnabled == true)  
    else  
        if getgenv().CharacterConnection then  
            getgenv().CharacterConnection:Disconnect()  
            getgenv().CharacterConnection = nil  
        end  
  
        if getgenv().CharacterAddedConnection then  
            getgenv().CharacterAddedConnection:Disconnect()  
            getgenv().CharacterAddedConnection = nil  
        end  
  
        if getgenv().InfiniteJumpConnection then  
            getgenv().InfiniteJumpConnection:Disconnect()  
            getgenv().InfiniteJumpConnection = nil  
        end  
  
        CharacterBackendRestore()  
        getgenv().OriginalValues = nil  
        getgenv().spinAngle = nil  
    end  
end  
  
local animation_system = {  
    storage = {},  
    current = nil,  
    track = nil  
}  
  
function animation_system.load_animations()  
    local emotes_folder = game:GetService("ReplicatedStorage").Misc.Emotes  
      
    for _, animation in pairs(emotes_folder:GetChildren()) do  
        if animation:IsA("Animation") and animation:GetAttribute("EmoteName") then  
            local emote_name = animation:GetAttribute("EmoteName")  
            animation_system.storage[emote_name] = animation  
        end  
    end  
end  
  
function animation_system.get_emotes_list()  
    local emotes_list = {}  
      
    for emote_name in pairs(animation_system.storage) do  
        table.insert(emotes_list, emote_name)  
    end  
      
    table.sort(emotes_list)  
    return emotes_list  
end  
  
function animation_system.play(emote_name)  
    local animation_data = animation_system.storage[emote_name]  
      
    if not animation_data or not LocalPlayer.Character then  
        return false  
    end  
      
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")  
    if not humanoid then  
        return false  
    end  
      
    local animator = humanoid:FindFirstChild("Animator")  
    if not animator then  
        return false  
    end  
      
    if animation_system.track then  
        animation_system.track:Stop()  
        animation_system.track:Destroy()  
    end  
      
    animation_system.track = animator:LoadAnimation(animation_data)  
    animation_system.track:Play()  
    animation_system.current = emote_name  
      
    return true  
end  
  
function animation_system.stop()  
    if animation_system.track then  
        animation_system.track:Stop()  
        animation_system.track:Destroy()  
        animation_system.track = nil  
    end  
    animation_system.current = nil  
end  
  
function animation_system.start()  
    if not System.__properties.__connections.animations then  
        System.__properties.__connections.animations = RunService.Heartbeat:Connect(function()  
            if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then  
                return  
            end  
              
            local speed = LocalPlayer.Character.PrimaryPart.AssemblyLinearVelocity.Magnitude  
              
            if speed > 30 and getgenv().AutoStop then  
                if animation_system.track and animation_system.track.IsPlaying then  
                    animation_system.track:Stop()  
                end  
            else  
                if animation_system.current and (not animation_system.track or not animation_system.track.IsPlaying) then  
                    animation_system.play(animation_system.current)  
                end  
            end  
        end)  
    end  
end  
  
function animation_system.cleanup()  
    animation_system.stop()  
      
    if System.__properties.__connections.animations then  
        System.__properties.__connections.animations:Disconnect()  
        System.__properties.__connections.animations = nil  
    end  
end  
  
animation_system.load_animations()  
local emotes_data = animation_system.get_emotes_list()  
local selected_animation = emotes_data[1]  
  
local Category = UI:create_category("VIREX")  
local CombatTab = Category:create_tab("Combat", "76499042599127")  
  
local AutoParryGroup = CombatTab:create_group("Auto Parry", "left")  
  
AutoParryGroup:create_toggle("VIREX_AutoParry", {  
    title = "Auto Parry",  
    default = false,  
    callback = function(state)  
        System.__properties.__autoparry_enabled = state  
        System.__properties.__play_animation = state  
        if state then System.autoparry.start() else System.autoparry.stop() end  
    end  
})  
  
AutoParryGroup:create_dropdown("VIREX_AutoParry_Mode", {  
    title = "Parry Mode",  
    options = {"Remote", "Keypress"},  
    default = "Remote",  
    callback = function(value)  
        getgenv().AutoParryMode = value  
    end  
})  
  
local ExpParryGroup = CombatTab:create_group("Experimental Parry", "left")

ExpParryGroup:create_toggle("VIREX_ExpParry", {
    title = "Experimental Parry",
    default = false,
    callback = function(state)
        System.__properties.__play_animation = state
        if state then System.exp_parry.start() else System.exp_parry.stop() end
    end
})

ExpParryGroup:create_slider("VIREX_ExpParry_Reach", {
    title = "Hitbox Reach",
    minimum = 0,
    maximum = 30,
    default = 8,
    rounding = true,
    callback = function(value)
        System.exp_parry.cfg.reach = value
    end
})

ExpParryGroup:create_slider("VIREX_ExpParry_Safety", {
    title = "Safety Margin (ms)",
    minimum = 0,
    maximum = 100,
    default = 15,
    rounding = true,
    callback = function(value)
        System.exp_parry.cfg.safety = value / 1000
    end
})

ExpParryGroup:create_toggle("VIREX_ExpParry_AntiMiss", {
    title = "Anti-Miss (retry + guard)",
    default = true,
    callback = function(state)
        System.exp_parry.cfg.antimiss = state
    end
})

ExpParryGroup:create_toggle("VIREX_ExpParry_Debug", {
    title = "Debug Print",
    default = false,
    callback = function(state)
        System.exp_parry.cfg.debug = state
    end
})

local CurveUIGroup = CombatTab:create_group("Curve UI", "right")  
  
CurveUIGroup:create_toggle("VIREX_CurveUI", {  
    title = "Curve UI",  
    default = false,  
    callback = function(state)  
        if state then  
            CreateCurveUI()  
            Notify("Curve UI", "UI ON", 2)  
        else  
            DestroyCurveUI()  
            Notify("Curve UI", "UI OFF", 2)  
        end  
    end  
})  
  
CurveUIGroup:create_toggle("VIREX_CurveUI_Random", {  
    title = "Random Curve",  
    default = false,  
    callback = function(state)  
        if state then  
            if not System.__properties.__connections.__random_curve then  
                System.__properties.__connections.__random_curve = RunService.PreSimulation:Connect(function()  
                    Selected_Parry_Type = CURVE_NAMES[math.random(1, #CURVE_NAMES)]  
                end)  
            end  
        elseif System.__properties.__connections.__random_curve then  
            System.__properties.__connections.__random_curve:Disconnect()  
            System.__properties.__connections.__random_curve = nil  
            Selected_Parry_Type = CurveType  
        end  
    end  
})  
  
AutoParryGroup:create_slider("VIREX_AutoParry_Accuracy", {  
    title = "Accuracy",  
    minimum = 1,  
    maximum = 100,  
    default = 50,  
    rounding = true,  
    callback = function(value)  
        System.__properties.__accuracy = value  
        update_divisor()  
    end  
})  
  
AutoParryGroup:create_toggle("VIREX_AutoParry_RandomAccuracy", {  
    title = "Randomize Accuracy",  
    default = false,  
    callback = function(state)  
        System.__properties.__randomized_accuracy_enabled = state  
        if state then update_randomized_accuracy() end  
    end  
})  
  
AutoParryGroup:create_toggle("VIREX_AutoParry_AutoAbility", {  
    title = "Auto Ability",  
    default = false,  
    callback = function(state)  
        getgenv().AutoAbility = state  
    end  
})  
  
local KeyboardGroup = CombatTab:create_group("Keyboard", "left")  
  
KeyboardGroup:create_toggle("VIREX_Keyboard_ShowUI", {  
    title = "Keyboard",  
    default = false,  
    callback = function(state)  
        if state then  
            CreateKeyboardUI()  
            Notify("Keyboard", "UI ON", 2)  
        else  
            DestroyKeyboardUI()  
            Notify("Keyboard", "UI OFF", 2)  
        end  
    end  
})  
  
local TriggerbotGroup = CombatTab:create_group("Triggerbot", "right")  
  
TriggerbotGroup:create_toggle("VIREX_Triggerbot", {  
    title = "Triggerbot",  
    default = false,  
    callback = function(state)  
        -- Main toggle only controls the Trigger UI visibility.  
        -- Triggerbot functionality is controlled exclusively by the UI button.  
        if state then  
            CreateTriggerUI()  
            Notify("Triggerbot", "UI ON", 2)  
        else  
            DestroyTriggerUI()  
            Notify("Triggerbot", "UI OFF", 2)  
        end  
    end  
})  
  
local DetectGroup = CombatTab:create_group("Detection", "right")  
  
DetectGroup:create_toggle("VIREX_Detect_Infinity", {  
    title = "Infinity",  
    default = false,  
    callback = function(state) System.__config.__detections.__infinity = state end  
})  
  
DetectGroup:create_toggle("VIREX_Detect_Deathslash", {  
    title = "Death Slash",  
    default = false,  
    callback = function(state) System.__config.__detections.__deathslash = state end  
})  
  
DetectGroup:create_toggle("VIREX_Detect_Timehole", {  
    title = "Time Hole",  
    default = false,  
    callback = function(state) System.__config.__detections.__timehole = state end  
})  
  
DetectGroup:create_toggle("VIREX_Detect_Slashesoffury", {  
    title = "Slashes Of Fury",  
    default = false,  
    callback = function(state) System.__config.__detections.__slashesoffury = state end  
})  
  
DetectGroup:create_toggle("VIREX_Detect_Phantom", {  
    title = "Phantom",  
    default = false,  
    callback = function(state) System.__config.__detections.__phantom = state end  
})  
  
local AutoSpamGroup = CombatTab:create_group("Auto Spam", "left")  
  
AutoSpamGroup:create_toggle("VIREX_AutoSpam", {  
    title = "Auto Spam",  
    default = false,  
    callback = function(state)  
        System.__properties.__auto_spam_enabled = state  
        if state then  
            System.auto_spam.start()  
        else  
            System.auto_spam.stop()  
        end  
    end  
})  
  
AutoSpamGroup:create_dropdown("VIREX_AutoSpam_Mode", {  
    title = "Spam Mode",  
    options = {"Remote", "Keypress"},  
    default = "Remote",  
    callback = function(value)  
        getgenv().AutoSpamMode = value  
    end  
})  
  
AutoSpamGroup:create_toggle("VIREX_AutoSpam_AnimationFix", {  
    title = "Animation Fix",  
    default = true,  
    callback = function(state)  
        getgenv().AutoSpamAnimationFix = state  
    end  
})  
  
AutoSpamGroup:create_toggle("VIREX_AutoSpam_Notify", {  
    title = "Notify",  
    default = false,  
    callback = function(state)  
        getgenv().AutoSpamNotify = state  
    end  
})  
  
AutoSpamGroup:create_slider("VIREX_AutoSpam_Rate", {  
    title = "Spam Rate",  
    minimum = 60,  
    maximum = 5000,  
    default = 240,  
    rounding = true,  
    callback = function(value)  
        System.__properties.__spam_rate = value  
    end  
})  
  
getgenv().AutoParryMode = getgenv().AutoParryMode or "Remote"  
getgenv().ManualSpamMode = getgenv().ManualSpamMode or "Remote"  
getgenv().AutoSpamMode = getgenv().AutoSpamMode or "Remote"  
getgenv().AutoSpamAnimationFix = getgenv().AutoSpamAnimationFix ~= false  
getgenv().AutoSpamNotify = getgenv().AutoSpamNotify or false  
getgenv().ManualSpamAnimationFix = true  
macroAnimFix = true  
  
local Visual = Category:create_tab("Visual", "7733774602")  
getgenv().AutoVote = getgenv().AutoVote or false  
getgenv().AutoStop = getgenv().AutoStop or false  
getgenv().CameraEnabled = getgenv().CameraEnabled or false  
getgenv().CameraFOV = getgenv().CameraFOV or 70  
getgenv().AutoParryMode = getgenv().AutoParryMode or "Remote"  
  
  
  
local HitSoundEnabled = false  
local VisualLeft = Visual:create_group("Ability ESP", "left")  
do  
    local Visual_Data = {}  
    local Visual_HeartbeatConn  
    local Visual_PlayerAddedConn  
    local Visual_Cooldowns = {}  
    local Visual_IconCache = {}  
    local Visual_CharConns = {}  
    local Visual_AliveAddedConn  
    local Visual_AliveRemovedConn  
    local visual_last_update = 0  
    local Abilities = require(ReplicatedStorage.Shared.Abilities)  
  
    local function esp_get_cd(plr)  
        local ability=plr:GetAttribute("CurrentlyEquippedAbility") or plr:GetAttribute("EquippedAbility")  
        if not ability then return nil end  
        local ok,cd=pcall(Abilities.getAbilityCooldown,plr,ability)  
        if ok and type(cd)=="number" and cd>0 then return cd end  
        return nil  
    end  
  
    local function esp_get_icon(abilityName)  
        if not abilityName or abilityName=="" then return "" end  
        if Visual_IconCache[abilityName]~=nil then return Visual_IconCache[abilityName] end  
        local shared=ReplicatedStorage:FindFirstChild("Shared")  
        local abilities=shared and shared:FindFirstChild("Abilities")  
        local m=abilities and abilities:FindFirstChild(abilityName)  
        if not m then Visual_IconCache[abilityName]=""; return "" end  
        local ok,mod=pcall(require,m)  
        local icon=(ok and mod and type(mod.iconId)=="string") and mod.iconId or ""  
        Visual_IconCache[abilityName]=icon  
        return icon  
    end  
  
    local function create_esp_for_player(plr)  
        task.spawn(function()  
            local char=plr.Character  
            while not char or not char.Parent do  
                if not getgenv().VisualESP then return end  
                task.wait()  
                char=plr.Character  
            end  
            local head=char:WaitForChild("Head",10)  
            if not head or not getgenv().VisualESP then return end  
            if Visual_Data[plr] then  
                pcall(function() Visual_Data[plr].bill:Destroy() end)  
                if Visual_Data[plr].cdConn then pcall(function() Visual_Data[plr].cdConn:Disconnect() end) end  
                Visual_Data[plr]=nil  
            end  
            local bill=Instance.new("BillboardGui")  
            bill.Name="VisualESPGui"  
            bill.Adornee=head  
            bill.Size=UDim2.fromOffset(100,62)  
            bill.StudsOffset=Vector3.new(0,3.2,0)  
            bill.AlwaysOnTop=true  
            bill.ResetOnSpawn=false  
            bill.Parent=CoreGui  
            local icon=Instance.new("ImageLabel")  
            icon.Name="AbilityIcon"  
            icon.Size=UDim2.fromOffset(32,32)  
            icon.AnchorPoint=Vector2.new(0.5,0)  
            icon.Position=UDim2.new(0.5,0,0,0)  
            icon.BackgroundTransparency=1  
            icon.BorderSizePixel=0  
            icon.ScaleType=Enum.ScaleType.Fit  
            icon.Image=esp_get_icon(plr:GetAttribute("CurrentlyEquippedAbility") or plr:GetAttribute("EquippedAbility") or "")  
            icon.Parent=bill  
            local label=Instance.new("TextLabel")  
            label.Size=UDim2.new(1,0,0,14)  
            label.Position=UDim2.new(0,0,0,34)  
            label.BackgroundTransparency=1  
            label.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal)  
            label.TextColor3=Color3.fromRGB(255,255,255)  
            label.TextSize=11  
            label.TextStrokeColor3=Color3.fromRGB(0,0,0)  
            label.TextStrokeTransparency=0.2  
            label.TextXAlignment=Enum.TextXAlignment.Center  
            label.TextTruncate=Enum.TextTruncate.AtEnd  
            label.Text=plr:GetAttribute("CurrentlyEquippedAbility") or plr:GetAttribute("EquippedAbility") or plr.DisplayName  
            label.Parent=bill  
            local timerLabel=Instance.new("TextLabel")  
            timerLabel.Size=UDim2.new(1,0,0,13)  
            timerLabel.Position=UDim2.new(0,0,0,49)  
            timerLabel.BackgroundTransparency=1  
            timerLabel.FontFace=Font.new("rbxasset://fonts/families/SFPro.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal)  
            timerLabel.TextColor3=Color3.fromRGB(100,220,100)  
            timerLabel.TextSize=12  
            timerLabel.TextStrokeColor3=Color3.fromRGB(0,0,0)  
            timerLabel.TextStrokeTransparency=0.2  
            timerLabel.TextXAlignment=Enum.TextXAlignment.Center  
            timerLabel.Text="Ready"  
            timerLabel.Parent=bill  
            local last_cd=0  
            local cdConn=char.AttributeChanged:Connect(function(attr)  
                if attr=="CooldownExpiration" then  
                    local val=char:GetAttribute("CooldownExpiration")  
                    if (val==0 or val==nil) and tick()-last_cd>0.5 then  
                        local dur=esp_get_cd(plr)  
                        if dur then last_cd=tick(); Visual_Cooldowns[plr]={expiry=tick()+dur,duration=dur} end  
                    end  
                elseif attr=="AbilityActive" then  
                    if char:GetAttribute("AbilityActive")==true and tick()-last_cd>0.5 then  
                        local dur=esp_get_cd(plr)  
                        if dur then last_cd=tick(); Visual_Cooldowns[plr]={expiry=tick()+dur,duration=dur} end  
                    end  
                end  
            end)  
            local ab=plr:GetAttribute("CurrentlyEquippedAbility") or plr:GetAttribute("EquippedAbility")  
            local ok,dur=pcall(Abilities.getAbilityCooldown,plr,ab or "")  
            Visual_Data[plr]={bill=bill,label=label,icon=icon,timerLabel=timerLabel,cdConn=cdConn,isPassive=ok and type(dur)=="number" and dur<=0}  
        end)  
    end  
  
    local function add_esp_player(plr)  
        if plr==LocalPlayer or Visual_CharConns[plr] then return end  
        local a=plr.CharacterAdded:Connect(function()  
            Visual_Cooldowns[plr]=nil  
            create_esp_for_player(plr)  
        end)  
        local r=plr.CharacterRemoving:Connect(function()  
            Visual_Cooldowns[plr]=nil  
        end)  
        Visual_CharConns[plr]={a,r}  
        if plr.Character then create_esp_for_player(plr) end  
    end  
  
    local function stop_ability_esp()  
        getgenv().VisualESP=false  
        if Visual_HeartbeatConn then Visual_HeartbeatConn:Disconnect(); Visual_HeartbeatConn=nil end  
        if Visual_PlayerAddedConn then Visual_PlayerAddedConn:Disconnect(); Visual_PlayerAddedConn=nil end  
        if Visual_AliveAddedConn then Visual_AliveAddedConn:Disconnect(); Visual_AliveAddedConn=nil end  
        if Visual_AliveRemovedConn then Visual_AliveRemovedConn:Disconnect(); Visual_AliveRemovedConn=nil end  
        for _,conns in pairs(Visual_CharConns) do  
            for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end  
        end  
        table.clear(Visual_CharConns)  
        for _,data in pairs(Visual_Data) do  
            pcall(function() data.bill:Destroy() end)  
            if data.cdConn then pcall(function() data.cdConn:Disconnect() end) end  
        end  
        Visual_Data={}  
        Visual_Cooldowns={}  
        table.clear(Visual_IconCache)  
    end  
  
    local function start_ability_esp()  
        getgenv().VisualESP=true  
        if not Visual_HeartbeatConn then  
            Visual_HeartbeatConn=RunService.Heartbeat:Connect(function()  
                if not getgenv().VisualESP then return end  
                local now=tick()  
                if now-visual_last_update<0.1 then return end  
                visual_last_update=now  
                for plr,data in pairs(Visual_Data) do  
                    if not plr.Parent then  
                        pcall(function() data.bill:Destroy() end)  
                        if data.cdConn then pcall(function() data.cdConn:Disconnect() end) end  
                        Visual_Data[plr]=nil  
                        Visual_Cooldowns[plr]=nil  
                    else  
                        local ab=plr:GetAttribute("CurrentlyEquippedAbility") or plr:GetAttribute("EquippedAbility") or ""  
                        local display=ab~="" and ab or plr.DisplayName  
                        if data.label.Text~=display then  
                            data.label.Text=display  
                            data.icon.Image=esp_get_icon(ab)  
                            local ok,dur=pcall(Abilities.getAbilityCooldown,plr,ab)  
                            data.isPassive=ok and type(dur)=="number" and dur<=0  
                            Visual_Cooldowns[plr]=nil  
                        end  
                        local cd=Visual_Cooldowns[plr]  
                        if cd and now<cd.expiry then  
                            data.timerLabel.Text=string.format("%.1fs",cd.expiry-now)  
                        elseif data.isPassive then  
                            data.timerLabel.Text="Passive"  
                        else  
                            data.timerLabel.Text="Ready"  
                        end  
                    end  
                end  
            end)  
        end  
        for _,plr in ipairs(Players:GetPlayers()) do add_esp_player(plr) end  
        if not Visual_PlayerAddedConn then  
            Visual_PlayerAddedConn=Players.PlayerAdded:Connect(function(plr)  
                if getgenv().VisualESP then add_esp_player(plr) end  
            end)  
        end  
    end  
  
    getgenv()._CSKR_VisualVisual_Stop=stop_ability_esp  
    VisualLeft:create_toggle("ability_esp", {  
        title="Ability ESP",  
        default=false,  
        callback=function(state)  
            if state then start_ability_esp() else stop_ability_esp() end  
        end,  
    })  
end  
  
-- ============================================================
-- Settings: бинд меню + конфиги
-- ============================================================
do
    local Window = Category.window
    local ConfigManager = Window.ConfigManager
    local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

    local MenuSection = SettingsTab:Section({ Title = "Menu", Box = true, BoxBorder = true, Opened = true })
    MenuSection:Keybind({
        Flag = "VIREX_MenuKey",
        Title = "Menu Keybind",
        Desc = "Open / close the menu",
        Value = "Insert",
        Callback = function(key)
            local kc
            if typeof(key) == "EnumItem" then
                kc = key
            else
                local ok, res = pcall(function() return Enum.KeyCode[tostring(key)] end)
                if ok then kc = res end
            end
            if kc then pcall(function() Window:SetToggleKey(kc) end) end
        end,
    })

    if ConfigManager then
        local ConfigSection = SettingsTab:Section({ Title = "Config", Box = true, BoxBorder = true, Opened = true })
        local ConfigName = "default"
        local NameInput, ConfigList

        local function refresh_list()
            if ConfigList then
                pcall(function() ConfigList:Refresh(ConfigManager:AllConfigs()) end)
            end
        end

        NameInput = ConfigSection:Input({
            Title = "Config Name",
            Icon = "file-cog",
            Value = ConfigName,
            Placeholder = "Enter config name...",
            Callback = function(text)
                if type(text) == "string" and text ~= "" then ConfigName = text end
            end,
        })

        local all = ConfigManager:AllConfigs()
        ConfigList = ConfigSection:Dropdown({
            Title = "Saved Configs",
            Desc = "Select an existing config",
            Values = all,
            Value = table.find(all, ConfigName) and ConfigName or nil,
            Callback = function(value)
                if type(value) == "string" and value ~= "" then
                    ConfigName = value
                    pcall(function() NameInput:Set(value) end)
                end
            end,
        })

        ConfigSection:Button({
            Title = "Create / Save Config",
            Icon = "save",
            Callback = function()
                local ok = pcall(function()
                    Window.CurrentConfig = ConfigManager:Config(ConfigName)
                    Window.CurrentConfig:Save()
                end)
                Notify("Config", ok and ("Saved: " .. ConfigName) or "Save failed", 2)
                refresh_list()
            end,
        })

        ConfigSection:Button({
            Title = "Load Config",
            Icon = "folder-open",
            Callback = function()
                local ok, res = pcall(function()
                    Window.CurrentConfig = ConfigManager:CreateConfig(ConfigName)
                    return Window.CurrentConfig:Load()
                end)
                Notify("Config", (ok and res) and ("Loaded: " .. ConfigName) or ("Load failed: " .. ConfigName), 2)
            end,
        })

        ConfigSection:Button({
            Title = "Delete Config",
            Icon = "trash-2",
            Callback = function()
                local ok = pcall(function() ConfigManager:DeleteConfig(ConfigName) end)
                Notify("Config", ok and ("Deleted: " .. ConfigName) or "Delete failed", 2)
                refresh_list()
            end,
        })
    else
        warn("[VIREX UI] ConfigManager unavailable (no writefile?)")
    end
end

print("VIREX  1/3")  
print("VIREX  2/3")  
print("VIREX  3/3")  
print("VIREX  success")  
  
  
end)  