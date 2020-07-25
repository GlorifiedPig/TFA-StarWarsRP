
-- Copyright (c) 2018-2020 TFA Base Devs

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

--[[Define Modules]]
SWEP.SV_MODULES = {}
SWEP.SH_MODULES = {"sh_ai_translations.lua", "sh_anims.lua", "sh_autodetection.lua", "sh_utils.lua", "sh_attachments.lua", "sh_bullet.lua", "sh_effects.lua", "sh_bobcode.lua", "sh_calc.lua", "sh_akimbo.lua", "sh_events.lua", "sh_nzombies.lua", "sh_ttt.lua", "sh_vm.lua", "sh_skins.lua" }
SWEP.ClSIDE_MODULES = { "cl_effects.lua", "cl_viewbob.lua", "cl_hud.lua", "cl_mods.lua", "cl_laser.lua", "cl_fov.lua", "cl_flashlight.lua" }
SWEP.Category = "" --The category.  Please, just choose something generic or something I've already done if you plan on only doing like one swep.
SWEP.Author = "TheForgottenArchitect"
SWEP.Contact = "theforgottenarchitect"
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.DrawCrosshair = true
SWEP.DrawCrosshairIS = false
SWEP.ViewModelFOV = 65
SWEP.ViewModelFlip = false
SWEP.Skin = 0 --Viewmodel skin
SWEP.Spawnable = false
SWEP.IsTFAWeapon = true

SWEP.Shotgun = false
SWEP.ShotgunEmptyAnim = false
SWEP.ShotgunEmptyAnim_Shell = true
SWEP.ShotgunStartAnimShell = false --shotgun start anim inserts shell
SWEP.ShellTime = nil

SWEP.data = {}
SWEP.data.ironsights = 1

SWEP.MoveSpeed = 1
SWEP.IronSightsMoveSpeed = nil

SWEP.FireSoundAffectedByClipSize = true

SWEP.Primary.Damage = -1
SWEP.Primary.DamageTypeHandled = true --true will handle damagetype in base
SWEP.Primary.NumShots = 1
SWEP.Primary.Force = -1
SWEP.Primary.Knockback = -1
SWEP.Primary.Recoil = 1
SWEP.Primary.RPM = 600
SWEP.Primary.RPM_Semi = -1
SWEP.Primary.RPM_Burst = -1
SWEP.Primary.StaticRecoilFactor = 0.5
SWEP.Primary.KickUp = 0.5
SWEP.Primary.KickDown = 0.5
SWEP.Primary.KickRight = 0.5
SWEP.Primary.KickHorizontal = 0.5
SWEP.Primary.DamageType = nil
SWEP.Primary.Ammo = "smg1"
SWEP.Primary.AmmoConsumption = 1
SWEP.Primary.Spread = 0
SWEP.Primary.SpreadMultiplierMax = -1 --How far the spread can expand when you shoot.
SWEP.Primary.SpreadIncrement = -1 --What percentage of the modifier is added on, per shot.
SWEP.Primary.SpreadRecovery = -1 --How much the spread recovers, per second.
SWEP.Primary.IronAccuracy = 0
SWEP.Primary.MaxPenetration = 100
SWEP.Primary.Range = -1--1200
SWEP.Primary.RangeFalloff = -1--0.5
SWEP.Primary.PenetrationMultiplier = 1
SWEP.Primary.DryFireDelay = nil

local sv_tfa_jamming = GetConVar('sv_tfa_jamming')
local sv_tfa_jamming_mult = GetConVar('sv_tfa_jamming_mult')
local sv_tfa_jamming_factor = GetConVar('sv_tfa_jamming_factor')
local sv_tfa_jamming_factor_inc = GetConVar('sv_tfa_jamming_factor_inc')

-- RP owners always like realism, so this feature might be something they like. Enable it for them!
TFA_AUTOJAMMING_ENABLED = string.find(engine.ActiveGamemode(), 'rp') or
	string.find(engine.ActiveGamemode(), 'roleplay') or
	string.find(engine.ActiveGamemode(), 'nutscript') or
	string.find(engine.ActiveGamemode(), 'serious') or
	TFA_ENABLE_JAMMING_BY_DEFAULT

SWEP.CanJam = tobool(TFA_AUTOJAMMING_ENABLED)

SWEP.JamChance = 0.04
SWEP.JamFactor = 0.06

SWEP.BoltAction = false --Unscope/sight after you shoot?
SWEP.BoltAction_Forced = false
SWEP.Scoped = false --Draw a scope overlay?
SWEP.ScopeOverlayThreshold = 0.875 --Percentage you have to be sighted in to see the scope.
SWEP.BoltTimerOffset = 0.25 --How long you stay sighted in after shooting, with a bolt action.
SWEP.ScopeScale = 0.5
SWEP.ReticleScale = 0.7

SWEP.MuzzleAttachment = "1"
SWEP.ShellAttachment = "2"

SWEP.MuzzleFlashEnabled = true
SWEP.MuzzleFlashEffect = nil
SWEP.MuzzleFlashEffectSilenced = "tfa_muzzleflash_silenced"
SWEP.CustomMuzzleFlash = true

SWEP.EjectionSmokeEnabled = true

SWEP.LuaShellEject = false
SWEP.LuaShellEjectDelay = 0
SWEP.LuaShellEffect = nil --Defaults to blowback

SWEP.SmokeParticle = nil --Smoke particle (ID within the PCF), defaults to something else based on holdtype

SWEP.StatusLengthOverride = {} --Changes the status delay of a given animation; only used on reloads.  Otherwise, use SequenceLengthOverride or one of the others
SWEP.SequenceLengthOverride = {} --Changes both the status delay and the nextprimaryfire of a given animation
SWEP.SequenceTimeOverride = {} --Like above but changes animation length to a target
SWEP.SequenceRateOverride = {} --Like above but scales animation length rather than being absolute

SWEP.BlowbackEnabled = false --Enable Blowback?
SWEP.BlowbackVector = Vector(0, -1, 0) --Vector to move bone <or root> relative to bone <or view> orientation.
SWEP.BlowbackCurrentRoot = 0 --Amount of blowback currently, for root
SWEP.BlowbackCurrent = 0 --Amount of blowback currently, for bones
SWEP.BlowbackBoneMods = nil --Viewmodel bone mods via SWEP Creation Kit
SWEP.Blowback_Only_Iron = true --Only do blowback on ironsights
SWEP.Blowback_PistolMode = false --Do we recover from blowback when empty?

SWEP.ProceduralHolsterEnabled = nil
SWEP.ProceduralHolsterTime = 0.3
SWEP.ProceduralHolsterPos = Vector(3, 0, -5)
SWEP.ProceduralHolsterAng = Vector(-40, -30, 10)

SWEP.ProceduralReloadEnabled = false --Do we reload using lua instead of a .mdl animation
SWEP.ProceduralReloadTime = 1 --Time to take when procedurally reloading, including transition in (but not out)

SWEP.Blowback_PistolMode_Disabled = {
	[ACT_VM_RELOAD] = true,
	[ACT_VM_RELOAD_EMPTY] = true,
	[ACT_VM_DRAW_EMPTY] = true,
	[ACT_VM_IDLE_EMPTY] = true,
	[ACT_VM_HOLSTER_EMPTY] = true,
	[ACT_VM_DRYFIRE] = true,
	[ACT_VM_FIDGET] = true,
	[ACT_VM_FIDGET_EMPTY] = true
}

SWEP.Blowback_Shell_Enabled = true
SWEP.Blowback_Shell_Effect = "ShellEject"

SWEP.Secondary.Ammo = ""
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0

SWEP.Sights_Mode = TFA.Enum.LOCOMOTION_LUA -- ANI = mdl, HYBRID = lua but continue idle, Lua = stop mdl animation
SWEP.Sprint_Mode = TFA.Enum.LOCOMOTION_LUA -- ANI = mdl, HYBRID = ani + lua, Lua = lua only
SWEP.Walk_Mode = TFA.Enum.LOCOMOTION_LUA -- ANI = mdl, HYBRID = ani + lua, Lua = lua only
SWEP.Customize_Mode = TFA.Enum.LOCOMOTION_LUA -- ANI = mdl, HYBRID = ani + lua, Lua = lua only
SWEP.SprintFOVOffset = 5
SWEP.Idle_Mode = TFA.Enum.IDLE_BOTH --TFA.Enum.IDLE_DISABLED = no idle, TFA.Enum.IDLE_LUA = lua idle, TFA.Enum.IDLE_ANI = mdl idle, TFA.Enum.IDLE_BOTH = TFA.Enum.IDLE_ANI + TFA.Enum.IDLE_LUA
SWEP.Idle_Blend = 0.25 --Start an idle this far early into the end of a transition
SWEP.Idle_Smooth = 0.05 --Start an idle this far early into the end of another animation

SWEP.IronSightTime = 0.3
SWEP.IronSightsSensitivity = 1

SWEP.InspectPosDef = Vector(9.779, -11.658, -2.241)
SWEP.InspectAngDef = Vector(24.622, 42.915, 15.477)

SWEP.RunSightsPos = Vector(0,0,0)
SWEP.RunSightsAng = Vector(0,0,0)
SWEP.AllowSprintAttack = false --Shoot while sprinting?

SWEP.EventTable = {}

SWEP.RTMaterialOverride = nil
SWEP.RTOpaque = false
SWEP.RTCode = nil--function(self) return end
SWEP.RTBGBlur = true

SWEP.VMPos = Vector(0,0,0)
SWEP.VMAng = Vector(0,0,0)
SWEP.CameraOffset = Angle(0, 0, 0)
SWEP.VMPos_Additive = true

SWEP.AllowIronSightsDoF = true

