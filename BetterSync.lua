---
--- Title: BetterSync
--- Author: superyu'#7167, special thanks to april#0001 for the code to change the desync width.
--- Description: Adds the ability to change the desync width together with some other stuff.
---

--- Main Variables and GUI stuff.

local BetterSync_wnd = gui.Window("BetterSync", "BetterSync™", 0 , 0, 250, 820)
local BetterSyncShowMenu = gui.Checkbox(gui.Reference("RAGE", "MAIN", "Anti-Aim Main"), "BetterSyncShow", "BetterSync", 0)
local BetterSyncGroup = gui.Groupbox(BetterSync_wnd, "Main", 5, 10, 240, 270)
local desyncCheckbox = gui.Checkbox( BetterSyncGroup, "desyncCheckbox", "Desync", 0)
local desyncRange = gui.Slider( BetterSyncGroup, "desyncRange", "Desync Width", 0, -60, 60)
local chokeLimiter = gui.Slider(BetterSyncGroup, "chokeLimiter", "Choke limit", 1, 1, 16)
local InverterKey = gui.Keybox(BetterSyncGroup, "desyncRangeInverter", "Inverter Key", 0);
local twistCheckbox = gui.Checkbox( BetterSyncGroup, "twistCheckbox", "Twist", 0)
local balanceIfMoving = gui.Checkbox( BetterSyncGroup, "BalanceIfMoving", "Better moving fake", 0)
local desyncCentering = gui.Checkbox( BetterSyncGroup, "desyncCentering", "Keep Head Centered", 0)
local standMovement  = gui.Checkbox( BetterSyncGroup, "standMovement", "Stand Movement", 0)

local ManualAA = gui.Groupbox(BetterSync_wnd, "Manual AA", 5, 540, 240, 240 )

---NiggerSync GUI Stuff
local niggerSyncGroup = gui.Groupbox(BetterSync_wnd, "NiggerSync", 5, 290, 240, 240 )
local niggerSyncCheckbox = gui.Checkbox( niggerSyncGroup, "niggerSyncCheckbox", "NiggerSync™ Enable", 0)
local niggerSyncSpeed = gui.Slider( niggerSyncGroup, "niggerSyncSpeed", "NiggerSync™ Speed", 1, 0.1, 25.0)
local niggerSyncRange1 = gui.Slider( niggerSyncGroup, "niggerSyncRange1", "NiggerSync™ Range Start", -60, -60, 60)
local niggerSyncRange2 = gui.Slider( niggerSyncGroup, "niggerSyncRange2", "NiggerSync™ Range End", 60, -60, 60)
local niggerSyncDeadzone = gui.Slider( niggerSyncGroup, "niggerSyncDeadzone", "NiggerSync™ Deadzone", 1, 1, 60)

--- Variables for betterSync code
local min, max = 0, 0;
local cs, cd = min, 0;
local niggerSyncVal;
local menuPressed = 1;
local manualAdd = 0;

--- Actual code.

local function isMoving() --- kinda made by april#0001

    if math.sqrt(entities.GetLocalPlayer():GetPropFloat( "localdata", "m_vecVelocity[0]" )^2 + entities.GetLocalPlayer():GetPropFloat( "localdata", "m_vecVelocity[1]" )^2) > 3 then
        return true
    else
        return false
    end

end

local function get_value(var, complement) --- by april#0001

    if gui.GetValue( var .. complement ) ~= nil then
        return var .. complement
    end

    return nil

end

local function fakelag()

    local local_player = entities.GetLocalPlayer()

    if not local_player or not local_player:IsAlive() then
        return
    end
    
    local twist_label = get_value("twist", "Checkbox")

    if (twistCheckbox:GetValue()) then
        gui.SetValue("msc_fakelag_mode", 1)
    end

    gui.SetValue("msc_fakelag_value", gui.GetValue(twist_label) and 2 or gui.GetValue("chokeLimiter"))

    if (gui.GetValue("lbot_active")) and not gui.GetValue("rbot_active") then
        gui.SetValue("msc_fakelag_enable", 0)
    else
        gui.SetValue("msc_fakelag_enable", 1)
    end

