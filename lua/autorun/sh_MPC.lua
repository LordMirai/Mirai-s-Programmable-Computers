include("MAddon/sh_MAddon.lua")
include("MAddon/sh_MAddon_enums.lua")
include("MAddon/sh_MAddon_configuration.lua")



if SERVER then
    include("MAddon/server/sv_MAddon.lua")
    include("MAddon/server/sv_MAddon_utils.lua")
    include("MAddon/server/sv_net_messages.lua")
    include("MAddon/server/sv_net.lua")
end



if CLIENT then
    include("MAddon/client/cl_MAddon.lua")
    include("MAddon/client/cl_MAddon_net.lua")
    include("MAddon/client/cl_MAddon_gui.lua")
    include("MAddon/client/cl_MAddon_hud.lua")
end


-- AddCSLua in the same order as above
AddCSLuaFile("MAddon/sh_MAddon.lua")
AddCSLuaFile("MAddon/sh_MAddon_enums.lua")
AddCSLuaFile("MAddon/sh_MAddon_configuration.lua")

AddCSLuaFile("MAddon/client/cl_MAddon.lua")
AddCSLuaFile("MAddon/client/cl_MAddon_net.lua")
AddCSLuaFile("MAddon/client/cl_MAddon_gui.lua")
AddCSLuaFile("MAddon/client/cl_MAddon_hud.lua")


-- if you have any modules or other files that need to be included, do it here

for _, v in ipairs(file.Find("MAddon/modules/*.lua", "LUA")) do
    include("MAddon/modules/" .. v)
    AddCSLuaFile("MAddon/modules/" .. v)
end


print("\n [[[  Mirai Addon Base Template loaded successfully  ]]] \n")