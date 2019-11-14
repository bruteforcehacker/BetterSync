---
--- Title: SuperLibrary
--- Author: superyu'#7167
--- Description: Adds global functions for other luas to use.
---

--- Code

function isMoving(minVelocity)

    if math.sqrt(entities.GetLocalPlayer():GetPropFloat( "localdata", "m_vecVelocity[0]" )^2 + entities.GetLocalPlayer():GetPropFloat( "localdata", "m_vecVelocity[1]" )^2) > minVelocity then
        return true
    else
        return false
    end

end

function velocity(pEntity)

    return math.sqrt(pEntity:GetPropFloat( "localdata", "m_vecVelocity[0]" )^2 + pEntity:GetPropFloat( "localdata", "m_vecVelocity[1]" )^2)

end

function getScreenCenter()

    local w, h = draw.GetScreenSize()

    return w / 2, h / 2

end

--- Auto updater by ShadyRetard/Shady#0001

--- Variables

local SCRIPT_FILE_NAME = GetScriptName();
local SCRIPT_FILE_ADDR = "https://raw.githubusercontent.com/superyor/BetterSync/master/BetterSync.lua";
local VERSION_FILE_ADDR = "https://raw.githubusercontent.com/superyor/BetterSync/master/version.txt"; --- in case of update i need to update this. (Note by superyu'#7167 "so i don't forget it.")
local VERSION_NUMBER = "1"; --- This too

local version_check_done = false;
local update_downloaded = false;
local update_available = false;

--- Actual code

local function updateEventHandler()
    if (update_available and not update_downloaded) then
        if (gui.GetValue("lua_allow_cfg") == false) then
            draw.Color(255, 0, 0, 255);
            draw.Text(0, 0, "[SuperLibrary] An update is available, please enable Lua Allow Config and Lua Editing in the settings tab");
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
        draw.Text(0, 0, "[SuperLibrary] An update has automatically been downloaded, please reload the BetterSync script");
        return;
    end

    if (not version_check_done) then
        if (gui.GetValue("lua_allow_http") == false) then
            draw.Color(255, 0, 0, 255);
            draw.Text(0, 0, "[SuperLibrary] Please enable Lua HTTP Connections in your settings tab to use this script");
            return;
        end

        version_check_done = true;
        local version = http.Get(VERSION_FILE_ADDR);
        if (version ~= VERSION_NUMBER) then
            update_available = true;
        end
    end
end

callbacks.Register("Draw", updateEventHandler)