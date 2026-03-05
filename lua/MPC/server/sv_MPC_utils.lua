function MPC.Message(ply, message, color)
    MPC.net.Message(ply, message, color, false)
end

function MPC.MessageConsole(msg)
    if not msg or msg == "" then return end

    MsgC(MPC.MessageHeadColor, "[MPC]  ", MPC.WHITE, msg .. "\n")
end



hook.Add("PlayerSay", "MPC_ChatCommands", function(ply, text, teamChat)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if string.StartsWith(text, MPC.CommandPrefix) then
        local cmd = string.sub(text, #MPC.CommandPrefix + 1)

        if cmd == "you know something will eventually work." then
        else
            MPC.Message(ply, "Unknown command: " .. cmd, Color(255, 0, 0))
            -- uncomment below to block unknown commands
            -- return ""
            return
        end
    end
end)