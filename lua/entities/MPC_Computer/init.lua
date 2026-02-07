AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

--[[
STEP ONE: Architecture

REGISTERS - $R0 -> $R15 -- can hold strings and numbers
Stack - LIFO
Execution Cycle --! LEFT FOR LATER

]]

local fallbackModel = "models/monitors/monitor_03.mdl" -- Default model if none is specified

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

    self:InitializeArchitecture()



    if self.PostInit then
        self:PostInit()
    end
    
    self.CanUse = true
end


function ENT:Use(ply, cal)
    if not self.CanUse then return end

    self:OpenTerminal()

    self.CanUse = false
    timer.Simple(self.UseCooldown, function()
        if IsValid(self) then
            self.CanUse = true
        end
    end)
end


function ENT:InitializeArchitecture()
    self.IsPoweredOn = false
    self.Stack = util.Stack()

    self.Registers = {}
    for i = 0, 15 do
        self.Registers[i] = 0
    end

    self.IP = 0 -- Instruction Pointer
    self.RA = -1 -- Return Address
end

function ENT:DumpRegisters()
    for i = 0, 15 do
        print("$R"..i.." = ", tostring(self.Registers[i]))
    end
end




function ENT:OpenTerminal()
    
end