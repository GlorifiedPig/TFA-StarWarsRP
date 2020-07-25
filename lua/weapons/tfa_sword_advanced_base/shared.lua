
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

--[[
PLEASE DON TUSE THIS ANYMIRE
PLEASe
PLEASSSSSSSS
]]
DEFINE_BASECLASS("tfa_gun_base")
SWEP.Primary.Ammo = "" -- Required for GMod legacy purposes.  Don't remove unless you want to see your sword's ammo.  Wat?
SWEP.data = {} --Ignore this.
--[[SWEP Info]]
--
SWEP.Gun = "" -- must be the name of your swep but NO CAPITALS!
SWEP.Category = ""
SWEP.Base = "tfa_gun_base"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Left click to slash" .. "\n" .. "Hold right mouse to put up guard."
SWEP.PrintName = "Snowflake Katana" -- Weapon name (Shown on HUD)
SWEP.Slot = 0 -- Slot in the weapon selection menu
SWEP.SlotPos = 21 -- Position in the slot
SWEP.DrawAmmo = false -- Should draw the default HL2 ammo counter
SWEP.DrawWeaponInfoBox = true -- Should draw the weapon info box
SWEP.BounceWeaponIcon = false -- Should the weapon icon bounce?
SWEP.DrawCrosshair = false -- set false if you want no crosshair
SWEP.Weight = 50 -- rank relative ot other weapons. bigger is better
SWEP.AutoSwitchTo = true -- Auto switch to if we pick it up
SWEP.AutoSwitchFrom = true -- Auto switch from if you pick up a better weapon
SWEP.Secondary.IronFOV = 90 -- How much you "zoom" in. Less is more!  Don't have this be <= 0
SWEP.WeaponLength = 8 --16 = 1 foot
SWEP.MoveSpeed = 0.9 --Multiply the player's movespeed by this.
SWEP.IronSightsMoveSpeed = 0.8 --Multiply the player's movespeed by this when sighting.
SWEP.IsMelee = true
SWEP.AllowSprintAttack = true
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
-- SWEP.CanBuy = {ROLE_TRAITOR, ROLE_DETECTIVE, ROLE_INNOCENT} -- only traitors can buy
-- SWEP.LimitedStock = true -- only buyable once
-- SWEP.NoSights = false
-- SWEP.IsSilent = true
--[[Worldmodel Variables]]
--
SWEP.HoldType = "melee2" -- how others view you carrying the weapon
SWEP.BlockHoldType = "slam" -- how others view you carrying the weapon, while blocking
--[[
Options:
normal - Pistol Idle / Weaponless, hands at sides
melee - One Handed Melee
melee2 - Two Handed Melee
fist - Fists Raised
knife - Knife/Dagger style melee.  Kind of hunched.
smg - SMG or Rifle with grip
ar2 - Rifle
pistol - One handed pistol
rpg - Used for RPGs or sometimes snipers.  AFAIK has no reload anim.
physgun - Used for physgun.  Kind of like SLAM, but holding a grip.
grenade - Used for nades, kind of similar to melee but more of a throwing animation.
shotgun - Used for shotugns, and really that's it.
crossbow -Similar to shotgun, but aimed.  Used for crossbows.
slam - Holding an explosive or other rectangular object with two hands
passive -- SMG idle, like you can see with some HL2 citizens
magic - One hand to temple, the other reaching out.  Can be used to mimic blocking a melee, if you're OK with the temple-hand-thing.
duel- dual pistols
revolver - 2 handed pistol
--]]
SWEP.WorldModel = "" -- Weapon world model
SWEP.ShowWorldModel = true --Draw the world model?
SWEP.Spawnable = false --Can it be spawned by a user?
SWEP.AdminSpawnable = false --Can it be spawned by an admin?
--[[Viewmodel Variables]]
--
SWEP.UseHands = true --Uses c_hands?  If you port a model directly from HL2, CS:S, etc. then set to false
	SWEP.ViewModelFOV = 60 --This controls the viewmodel FOV.  The larger, the smaller it appears.  Decrease if you can see something you shouldn't.
	SWEP.ViewModelFlip = false --Flip the viewmodel?  Usually gonna be yes for CS:S ports.
	SWEP.ViewModel = "" -- Weapon view model
	--[[Shooting/Attacking Vars]]
	--
	SWEP.Primary.Damage = 200 -- Base damage per bullet
	SWEP.DamageType = DMG_SLASH
	SWEP.Primary.RPM = 180 -- This is in Rounds Per Minute
	SWEP.Primary.KickUp = 0.4 -- Maximum up recoil (rise)
	SWEP.Primary.KickDown = 0.3 -- Maximum down recoil (skeet)
	SWEP.Primary.KickHorizontal = 0.3 -- Maximum up recoil (stock)
	SWEP.Primary.Automatic = false -- Automatic = true; Semi Auto = false.  In the case of our sword, if you can hold and keep swinging.
	SWEP.FiresUnderwater = true --Can you swing your sword underwater?
	--[[ Block Procedural Animation Variables]]
	--
	SWEP.BlockPos = Vector(-18, -10, 3) --Blocking Position.
	SWEP.BlockAng = Vector(10, -25, -15) --Blocking Angle.
	--[[Begin Slashing Variables]]
	--
	SWEP.Slash = 1
	SWEP.Sequences = {} --Swinging Sequences
	--[[
	SWEP.Sequences[1]={
	name="swipe_u2d",--Sequence name, can be found in HLMV
	holdtype="melee2",--Holdtype (thirdperson type of weapon, usually gonna be melee for a one handed or melee2 for a two handed)
	startt=10/60,--swing start in seconds, from the sequence start
endt=20/60,--swing end in seconds, from the sequence start
pitch=5, --This is a component of the slash's arc.  Pitch is added last, and changes based on the time of the trace.
yaw=35, --This is a component of the slash's arc.  Yaw is added second, and changes based on the time of the trace.
roll=-90,--This is a component of the slash's arc.  Roll is added first, and remains static.
dir=1--Left to right = -1, right to left =1.  Base this off if the roll were 0.
}
SWEP.Sequences[2]={
name="swipe_l2r",
holdtype="melee2",
startt=10/60,
endt=20/60,
pitch=5,
yaw=45,
roll=10,
dir=-1
}
SWEP.Sequences[3]={
name="swipe_r2l",
holdtype="melee2",
startt=10/60,
endt=20/60,
pitch=5,
yaw=45,
roll=-5,
dir=1
}
]]
--
SWEP.SlashRandom = Angle(5, 0, 10) --This is a random angle for the overall slash, added onto the sequence angle
SWEP.SlashJitter = Angle(1, 1, 1) --This is jitter for each point of the slash
SWEP.randfac = 0 --Don't change this, it's autocalculated
SWEP.HitRange = 86 -- Blade Length.  Set slightly longer to compensate for animation.
SWEP.AmmoType = "TFMSwordHitGenericSlash" --Ammotype.  You can set a damage type in a custom ammo, which you can create in autorun.  Then set it to that custom ammotype here.
SWEP.SlashPrecision = 15 --The number of traces per slash
SWEP.SlashDecals = 8 --The number of decals per slash.  May slightly vary
SWEP.SlashSounds = 6 --The number of sounds per slash.  May slightly vary.
SWEP.LastTraceTime = 0 --Don't change this, it's autocalculated
SWEP.NextPrimaryFire = 0 --In case SetNextPrimaryFire doesn't work.  Don't change this here.  Please.
--[[Blocking Variables]]
--
SWEP.BlockSequences = {} --Sequences for blocking
--[[
SWEP.BlockSequences[1]={
name="swipe_u2d", --Sequence name, can be found in HLMV
recoverytime=0.3, --Recovery Time (Added onto sequence time, if enabled)
recoverysequence=false  --Automatically add recovery time based on sequence length
}
SWEP.BlockSequences[2]={
name="swipe_l2r",
recoverytime=0.3,
recoverysequence=false
}
SWEP.BlockSequences[3]={
name="swipe_r2l",
recoverytime=0.3,
recoverysequence=false
}
]]
--
SWEP.DisableIdleAnimations = false --Disables idle animations.  Set to false to enable them.
SWEP.IronBobMult = 1 -- More is more bobbing, proportionally.  This is multiplication, not addition.  You want to make this < 1 for sighting, 0 to outright disable.
SWEP.NinjaMode = false --Can block bullets/everything
SWEP.DrawTime = 0.2 --Time you can't swing after drawing
SWEP.BlockAngle = 135 --Think of the player's view direction as being the middle of a sector, with the sector's angle being this
SWEP.BlockMaximum = 0.1 --Multiply damage by this for a maximumly effective block
SWEP.BlockMinimum = 0.7 --Multiply damage by this for a minimumly effective block
SWEP.BlockWindow = 0.5 --Time to absorb maximum damage
SWEP.BlockFadeTime = 1 --Time for blocking to do minimum damage.  Does not include block window
SWEP.PrevBlocking = false --Don't change this, just related to the block procedural animation
SWEP.BlockProceduralAnimTime = 0.15 --Change how slow or quickly the player moves their sword to block
--[[Sounds]]
--
--These are just kinda constants you can use.  Don't change these, or do if you want to be lazy.
SWEP.SlashSound = Sound("weapons/blades/woosh.mp3") --Weapon woosh/slash sound
SWEP.KnifeShink = Sound("weapons/blades/hitwall.mp3") --When a knife hits a wall.  Grating noise.
SWEP.KnifeSlash = Sound("weapons/blades/slash.mp3") --Meaty slash
SWEP.KnifeStab = Sound("weapons/blades/nastystab.mp3") --Meaty stab and pull-out
SWEP.SwordChop = Sound("weapons/blades/swordchop.mp3") --Meaty impact, without the pull-out
SWEP.SwordClash = Sound("weapons/blades/clash.mp3") --Sound played when you block something
--[[ Edit These ]]
--
SWEP.Primary.Sound = SWEP.SlashSound --Change this to your swing sound
SWEP.Primary.Sound_Impact_Flesh = SWEP.SwordChop --Change this to your flesh hit sound
SWEP.Primary.Sound_Impact_Generic = SWEP.KnifeShink --Change this to your generic hit sound
SWEP.Primary.Sound_Impact_Metal = SWEP.SwordClash --Change this to your metal hit
SWEP.Primary.Sound_Pitch_Low = 97 --Percentage of pitch out of 100, lowe end.  Up to 255.
SWEP.Primary.Sound_Pitch_High = 100 --Percentage of pitch out of 100  Up to 255.
SWEP.Primary.Sound_World_Glass_Enabled = true --Override for glass?
SWEP.Primary.Sound_Glass_Enabled = true --Override for glass?
SWEP.Primary.Sound_Glass = Sound("impacts/glass_impact.wav")
SWEP.GlassSoundPlayed = false -- DO NOT CHANGE THIS.  It's automatically set.   This way, it doesn't spam the glass sound.
SWEP.VElements = {} --View elements
SWEP.WElements = {} --World elements
SWEP.sounds = 0
SWEP.Action = true --Use action IDs?
--[[Stop editing here for normal users of my base.  Code starts here.]]--
--[[
function SWEP:Precache()
util.PrecacheSound(self.Primary.Sound)
util.PrecacheModel(self.ViewModel)
util.PrecacheModel(self.WorldModel)
end
]]--

