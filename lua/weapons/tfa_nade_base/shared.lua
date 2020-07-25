
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
SWEP.Type = "Grenade"
SWEP.MuzzleFlashEffect = ""
SWEP.data = {}
SWEP.data.ironsights = 0
SWEP.Delay = 0.3 -- Delay to fire entity
SWEP.Delay_Underhand = 0.3 -- Delay to fire entity
SWEP.Primary.Round = "" -- Nade Entity
SWEP.Velocity = 550 -- Entity Velocity
SWEP.Underhanded = false
SWEP.DisableIdleAnimations = true
SWEP.IronSightsPos = Vector(5,0,0)
SWEP.IronSightsAng = Vector(0,0,0)
SWEP.Callback = {}


SWEP.AllowSprintAttack = true

local nzombies = nil

function SWEP:Initialize()
	if nzombies == nil then
		nzombies = engine.ActiveGamemode() == "nzombies"
	end
	self.ProjectileEntity = self.Primary.Round --Entity to shoot
	self.ProjectileVelocity = self.Velocity and self.Velocity or 550 --Entity to shoot's velocity
	self.ProjectileModel = nil --Entity to shoot's model
	self:SetNW2Bool("Ready", false)
	self:SetNW2Bool("Underhanded", false)
	BaseClass.Initialize(self)
end

function SWEP:Deploy()
	if self:Clip1() <= 0 then
		if self:Ammo1() <= 0 then
			timer.Simple(0, function()
				if IsValid(self) and self:OwnerIsValid() and SERVER and not nzombies then
					self:GetOwner():StripWeapon(self:GetClass())
				end
			end)
		else
			self:TakePrimaryAmmo(1,true)
			self:SetClip1(1)
		end
	end

	self:SetNW2Bool("Ready", false)
	self:SetNW2Bool("Underhanded", false)
	self.oldang = self:GetOwner():EyeAngles()
	self.anga = Angle()
	self.angb = Angle()
	self.angc = Angle()
	self:CleanParticles()
	BaseClass.Deploy(self)
end

function SWEP:ChoosePullAnim()
	if not self:OwnerIsValid() then return end

	if self.Callback.ChoosePullAnim then
		self.Callback.ChoosePullAnim(self)
	end

	self:GetOwner():SetAnimation(PLAYER_RELOAD)
	--self:ResetEvents()
	local tanim = ACT_VM_PULLPIN
	local success = true
	self:SendViewModelAnim(ACT_VM_PULLPIN)

	if game.SinglePlayer() then
		self:CallOnClient("AnimForce", tanim)
	end

	self.lastact = tanim

	return success, tanim
end

function SWEP:ChooseShootAnim()
	if not self:OwnerIsValid() then return end

	if self.Callback.ChooseShootAnim then
		self.Callback.ChooseShootAnim(self)
	end

	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	--self:ResetEvents()
	local mybool = self:GetNW2Bool("Underhanded", false)
	local tanim = mybool and ACT_VM_RELEASE or ACT_VM_THROW
	if not self.SequenceEnabled[ACT_VM_RELEASE] then
		tanim = ACT_VM_THROW
	end
	local success = true
	self:SendViewModelAnim(tanim)

	if game.SinglePlayer() then
		self:CallOnClient("AnimForce", tanim)
	end

	self.lastact = tanim

	return success, tanim
end

function SWEP:ThrowStart()
	if self:Clip1() > 0 then
		local _, tanim = self:ChooseShootAnim()
		self:SetStatus( TFA.GetStatus("grenade_throw") )
		self:SetStatusEnd( CurTime() + (self.SequenceLengthOverride[tanim] or self.OwnerViewModel:SequenceDuration()) )
		local bool = self:GetNW2Bool("Underhanded", false)

		if bool then
			timer.Simple(self.Delay_Underhand, function()
				if IsValid(self) and self:OwnerIsValid() then
					self:Throw()
				end
			end)
		else
			timer.Simple(self.Delay, function()
				if IsValid(self) and self:OwnerIsValid() then
					self:Throw()
				end
			end)
		end
	end
