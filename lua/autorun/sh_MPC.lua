include("MPC/sh_MPC.lua")
include("MPC/sh_MPC_enums.lua")
include("MPC/sh_MPC_configuration.lua")



if SERVER then
    include("MPC/server/sv_MPC.lua")
    include("MPC/server/sv_MPC_utils.lua")
    include("MPC/server/sv_MPC_net_messages.lua")
    include("MPC/server/sv_MPC_net.lua")
end



if CLIENT then
    include("MPC/client/cl_MPC.lua")
    include("MPC/client/cl_MPC_net.lua")
    include("MPC/client/cl_MPC_gui.lua")
    include("MPC/client/cl_MPC_hud.lua")
    include("MPC/client/cl_MPC_terminal_gui.lua")
    include("MPC/client/cl_MPC_clientCommands.lua")
end


-- AddCSLua in the same order as above
AddCSLuaFile("MPC/sh_MPC.lua")
AddCSLuaFile("MPC/sh_MPC_enums.lua")
AddCSLuaFile("MPC/sh_MPC_configuration.lua")

AddCSLuaFile("MPC/client/cl_MPC.lua")
AddCSLuaFile("MPC/client/cl_MPC_net.lua")
AddCSLuaFile("MPC/client/cl_MPC_gui.lua")
AddCSLuaFile("MPC/client/cl_MPC_hud.lua")
AddCSLuaFile("MPC/client/cl_MPC_terminal_gui.lua")
AddCSLuaFile("MPC/client/cl_MPC_clientCommands.lua")


local function recurseListContents(path, addon, direct, pattern)
    local files, dirs = file.Find(path .. "*", addon)
    local matchedFiles = {}

    for _, v in ipairs(files) do
        local fullPath = path .. v
        if not pattern or string.match(fullPath, pattern) then
            table.insert(matchedFiles, fullPath)
        end
    end
    if direct then return matchedFiles end

    for _, dir in ipairs(dirs) do
        local subFiles = recurseListContents(path .. dir .. "/", addon, false, pattern)
        for _, file in ipairs(subFiles) do
            table.insert(matchedFiles, file)
        end
    end

    return matchedFiles
end

local function includeFolder(folderPath)
    local files = recurseListContents(folderPath, "LUA", false, "%.lua$")
    for _, file in ipairs(files) do
        include(file)
        AddCSLuaFile(file)
    end
end




includeFolder("MPC/classes/")
includeFolder("MPC/modules/")



print("\n\n [[[  Mirai's Programmable Computers loaded successfully  ]]] \n")