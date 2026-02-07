AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


function ENT:Initialize()
    self:SetModel("models/Humans/Group02/male_08.mdl")
    self:SetHullType(HULL_HUMAN)
    self:SetSolid(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_STEP)
    self:SetHealth(100)
    self:SetPos(self:GetPos() + Vector(0, 0, 10))
    self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
    self:CapabilitiesAdd(CAP_ANIMATEDFACE)
    self:CapabilitiesAdd(CAP_TURN_HEAD)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end

    if self:IsValid() then
        self:Activate()
        self:DropToFloor()
    end

    timer.Simple(1, function()
        if IsValid(self) then
            self:SetNPCState(NPC_STATE_IDLE)
        end
    end)
end

function ENT:Use(ply)
    if ply:IsPlayer() then
        
    end
end
