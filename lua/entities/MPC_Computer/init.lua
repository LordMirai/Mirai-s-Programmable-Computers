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

    self:OpenTerminal(ply)

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

    self.SystemVariables = {}
    self.UserVariables = {}

    self.Cache = {} -- Command cache for the currently loaded command schemas
end

function ENT:DumpRegisters()
    for i = 0, 15 do
        print("$R"..i.." = ", tostring(self.Registers[i]))
    end
end




function ENT:OpenTerminal(user)
    -- for now, it'll be a derma popup, eventually it's gonna be cast to computer monitor, Maxnet-style
    if self.user and IsValid(self.user) and self.user != user then
        MPC.Message(user, "This computer is currently in use by " .. self.user:Nick())
        return
    end
    self.user = user
    MPC.net.OpenTerminal(user, self)
end

function ENT:print(msg)
    MPC.net.SendLine(self, msg)
end




function ENT:RunCommand(text)
    -- Tokenize the input text
    local tokens = MPC.CLI.Tokenize(text)

    -- Resolve aliases
    tokens = MPC.CLI.ResolveAlias(tokens)

    -- Fetch the command schema
    local cmdTable, consumedTokens = MPC.CLI.FetchCommand(tokens, self)
    if not cmdTable then
        self:print("Error: Command not found.")
        return
    end

    -- Evaluate the command
    local cmdInstance = MPC.CLI.EvaluateCommand(self, cmdTable, tokens, consumedTokens + 1)

    -- Execute the command
    local response = MPC.CLI.ExecuteCommand(self, cmdInstance)

    -- Handle the response
    if response.message then
        if response.type == "error" then
            self:print("Error: " .. response.message)
        elseif response.type == "info" then
            self:print(response.message)
        elseif response.type == "warning" then
            self:print("Warning: " .. response.message)
        end
    end
end