end

local function menu()

    if input.IsButtonPressed(gui.GetValue("msc_menutoggle")) then
        menuPressed = menuPressed == 0 and 1 or 0;
    end

    if (BetterSyncShowMenu:GetValue()) then
        BetterSync_wnd:SetActive(menuPressed);
    else
        BetterSync_wnd:SetActive(0);
    end
end

local function niggersync()

    local speed = gui.GetValue("niggerSyncSpeed")

    if gui.GetValue("niggerSyncRange1") < gui.GetValue("niggerSyncRange2") then
        min = gui.GetValue("niggerSyncRange1")
        max = gui.GetValue("niggerSyncRange2")
    else
        min = gui.GetValue("niggerSyncRange2")
        max = gui.GetValue("niggerSyncRange1")
    end


    if gui.GetValue("niggerSyncCheckbox") then
        if (cs >= max) then
            cd = 1;
        elseif (cs <= min+speed) then
            cd = 0;
        end
        
        if (cd == 0) then
            cs = cs + speed;
        elseif (cd == 1) then
            cs = cs - speed;
        end

        local deadzoneP = gui.GetValue("niggerSyncDeadzone")
        local deadzoneN = deadzoneP * -1

        if cs > 0 then
            if cs < deadzoneP then
                cs = deadzoneN
            end
        end

        if cs < 0 then
            if cs > deadzoneN then
                cs = deadzoneP
            end
        end

        niggerSyncVal = cs;
    end
end

local function desync()

    local local_player = entities.GetLocalPlayer()

    if not local_player or not local_player:IsAlive() then
        return
    end

    local dv = 0;
    local invert;

    if (InverterKey:GetValue() ~= 0) then
        if (input.IsButtonPressed(InverterKey:GetValue())) then
            invert = true
        end
    end

    if invert then
        desyncRange:SetValue(desyncRange:GetValue()*-1)
    end

    local width = desyncRange:GetValue();

    if width < 0 then
        dv = 3
    else
        dv = 2
    end

    if (gui.GetValue("NiggerSyncCheckbox")) == true then
        if niggerSyncVal < 0 then
            dv = 3
        else
            dv = 2
        end
    end

    if (gui.GetValue("BalanceIfMoving") == true) then
        if (isMoving() == true) then
            dv = 2
        end
    end

    gui.SetValue("rbot_antiaim_stand_desync", dv)
    gui.SetValue("rbot_antiaim_move_desync", dv)
    gui.SetValue("rbot_antiaim_edge_desync", dv)
    gui.SetValue("lbot_antiaim", dv)

    local desync_label = gui.GetValue("desyncCheckbox")
    local desync_label = get_value("desync", "Checkbox")

    if gui.GetValue("niggerSyncCheckbox") then
        width = niggerSyncVal;
    end

    currentDesyncRange = width;

    local FixedlowerbodyTarget = gui.GetValue(desync_label) and local_player:GetProp("m_angEyeAngles[1]") + width or local_player:GetProp("m_angEyeAngles[1]")

    local_player:SetProp("m_flLowerBodyYawTarget", FixedlowerbodyTarget)  
end

local function headcentering() --- THIS ONLY WORKS FOR AUTO OR WEAPONS WITH SIMILAR MAXDELTA BECAUSE AIMWARE DOESN'T ALLOW ME TO GET MAXDESYNCDELTA YET.

    local offset = 0;
    local r = currentDesyncRange;

    local local_player = entities.GetLocalPlayer()

    if not local_player then
        return
    end

    if gui.GetValue("desyncCentering") == true then
        
        if gui.GetValue("rbot_antiaim_stand_desync") == 2  then
            offset = 24
        elseif gui.GetValue("rbot_antiaim_stand_desync") == 3 then
            offset = -10
        end
    else 
        offset = 0;
    end

    gui.SetValue("rbot_antiaim_stand_real_add", offset + manualAdd)
    gui.SetValue("rbot_antiaim_move_real_add", offset + manualAdd)
    gui.SetValue("rbot_antiaim_edge_real_add", offset + manualAdd)

