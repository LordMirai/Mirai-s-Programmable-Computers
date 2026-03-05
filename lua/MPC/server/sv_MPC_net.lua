-- net message calls.
local net = net


-- ! SENDING


function MPC.net.Message(ply, msg, col, broadcast)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not msg or msg == "" then return end

    net.Start("MPC_Message")
    net.WriteString(msg)
    net.WriteColor(col or MPC.WHITE)
    if broadcast then
        net.Broadcast()
    else
        net.Send(ply)
    end
end


function MPC.net.OpenTerminal(ply, computer)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not IsValid(computer) then return end

    net.Start("MPC_OpenTerminal")
    net.WriteEntity(computer)
    net.Send(ply)
end



function MPC.net.SendLine(ent, msg)
    if not IsValid(ent) then return end
    if not msg or msg == "" then return end

    net.Start("MPC_SendLine")
    net.WriteEntity(ent)
    net.WriteString(msg)
    net.Broadcast()
end






-- * RECIEVING


net.Receive("MPC_RunCommand", function()
    local ent = net.ReadEntity()
    local text = net.ReadString()

    if not IsValid(ent) or not ent.IsComputer then return end
    if not text or text == "" then return end

    ent:RunCommand(text)
end)


net.Receive("MPC_TerminalClosed", function(len, ply)
    local computer = net.ReadEntity()

    if IsValid(computer) and computer.IsComputer then
        computer.user = nil
        if IsValid(ply) then
            MPC.Message(ply, "You have closed the terminal.")
            MPC.MessageConsole(string.format("%s has closed the terminal", ply:Nick()))
        else
            MPC.MessageConsole("An invalid user has closed the terminal")
        end
    end
end)