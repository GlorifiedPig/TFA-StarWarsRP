
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

DEFINE_BASECLASS("tfa_gun_base")
SWEP.Secondary.BashDamage = 25
SWEP.Secondary.BashSound = Sound("TFA.Bash")
SWEP.Secondary.BashHitSound = Sound("TFA.BashWall")
SWEP.Secondary.BashHitSound_Flesh = Sound("TFA.BashFlesh")
SWEP.Secondary.BashLength = 54
SWEP.Secondary.BashDelay = 0.2
SWEP.Secondary.BashDamageType = DMG_SLASH
SWEP.Secondary.BashEnd = nil --Override bash sequence length easier
SWEP.Secondary.BashInterrupt = false --Do you need to be in a "ready" status to bash?
SWEP.BashBase = true

--SWEP.tmptoggle = true
function SWEP:BashForce(ent, force, pos, now)
	if not IsValid(ent) or not ent.GetPhysicsObjectNum then return end

	if now then
		if ent.GetRagdollEntity then
			ent = ent:GetRagdollEntity() or ent
		end

		local phys = ent:GetPhysicsObjectNum(0)

		if IsValid(phys) then
			if ent:IsPlayer() or ent:IsNPC() then
				ent:SetVelocity( force * 0.1)
				phys:SetVelocity(phys:GetVelocity() + force * 0.1)
			else
				phys:ApplyForceOffset(force, pos)
			end
		end
	else
		timer.Simple(0, function()
			if IsValid(self) and self:OwnerIsValid() and IsValid(ent) then
				self:BashForce(ent, force, pos, true)
			end
		end)
	end
end

local function bashcallback(a, b, c, wep, pain)
	if not IsValid(wep) then return end

	c:SetInflictor(wep)

	if c then
		c:SetDamageType(wep:GetStat("Secondary.BashDamageType"))
	end

	if IsValid(b.Entity) and b.Entity.TakeDamageInfo then
		local dmg = DamageInfo()
		dmg:SetAttacker(wep:GetOwner())
		dmg:SetInflictor(wep)
		dmg:SetDamagePosition(wep:GetOwner():GetShootPos())
		dmg:SetDamageForce(wep:GetOwner():GetAimVector() * 1) --(pain))
		dmg:SetDamage(pain)
		dmg:SetDamageType(wep:GetStat("Secondary.BashDamageType"))
		b.Entity:TakeDamageInfo(dmg)
		wep:BashForce(b.Entity, wep:GetOwner():GetAimVector() * math.sqrt(pain / 80) * 32 * 80, b.HitPos)
	end
end

local cv_doordestruction = GetConVar("sv_tfa_melee_doordestruction")

function SWEP:HandleDoor(slashtrace)
	if CLIENT or not IsValid(slashtrace.Entity) then return end

	if not cv_doordestruction:GetBool() then return end

	if slashtrace.Entity:GetClass() == "func_door_rotating" or slashtrace.Entity:GetClass() == "prop_door_rotating" then
		slashtrace.Entity:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(80, 120))

		local newname = "TFABash" .. self:EntIndex()
		self.PreBashName = self:GetName()
		self:SetName(newname)

		slashtrace.Entity:SetKeyValue("Speed", "500")
		slashtrace.Entity:SetKeyValue("Open Direction", "Both directions")
		slashtrace.Entity:SetKeyValue("opendir", "0")
		slashtrace.Entity:Fire("unlock", "", .01)
		slashtrace.Entity:Fire("openawayfrom", newname, .01)

		timer.Simple(0.02, function()
			if not IsValid(self) or self:GetName() ~= newname then return end

			self:SetName(self.PreBashName)
		end)

		timer.Simple(0.3, function()
			if IsValid(slashtrace.Entity) then
				slashtrace.Entity:SetKeyValue("Speed", "100")
			end
		end)
	end
end

local l_CT = CurTime
local sp = game.SinglePlayer()

function SWEP:AltAttack()
	if self:GetStat("Secondary.CanBash") == false then return end
	if not self:OwnerIsValid() then return end
	if l_CT() < self:GetNextSecondaryFire() then return end
	local stat = self:GetStatus()
	if ( not TFA.Enum.ReadyStatus[stat] ) and not self.Secondary.BashInterrupt then return end
	if ( stat == TFA.Enum.STATUS_BASHING ) and self.Secondary.BashInterrupt then return end
	if self:IsSafety() then return end
	if self:GetHolding() then return end
	local enabled, act = self:ChooseBashAnim()

	if not enabled then return end

	if self:GetOwner().Vox then
		self:GetOwner():Vox("bash", 0)
	end
	self.unpredbash = true

	timer.Simple(0.1, function()
		if IsValid(self) then
			self.unpredbash = false
		end
	end)

	self:BashAnim()
	if sp and SERVER then self:CallOnClient("BashAnim","") end

	self.tmptoggle = not self.tmptoggle
	self:SetNextPrimaryFire(l_CT() + (self:GetStat("Secondary.BashEnd") or self:GetActivityLength(act, false) ) )
	self:SetNextSecondaryFire(l_CT() + (self:GetStat("Secondary.BashEnd") or self:GetActivityLength(act, true) ) )

	self:EmitSoundNet(self:GetStat("Secondary.BashSound"))

	self:SetStatus(TFA.Enum.STATUS_BASHING)
	self:SetStatusEnd( l_CT() + (self:GetStat("Secondary.BashEnd") or self:GetActivityLength(act, true) ) )

	self:SetNW2Float("BashTTime", l_CT() + self:GetStat("Secondary.BashDelay"))
