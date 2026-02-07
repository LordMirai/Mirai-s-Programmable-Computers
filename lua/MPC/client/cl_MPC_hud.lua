CreateClientConVar("MPC_hud", "1", true, false, "Enable MPC HUD")

hook.Add("HUDPaint", "MPC_HUD", function()
    if GetConVar("MPC_hud"):GetBool() then
        -- Draw your HUD elements here
    end
end)