function SWEP:Deploy()
	self:SetNW2Float("SharedRandomVal", CurTime())
	self:SetBlockStart(-1)
	self.PrevBlockRat = 0
	BaseClass.Deploy(self)
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 20, "BlockStart")
	BaseClass.SetupDataTables(self)
end

function SWEP:DoImpactEffect(tr, dmg)
	local impactpos, impactnormal
	impactpos = tr.HitPos
	impactnormal = tr.HitNormal
	self.sounds = self.sounds and self.sounds or 0

	if (tr.HitSky == false) then
		if (util.SharedRandom(CurTime(), 1, self.SlashPrecision, "TFMSwordDecal") < self.SlashDecals) then
			util.Decal("ManhackCut", impactpos + impactnormal, impactpos - impactnormal)
		end

		if (tr.MatType == MAT_GLASS) and (self.Primary.Sound_Glass and self.Primary.Sound_Glass_Enabled == true) and (self.GlassSoundPlayed == false) then
			self:EmitSound(self.Primary.Sound_Glass, 100, math.random(self.Primary.Sound_Pitch_Low, self.Primary.Sound_Pitch_High), 0.75, CHAN_WEAPON)
			self.GlassSoundPlayed = true
		end
	end

	return true
end

function SWEP:HitThing(ent, posv, normalv, damage, tr)
	local ply
	ply = self:GetOwner()

	if IsValid(ply) then
		--[[
		ply:LagCompensation(true)
		local tr,tres;
		tr={}
		tr.start=posv
		tr.endpos=posv+normalv*self.HitRange
		tr.filter=ply
		tr.mask=2147483647--MASK_SOLID && MASK_SHOT && MASK_VISIBLE_AND_NPCS--MASK_SHOT
		tres=util.TraceLine(tr)
		ply:LagCompensation(false)
		if tres.Hit and tres.Fraction<1 and !tres.HitSky then
		]]
		--
		local bullet = {}
		bullet.Num = 1
		bullet.Src = posv -- Source
		bullet.Dir = normalv -- Dir of bullet
		bullet.Spread = vector_origin -- Aim Cone
		bullet.Tracer = 0 -- Show a tracer on every x bullets
		bullet.Force = damage / 16 -- Amount of force to give to phys objects
		bullet.Damage = damage
		bullet.Distance = self.HitRange
		bullet.HullSize = self.WeaponLength / self.SlashPrecision
		bullet.AmmoType = self.AmmoType

		bullet.Callback = function(a, b, c)
			local wep = a:GetActiveWeapon()
			if not IsValid(self) then return end
			if not self.sounds then return end
			c:SetDamageType(self.DamageType)

			if (self.sounds < self.SlashSounds) then
				local hitmat = b.MatType

				if (hitmat == MAT_METAL or hitmat == MAT_GRATE or hitmat == MAT_VENT or hitmat == MAT_COMPUTER) then
					--Emit metal sound
					wep.Weapon:EmitSound(self.Primary.Sound_Impact_Metal, 100, math.random(self.Primary.Sound_Pitch_Low, self.Primary.Sound_Pitch_High), 0.75, CHAN_AUTO)
					wep.sounds = self.sounds + 1
					--Emit flesh sound
					--Emit generic sound.
				elseif (hitmat == MAT_FLESH or hitmat == MAT_BLOODYFLESH or hitmat == MAT_ALIENFLESH) then
					wep.Weapon:EmitSound(self.Primary.Sound_Impact_Flesh, 100, math.random(self.Primary.Sound_Pitch_Low, self.Primary.Sound_Pitch_High), 0.75, CHAN_AUTO)
					wep.sounds = self.sounds + 1
				else
					wep.Weapon:EmitSound(self.Primary.Sound_Impact_Generic, 100, math.random(self.Primary.Sound_Pitch_Low, self.Primary.Sound_Pitch_High), 0.75, CHAN_AUTO)
					wep.sounds = self.sounds + 1
				end
			end
		end

		if CLIENT and SERVER then
			if self:GetOwner() ~= LocalPlayer() then
				self:GetOwner():FireBullets(bullet)
			end
		else
			self:GetOwner():FireBullets(bullet)
		end
		--end
	end
