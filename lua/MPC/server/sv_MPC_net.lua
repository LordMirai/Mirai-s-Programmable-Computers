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





-- * RECIEVING