SWEP.IronAnimation = {
	--[[
	["in"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Idle_To_Iron", --Number for act, String/Number for sequence
		["value_empty"] = "Idle_To_Iron_Dry",
		["transition"] = true
	}, --Inward transition
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Idle_Iron", --Number for act, String/Number for sequence
		["value_empty"] = "Idle_Iron_Dry"
	}, --Looping Animation
	["out"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Iron_To_Idle", --Number for act, String/Number for sequence
		["value_empty"] = "Iron_To_Idle_Dry",
		["transition"] = true
	}, --Outward transition
	["shoot"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Fire_Iron", --Number for act, String/Number for sequence
		["value_last"] = "Fire_Iron_Last",
		["value_empty"] = "Fire_Iron_Dry"
	} --What do you think
	]]--
}

SWEP.SprintAnimation = {
	--[[
	["in"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Idle_to_Sprint", --Number for act, String/Number for sequence
		["value_empty"] = "Idle_to_Sprint_Empty",
		["transition"] = true
	}, --Inward transition
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Sprint_", --Number for act, String/Number for sequence
		["value_empty"] = "Sprint_Empty_",
		["is_idle"] = true
	},--looping animation
	["out"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Sprint_to_Idle", --Number for act, String/Number for sequence
		["value_empty"] = "Sprint_to_Idle_Empty",
		["transition"] = true
	} --Outward transition
	]]--
}

SWEP.ShootAnimation = {--[[
	["in"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "shoot_loop_start", --Number for act, String/Number for sequence
		["value_is"] = "shoot_loop_iron_start"
	},
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "shoot_loop", --Number for act, String/Number for sequence
		["value_is"] = "shoot_loop_iron",
		["is_idle"] = true
	},
	["out"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "shoot_loop_end", --Number for act, String/Number for sequence
		["value_is"] = "shoot_loop_iron_end"
	}]]--
}

SWEP.FirstDeployEnabled = nil--Force first deploy enabled

--[[Dont edit under this unless you know what u r doing]]

SWEP.IronSightsProgress = 0
SWEP.CLIronSightsProgress = 0
SWEP.SprintProgress = 0
SWEP.WalkProgress = 0
SWEP.SpreadRatio = 0
SWEP.CrouchingRatio = 0
SWEP.SmokeParticles = {
	pistol = "tfa_ins2_weapon_muzzle_smoke",
	smg = "tfa_ins2_weapon_muzzle_smoke",
	grenade = "tfa_ins2_weapon_muzzle_smoke",
	ar2 = "tfa_ins2_weapon_muzzle_smoke",
	shotgun = "tfa_ins2_weapon_muzzle_smoke",
	rpg = "tfa_ins2_weapon_muzzle_smoke",
	physgun = "tfa_ins2_weapon_muzzle_smoke",
	crossbow = "tfa_ins2_weapon_muzzle_smoke",
	melee = "tfa_ins2_weapon_muzzle_smoke",
	slam = "tfa_ins2_weapon_muzzle_smoke",
	normal = "tfa_ins2_weapon_muzzle_smoke",
	melee2 = "tfa_ins2_weapon_muzzle_smoke",
	knife = "tfa_ins2_weapon_muzzle_smoke",
	duel = "tfa_ins2_weapon_muzzle_smoke",
	camera = "tfa_ins2_weapon_muzzle_smoke",
	magic = "tfa_ins2_weapon_muzzle_smoke",
	revolver = "tfa_ins2_weapon_muzzle_smoke",
	silenced = "tfa_ins2_weapon_muzzle_smoke"
}
--[[ SWEP.SmokeParticles = {
	pistol = "weapon_muzzle_smoke",
	smg = "weapon_muzzle_smoke",
	grenade = "weapon_muzzle_smoke",
	ar2 = "weapon_muzzle_smoke",
	shotgun = "weapon_muzzle_smoke_long",
	rpg = "weapon_muzzle_smoke_long",
	physgun = "weapon_muzzle_smoke_long",
	crossbow = "weapon_muzzle_smoke_long",
	melee = "weapon_muzzle_smoke",
	slam = "weapon_muzzle_smoke",
	normal = "weapon_muzzle_smoke",
	melee2 = "weapon_muzzle_smoke",
	knife = "weapon_muzzle_smoke",
	duel = "weapon_muzzle_smoke",
	camera = "weapon_muzzle_smoke",
	magic = "weapon_muzzle_smoke",
	revolver = "weapon_muzzle_smoke_long",
	silenced = "weapon_muzzle_smoke"
}--]]
--[[
SWEP.SmokeParticles = {
	pistol = "smoke_trail_controlled",
	smg = "smoke_trail_tfa",
	grenade = "smoke_trail_tfa",
	ar2 = "smoke_trail_tfa",
	shotgun = "smoke_trail_wild",
	rpg = "smoke_trail_tfa",
	physgun = "smoke_trail_tfa",
	crossbow = "smoke_trail_tfa",
	melee = "smoke_trail_tfa",
	slam = "smoke_trail_tfa",
	normal = "smoke_trail_tfa",
	melee2 = "smoke_trail_tfa",
	knife = "smoke_trail_tfa",
	duel = "smoke_trail_tfa",
	camera = "smoke_trail_tfa",
	magic = "smoke_trail_tfa",
	revolver = "smoke_trail_tfa",
	silenced = "smoke_trail_controlled"
}
]]--

SWEP.Inspecting = false
SWEP.InspectingProgress = 0
SWEP.LuaShellRequestTime = -1
SWEP.BobScale = 0
SWEP.SwayScale = 0
SWEP.BoltDelay = 1
SWEP.ProceduralHolsterProgress = 0
SWEP.BurstCount = 0
SWEP.DefaultFOV = 90

--[[ Localize Functions  ]]
local function l_Lerp(v, f, t)
	return f + (t - f) * v
end

local l_mathApproach = math.Approach
local l_CT = CurTime


--[[Localize Functions]]
local l_ct = CurTime
--[[Frequently Reused Local Vars]]
local stat, statend --Weapon status
local ct, ft  = 0, 0.01--Curtime, frametime, real frametime
local sp = game.SinglePlayer() --Singleplayer

--[[
Function Name:  SetupDataTables
Syntax: Should not be manually called.
Returns:  Nothing.  Simple sets up DTVars to be networked.
Purpose:  Networking.
]]
function SWEP:SetupDataTables()
	--self:NetworkVar("Bool", 0, "IronSights")
	self:NetworkVar("Bool", 0, "IronSightsRaw")
	self:NetworkVar("Bool", 1, "Sprinting")
	self:NetworkVar("Bool", 2, "Silenced")
	self:NetworkVar("Bool", 3, "ShotgunCancel")
	self:NetworkVar("Bool", 4, "Walking")
	self:NetworkVar("Bool", 5, "Customizing")
	self:NetworkVar("Bool", 18, "FlashlightEnabled")
	self:NetworkVar("Bool", 19, "Jammed")
	self:NetworkVar("Float", 0, "StatusEnd")
	self:NetworkVar("Float", 1, "NextIdleAnim")
	self:NetworkVar("Float", 18, "NextLoopSoundCheck")
	self:NetworkVar("Float", 19, "JamFactor")
	self:NetworkVar("Int", 0, "Status")
	self:NetworkVar("Int", 1, "FireMode")
	self:NetworkVar("Int", 2, "LastActivity")
	self:NetworkVar("Int", 3, "BurstCount")
	self:NetworkVar("Int", 4, "ShootStatus")
	self:NetworkVar("Entity", 0, "SwapTarget")
	hook.Run("TFA_SetupDataTables",self)
end

--[[
Function Name:  Initialize
Syntax: Should not be normally called.
Notes:   Called after actual SWEP code, but before deploy, and only once.
Returns:  Nothing.  Sets the intial values for the SWEP when it's created.
Purpose:  Standard SWEP Function
]]

local PistolHoldTypes = {
	["pistol"] = true,
	["357"] = true,
	["revolver"] = true
}
local MeleeHoldTypes = {
	["melee"] = true,
	["melee2"] = true,
	["knife"] = true
}

function SWEP:Initialize()
	hook.Run("TFA_PreInitialize",self)
	self.DrawCrosshairDefault = self.DrawCrosshair
	self.HasInitialized = true
	if ( not self.BobScaleCustom ) or self.BobScaleCustom <= 0 then
		self.BobScaleCustom = 1
	end
	self.BobScale = 0
	self.SwayScaleCustom = 1
	self.SwayScale = 0
	self:SetSilenced( self.Silenced or self.DefaultSilenced )
	self.Silenced = self.Silenced or self.DefaultSilenced
	self:InitializeAnims()
	self:InitializeMaterialTable()
	self:PatchAmmoTypeAccessors()
	self:FixRPM()
	self:FixIdles()
	self:FixIS()
	self:FixProceduralReload()
	self:FixCone()
	self:FixProjectile()
	self:AutoDetectMuzzle()
	self:AutoDetectDamage()
	self:AutoDetectDamageType()
	self:AutoDetectForce()
	self:AutoDetectKnockback()
	self:AutoDetectSpread()
	self:AutoDetectRange()
	self:IconFix()
	self:CreateFireModes()
	self:FixAkimbo()
	self:FixSprintAnimBob()
	self:FixWalkAnimBob()
	self:PathStatsTable("Primary")
	self:PathStatsTable("Secondary")
	self:ClearStatCache()

	if not self.IronSightsMoveSpeed then
		self.IronSightsMoveSpeed = self.MoveSpeed * 0.8
	end

	if self:GetStat("Skin") and isnumber(self:GetStat("Skin")) then
		self:SetSkin(self:GetStat("Skin"))
	end

	self:SetNextLoopSoundCheck(-1)
	self:SetShootStatus(TFA.Enum.SHOOT_IDLE)

	if SERVER and self.Owner:IsNPC() then
		local seq = self.Owner:LookupSequence("shootp1")
		if MeleeHoldTypes[self.DefaultHoldType or self.HoldType] then
			if self.Owner:GetSequenceName(seq) == "shootp1" then
				self:SetWeaponHoldType("melee2")
			else
				self:SetWeaponHoldType("melee")
			end
		elseif PistolHoldTypes[self.DefaultHoldType or self.HoldType] then
			if self.Owner:GetSequenceName(seq) == "shootp1" then
				self:SetWeaponHoldType("pistol")
			else
				self:SetWeaponHoldType("smg")
			end
		else
			self:SetWeaponHoldType(self.DefaultHoldType or self.HoldType)
		end
		if self.Owner:GetClass() == "npc_citizen" then
			self.Owner:Fire( "DisableWeaponPickup" )
		end
		self.Owner:SetKeyValue( "spawnflags", "256" )
		return
	end
	hook.Run("TFA_Initialize",self)