end

function SWEP:BashAnim()
	--if IsValid(wep) and wep.GetHoldType then
	local ht = self.DefaultHoldType or self.HoldType
	local altanim = false

	if ht == "ar2" or ht == "shotgun" or ht == "crossbow" or ht == "physgun" then
		altanim = true
	end

	self:GetOwner():AnimRestartGesture(0, altanim and ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND or ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2, true)
end

local ttime = -1

function SWEP:Think2()
	ttime = self:GetNW2Float("BashTTime", -1)

	if ttime ~= -1 and l_CT() > ttime then
		self:SetNW2Float("BashTTime", -1)
		local pos = self:GetOwner():GetShootPos()
		local av = self:GetOwner():EyeAngles():Forward()
		local slash = {}
		slash.start = pos
		slash.endpos = pos + (av * self:GetStat("Secondary.BashLength"))
		slash.filter = self:GetOwner()
		slash.mins = Vector(-10, -5, 0)
		slash.maxs = Vector(10, 5, 5)
		local slashtrace = util.TraceHull(slash)
		local pain = self:GetStat("Secondary.BashDamage")

		if slashtrace.Hit then
			self:HandleDoor(slashtrace)
			if not ( sp and CLIENT ) then
				self:EmitSound((slashtrace.MatType == MAT_FLESH or slashtrace.MatType == MAT_ALIENFLESH) and self:GetStat("Secondary.BashHitSound_Flesh") or self:GetStat("Secondary.BashHitSound"))
			end

			if game.GetTimeScale() > 0.99 then
				self:GetOwner():FireBullets({
					Attacker = self:GetOwner(),
					Inflictor = self,
					Damage = 1,
					Force = 1, --pain,
					Distance = self:GetStat("Secondary.BashLength") + 10,
					HullSize = 10,
					Tracer = 0,
					Src = self:GetOwner():GetShootPos(),
					Dir = slashtrace.Normal,
					Callback = function(a, b, c)
						bashcallback(a, b, c, self, pain)
					end
				})
			else
				local dmg = DamageInfo()
				dmg:SetAttacker(self:GetOwner())
				dmg:SetInflictor(self)
				dmg:SetDamagePosition(self:GetOwner():GetShootPos())
				dmg:SetDamageForce(self:GetOwner():GetAimVector() * pain)
				dmg:SetDamage(pain)
				dmg:SetDamageType(self:GetStat("Secondary.BashDamageType"))

				if IsValid(slashtrace.Entity) and slashtrace.Entity.TakeDamageInfo then
					slashtrace.Entity:TakeDamageInfo(dmg)
				end
			end

			local ent = slashtrace.Entity
			if not IsValid(ent) or not ent.GetPhysicsObject then return end
			local phys

			if ent:IsRagdoll() then
				phys = ent:GetPhysicsObjectNum(slashtrace.PhysicsBone or 0)
			else
				phys = ent:GetPhysicsObject()
			end

			if IsValid(phys) then
				if ent:IsPlayer() or ent:IsNPC() then
					ent:SetVelocity( self:GetOwner():GetAimVector() * self:GetStat("Secondary.BashDamage") * 0.5 )
					phys:SetVelocity(phys:GetVelocity() + self:GetOwner():GetAimVector() * self:GetStat("Secondary.BashDamage") * 0.5 )
				else
					phys:ApplyForceOffset(self:GetOwner():GetAimVector() * self:GetStat("Secondary.BashDamage") * 0.5, slashtrace.HitPos)
				end
			end
		end
	end

	BaseClass.Think2(self)
end

function SWEP:SecondaryAttack()
	if self:GetStat("data.ironsights", 0) == 0 then
		self:AltAttack()
		return
	end

	BaseClass.SecondaryAttack(self)
end

function SWEP:GetBashing()
	if not self:VMIV() or not IsValid(self.OwnerViewModel) then return false end

	local stat = self:GetStatus()

	return ((stat == TFA.Enum.STATUS_BASHING) and self.OwnerViewModel:GetCycle() > 0 and self.OwnerViewModel:GetCycle() < 0.65) or self.unpredbash
end