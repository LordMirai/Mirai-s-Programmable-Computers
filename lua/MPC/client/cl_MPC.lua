
-- standardized message function for MPC
function MPC.Message(msg, col, noHead)
    if not msg or msg == "" then return end

    col = col or MPC.WHITE

    if noHead then
        chat.AddText(col, msg)
    else
        chat.AddText(MPC.Config.MessageHeadColor, "[MPC]  ", col, msg)
    end
end


print("cl_MPC.lua reloaded")