end

function SWEP:PathStatsTable(statID)
	local tableDest = self[statID]
	local tableCopy = table.Copy(tableDest)
	self[statID .. "_TFA"] = tableCopy
	local ammo = statID .. ".Ammo"
	local clipSize = statID .. ".ClipSize"
	table.Empty(tableDest)
	local ignore = false

	local function ignoreHack(key)
		if key == "Ammo" then
			return self:GetStat(ammo)
		elseif key == "ClipSize" then
			return self:GetStat(clipSize)
		else
			return tableCopy[key]
		end
	end

	self[statID] = setmetatable(tableDest, {
		__index = function(_, key)
			if ignore then return tableCopy[key] end
			ignore = true
			local val = ignoreHack(key)
			ignore = false

			return val
		end,
		__newindex = function(_, key, value)
			tableCopy[key] = value
		end
	})
	hook.Run("TFA_PathStatsTable",self)
end

function SWEP:NPCWeaponThinkHook()
	if not self:GetOwner():IsNPC() then
		hook.Remove("TFA_NPCWeaponThink", self)

		return
	end

	self:Think()
end

function SWEP:Equip( ... )
	if self:GetOwner():IsNPC() then
		hook.Add("TFA_NPCWeaponThink", self, self.NPCWeaponThinkHook)
	end

	self.OwnerViewModel = nil
	self:EquipTTT(  ... )
end

--[[
Function Name:  Deploy
Syntax: self:Deploy()
Notes:  Called after self:Initialize().  Called each time you draw the gun.  This is also essential to clearing out old networked vars and resetting them.
Returns:  True/False to allow quickswitch.  Why not?  You should really return true.
Purpose:  Standard SWEP Function
]]

function SWEP:Deploy()
	hook.Run("TFA_PreDeploy",self)

	if IsValid(self:GetOwner()) and IsValid(self:GetOwner():GetViewModel()) then
		self.OwnerViewModel = self:GetOwner():GetViewModel()
	end

	if SERVER and self:GetStat("FlashlightAttachment", 0) > 0 and IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() and self:GetOwner():FlashlightIsOn() then
		if not self:GetFlashlightEnabled() then
			self:ToggleFlashlight(true)
		end

		self:GetOwner():Flashlight(false)
	end

	ct = l_CT()

	if not self:VMIV() then
		print("Invalid VM on owner: ")
		print(self:GetOwner())

		return
	end

	if not self.HasDetectedValidAnimations then
		self:CacheAnimations()
	end

	local _,tanim = self:ChooseDrawAnim()

	if sp then
		self:CallOnClient("ChooseDrawAnim", "")
	end

	self:SetStatus(TFA.Enum.STATUS_DRAW)
	local len = self:GetActivityLength( tanim )
	self:SetStatusEnd(ct + len )
	self:SetNextPrimaryFire( ct + len )
	self:SetIronSightsRaw(false)
	if not self:GetStat("PumpAction") then
		self:SetShotgunCancel( false )
	end
	self:SetBurstCount(0)
	self.IronSightsProgress = 0
	self.SprintProgress = 0
	self.InspectingProgress = 0
	self.ProceduralHolsterProgress = 0
	if self.Inspecting then
		--if gui then
		--  gui.EnableScreenClicker(false)
		--end
		self.Inspecting = false
	end
	self.DefaultFOV = TFADUSKFOV or ( IsValid(self:GetOwner()) and self:GetOwner():GetFOV() or 90 )
	if self:GetStat("Skin") and isnumber(self:GetStat("Skin")) then
		self.OwnerViewModel:SetSkin(self:GetStat("Skin"))
		self:SetSkin(self:GetStat("Skin"))
	end

	self:InitAttachments()
	local v = hook.Run("TFA_Deploy",self)
	if v ~= nil then
		return v
	end

	return true
end

--[[
Function Name:  Holster
Syntax: self:Holster( weapon entity to switch to )
Notes:  This is kind of broken.  I had to manually select the new weapon using ply:ConCommand.  Returning true is simply not enough.  This is also essential to clearing out old networked vars and resetting them.
Returns:  True/False to allow holster.  Useful for animations.
Purpose:  Standard SWEP Function
]]
function SWEP:Holster(target)
	local v = hook.Run("TFA_PreHolster", self)
	if v ~= nil then return v end
	if self.Owner:IsNPC() then return end

	if not IsValid(target) then
		self.InspectingProgress = 0

		return true
	end

	if not IsValid(self) then return end
	ct = l_CT()
	stat = self:GetStatus()

	if not TFA.Enum.HolsterStatus[stat] then
		if stat == TFA.GetStatus("reloading_wait") and self:Clip1() <= self:GetStat("Primary.ClipSize") and (not self:GetStat("DisableChambering")) and (not self:GetStat("Shotgun")) then
			self:ResetFirstDeploy()

			if sp then
				self:CallOnClient("ResetFirstDeploy", "")
			end
		end

		local success, tanim = self:ChooseHolsterAnim()

		if IsFirstTimePredicted() then
			self:SetSwapTarget(target)
		end

		self:SetStatus(TFA.Enum.STATUS_HOLSTER)

		if success then
			self:SetStatusEnd(ct + self:GetActivityLength(tanim))
		else
			self:SetStatusEnd(ct + self:GetStat("ProceduralHolsterTime") / self:GetAnimationRate(ACT_VM_HOLSTER))
		end

		return false
	elseif stat == TFA.Enum.STATUS_HOLSTER_READY or stat == TFA.Enum.STATUS_HOLSTER_FINAL then
		self.InspectingProgress = 0
		self:ResetViewModelModifications()

		return true
	end
end

function SWEP:FinishHolster()
	self:CleanParticles()
	local v2 = hook.Run("TFA_Holster", self)
	self.InspectingProgress = 0
	if self.Owner:IsNPC() then return end
	if v2 ~= nil then return v2 end

	if SERVER then
		local ent = self:GetSwapTarget()
		self:Holster(ent)

		if IsValid(ent) and ent:IsWeapon() then
			self:GetOwner():SelectWeapon(ent:GetClass())
			self.OwnerViewModel = nil
		end
	end
end

--[[
Function Name:  OnRemove
Syntax: self:OnRemove()
Notes:  Resets bone mods and cleans up.
Returns:  Nil.
Purpose:  Standard SWEP Function
]]
function SWEP:OnRemove()
	if self.CleanParticles then
		self:CleanParticles()
	end

	if self.ResetViewModelModifications then
		self:ResetViewModelModifications()
	end

	return hook.Run("TFA_OnRemove",self)
end

--[[
Function Name:  OnDrop
Syntax: self:OnDrop()
Notes:  Resets bone mods and cleans up.
Returns:  Nil.
Purpose:  Standard SWEP Function
]]
function SWEP:OnDrop()
	if self.CleanParticles then
		self:CleanParticles()
	end

	-- if self.ResetViewModelModifications then
	-- 	self:ResetViewModelModifications()
	-- end

	return hook.Run("TFA_OnDrop",self)
end

function SWEP:OwnerChanged() -- TODO: sometimes not called after switching weapon ???
	if not IsValid(self:GetOwner()) and self.ResetViewModelModifications then
		self:ResetViewModelModifications()
	end
end

--[[
Function Name:  Think
Syntax: self:Think()
Returns:  Nothing.
Notes:  This is blank.
Purpose:  Standard SWEP Function
]]
function SWEP:Think()
	if self:OwnerIsValid() and self:GetOwner():IsNPC() then
		if SERVER then
			if self.ThinkNPC then self:ThinkNPC() end

			if self:GetOwner():GetClass() == "npc_combine_s" then
				if self:GetOwner():GetActivity() == 16 then
					self:PrimaryAttack()
				end
			else
				if self:GetOwner():GetActivity() == 11 then
					self:PrimaryAttack()
				end
			end
		end

		return
	end
end

function SWEP:PlayerThink(plyv)
	if self:GetOwner():IsNPC() then
		return
	end

	ft = TFA.FrameTime()

	if not self:NullifyOIV() then return end

	self:Think2()

	if SERVER then
		self:CalculateRatios()
	end
end

function SWEP:PlayerThinkCL(plyv)
	if self:GetOwner():IsNPC() then
		return
	end

	ft = TFA.FrameTime()

	if not self:NullifyOIV() then return end

	self:SmokePCFLighting()
	self:CalculateRatios(true)

	if sp then
		self:Think2()
	end

	if self:GetStat("BlowbackEnabled") then
		if not self.Blowback_PistolMode or self:Clip1() == -1 or self:Clip1() > 0.1 or self.Blowback_PistolMode_Disabled[ self:GetLastActivity() ] then
			self.BlowbackCurrent = l_mathApproach(self.BlowbackCurrent, 0, self.BlowbackCurrent * ft * 15)
		end

		self.BlowbackCurrentRoot = l_mathApproach(self.BlowbackCurrentRoot, 0, self.BlowbackCurrentRoot * ft * 15)
	end
