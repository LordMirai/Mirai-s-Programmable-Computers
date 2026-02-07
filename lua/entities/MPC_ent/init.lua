AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")


local fallbackModel = "models/props_c17/oildrum001.mdl" -- Default model if none is specified

function ENT:Initialize()
    if self.PreInit then
        self:PreInit()
    end
    
    self:SetModel(self.model or fallbackModel) -- TODO: Change to a custom model
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetTrigger(true)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    self.UseCooldown = 1

    if self.PostInit then
        self:PostInit()
    end
    
    self.CanUse = true
end


function ENT:Use(ply, cal)
    if not self.CanUse then return end

    -- Your use logic here

    --[[
    ? if you want cooldown, uncomment this
    
    self.CanUse = false
    timer.Simple(self.UseCooldown, function()
        if IsValid(self) then
            self.CanUse = true
        end
    end)
    ]]
end