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

    self.SystemVariables.Test = "This is making sure the variable works correctly!"

    self.Cache = {} -- Command cache for the currently loaded command schemas

    -- Assembly-like flags. These greatly depend on "the last command" executed, especially regarding $R0
    self.Flags = {
        ZF = false, -- Zero Flag
        SF = false, -- Sign Flag - 1 = negative, 0 = positive
        CF = false  -- Carry Flag
    }
end

function MPC.RegNum(reg)
    if tonumber(reg) then
        reg = math.Clamp(math.floor(tonumber(reg)), 0, 15)
        return tonumber(reg)
    end
    local regNum = reg:lower():match("^r(%d+)$") or reg:lower():match("^%$r(%d+)$")
    if regNum then
        regNum = math.Clamp(math.floor(tonumber(regNum)), 0, 15)
        return tonumber(regNum)
    end
    return nil
end

function ENT:DumpRegisters()
    for i = 0, 15 do
        self:print("$R"..i.." = ", tostring(self.Registers[i]))
    end
end

function ENT:RR(reg) -- read register
    local regNum = MPC.RegNum(reg)
    if regNum then
        return self.Registers[regNum] or 0
    end

    return 0
end

function ENT:WR(reg, value) -- write register
    local regNum = MPC.RegNum(reg)

    if tonumber(value) then
        value = tonumber(value)
    else
        value = string.Trim(tostring(value))
    end
    
    self:UpdateFlags(value)

    self.Registers[regNum] = value
end

function ENT:UpdateFlags(value)
    self.Flags.ZF = (value == 0) or value == "" -- Zero Flag
    self.Flags.SF = (type(value) == "number" and value < 0) or 0  -- Sign Flag
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
        if string.Trim(response.message) == "" then
            return
        end

        if response.type == "error" then
            self:print("Error: " .. response.message)
        elseif response.type == "info" then
            self:print(response.message)
        elseif response.type == "warning" then
            self:print("Warning: " .. response.message)
        end
    end
end
