MPC.ClientCommands = MPC.ClientCommands or {}


MPC.ClientCommands["exit"] = {
    func = function(ent, args)
        if MPC.TerminalTopLevel and IsValid(MPC.TerminalTopLevel) then
            MPC.TerminalTopLevel:Close()
        end
    end,
    description = "Closes the terminal interface.",
    usage = "exit",
    category = "General"
}

MPC.ClientCommands["mflood"] = {
    func = function(ent, args)
        local count = tonumber(args[2]) or 10
        local message = args[3] or "Hello from MPC!"

        local frame = MPC.TerminalTopLevel
        for i = 1, count do
            frame:AddLine(string.format("[%d] %s", i, message), ColorRand())
        end
    end,
    description = "Message flood - Sends multiple messages to the player's chat.",
    usage = "mflood <count> <message>",
    category = "General"
}


function MPC.RunClientCommand(ent, text)
    if not IsValid(ent) then return end
    if not text or text == "" then return end
     
    local tokens = MPC.CLI.Tokenize(text)
    local cmdName = tokens[1]

    local cmdFunc = MPC.ClientCommands[cmdName]
    if cmdFunc then
        cmdFunc.func(ent, tokens)
        return true
    end

    return false
end