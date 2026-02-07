local net = net



-- ! SENDING









-- * RECIEVING


net.Receive("MAddon_Message", function()
    local msg = net.ReadString()
    local col = net.ReadColor()

    MAddon.Message(msg, col)
end)