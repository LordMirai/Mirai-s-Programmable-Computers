function MPC.Message(ply, message, color)
    MPC.net.Message(ply, message, color, false)
end




hook.Add("PlayerSay", "MPC_ChatCommands", function(ply, text, teamChat)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if string.StartsWith(text, MPC.Config.CommandPrefix) then
        local cmd = string.sub(text, #MPC.Config.CommandPrefix + 1)

        if cmd == "hello" then
            MPC.Message(ply, "Hello, " .. ply:Nick() .. "!", Color(0, 255, 0))
            return ""
        else
            MPC.Message(ply, "Unknown command: " .. cmd, Color(255, 0, 0))
            -- uncomment below to block unknown commands
            -- return ""
            return
        end
    end
end)