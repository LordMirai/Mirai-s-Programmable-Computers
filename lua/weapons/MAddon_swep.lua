SWEP.Base = "weapon_base"
SWEP.PrintName = "MAddon SWEP"
SWEP.Author = "Lord Mirai (未来)"
SWEP.Instructions = "Left click to use"
SWEP.Category = "MAddon"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
    self:EmitSound("ambient/levels/labs/electric_explosion1.wav")
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:SecondaryAttack()
    self:EmitSound("ambient/levels/labs/electric_explosion2.wav")
    self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
    self:SetNextSecondaryFire(CurTime() + 1)
end