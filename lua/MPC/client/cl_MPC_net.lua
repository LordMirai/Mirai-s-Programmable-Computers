local net = net



-- ! SENDING


function MPC.net.RunCommand(ent, text)
    if not IsValid(ent) then return end
    if not text or text == "" then return end

    net.Start("MPC_RunCommand")
    net.WriteEntity(ent)
    net.WriteString(text)
    net.SendToServer()
end


function MPC.net.TerminalClosed(ent)
    if not IsValid(ent) then return end

    net.Start("MPC_TerminalClosed")
    net.WriteEntity(ent)
    net.SendToServer()
end





-- * RECIEVING


net.Receive("MPC_Message", function()
    local msg = net.ReadString()
    local col = net.ReadColor()

    MPC.Message(msg, col)
end)


net.Receive("MPC_OpenTerminal", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end

    MPC.TerminalMenu(ent)
end)


net.Receive("MPC_SendLine", function()
    local ent = net.ReadEntity()
    local msg = net.ReadString()

    if not IsValid(ent) then return end
    if not msg or msg == "" then return end

    if MPC.TerminalTopLevel and MPC.TerminalTopLevel.AddLine then
        MPC.TerminalTopLevel:AddLine(msg)
    end
end)