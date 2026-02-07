-- net message calls.
local net = net


-- ! SENDING


function MAddon.net.Message(ply, msg, col, broadcast)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not msg or msg == "" then return end

    net.Start("MAddon_Message")
    net.WriteString(msg)
    net.WriteColor(col or MAddon.WHITE)
    if broadcast then
        net.Broadcast()
    else
        net.Send(ply)
    end
end












-- * RECIEVING



