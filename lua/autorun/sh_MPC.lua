include("MPC/sh_MPC.lua")
include("MPC/sh_MPC_enums.lua")
include("MPC/sh_MPC_configuration.lua")



if SERVER then
    include("MPC/server/sv_MPC.lua")
    include("MPC/server/sv_MPC_utils.lua")
    include("MPC/server/sv_net_messages.lua")
    include("MPC/server/sv_net.lua")
end



if CLIENT then
    include("MPC/client/cl_MPC.lua")
    include("MPC/client/cl_MPC_net.lua")
    include("MPC/client/cl_MPC_gui.lua")
    include("MPC/client/cl_MPC_hud.lua")
end


-- AddCSLua in the same order as above
AddCSLuaFile("MPC/sh_MPC.lua")
AddCSLuaFile("MPC/sh_MPC_enums.lua")
AddCSLuaFile("MPC/sh_MPC_configuration.lua")

AddCSLuaFile("MPC/client/cl_MPC.lua")
AddCSLuaFile("MPC/client/cl_MPC_net.lua")
AddCSLuaFile("MPC/client/cl_MPC_gui.lua")
AddCSLuaFile("MPC/client/cl_MPC_hud.lua")


-- if you have any modules or other files that need to be included, do it here

for _, v in ipairs(file.Find("MPC/modules/*.lua", "LUA")) do
    include("MPC/modules/" .. v)
    AddCSLuaFile("MPC/modules/" .. v)
end


print("\n [[[  Mirai Addon Base Template loaded successfully  ]]] \n")