ENT.Base = "base_gmodentity"
ENT.Type = "anim"

ENT.PrintName = "MPC Computer"
ENT.Author = "Lord Mirai (未来)"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Mirai's Programmable Computers"

function ENT:SetupDataTables()

end

MPC = MPC or {}

ENT.IsComputer = true

--[[

0. Entity initialization
1. Computer Architecture - Registers, Stack, Execution Cycle
2. Command Line Interact (Terminal)
3. Pseudo-Operating System - sys variables, process management
4. Filesystem - virtual drive (60kB)
5. Peripherals - connectivity, networking etc.

]]