end

--[[
Function Name:  Think2
Syntax: self:Think2().  Called from Think.
Returns:  Nothing.
Notes:  Essential for calling other important functions.
Purpose:  Standard SWEP Function
]]
local CT, is, spr, wlk, cst, waittime, sht, lact, finalstat

function SWEP:Think2()
	CT = CurTime()

	if self.LuaShellRequestTime > 0 and CT > self.LuaShellRequestTime then
		self.LuaShellRequestTime = -1
		self:MakeShell()
	end

	if not self.HasInitialized then
		self:Initialize()
	end

	if not self.HasDetectedValidAnimations then
		self:CacheAnimations()
		self:ChooseDrawAnim()
	end
	self:InitAttachments()
	self:ProcessBodygroups()
	self:ProcessEvents()
	self:ProcessFireMode()
	self:ProcessHoldType()
	self:ReloadCV()
	self:IronSightSounds()
	self:ProcessLoopSound()
	is, spr, wlk, cst = self:IronSights()
	if stat == TFA.Enum.STATUS_FIDGET and is then
		self:SetStatusEnd(0)
		self.Idle_Mode_Old = self.Idle_Mode
		self.Idle_Mode = TFA.Enum.IDLE_BOTH
		self:ChooseIdleAnim()
		if sp then
			self:CallOnClient("ChooseIdleAnim","")
		end
		self.Idle_Mode = self.Idle_Mode_Old
		self.Idle_Mode_Old = nil
		statend = -1
	end
	is = self:GetIronSights()
	ct = l_ct()
	stat = self:GetStatus()
	statend = self:GetStatusEnd()

	if stat ~= TFA.Enum.STATUS_IDLE and ct > statend then
		finalstat = TFA.Enum.STATUS_IDLE

		if stat == TFA.Enum.STATUS_HOLSTER then--Holstering
			finalstat = TFA.Enum.STATUS_HOLSTER_READY
			self:SetStatusEnd(ct + 0.0)
		elseif stat == TFA.Enum.STATUS_HOLSTER_READY then
			self:FinishHolster()
			finalstat = TFA.Enum.STATUS_HOLSTER_FINAL
			self:SetStatusEnd(ct + 0.6)
		elseif stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_START_SHELL then--Shotgun Reloading from empty
			if not self:IsJammed() then
				self:TakePrimaryAmmo(1, true)
				self:TakePrimaryAmmo(-1)
			end

			if self:Ammo1() <= 0 or self:Clip1() >= self:GetPrimaryClipSize() or self:GetShotgunCancel() then
				finalstat = TFA.Enum.STATUS_RELOADING_SHOTGUN_END
				local _,tanim = self:ChooseShotgunPumpAnim()
				self:SetStatusEnd(ct + self:GetActivityLength( tanim ))
				self:SetShotgunCancel( false )

				if not self:GetShotgunCancel() then
					self:SetJammed(false)
				end
			else
				waittime = self:GetActivityLength( self:GetLastActivity(), false ) - self:GetActivityLength( self:GetLastActivity(), true )
				if waittime > 0.01 then
					finalstat = TFA.GetStatus("reloading_wait")
					self:SetStatusEnd( CT + waittime )
				else
					finalstat = self:LoadShell()
				end

				self:SetJammed(false)
				--finalstat = self:LoadShell()
				--self:SetStatusEnd( self:GetNextPrimaryFire() )
			end
		elseif stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_START then--Shotgun Reloading
			finalstat = self:LoadShell()
		elseif stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_LOOP then
			self:TakePrimaryAmmo(1,true)
			self:TakePrimaryAmmo(-1)
			lact = self:GetLastActivity()
			if self:GetActivityLength(lact,true) < self:GetActivityLength(lact,false) - 0.01 then
				sht = self:GetStat("ShellTime")
				if sht then sht = sht / self:GetAnimationRate(ACT_VM_RELOAD) end
				waittime = ( sht or self:GetActivityLength( lact , false ) ) -  self:GetActivityLength( lact , true )
			else
				waittime = 0
			end
			if waittime > 0.01 then
				finalstat = TFA.GetStatus("reloading_wait")
				self:SetStatusEnd( CT + waittime )
			else
				if self:Ammo1() <= 0 or self:Clip1() >= self:GetPrimaryClipSize() or self:GetShotgunCancel() then
					finalstat = TFA.Enum.STATUS_RELOADING_SHOTGUN_END
					local _,tanim = self:ChooseShotgunPumpAnim()
					self:SetStatusEnd(ct + self:GetActivityLength( tanim ))
					self:SetShotgunCancel( false )
				else
					finalstat = self:LoadShell()
				end
			end
		elseif stat == TFA.Enum.STATUS_RELOADING then
			self:CompleteReload()
			waittime = self:GetActivityLength( self:GetLastActivity(), false ) - self:GetActivityLength( self:GetLastActivity(), true )
			if waittime > 0.01 then
				finalstat = TFA.GetStatus("reloading_wait")
				self:SetStatusEnd( CT + waittime )
			end
			--self:SetStatusEnd( self:GetNextPrimaryFire() )
		elseif stat == TFA.Enum.STATUS_SILENCER_TOGGLE then
			self:SetSilenced( not self:GetSilenced() )
			self.Silenced = self:GetSilenced()
		elseif stat == TFA.GetStatus("reloading_wait") and self.Shotgun then
			if self:Ammo1() <= 0 or self:Clip1() >= self:GetPrimaryClipSize() or self:GetShotgunCancel() then
				finalstat = TFA.Enum.STATUS_RELOADING_SHOTGUN_END
				local _,tanim = self:ChooseShotgunPumpAnim()
				self:SetStatusEnd(ct + self:GetActivityLength( tanim ))
				--self:SetShotgunCancel( false )
			else
				finalstat = self:LoadShell()
			end
		elseif stat == TFA.GetStatus("reloading_shotgun_end") and self.Shotgun then
			self:SetShotgunCancel( false )
		elseif self:GetStat("PumpAction") and stat == TFA.GetStatus("pump") then
			self:SetShotgunCancel( false )
		elseif stat == TFA.GetStatus("shooting") and self:GetStat("PumpAction") then
			if self:Clip1() == 0 and self:GetStat("PumpAction").value_empty then
				--finalstat = TFA.GetStatus("pump_ready")
				self:SetShotgunCancel( true )
			elseif ( self:GetStat("Primary.ClipSize") < 0 or self:Clip1() > 0 ) and self:GetStat("PumpAction").value then
				--finalstat = TFA.GetStatus("pump_ready")
				self:SetShotgunCancel( true )
			end
			--self:SetStatusEnd( math.huge )
		end

		self:SetStatus(finalstat)

		local smi = self.Sights_Mode == TFA.Enum.LOCOMOTION_HYBRID or self.Sights_Mode == TFA.Enum.LOCOMOTION_ANI
		local spi = self.Sprint_Mode == TFA.Enum.LOCOMOTION_HYBRID or self.Sprint_Mode == TFA.Enum.LOCOMOTION_ANI
		local wmi = self.Walk_Mode == TFA.Enum.LOCOMOTION_HYBRID or self.Walk_Mode == TFA.Enum.LOCOMOTION_ANI
		local cmi = self.Customize_Mode == TFA.Enum.LOCOMOTION_HYBRID or self.Customize_Mode == TFA.Enum.LOCOMOTION_ANI

		if ( not TFA.Enum.ReadyStatus[stat] ) and stat ~= TFA.GetStatus("shooting") and stat ~= TFA.GetStatus("pump") and finalstat == TFA.Enum.STATUS_IDLE and ( (smi or spi) or (cst and cmi) ) then
			is = self:GetIronSights( true )
			if ( is and smi ) or ( spr and spi ) or ( wlk and wmi ) or ( cst and cmi ) then
				local success,_ = self:Locomote(is and smi, is, spr and spi, spr, wlk and wmi, wlk, cst and cmi, cst)
				if success == false then
					self:SetNextIdleAnim(-1)
				else
					self:SetNextIdleAnim(math.max(self:GetNextIdleAnim(),CT + 0.1))
				end
			end
		end
		self.LastBoltShoot = nil
		if self:GetBurstCount() > 0 then
			if finalstat ~= TFA.Enum.STATUS_SHOOTING and finalstat ~= TFA.Enum.STATUS_IDLE then
				self:SetBurstCount(0)
			elseif self:GetBurstCount() < self:GetMaxBurst() and self:Clip1() > 0 then
				self:PrimaryAttack()
			else
				self:SetBurstCount(0)
				self:SetNextPrimaryFire( CT + self:GetBurstDelay() )
			end
		end
	end

	if stat == TFA.Enum.STATUS_IDLE and self:GetShotgunCancel() then
		if self:GetStat("PumpAction") then
			if CT > self:GetNextPrimaryFire() and not self:GetOwner():KeyDown(IN_ATTACK) then
				self:DoPump()
			end
		else
			self:SetShotgunCancel( false )
		end
	end

	self:ProcessLoopFire()

	if ( ( TFA.Enum.ReadyStatus[stat]
		or (stat == TFA.Enum.STATUS_SHOOTING and TFA.Enum.ShootLoopingStatus[self:GetShootStatus()] ) )
		and ct > self:GetNextIdleAnim() ) then
		self:ChooseIdleAnim()
	end
end

local issighting, issprinting, iswalking, iscustomizing = false, false, false, false
SWEP.spr_old = false
SWEP.is_old = false
SWEP.walk_old = false
SWEP.cust_old = false
local issighting_tmp
local ironsights_toggle_cvar, ironsights_resight_cvar
local sprint_cv = GetConVar("sv_tfa_sprint_enabled")
if CLIENT then
	ironsights_resight_cvar = GetConVar("cl_tfa_ironsights_resight")
	ironsights_toggle_cvar = GetConVar("cl_tfa_ironsights_toggle")