end

-- Manual AA, credits to "El Credito"/gowork88#1556.

local LeftKey = 0;
local BackKey = 0;
local RightKey = 0;

local creditsManualAA = gui.Text(ManualAA, "Thanks to gowork88#1556." )
local ManualAAEnable = gui.Checkbox(ManualAA, "Enable", "Manual AA", false)
local AntiAimleft = gui.Keybox(ManualAA, "Anti-Aim_left", "Left Keybind", 0);
local AntiAimRight = gui.Keybox(ManualAA, "Anti-Aim_Right", "Right Keybind", 0);
local AntiAimBack = gui.Keybox(ManualAA, "Anti-Aim_Back", "Back Keybind", 0);
local AntiAimRangeLeft = gui.Slider(ManualAA, "AntiAimRangeLeft", "AntiAim Range Left", 0, -180, 180);
local AntiAimRangeRight = gui.Slider(ManualAA, "AntiAimRangeRight", "AntiAim Range Right", 0, -180, 180);

local rifk7_font = draw.CreateFont("Verdana", 20, 700)
local damage_font = draw.CreateFont("Verdana", 15, 700)
local arrow_font = draw.CreateFont("Marlett", 37, 500)
local normal = draw.CreateFont("Arial")

local function draw_indicator()

    local active = ManualAAEnable:GetValue()

    if active then
        local w, h = draw.GetScreenSize();
        draw.SetFont(rifk7_font)
        if (LeftKey == 1) then
            draw.Color(255, 0, 0, 255)
            draw.Text(6, h - 60, "Manual");
            draw.TextShadow(6, h - 60, "Manual");
            draw.SetFont(arrow_font)
            draw.Text( w/2 - 100, h/2 - 21, "3");
            draw.SetFont(rifk7_font)
        elseif (BackKey == 1) then
            draw.Color(255, 0, 0, 255)
            draw.Text(6, h - 60, "Manual");
            draw.TextShadow(6, h - 60, "Manual");
            draw.SetFont(arrow_font)
            draw.Text( w/2 - 21, h/2 + 60, "6");
            draw.SetFont(rifk7_font)
        elseif (RightKey == 1) then
            draw.Color(255, 0, 0, 255);
            draw.Text(6, h - 60, "Manual");
            draw.TextShadow(6, h - 60, "Manual");
            draw.SetFont(arrow_font)
            draw.Text( w/2 + 60, h/2 - 21, "4");
            draw.SetFont(rifk7_font)
        elseif ((LeftKey == 0) and (BackKey == 0) and (RightKey == 0)) then
            draw.Color(47, 255, 0, 255);
            draw.Text(6, h - 60, "Disabled");
            draw.TextShadow(6, h - 60, "Disabled");
        end
        draw.SetFont(normal)
    end
end

local function changeAA()

    gui.SetValue("rbot_antiaim_at_targets", false);
    
    if (LeftKey == 1) then
        manualAdd = AntiAimRangeLeft:GetValue()
        manualAdd = AntiAimRangeLeft:GetValue()
        
    elseif (RightKey == 1) then
        manualAdd = AntiAimRangeRight:GetValue()
        manualAdd = AntiAimRangeRight:GetValue()
        
    elseif (BackKey == 1) then
        manualAdd = 0
        manualAdd = 0
        
    elseif ((LeftKey == 0) and (RightKey == 0) and (BackKey == 0)) then
        manualAdd = 0
        manualAdd = 0
    end
end

