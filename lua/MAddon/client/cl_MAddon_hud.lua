CreateClientConVar("maddon_hud", "1", true, false, "Enable MAddon HUD")

hook.Add("HUDPaint", "MAddon_HUD", function()
    if GetConVar("maddon_hud"):GetBool() then
        -- Draw your HUD elements here
    end
end)