end

function SWEP:PrimaryAttack()
	local sharedrandomval = self:GetNW2Float("SharedRandomVal", 0)
	math.randomseed(sharedrandomval)
	if CLIENT and not IsFirstTimePredicted() then return end
	if not self:OwnerIsValid() then return end
	if CurTime() < self:GetNextPrimaryFire() then return end
	if not TFA.Enum.ReadyStatus[self:GetStatus()] then return end

	if self:IsSafety() then return end
	self:SetStatus(TFA.Enum.STATUS_SHOOTING)
	self.sounds = 0
	self:ChooseShootAnim() -- View model animation

	if SERVER then
		timer.Simple(0, function()
			if IsValid(self) then
				self:SetNW2Float("SharedRandomVal", math.Rand(-1024, 1024))
			end
		end)
	end

	local vm = self:GetOwner():GetViewModel()
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:GetOwner():SetNW2Float("TFM_SwingStart", CurTime())
	self:SetStatusEnd(CurTime() + vm:SequenceDuration(vm:LookupSequence(self.Sequences[self:GetNW2Int("Slash", 1)].name)))
	self.LastTraceTime = CurTime() + self.Sequences[self:GetNW2Int("Slash", 1)].startt

	self:SetNextPrimaryFire(CurTime() + 1 / (self.Primary.RPM / 60))

	if SERVER then
		timer.Simple(self.Sequences[self:GetNW2Int("Slash", 1)].startt, function()
			if IsValid(self) and self.Primary.Sound then
				self:EmitSound(self.Primary.Sound)
			end
		end)
	end