end

function SWEP:Throw()
	if self:Clip1() > 0 then
		local bool = self:GetNW2Bool("Underhanded", false)

		if not bool then
			self.ProjectileVelocity = self.Velocity and self.Velocity or 550 --Entity to shoot's velocity
			--Entity to shoot's velocity
		else
			if self.Velocity_Underhand then
				self.ProjectileVelocity = self.Velocity_Underhand
			else
				self.ProjectileVelocity = (self.Velocity and self.Velocity or 550) / 1.5
			end
		end

		self:TakePrimaryAmmo(1)
		self:ShootBulletInformation()
		self:DoAmmoCheck()
	end
end

function SWEP:DoAmmoCheck()
	if IsValid(self) and SERVER then
		local vm = self:GetOwner():GetViewModel()
		if not IsValid(vm) then return end
		local delay = vm:SequenceDuration()
		delay = delay * 1 - math.Clamp(vm:GetCycle(), 0, 1)

		timer.Simple(delay, function()
			if IsValid(self) then
				self:Deploy()
			end
		end)
	end
end

local stat

function SWEP:Think2()
	if not self:OwnerIsValid() then return end
	stat = self:GetStatus()
	if stat == TFA.GetStatus("grenade_pull") then
		if self:GetOwner():KeyDown(IN_ATTACK2) then
			self:SetNW2Bool("Underhanded", true)
		end
		if CurTime() > self:GetStatusEnd() then
			stat = TFA.GetStatus("grenade_ready")
			self:SetStatus( stat )
			self:SetStatusEnd(math.huge)
		end
	end
	if stat == TFA.GetStatus("grenade_ready") then
		if self:GetOwner():KeyDown(IN_ATTACK2) then
			self:SetNW2Bool("Underhanded", true)
		end
		if not self:GetOwner():KeyDown(IN_ATTACK2) and not self:GetOwner():KeyDown(IN_ATTACK) then
			self:ThrowStart()
		end
	end
	BaseClass.Think2(self)
end

function SWEP:PrimaryAttack()
	if self:Clip1() > 0 and self:OwnerIsValid() and self:CanFire() then
		local _,tanim = self:ChoosePullAnim()
		self:SetStatus(TFA.GetStatus("grenade_pull"))
		self:SetStatusEnd( CurTime() + (self.SequenceLengthOverride[tanim] or self.OwnerViewModel:SequenceDuration()) )
		self:SetNW2Bool("Charging", true)
		self:SetNW2Bool("Underhanded", false)

		if IsFirstTimePredicted() then
			timer.Simple(self:GetOwner():GetViewModel():SequenceDuration(), function()
				if IsValid(self) then
					self:SetNW2Bool("Ready", true)
				end
			end)
		end
	end
end

function SWEP:SecondaryAttack()
	if self:Clip1() > 0 and self:OwnerIsValid() and self:CanFire() then
		local _,tanim = self:ChoosePullAnim()
		self:SetNW2Bool("Ready", false)
		self:SetNW2Bool("Underhanded", true)
		self:SetStatus(TFA.GetStatus("grenade_pull"))
		self:SetStatusEnd( CurTime() + (self.SequenceLengthOverride[tanim] or self.OwnerViewModel:SequenceDuration()) )
	end
end

function SWEP:Reload()
	if self:Clip1() <= 0 and self:OwnerIsValid() and self:CanFire() then
		self:Deploy()
	end
end

function SWEP:CanFire()
	if not self:CanPrimaryAttack() then return false end
	return true
end

function SWEP:ChooseIdleAnim( ... )
	if self:GetNW2Bool("Ready") then return end
	BaseClass.ChooseIdleAnim(self,...)
end

SWEP.AllowSprintAttack = true