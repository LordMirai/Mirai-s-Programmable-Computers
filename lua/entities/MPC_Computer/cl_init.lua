include("shared.lua")

function ENT:Draw()
    self:DrawModel()


    --[[ 
    ? cam3d2d to display text facing the player

    local ply = LocalPlayer()
    local pos = self:GetPos() + Vector(0, 0, 30)

    local ang = self:GetAngles()
    ang.y = ply:EyeAngles().y

    ang:RotateAroundAxis(ang:Right(), 90)
    ang:RotateAroundAxis(ang:Up(), -90)

    cam.Start3D2D(pos, ang, 0.1)
        draw.RoundedBox(0, -50, -20, 200, 40, MPC.BLACK, 5, 5)
        draw.SimpleText("I'm so cool", MPC.FONT, -35, 0, MPC.WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    cam.End3D2D()
    ]]
end