end

function SWEP:IronSights()
	if self.Owner:IsNPC() then
		return
	end

	ct = l_CT()
	stat = self:GetStatus()
	local owent = self:GetOwner()
	if not IsValid(owent) then return end

	issighting = false
	issprinting = false
	iswalking = false
	iscustomizing = false
	self.is_old = self:GetIronSightsRaw()
	self.spr_old = self:GetSprinting()
	self.walk_old = self:GetWalking()
	self.cust_old = self:GetCustomizing()
	if sprint_cv:GetBool() and not self:GetStat("AllowSprintAttack", false) then
		issprinting = owent:GetVelocity():Length2D() > owent:GetRunSpeed() * 0.6 and owent:IsSprinting() and owent:OnGround()
	end

	if (SERVER or not sp) and self:GetStat("data.ironsights") ~= 0 then
		if (CLIENT and not ironsights_toggle_cvar:GetBool()) or owent:GetInfoNum("cl_tfa_ironsights_toggle", 0) == 0 then
			if owent:KeyDown(IN_ATTACK2) then
				issighting = true
			end
		else
			issighting = self:GetIronSightsRaw()

			if owent:KeyPressed(IN_ATTACK2) then
				issighting = not issighting
				self:SetIronSightsRaw(issighting)
			end
		end
	end

	if CLIENT and sp then
		issighting = self:GetIronSightsRaw()
	end

	if ( ( CLIENT and ironsights_toggle_cvar:GetBool() ) or ( SERVER and owent:GetInfoNum("cl_tfa_ironsights_toggle", 0) == 1 ) ) and not ( ( CLIENT and ironsights_resight_cvar:GetBool() ) or ( SERVER and owent:GetInfoNum("cl_tfa_ironsights_resight", 0) == 1 ) ) then
		if issprinting then
			issighting = false
		end

		if not TFA.Enum.IronStatus[stat] then
			issighting = false
		end
		if self:GetStat("BoltAction") or self:GetStat("BoltAction_Forced") then
			if stat == TFA.Enum.STATUS_SHOOTING then
				if not self.LastBoltShoot then
					self.LastBoltShoot = CurTime()
				end

				if CurTime() > self.LastBoltShoot + self.BoltTimerOffset then
					issighting = false
				end
			elseif (stat == TFA.Enum.STATUS_IDLE and self:GetShotgunCancel(true)) or stat == TFA.Enum.STATUS_PUMP then
				issighting = false
			else
				self.LastBoltShoot = nil
			end
		end
	end

	if TFA.Enum.ReloadStatus[stat] then
		issprinting = false
	end

	if issighting and owent:InVehicle() and not owent:GetAllowWeaponsInVehicle() then
		issighting = false
		self:SetIronSightsRaw(false)
	end

	self.is_cached = nil

	if ( issighting or issprinting or stat ~= TFA.Enum.STATUS_IDLE ) and self.Inspecting then
		--if gui then
		--  gui.EnableScreenClicker(false)
		--end
		self.Inspecting = false
	end

	if (self.is_old ~= issighting) then
		self:SetIronSightsRaw(issighting)
	end

	issighting_tmp = issighting

	if issprinting then
		issighting = false
	end

	if not TFA.Enum.IronStatus[stat] then
		issighting = false
	end

	if self:IsSafety() then
		issighting = false
		--issprinting = true
	end

	if self:GetStat("BoltAction") or self:GetStat("BoltAction_Forced") then
		if stat == TFA.Enum.STATUS_SHOOTING then
			if not self.LastBoltShoot then
				self.LastBoltShoot = CurTime()
			end

			if CurTime() > self.LastBoltShoot + self.BoltTimerOffset then
				issighting = false
			end
		elseif (stat == TFA.Enum.STATUS_IDLE and self:GetShotgunCancel(true)) or stat == TFA.Enum.STATUS_PUMP then
			issighting = false
		else
			self.LastBoltShoot = nil
		end
	end

	if (self.is_old_final ~= issighting) and self.Sights_Mode == TFA.Enum.LOCOMOTION_LUA then--and stat == TFA.Enum.STATUS_IDLE then
		self:SetNextIdleAnim(-1)
	end

	iscustomizing = self.Inspecting
	iswalking = owent:GetVelocity():Length2D() > (owent:GetWalkSpeed() * self:GetStat("MoveSpeed", 1) * .75) and owent:GetNW2Bool("TFA_IsWalking") and owent:OnGround() and not issprinting and not iscustomizing

	local smi = ( self.Sights_Mode == TFA.Enum.LOCOMOTION_HYBRID or self.Sights_Mode == TFA.Enum.LOCOMOTION_ANI ) and self.is_old_final ~= issighting
	local spi = ( self.Sprint_Mode == TFA.Enum.LOCOMOTION_HYBRID or self.Sprint_Mode == TFA.Enum.LOCOMOTION_ANI ) and self.spr_old ~= issprinting
	local wmi = ( self.Walk_Mode == TFA.Enum.LOCOMOTION_HYBRID or self.Walk_Mode == TFA.Enum.LOCOMOTION_ANI ) and self.walk_old ~= iswalking
	local cmi = ( self.Customize_Mode == TFA.Enum.LOCOMOTION_HYBRID or self.Customize_Mode == TFA.Enum.LOCOMOTION_ANI ) and self.cust_old ~= iscustomizing

	if ( smi or spi or wmi or cmi ) and ( self:GetStatus() == TFA.Enum.STATUS_IDLE or ( self:GetStatus() == TFA.Enum.STATUS_SHOOTING and self:CanInterruptShooting() ) ) and not self:GetShotgunCancel() then
		local toggle_is = self.is_old ~= issighting
		if issighting and self.spr_old ~= issprinting then
			toggle_is = true
		end
		local success,_ = self:Locomote(toggle_is and (self.Sights_Mode ~= TFA.Enum.LOCOMOTION_LUA), issighting, spi, issprinting, wmi, iswalking, cmi, iscustomizing)

		if ( not success ) and ( ( toggle_is and smi ) or spi or wmi or cmi ) then
			self:SetNextIdleAnim(-1)
		end
	end

	if (self.spr_old ~= issprinting) then
		self:SetSprinting(issprinting)
	end

	if (self.walk_old ~= iswalking) then
		self:SetWalking(iswalking)
	end

	if (self.cust_old ~= iscustomizing) then
		self:SetCustomizing(iscustomizing)
	end

	self.is_old_final = issighting

	return issighting_tmp, issprinting, iswalking, iscustomizing
end

SWEP.is_cached = nil
SWEP.is_cached_old = false

function SWEP:GetIronSights( ignorestatus )
	if self.Owner:IsNPC() then
		return
	end
	if ignorestatus then
		issighting = self:GetIronSightsRaw()
		issprinting = self:GetSprinting()
		if issprinting then
			issighting = false
		end

		if self:GetStat("BoltAction") or self:GetStat("BoltAction_Forced") then
			if stat == TFA.Enum.STATUS_SHOOTING then
				if not self.LastBoltShoot then
					self.LastBoltShoot = CurTime()
				end

				if CurTime() > self.LastBoltShoot + self.BoltTimerOffset then
					issighting = false
				end
			elseif (stat == TFA.Enum.STATUS_IDLE and self:GetShotgunCancel(true)) or stat == TFA.Enum.STATUS_PUMP then
				issighting = false
			else
				self.LastBoltShoot = nil
			end
		end

		return issighting
	end
	if self.is_cached == nil then
		issighting = self:GetIronSightsRaw()
		issprinting = self:GetSprinting()
		stat = self:GetStatus()
		if issprinting then
			issighting = false
		end

		if not TFA.Enum.IronStatus[stat] then
			issighting = false
		end

		if self:GetStat("BoltAction") or self:GetStat("BoltAction_Forced") then
			if stat == TFA.Enum.STATUS_SHOOTING then
				if not self.LastBoltShoot then
					self.LastBoltShoot = CurTime()
				end

				if CurTime() > self.LastBoltShoot + self.BoltTimerOffset then
					issighting = false
				end
			elseif (stat == TFA.Enum.STATUS_IDLE and self:GetShotgunCancel(true)) or stat == TFA.Enum.STATUS_PUMP then
				issighting = false
			else
				self.LastBoltShoot = nil
			end
		end

		self.is_cached = issighting

		--[[
		if (self.is_cached_old ~= issighting) and not ( sp and CLIENT ) then
			if (issighting == false) then--and ((CLIENT and IsFirstTimePredicted()) or (SERVER and sp)) then
				self:EmitSound(self.IronOutSound or "TFA.IronOut")
			elseif issighting == true then--and ((CLIENT and IsFirstTimePredicted()) or (SERVER and sp)) then
				self:EmitSound(self.IronInSound or "TFA.IronIn")
			end
		end
		]]--

		self.is_cached_old = self.is_cached
	end

	return self.is_cached
end

function SWEP:GetIronSightsDirect()
	if self.is_cached then
		return true
	end
	return false
end

SWEP.is_sndcache_old = false

function SWEP:IronSightSounds()
	if self.Owner:IsNPC() then
		return
	end
	is = self:GetIronSights()
	if SERVER or ( CLIENT and IsFirstTimePredicted() ) then
		if is ~= self.is_sndcache_old and hook.Run("TFA_IronSightSounds",self) == nil then
			if is then
				self:EmitSound(self:GetStat("IronInSound", "TFA.IronIn"))
			else
				self:EmitSound(self:GetStat("IronOutSound", "TFA.IronOut"))
			end
		end
		self.is_sndcache_old = is
	end
end

local legacy_reloads_cv = GetConVar("sv_tfa_reloads_legacy")
local dryfire_cvar = GetConVar("sv_tfa_allow_dryfire")

