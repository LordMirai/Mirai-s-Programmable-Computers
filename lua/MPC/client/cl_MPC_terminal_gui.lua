local function addLine(frame, pnl, text, col)
    local line = pnl:Add("DLabel")
    line:SetText(text)
    line:SetTextColor(col or MPC.WHITE)
    line:SetFont("Trebuchet24")
    line:SizeToContents()

    pnl:ScrollToChild(line)
end


function MPC.TerminalMenu(ent)
    if not IsValid(ent) then return end

    if IsValid(MPC.TerminalTopLevel) then
        MPC.TerminalTopLevel:Close() -- close existing terminal
    end

    local lastCommand = ""

    local frame = vgui.Create("DFrame")
    frame:SetSize(800, 600)
    frame:Center()
    frame:SetTitle("MPC Terminal - " .. tostring(ent))
    frame:MakePopup()
    
    frame.computer = ent

    local inputPnl = vgui.Create("DPanel", frame)
    inputPnl:Dock(BOTTOM)
    inputPnl:SetTall(30)

    -- history and output panel
    local linePnl = vgui.Create("DScrollPanel", frame)
    linePnl:Dock(FILL)
    linePnl:SetBackgroundColor(Color(33, 33, 33))
    linePnl:GetVBar():SetVisible(true)

    local lineIn = vgui.Create("DTextEntry", inputPnl)
    lineIn:Dock(FILL)
    lineIn:RequestFocus()
    lineIn:SetPlaceholderText("Enter command...")

    function lineIn:OnEnter()
        local text = self:GetText()
        text = string.Trim(text)
        if text == "" then return end

        addLine(frame, linePnl, "> " .. text)

        -- prioritize client-only
        local prevent = MPC.RunClientCommand(ent, text)
        if prevent then
            self:SetText("")
            self:RequestFocus()
            return
        end

        MPC.net.RunCommand(ent, text)

        lastCommand = text

        self:SetText("")
        self:RequestFocus()
    end

    function lineIn:OnKeyCodePressed(key)
        if key == KEY_UP and lastCommand != "" then
            self:SetText(lastCommand)
            self:SetCaretPos(string.len(lastCommand))
            
            lastCommand = ""
        end
    end
    
    function frame:OnClose()
        MPC.TerminalTopLevel = nil

        MPC.net.TerminalClosed(ent)
    end


    function frame:AddLine(text, col)
        addLine(frame, linePnl, text, col)
    end


    MPC.TerminalTopLevel = frame
end