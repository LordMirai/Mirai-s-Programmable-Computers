local net = net



-- ! SENDING









-- * RECIEVING


net.Receive("MPC_Message", function()
    local msg = net.ReadString()
    local col = net.ReadColor()

    MPC.Message(msg, col)
end)