end

local seq, swe
local ft, len, strikepercent, swingprogress, sws
local aimoff, jitfac
local blockseqn, ply
local vm

function SWEP:IronSights()
	BaseClass.IronSights(self)
	ply = self:GetOwner()
	seq = self.Sequences[self:GetNW2Int("Slash", 1)]
	swe = ply:GetNW2Float("TFM_SwingStart", CurTime()) + seq.endt

	if CurTime() < swe then
		self:SetIronSightsRaw(false)
	end
end


function SWEP:Think2()
	BaseClass.Think2(self)
	local isr = self.IronSightsProgress
	ply = self:GetOwner()

	if self.PrevBlockRat and isr and self.PrevBlockRat <= 0.3 and isr > 0.3 then
		self:SetBlockStart(CurTime())
		--print(CurTime())
	end

	if isr and self.PrevBlockRat and isr < 0.1 and self.PrevBlockRat > 0.1 then
		self:SetBlockStart(-1)
		--print(-1)
	end

	self.PrevBlockRat = isr
	local stat = self:GetStatus()
	if stat == TFA.Enum.STATUS_SHOOTING then
		seq = self.Sequences[self:GetNW2Int("Slash", 1)]
		ft = CurTime() - self.LastTraceTime
		len = seq.endt - seq.startt
		strikepercent = ft / len
		sws = ply:GetNW2Float("TFM_SwingStart", CurTime()) + seq.startt
		swe = ply:GetNW2Float("TFM_SwingStart", CurTime()) + seq.endt
		swingprogress = (CurTime() - sws) / len

		if CurTime() < swe then
			self:SetIronSightsRaw(false)
		end

		if (CurTime() > sws) and CurTime() < swe and ft > len / self.SlashPrecision and (strikepercent > 0) then
			aimoff = ply:EyeAngles()
			--aimoff = Angle(0,0,0)
			local cutangle = Angle(seq.pitch * (swingprogress - 0.5) * seq.dir, seq.yaw * (swingprogress - 0.5) * seq.dir, seq.roll)
			jitfac = 0.5 - util.SharedRandom("TFMSwordJitter", 0, 1, CurTime())
			aimoff:RotateAroundAxis(aimoff:Forward(), cutangle.r + self.SlashRandom.r * self.randfac + self.SlashJitter.r * jitfac) --Roll is static
			aimoff:RotateAroundAxis(aimoff:Up(), cutangle.y + self.SlashRandom.y * self.randfac + self.SlashJitter.y * jitfac)
			aimoff:RotateAroundAxis(aimoff:Right(), cutangle.p + self.SlashRandom.p * self.randfac + self.SlashJitter.p * jitfac)
			self:HitThing(ply, ply:GetShootPos(), aimoff:Forward(), self.Primary.Damage * strikepercent)
			self.LastTraceTime = CurTime()
		end
	end