local function setterValue(left, right, back)
    if (left) then
        if (LeftKey == 1) then
            LeftKey = 0
        else
            LeftKey = 1;RightKey = 0;zBackKey = 0
        end
    elseif (right) then
        if (RightKey == 1) then
            RightKey = 0
        else
            RightKey = 1;LeftKey = 0;BackKey = 0
        end
    elseif (back) then
        if (BackKey == 1) then
            BackKey = 0
        else
            BackKey = 1;LeftKey = 0;RightKey = 0
        end
    end
    changeAA()
end

local function mainManualAA()
    if (ManualAAEnable:GetValue()) then
        if AntiAimleft:GetValue() ~= 0 then
            if input.IsButtonPressed(AntiAimleft:GetValue()) then
                setterValue(true, false, false);
            end
        end
        if AntiAimBack:GetValue() ~= 0 then
            if input.IsButtonPressed(AntiAimBack:GetValue()) then
                setterValue(false, false, true);
            end
        end
        if AntiAimRight:GetValue() ~= 0 then
            if input.IsButtonPressed(AntiAimRight:GetValue()) then
            setterValue(false, true, false);
            end
        end
        draw_indicator()
    end 
end

--- Auto updater by ShadyRetard/Shady#0001

--- Variables

local SCRIPT_FILE_NAME = GetScriptName();
local SCRIPT_FILE_ADDR = "https://raw.githubusercontent.com/superyor/BetterSync/master/BetterSync.lua";
local VERSION_FILE_ADDR = "https://raw.githubusercontent.com/superyor/BetterSync/master/version.txt"; --- in case of update i need to update this. (Note by superyu'#7167 "so i don't forget it.")
local VERSION_NUMBER = "1.2.1a"; --- This too

local version_check_done = false;
local update_downloaded = false;
local update_available = false;

--- Actual code

local function updateEventHandler()
    if (update_available and not update_downloaded) then
        if (gui.GetValue("lua_allow_cfg") == false) then
            draw.Color(255, 0, 0, 255);
            draw.Text(0, 0, "[BetterSync] An update is available, please enable Lua Allow Config and Lua Editing in the settings tab");
        else
            local new_version_content = http.Get(SCRIPT_FILE_ADDR);
            local old_script = file.Open(SCRIPT_FILE_NAME, "w");
            old_script:Write(new_version_content);
            old_script:Close();
            update_available = false;
            update_downloaded = true;
        end
    end

    if (update_downloaded) then
        draw.Color(255, 0, 0, 255);
        draw.Text(0, 0, "[BetterSync] An update has automatically been downloaded, please reload the BetterSync script");
        return;
    end

    if (not version_check_done) then
        if (gui.GetValue("lua_allow_http") == false) then
            draw.Color(255, 0, 0, 255);
            draw.Text(0, 0, "[BetterSync] Please enable Lua HTTP Connections in your settings tab to use this script");
            return;
        end

        version_check_done = true;
        local version = http.Get(VERSION_FILE_ADDR);
        if (version ~= VERSION_NUMBER) then
            update_available = true;
        end
    end
end

callbacks.Register("Draw", updateEventHandler);

callbacks.Register( "Draw", function()
    menu()
    mainManualAA()
    niggersync()
    fakelag()
    desync()
    headcentering()
end
);

local del = globals.CurTime() + 0.05

callbacks.Register( "CreateMove", function(pCmd)

    local vel = math.sqrt(entities.GetLocalPlayer():GetPropFloat( "localdata", "m_vecVelocity[0]" )^2 + entities.GetLocalPlayer():GetPropFloat( "localdata", "m_vecVelocity[1]" )^2)

    if vel > 2 then
        del = globals.CurTime() + 0.05 
        return 
    end

    if del > globals.CurTime() then
        switch = not switch
        del = globals.CurTime() + 0.05
    end

    if gui.GetValue("standMovement") and gui.GetValue("rbot_active") and not gui.GetValue("lbot_active") then
        if switch then
            pCmd:SetSideMove(2)
        else
            pCmd:SetSideMove(-2)
        end
    end
end)