SWEP.Primary.Sound_DryFire = Sound("Weapon_Pistol.Empty2") -- dryfire sound, played only once
SWEP.Primary.Sound_DrySafety = Sound("Weapon_AR2.Empty2") -- safety click sound
SWEP.Primary.Sound_Blocked = Sound("Weapon_AR2.Empty") -- underwater click sound
SWEP.Primary.Sound_Jammed = Sound("Default.ClipEmpty_Rifle") -- jammed click sound

function SWEP:CanPrimaryAttack( )
	local v = hook.Run("TFA_PreCanPrimaryAttack",self)
	if v ~= nil then
		return v
	end
	if self.Owner:IsNPC() and SERVER then
		if CurTime() < self:GetNextPrimaryFire() then
			return false
		end
		return true
	end

	stat = self:GetStatus()
	if not TFA.Enum.ReadyStatus[stat] and stat ~= TFA.Enum.STATUS_SHOOTING then
		if self.Shotgun and TFA.Enum.ReloadStatus[stat] then
			self:SetShotgunCancel( true )
		end
		return false
	end

	if self:IsSafety() then
		self:EmitSound(self:GetStat("Primary.Sound_DrySafety"))
		self.LastSafetyShoot = self.LastSafetyShoot or 0

		if l_CT() < self.LastSafetyShoot + 0.2 then
			self:CycleSafety()
			self:SetNextPrimaryFire(l_CT() + 0.1)
		end

		self.LastSafetyShoot = l_CT()

		return
	end

	if self:GetStat("Primary.ClipSize") <= 0 and self:Ammo1() < self:GetStat("Primary.AmmoConsumption") then
		return false
	end

	if self:GetSprinting() and not self:GetStat("AllowSprintAttack", false) then
		return false
	end

	if self:GetPrimaryClipSize(true) > 0 and self:Clip1() < self:GetStat("Primary.AmmoConsumption") then
		if self:GetOwner():KeyPressed(IN_ATTACK) then
			local enabled, act = self:ChooseDryFireAnim()

			if enabled then
				self:SetNextPrimaryFire(l_CT() + self:GetStat("Primary.DryFireDelay", self:GetActivityLength(act, true)))

				return false
			end
		end

		if not self.HasPlayedEmptyClick then
			self:EmitSound(self:GetStat("Primary.Sound_DryFire"))

			if not dryfire_cvar:GetBool() then
				self:Reload( true )
			end

			self.HasPlayedEmptyClick = true
		end

		return false
	end

	if self.FiresUnderwater == false and self:GetOwner():WaterLevel() >= 3 then
		self:SetNextPrimaryFire(l_CT() + 0.5)
		self:EmitSound(self:GetStat("Primary.Sound_Blocked"))
		return false
	end

	self.HasPlayedEmptyClick = false

	if CurTime() < self:GetNextPrimaryFire() then return false end

	local v2 = hook.Run("TFA_CanPrimaryAttack",self)

	if v2 ~= nil then
		return v2
	end

	if self:CheckJammed() then
		if IsFirstTimePredicted() then
			self:EmitSound(self:GetStat("Primary.Sound_Jammed"))
		end

		local typev, tanim = self:ChooseAnimation("shoot1_empty")

		if typev ~= TFA.Enum.ANIMATION_SEQ then
			self:SendViewModelAnim(tanim)
		else
			self:SendViewModelSeq(tanim)
		end

		self:SetNextPrimaryFire(CurTime() + 1)

		return false
	end

	return true
end
local npc_ar2_damage_cv = GetConVar("sk_npc_dmg_ar2")

local sv_tfa_nearlyempty = GetConVar("sv_tfa_nearlyempty")

SWEP.Primary.Sound_NearlyEmpty = Sound("TFA.NearlyEmpty") -- cs:go-like nearly-empty mag click sound

function SWEP:EmitGunfireLoop()
	local tgtSound = self:GetSilenced() and self:GetStat("Primary.LoopSoundSilenced", self:GetStat("Primary.LoopSound")) or self:GetStat("Primary.LoopSound")

	if self:GetNextLoopSoundCheck() < 0 or (CurTime() >= self:GetNextLoopSoundCheck() and self.LastLoopSound ~= tgtSound) then
		if self.LastLoopSound ~= tgtSound and self.LastLoopSound ~= nil then
			self:StopSound(self.LastLoopSound)
		end

		self.LastLoopSound = tgtSound

		self:EmitSound(tgtSound)
	end

	self:SetNextLoopSoundCheck(CurTime() + self:GetFireDelay())

	if not sv_tfa_nearlyempty:GetBool() then return end

	if not self.FireSoundAffectedByClipSize or self.Shotgun then return end

	local clip1, maxclip1 = self:Clip1(), self:GetMaxClip1()

	if maxclip1 <= 4 or maxclip1 >= 70 or clip1 <= 0 then return end

	local mult = clip1 / maxclip1
	if mult >= 0.3 or mult <= 0 then return end

	local pitch = 0.8 + math.min(0.02 / mult, 0.4)

	self.GonnaAdjuctPitch = true
	self.RequiredPitch = pitch

	self:EmitSound(self:GetStat("Primary.Sound_NearlyEmpty"), "TFA.NearlyEmpty")
end

function SWEP:EmitGunfireSound(soundscript)
	if not self.FireSoundAffectedByClipSize or self.Shotgun then
		return self:EmitSound(soundscript)
	end

	local clip1, maxclip1 = self:Clip1(), self:GetMaxClip1()

	if maxclip1 <= 4 or maxclip1 >= 70 then
		return self:EmitSound(soundscript)
	end

	if clip1 <= 0 then
		return self:EmitSound(soundscript)
	end

	local mult = clip1 / maxclip1
	if mult >= 0.3 or mult <= 0 then return self:EmitSound(soundscript) end

	local pitch = 0.8 + math.min(0.02 / mult, 0.4)

	self:EmitSound(soundscript)

	if not sv_tfa_nearlyempty:GetBool() then return end

	self.GonnaAdjuctPitch = true
	self.RequiredPitch = pitch

	self:EmitSound(self:GetStat("Primary.Sound_NearlyEmpty"), "TFA.NearlyEmpty")
end

function SWEP:PrimaryAttack()
	self:PrePrimaryAttack()
	if self.Owner:IsNPC() then
		if self:Clip1() <= 0 then
			if SERVER then
				self.Owner:SetSchedule(SCHED_RELOAD)
			end

			return
		end

		if SERVER and CurTime() < self:GetNextPrimaryFire() then return false end

		local times_to_fire = 2

		if self.OnlyBurstFire then
			times_to_fire = 3
		end

		if self.Primary.Automatic then
			times_to_fire = math.random(5, 8)
		end

		self:SetNextPrimaryFire(CurTime() + (((self.Primary.RPM / 60) / 100) * times_to_fire) + math.random(0.2, 0.6))

		timer.Create("GunTimer" .. tostring(self:GetOwner():EntIndex()), (self.Primary.RPM / 60) / 100, times_to_fire, function()
			if not IsValid(self) then return end
			if not IsValid(self.Owner) then return end
			if not self:GetOwner().GetShootPos then return end
			self:EmitGunfireSound(self.Primary.Sound)
			self:TakePrimaryAmmo(1)
			local damage_to_do = self.Primary.Damage * npc_ar2_damage_cv:GetFloat() / 16
			local bullet = {}
			bullet.Num = self.Primary.NumShots
			bullet.Src = self.Owner:GetShootPos()
			bullet.Dir = self.Owner:GetAimVector()
			bullet.Tracer = 1
			bullet.Damage = damage_to_do
			bullet.AmmoType = self.Primary.Ammo
			self.Owner:FireBullets(bullet)
		end)

		return
	end

	if not IsValid(self) then return end
	if not self:VMIV() then return end
	if not self:CanPrimaryAttack() then return end
	if hook.Run("TFA_PrimaryAttack",self) then return end
	if TFA.Enum.ShootReadyStatus[self:GetShootStatus()] then
		self:SetShootStatus(TFA.Enum.SHOOT_IDLE)
	end

	if self.CanBeSilenced and self:GetOwner():KeyDown(IN_USE) and (SERVER or not sp) then
		self:ChooseSilenceAnim(not self:GetSilenced())
		local _, tanim = self:SetStatus(TFA.Enum.STATUS_SILENCER_TOGGLE)
		self:SetStatusEnd(l_CT() + self:GetActivityLength(tanim, true))

		return
	end

	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())

	if self:GetMaxBurst() > 1 then
		self:SetBurstCount(math.max(1, self:GetBurstCount() + 1))
	end

	if self:GetStat("PumpAction") and self:GetShotgunCancel() then return end
	self:SetStatus(TFA.Enum.STATUS_SHOOTING)
	self:SetStatusEnd(self:GetNextPrimaryFire())
	self:ToggleAkimbo()
	local _, tanim = self:ChooseShootAnim()

	if (not sp) or (not self:IsFirstPerson()) then
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	end

	if self:GetStat("Primary.Sound") and IsFirstTimePredicted() and not (sp and CLIENT) then
		if self:GetOwner():IsPlayer() and self:GetStat("Primary.LoopSound") and (not self:GetStat("Primary.LoopSoundAutoOnly", false) or self.Primary.Automatic) then
			self:EmitGunfireLoop()
		elseif self:GetStat("Primary.SilencedSound") and self:GetSilenced() then
			self:EmitGunfireSound(self:GetStat("Primary.SilencedSound"))
		else
			self:EmitGunfireSound(self:GetStat("Primary.Sound"))
		end
	end

	self:TakePrimaryAmmo(self:GetStat("Primary.AmmoConsumption"))

	if self:Clip1() == 0 and self:GetStat("Primary.ClipSize") > 0 then
		self:SetNextPrimaryFire(math.max(self:GetNextPrimaryFire(), CurTime() + (self.Primary.DryFireDelay or self:GetActivityLength(tanim, true))))
	end

	self:ShootBulletInformation()
	self:UpdateJamFactor()
	local _, CurrentRecoil = self:CalculateConeRecoil()
	self:Recoil(CurrentRecoil, IsFirstTimePredicted())

	if sp and SERVER then
		self:CallOnClient("Recoil", "")
	end

	if self.MuzzleFlashEnabled and (not self:IsFirstPerson() or not self.AutoDetectMuzzleAttachment) then
		self:ShootEffectsCustom()
	end

	if self.EjectionSmoke and CLIENT and self:GetOwner() == LocalPlayer() and IsFirstTimePredicted() and not self.LuaShellEject then
		self:EjectionSmoke()
	end

	self:DoAmmoCheck()

	if self:GetStatus() == TFA.GetStatus("shooting") and self:GetStat("PumpAction") then
		if self:Clip1() == 0 and self:GetStat("PumpAction").value_empty then
			--finalstat = TFA.GetStatus("pump_ready")
			self:SetShotgunCancel(true)
		elseif (self:GetStat("Primary.ClipSize") < 0 or self:Clip1() > 0) and self:GetStat("PumpAction").value then
			--finalstat = TFA.GetStatus("pump_ready")
			self:SetShotgunCancel(true)
		end
	end

	if IsFirstTimePredicted() then
		self:RollJamChance()
	end

	self:PostPrimaryAttack()
	hook.Run("TFA_PostPrimaryAttack",self)
