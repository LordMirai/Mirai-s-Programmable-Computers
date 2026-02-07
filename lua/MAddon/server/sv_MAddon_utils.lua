function MAddon.Message(ply, message, color)
    MAddon.net.Message(ply, message, color, false)
end








hook.Add("PlayerSay", "MAddon_ChatCommands", function(ply, text, teamChat)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if string.StartsWith(text, MAddon.Config.CommandPrefix) then
        local cmd = string.sub(text, #MAddon.Config.CommandPrefix + 1)

        if cmd == "hello" then
            MAddon.Message(ply, "Hello, " .. ply:Nick() .. "!", Color(0, 255, 0))
            return ""
        else
            MAddon.Message(ply, "Unknown command: " .. cmd, Color(255, 0, 0))
            -- uncomment below to block unknown commands
            -- return ""
            return
        end
    end
end)