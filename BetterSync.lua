---
--- Title: BetterSync
--- Author: superyu'#7167, special thanks to april#0001 for the code to change the desync width.
--- Description: Adds the ability to change the desync width together with some other stuff.
---

--- Variables and gui stuff

local Position = gui.Reference( "RAGE", "MAIN", "STAND", "Anti-Aim");
local desyncCheckbox = gui.Checkbox( Position, "desyncCheckbox", "Desync", 0)
local desyncCentering = gui.Checkbox( gui.Reference("RAGE", "MAIN", "Anti-Aim Main"), "desyncCentering", "Keep Head Centered", 0)
local desyncRange = gui.Slider( Position, "desyncRange", "Desync Width", 0, -60, 60)
local chokeLimiter = gui.Slider(Position, "chokeLimiter", "Choke limit", 1, 1, 16)
local twistCheckbox = gui.Checkbox( Position, "twistCheckbox", "Twist", 0)
local balanceIfMoving = gui.Checkbox( Position, "BalanceIfMoving", "Better moving fake", 0)

local NiggerSync_wnd = gui.Window("NiggerSync", "NiggerSync™", 100 , 100, 250, 280)
local niggerSyncShowMenu = gui.Checkbox(Position, "NiggerSyncShow", "NiggerSync™", 0)
local niggerSyncGroup = gui.Groupbox(NiggerSync_wnd, "Main", 5, 5, 240, 240 )
local niggerSyncCheckbox = gui.Checkbox( niggerSyncGroup, "niggerSyncCheckbox", "NiggerSync™ Enable", 0)
local niggerSyncSpeed = gui.Slider( niggerSyncGroup, "niggerSyncSpeed", "NiggerSync™ Speed", 1, 0.1, 25.0)
local niggerSyncRange1 = gui.Slider( niggerSyncGroup, "niggerSyncRange1", "NiggerSync™ Range Start", -60, -60, 60)
local niggerSyncRange2 = gui.Slider( niggerSyncGroup, "niggerSyncRange2", "NiggerSync™ Range End", 60, -60, 60)
local niggerSyncDeadzone = gui.Slider( niggerSyncGroup, "niggerSyncDeadzone", "NiggerSync™ Deadzone", 1, 1, 60)

local min, max = 0, 0;
local cs, cd = min, 0;
local niggerSyncVal;
local menuPressed = 1;

local function isMoving() --- kinda made by april#0001

    local local_player = entities.GetLocalPlayer()
    local x, y, z = local_player:GetPropVector("localdata", "m_vecVelocity[0]")
    if math.sqrt(x*x + y*y) > 0 then
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

function fakelag()

    local local_player = entities.GetLocalPlayer()

    if not local_player or not local_player:IsAlive() then
        return
    end
    
    local twist_label = get_value("twist", "Checkbox")

    gui.SetValue("msc_fakelag_value", gui.GetValue(twist_label) and 2 or gui.GetValue("chokeLimiter"))

end

function menu()

    if input.IsButtonPressed(gui.GetValue("msc_menutoggle")) then
        menuPressed = menuPressed == 0 and 1 or 0;
    end

    if (niggerSyncShowMenu:GetValue()) then
        NiggerSync_wnd:SetActive(menuPressed);
    else
        NiggerSync_wnd:SetActive(0);
    end
end

function niggersync()

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

function desync()

    local local_player = entities.GetLocalPlayer()

    if not local_player or not local_player:IsAlive() then
        return
    end

    local dv = 0;

    if gui.GetValue("desyncRange") < 0 then
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

    local desync_label = gui.GetValue("desyncCheckbox")
    local desync_label = get_value("desync", "Checkbox")

    local max = gui.GetValue("desyncRange")

    if gui.GetValue("niggerSyncCheckbox") then
        max = niggerSyncVal;
    end

    currentDesyncRange = max;

    local target_angles = gui.GetValue(desync_label) and local_player:GetProp("m_angEyeAngles[1]") + max or local_player:GetProp("m_angEyeAngles[1]")

    local_player:SetProp("m_flLowerBodyYawTarget", target_angles)  
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

    gui.SetValue("rbot_antiaim_stand_real_add", offset)
    gui.SetValue("rbot_antiaim_move_real_add", offset)
    gui.SetValue("rbot_antiaim_edge_real_add", offset)

end

callbacks.Register( "Draw", function()
    menu()
    niggersync()
    fakelag()
    desync()
    headcentering()
end
);