end

function SWEP:PrePrimaryAttack()
end

function SWEP:PostPrimaryAttack()
end

function SWEP:CanSecondaryAttack()
end

function SWEP:SecondaryAttack()
	self:PreSecondaryAttack()
	if hook.Run("TFA_SecondaryAttack",self) then return end
	if self.Owner:IsNPC() then
		return
	end
	if self:GetStat("data.ironsights", 0) == 0 and self.AltAttack then
		self:AltAttack()
		self:PostSecondaryAttack()
		return
	end
	self:PostSecondaryAttack()
end

function SWEP:PreSecondaryAttack()
end

function SWEP:PostSecondaryAttack()
end

function SWEP:GetLegacyReloads()
	return legacy_reloads_cv:GetBool()
end

function SWEP:Reload(released)
	self:PreReload(released)
	if hook.Run("TFA_PreReload",self,released) then return end

	if self.Owner:IsNPC() then
		return
	end

	if not self:VMIV() then return end

	if not self:IsJammed() then
		if self:Ammo1() <= 0 then return end
		if self:GetStat("Primary.ClipSize") < 0 then return end
	end

	if ( not released ) and ( not self:GetLegacyReloads() ) then return end
	if self:GetLegacyReloads() and not dryfire_cvar:GetBool() and not self:GetOwner():KeyDown(IN_RELOAD) then return end
	if self:GetOwner():KeyDown(IN_USE) then return end

	ct = l_CT()
	stat = self:GetStatus()

	if self:GetStat("PumpAction") and self:GetShotgunCancel() then
		if stat == TFA.Enum.STATUS_IDLE then
			self:DoPump()
		end
	elseif TFA.Enum.ReadyStatus[stat] or ( stat == TFA.Enum.STATUS_SHOOTING and self:CanInterruptShooting() ) or self:IsJammed() then
		if self:Clip1() < self:GetPrimaryClipSize() or self:IsJammed() then
			if hook.Run("TFA_Reload",self) then return end
			self:SetBurstCount(0)

			if self.Shotgun then
				local _, tanim = self:ChooseShotgunReloadAnim()
				if self:GetStat("ShotgunStartAnimShell") then
					self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START_SHELL)
				elseif self.ShotgunEmptyAnim then
					local _, tg = self:ChooseAnimation( "reload_empty" )
					local action = tanim
					if type(tg) == "string" and tonumber(tanim) and tonumber(tanim) > 0 then
						action = self.OwnerViewModel:GetSequenceName( self.OwnerViewModel:SelectWeightedSequenceSeeded( tanim, self:GetSeed() ) )
					end
					if action == tg and self:GetStat("ShotgunEmptyAnim_Shell") then
						self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START_SHELL)
					else
						self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START)
					end
				else
					self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START)
				end
				self:SetStatusEnd(ct + self:GetActivityLength( tanim, true ))
				--self:SetNextPrimaryFire(ct + self:GetActivityLength( tanim, false ) )
			else
				local _, tanim = self:ChooseReloadAnim()
				self:SetStatus(TFA.Enum.STATUS_RELOADING)
				if self:GetStat("ProceduralReloadEnabled") then
					self:SetStatusEnd(ct + self:GetStat("ProceduralReloadTime"))
				else
					self:SetStatusEnd(ct + self:GetActivityLength( tanim, true ) )
					self:SetNextPrimaryFire(ct + self:GetActivityLength( tanim, false ) )
				end
			end

			if ( not sp ) or ( not self:IsFirstPerson() ) then
				self:GetOwner():SetAnimation(PLAYER_RELOAD)
			end

			if self:GetStat("Primary.ReloadSound") and IsFirstTimePredicted() then
				self:EmitSound(self:GetStat("Primary.ReloadSound"))
			end

			self:SetNextPrimaryFire( -1 )
		elseif released or self:GetOwner():KeyPressed(IN_RELOAD) then--if self:GetOwner():KeyPressed(IN_RELOAD) or not self:GetLegacyReloads() then
			self:CheckAmmo()
		end
	end
	self:PostReload(released)
	hook.Run("TFA_PostReload",self)
end

function SWEP:PreReload(released)
end

function SWEP:PostReload(released)
end

function SWEP:Reload2(released)
	if self.Owner:IsNPC() then
		return
	end
	if not self:VMIV() then return end
	if self:Ammo2() <= 0 then return end
	if self:GetStat("Secondary.ClipSize") < 0 then return end
	if ( not released ) and ( not self:GetLegacyReloads() ) then return end
	if self:GetLegacyReloads() and not  dryfire_cvar:GetBool() and not self:GetOwner():KeyDown(IN_RELOAD) then return end
	if self:GetOwner():KeyDown(IN_USE) then return end

	ct = l_CT()
	stat = self:GetStatus()

	if self:GetStat("PumpAction") and self:GetShotgunCancel() then
		if stat == TFA.Enum.STATUS_IDLE then
			self:DoPump()
		end
	elseif TFA.Enum.ReadyStatus[stat] or ( stat == TFA.Enum.STATUS_SHOOTING and self:CanInterruptShooting() ) then
		if self:Clip2() < self:GetSecondaryClipSize() then
			if self.Shotgun then
				local _, tanim = self:ChooseShotgunReloadAnim()
				if self.ShotgunEmptyAnim  then
					local _, tg = self:ChooseAnimation( "reload_empty" )
					if tanim == tg and self.ShotgunEmptyAnim_Shell then
						self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START_SHELL)
					else
						self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START)
					end
				else
					self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START)
				end
				self:SetStatusEnd(ct + self:GetActivityLength( tanim, true ))
				--self:SetNextPrimaryFire(ct + self:GetActivityLength( tanim, false ) )
			else
				local _, tanim = self:ChooseReloadAnim()
				self:SetStatus(TFA.Enum.STATUS_RELOADING)
				if self:GetStat("ProceduralReloadEnabled") then
					self:SetStatusEnd(ct + self:GetStat("ProceduralReloadTime"))
				else
					self:SetStatusEnd(ct + self:GetActivityLength( tanim, true ) )
					self:SetNextPrimaryFire(ct + self:GetActivityLength( tanim, false ) )
				end
			end
			if ( not sp ) or ( not self:IsFirstPerson() ) then
				self:GetOwner():SetAnimation(PLAYER_RELOAD)
			end
			if self:GetStat("Secondary.ReloadSound") and IsFirstTimePredicted() then
				self:EmitSound(self:GetStat("Secondary.ReloadSound"))
			end
			self:SetNextPrimaryFire( -1 )
		elseif released or self:GetOwner():KeyPressed(IN_RELOAD) then--if self:GetOwner():KeyPressed(IN_RELOAD) or not self:GetLegacyReloads() then
			self:CheckAmmo()
		end
	end
end

function SWEP:DoPump()
	if hook.Run("TFA_Pump",self) then return end
	if self.Owner:IsNPC() then
		return
	end
	local _,tanim = self:PlayAnimation( self:GetStat("PumpAction") )
	self:SetStatus( TFA.GetStatus("pump") )
	self:SetStatusEnd( CurTime() + self:GetActivityLength( tanim, true ) )
	self:SetNextPrimaryFire( CurTime() + self:GetActivityLength( tanim, false ) )
	self:SetNextIdleAnim(math.max( self:GetNextIdleAnim(), CurTime() + self:GetActivityLength( tanim, false ) ))
end

function SWEP:LoadShell( )
	if hook.Run("TFA_LoadShell",self) then return end
	if self.Owner:IsNPC() then
		return
	end
	local _, tanim = self:ChooseReloadAnim()
	if self:GetActivityLength(tanim,true) < self:GetActivityLength(tanim,false) then
		self:SetStatusEnd(ct + self:GetActivityLength( tanim, true ) )
	else
		sht = self:GetStat("ShellTime")
		if sht then sht = sht / self:GetAnimationRate(ACT_VM_RELOAD) end
		self:SetStatusEnd(ct + ( sht or self:GetActivityLength( tanim, true ) ) )
	end
	return TFA.Enum.STATUS_RELOADING_SHOTGUN_LOOP
end

