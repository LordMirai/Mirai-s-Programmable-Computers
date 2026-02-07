
-- standardized message function for MAddon
function MAddon.Message(msg, col, noHead)
    if not msg or msg == "" then return end

    col = col or MAddon.WHITE

    if noHead then
        chat.AddText(col, msg)
    else
        chat.AddText(MAddon.Config.MessageHeadColor, "[MAddon]  ", col, msg)
    end
end


print("cl_MAddon.lua reloaded")