end

function SWEP:ChooseShootAnim(mynewvar)
	local sharedrandomval = self:GetNW2Float("SharedRandomVal", 0)
	if not self:OwnerIsValid() then return end
	if not IsValid(self) or not self:OwnerIsValid() then return end
	ply = self:GetOwner()
	vm = ply:GetViewModel()
	local selection = {}
	local relativedir = WorldToLocal(ply:GetVelocity(), Angle(0, 0, 0), vector_origin, ply:EyeAngles())
	local fwd = relativedir.x
	local hor = relativedir.y

	if hor < -ply:GetWalkSpeed() / 2 then
		for k, v in pairs(self.Sequences) do
			if v.right then
				table.insert(selection, #selection + 1, k)
			end
		end
	elseif hor > ply:GetWalkSpeed() / 2 then
		for k, v in pairs(self.Sequences) do
			if v.left then
				table.insert(selection, #selection + 1, k)
			end
		end
	elseif fwd > ply:GetWalkSpeed() / 2 then
		for k, v in pairs(self.Sequences) do
			if (v.up) then
				table.insert(selection, #selection + 1, k)
			end
		end
	elseif fwd < ply:GetWalkSpeed() / 2 then
		for k, v in pairs(self.Sequences) do
			if (v.down) then
				table.insert(selection, #selection + 1, k)
			end
		end
	end

	if #selection <= 0 and math.abs(fwd) < ply:GetWalkSpeed() / 2 and math.abs(hor) < ply:GetWalkSpeed() / 2 then
		for k, v in pairs(self.Sequences) do
			if v.up or v.down then
				table.insert(selection, #selection + 1, k)
			end
		end
	end

	if #selection <= 0 and math.abs(hor) < ply:GetWalkSpeed() / 2 and math.abs(fwd) < ply:GetWalkSpeed() / 2 then
		for k, v in pairs(self.Sequences) do
			if v.standing then
				table.insert(selection, #selection + 1, k)
			end
		end
	end

	if #selection <= 0 then
		--print("random test:")
		math.randomseed(sharedrandomval)

		if math.random(0, 1) == 0 then
			math.randomseed(sharedrandomval)
			self:SetNW2Int("Slash", math.random(1, #self.Sequences))
		else
			self:SetNW2Int("Slash", self:GetNW2Int("Slash", 1) + 1)

			if self:GetNW2Int("Slash", 1) > #self.Sequences then
				self:SetNW2Int("Slash", 1)
			end
		end
		--print("selection sequence")
		--print(math.Round( util.SharedRandom( "TFAMelee", 1, #selection, sharedrandomval ) ))
	else
		math.randomseed(sharedrandomval)
		self:SetNW2Int("Slash", selection[math.random(1, #selection)])
	end

	--print("Shared Random Value:")
	--print(sharedrandomval)
	--print("Slash Number")
	--print(self:GetNW2Int("Slash",0))
	local n = tonumber(mynewvar and mynewvar or "")
	local seqn = n and n or self:GetNW2Int("Slash", 1)
	--self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
	seq = self.Sequences[seqn]
	--vm:ResetSequence(vm:LookupSequence(seq.name))
	--print(seq.name)
	local seqid = vm:LookupSequence(seq.name)
	seqid = seqid and seqid or 0
	local actid = vm:GetSequenceActivity(seqid)

	if actid and actid >= 0 and self.Action then
		self:SendViewModelAnim(actid)
		--vm:SendViewModelMatchingSequence(seqid)
	else
		self:SendViewModelSeq(seqid)
	end

	if SERVER and game.SinglePlayer() then
		self:CallOnClient("ChooseShootAnim", tostring(seqn))
	end

	return true, ACT_VM_PRIMARYATTACK
end

function SWEP:BlockAnim()
	local sharedrandomval = self:GetNW2Float("SharedRandomVal", 0)

	if self.BlockSequences and #self.BlockSequences > 0 then
		math.randomseed(sharedrandomval)
		blockseqn = math.random(1, #self.BlockSequences)
		seq = self.BlockSequences[blockseqn]
		ply = self:GetOwner()

		if IsValid(ply) then
			vm = ply:GetViewModel()

			if IsValid(vm) then
				self:SetNextIdleAnim(-1)
				self:SendWeaponAnim(ACT_VM_IDLE)
				vm:SendViewModelMatchingSequence(vm:LookupSequence(seq.name))

				if seq.recoverysequence and seq.recoverysequence == true then
					if seq.recoverytime then
						self.NextPrimaryFire = CurTime() + vm:SequenceDuration() + seq.recoverytime
						self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration() + seq.recoverytime)
						self:SetStatus(TFA.Enum.STATUS_FIDGET)
						self:SetStatusEnd(self.NextPrimaryFire)
					else
						self.NextPrimaryFire = CurTime() + vm:SequenceDuration()
						self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration())
						self:SetStatus(TFA.Enum.STATUS_FIDGET)
						self:SetStatusEnd(self.NextPrimaryFire)
					end
				else
					self.NextPrimaryFire = CurTime() + seq.recoverytime

					if seq.recoverytime then
						self.NextPrimaryFire = CurTime() + seq.recoverytime
						self:SetNextPrimaryFire(CurTime() + seq.recoverytime)
					else
						self.NextPrimaryFire = CurTime()
						self:SetNextPrimaryFire(CurTime())
					end
				end
			end
		end
	end
end