function SWEP:CompleteReload()
	if hook.Run("TFA_CompleteReload",self) then return end

	if self.Owner:IsNPC() then
		return
	end

	local maxclip = self:GetPrimaryClipSizeForReload(true)
	local curclip = self:Clip1()
	local amounttoreplace = math.min(maxclip - curclip, self:Ammo1())
	self:TakePrimaryAmmo(amounttoreplace * -1)
	self:TakePrimaryAmmo(amounttoreplace, true)
	self:SetJammed(false)
end


function SWEP:CheckAmmo()
	if hook.Run("TFA_CheckAmmo",self) then return end
	if self.Owner:IsNPC() then
		return
	end
	if self:GetIronSights() or self:GetSprinting() then return end

	--if self.NextInspectAnim == nil then
	--  self.NextInspectAnim = -1
	--end

	if self:GetOwner().GetInfoNum and self:GetOwner():GetInfoNum("cl_tfa_keys_inspect", 0) > 0 then
		return
	end

	if (self:GetActivityEnabled(ACT_VM_FIDGET) or self.InspectionActions) and self:GetStatus() == TFA.Enum.STATUS_IDLE then--and CurTime() > self.NextInspectAnim then
		local _, tanim = self:ChooseInspectAnim()
		self:SetStatus(TFA.GetStatus("fidget"))
		self:SetStatusEnd( l_CT() + self:GetActivityLength( tanim ) )
	end
end

local cv_strip = GetConVar("sv_tfa_weapon_strip")
function SWEP:DoAmmoCheck()
	if self.Owner:IsNPC() then
		return
	end
	if IsValid(self) and SERVER and cv_strip:GetBool() and self:Clip1() == 0 and self:Ammo1() == 0 then
		timer.Simple(.1, function()
			if SERVER and IsValid(self) and self:OwnerIsValid() then
				self:GetOwner():StripWeapon(self.ClassName)
			end
		end)
	end
end

--[[
Function Name:  AdjustMouseSensitivity
Syntax: Should not normally be called.
Returns:  SWEP sensitivity multiplier.
Purpose:  Standard SWEP Function
]]

local fovv
local sensval
local sensitivity_cvar, sensitivity_fov_cvar, sensitivity_speed_cvar
if CLIENT then
	sensitivity_cvar = GetConVar("cl_tfa_scope_sensitivity")
	sensitivity_fov_cvar = GetConVar("cl_tfa_scope_sensitivity_autoscale")
	sensitivity_speed_cvar = GetConVar("sv_tfa_scope_gun_speed_scale")
end

function SWEP:AdjustMouseSensitivity()
	sensval = 1

	if self:GetIronSights() then
		sensval = sensval * sensitivity_cvar:GetFloat() / 100

		if sensitivity_fov_cvar:GetBool() then
			fovv = self:GetStat("Secondary.IronFOV") or 70
			sensval = sensval * TFA.CalculateSensitivtyScale( fovv, nil, 1 )
		else
			sensval = sensval
		end

		if sensitivity_speed_cvar:GetFloat() then
			sensval = sensval * self:GetStat("IronSightsMoveSpeed")
		end
	end

	sensval = sensval * l_Lerp(self.IronSightsProgress, 1, self:GetStat( "IronSightsSensitivity" ) )
	return sensval
end

--[[
Function Name:  TranslateFOV
Syntax: Should not normally be called.  Takes default FOV as parameter.
Returns:  New FOV.
Purpose:  Standard SWEP Function
]]

local nfov
function SWEP:TranslateFOV(fov)
	if self.Owner:IsNPC() then
		return
	end

	self.LastTranslatedFOV = fov

	local retVal = hook.Run("TFA_PreTranslateFOV",self,fov)

	if retVal then return retVal end

	self:CorrectScopeFOV()

	nfov = l_Lerp(self.IronSightsProgress, fov, fov * math.min(self:GetStat("Secondary.IronFOV") / 90, 1))

	local ret = l_Lerp(self.SprintProgress, nfov, nfov + self.SprintFOVOffset)

	if self:OwnerIsValid() and not self.IsMelee then
		local vpa = self:GetOwner():GetViewPunchAngles()

		ret = ret + math.abs(vpa.p) / 4 + math.abs(vpa.y) / 4 + math.abs(vpa.r) / 4
	end

	ret = hook.Run("TFA_TranslateFOV",self,ret) or ret

	return ret
end

function SWEP:GetPrimaryAmmoType()
	return self:GetStat("Primary.Ammo") or ""
end

function SWEP:ToggleInspect()
	if self.Owner:IsNPC() then
		return
	end
	if self:GetSprinting() or self:GetIronSights() or self:GetStatus() ~= TFA.Enum.STATUS_IDLE then return end
	self.Inspecting = not self.Inspecting
	--if self.Inspecting then
	--  gui.EnableScreenClicker(true)
	--else
	--  gui.EnableScreenClicker(false)
	--end
end

function SWEP:EmitSoundNet(sound)
	if CLIENT or sp then
		if sp and not IsFirstTimePredicted() then return end

		self:EmitSound(sound)

		return
	end

	local filter = RecipientFilter()
	filter:AddPAS(self:GetPos())
	if IsValid(self:GetOwner()) then
		filter:RemovePlayer(self:GetOwner())
	end

	net.Start("tfaSoundEvent")
	net.WriteEntity(self)
	net.WriteString(sound)
	net.Send(filter)
end

function SWEP:CanBeJammed()
	return self.CanJam and self:GetMaxClip1() > 0 and sv_tfa_jamming:GetBool()
end

-- Use this to increase/decrease factor added based on ammunition/weather conditions/etc
function SWEP:GrabJamFactorMult()
	return 1
end

function SWEP:UpdateJamFactor()
	if not self:CanBeJammed() then return self end
	self:SetJamFactor(math.min(100, self:GetJamFactor() + self.JamFactor * sv_tfa_jamming_factor_inc:GetFloat() * self:GrabJamFactorMult()))
	return self
end

function SWEP:IsJammed()
	if not self:CanBeJammed() then return false end
	return self:GetJammed()
end

function SWEP:NotifyJam()
	local ply = self:GetOwner()

	if IsValid(ply) and ply:IsPlayer() and IsFirstTimePredicted() and (not ply._TFA_LastJamMessage or ply._TFA_LastJamMessage < RealTime()) then
		ply:PrintMessage(HUD_PRINTCENTER, "#tfa.msg.weaponjammed")
		ply._TFA_LastJamMessage = RealTime() + 4
	end
end

function SWEP:CheckJammed()
	if not self:IsJammed() then return false end
	self:NotifyJam()
	return true
end

function SWEP:RollJamChance()
	if not self:CanBeJammed() then return false end
	if self:IsJammed() then return true end
	local chance = self:GetJamChance()
	local roll = util.SharedRandom('tfa_base_jam', math.max(0.002711997795105, math.pow(chance, 1.19)), 1, CurTime())
	--print(chance, roll)

	if roll <= chance * sv_tfa_jamming_mult:GetFloat() then
		self:SetJammed(true)
		self:NotifyJam()
		return true
	end

	return false
end

function SWEP:GrabJamChanceMult()
	return 1
end

function SWEP:GetJamChance()
	if not self:CanBeJammed() then return 0 end
	return self:GetJamFactor() * sv_tfa_jamming_factor:GetFloat() * (self.JamChance / 100) * self:GrabJamChanceMult()
end

SWEP.FlashlightSoundToggleOn = Sound("HL2Player.FlashLightOn")
SWEP.FlashlightSoundToggleOff = Sound("HL2Player.FlashLightOff")

function SWEP:ToggleFlashlight(toState)
	if toState == nil then
		toState = not self:GetFlashlightEnabled()
	end

	self:SetFlashlightEnabled(toState)
	self:EmitSoundNet(self:GetStat("FlashlightSoundToggle" .. (toState and "On" or "Off")))
end

-- source engine save load
function SWEP:OnRestore()
	self.HasInitialized = false
	self.HasInitAttachments = false
end

function SWEP:ProcessLoopSound()
	if (SERVER or not sp) and (
			self:GetNextLoopSoundCheck() >= 0
			and ct > self:GetNextLoopSoundCheck()
			and self:GetStatus() ~= TFA.Enum.STATUS_SHOOTING
		) then

		self:SetNextLoopSoundCheck(-1)

		local tgtSound = self:GetSilenced() and self:GetStat("Primary.LoopSoundSilenced", self:GetStat("Primary.LoopSound")) or self:GetStat("Primary.LoopSound")

		self:StopSound(tgtSound)

		tgtSound = self:GetSilenced() and self:GetStat("Primary.LoopSoundTailSilenced", self:GetStat("Primary.LoopSoundTail")) or self:GetStat("Primary.LoopSoundTail")

		if tgtSound then
			self:EmitSound(tgtSound)
		end
	end
end

function SWEP:ProcessLoopFire()
	if game.SinglePlayer() and !IsFirstTimePredicted() then return end
	if (self:GetStatus() == TFA.Enum.STATUS_SHOOTING ) then
		if TFA.Enum.ShootLoopingStatus[self:GetShootStatus()] then
			self:SetShootStatus(TFA.Enum.SHOOT_LOOP)
		end
	else --not shooting
		if (!TFA.Enum.ShootReadyStatus[self:GetShootStatus()]) then
			if ( self:GetShootStatus() ~= TFA.Enum.SHOOT_CHECK ) then
				self:SetShootStatus(TFA.Enum.SHOOT_CHECK) --move to check first
			else --if we've checked for one more tick that we're not shooting
				self:SetShootStatus(TFA.Enum.SHOOT_IDLE) --move to check first
				if not ( self:GetSprinting() and self.Sprint_Mode ~= TFA.Enum.LOCOMOTION_LUA ) then --assuming we don't need to transition into sprint
					self:PlayAnimation(self:GetStat("ShootAnimation.out")) --exit
				end
			end
		end
	end
end