
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

local fx, sp
local shelltype

function SWEP:PCFTracer(bul, hitpos, ovrride)
	if bul.PCFTracer then
		self:UpdateMuzzleAttachment()
		local mzp = self:GetMuzzlePos()
		if bul.PenetrationCount > 0 and not ovrride then return end --Taken care of with the pen effect

		if (CLIENT or game.SinglePlayer()) and self.Scoped and self:IsCurrentlyScoped() and self:IsFirstPerson() then
			TFA.ParticleTracer(bul.PCFTracer, self:GetOwner():GetShootPos() - self:GetOwner():EyeAngles():Up() * 5, hitpos, false, 0, -1)
		else
			local vent = self

			if (CLIENT or game.SinglePlayer()) and self:IsFirstPerson() then
				vent = self.OwnerViewModel
			end

			if game.SinglePlayer() and not self:IsFirstPerson() then
				TFA.ParticleTracer(bul.PCFTracer, self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 32, hitpos, false)
			else
				TFA.ParticleTracer(bul.PCFTracer, mzp.Pos, hitpos, false, vent, self.MuzzleAttachmentRaw or 1)
			end
		end
	end
end

function SWEP:EventShell()
	if SERVER and not game.SinglePlayer() then
		net.Start("tfaBaseShellSV")
		net.WriteEntity(self)
		net.SendOmit(self:GetOwner())
	else
		self:MakeShellBridge(true)
	end
end

function SWEP:MakeShellBridge(ifp)
	if game.SinglePlayer() and CLIENT then return end

	if ifp then
		if self.LuaShellEjectDelay > 0 then
			self.LuaShellRequestTime = CurTime() + self.LuaShellEjectDelay / self:GetAnimationRate(ACT_VM_PRIMARYATTACK)
		else
			self:MakeShell()
		end
	end
end

SWEP.ShellEffectOverride = nil

function SWEP:MakeShell()
	local retVal = hook.Run("TFA_MakeShell",self)
	if retVal ~= nil then
		return retVal
	end
	if self:GetStat("ShellEffectOverride") then
		shelltype = self:GetStat("ShellEffectOverride")
	elseif TFA.GetLegacyShellsEnabled() then
		shelltype = "tfa_shell_legacy"
	else
		shelltype = "tfa_shell"
	end

	if IsValid(self) then
		self:EjectionSmoke(true)
		local vm = (self:IsFirstPerson()) and self.OwnerViewModel or self
		if type(shelltype) ~= "string" or shelltype == "" then return end -- allows to disable shells by setting override to "" - will shut up all rp fags

		if IsValid(vm) then
			fx = EffectData()
			local attid = vm:LookupAttachment(self:GetStat("ShellAttachment"))

			if self:GetStat("Akimbo") then
				attid = 3 + self.AnimCycle
			end

			attid = math.Clamp(attid and attid or 2, 1, 127)
			local angpos = vm:GetAttachment(attid)

			if angpos then
				fx:SetEntity(self)
				fx:SetAttachment(attid)
				fx:SetMagnitude(1)
				fx:SetScale(1)
				fx:SetOrigin(angpos.Pos)
				fx:SetNormal(angpos.Ang:Forward())
				TFA.Effects.Create(shelltype, fx)
			end
		end
	end
end

--[[
Function Name:  CleanParticles
Syntax: self:CleanParticles().
Returns:  Nothing.
Notes:	Cleans up particles.
Purpose:  FX
]]
--
function SWEP:CleanParticles()
	if not IsValid(self) then return end

	if self.StopParticles then
		self:StopParticles()
	end

	if self.StopParticleEmission then
		self:StopParticleEmission()
	end

	if not self:VMIV() then return end
	local vm = self.OwnerViewModel

	if IsValid(vm) then
		if vm.StopParticles then
			vm:StopParticles()
		end

		if vm.StopParticleEmission then
			vm:StopParticleEmission()
		end
	end
end

--[[
Function Name:  EjectionSmoke
Syntax: self:EjectionSmoke().
Returns:  Nothing.
Notes:	Puff of smoke on shell attachment.
Purpose:  FX
]]
--
function SWEP:EjectionSmoke(ovrr)
	local retVal = hook.Run("TFA_EjectionSmoke",self)
	if retVal ~= nil then
		return retVal
	end
	if TFA.GetEJSmokeEnabled() and (self:GetStat("EjectionSmokeEnabled") or ovrr) then
		local vm = self:IsFirstPerson() and self.OwnerViewModel or self

		if IsValid(vm) then
			local att = vm:LookupAttachment(self.ShellAttachment)

			if not att or att <= 0 then
				att = 2
			end

			local oldatt = att

			if self.ShellAttachmentRaw then
				att = self.ShellAttachmentRaw
			end

			local angpos = vm:GetAttachment(att)

			if not angpos then
				att = oldatt
				angpos = vm:GetAttachment(att)
			end

			if angpos then
				fx = EffectData()
				fx:SetEntity(self)
				fx:SetOrigin(angpos.Pos)
				fx:SetAttachment(att)
				fx:SetNormal(angpos.Ang:Forward())
				TFA.Effects.Create("tfa_shelleject_smoke", fx)
			end
		end
	end
end

--[[
Function Name:  ShootEffectsCustom
Syntax: self:ShootEffectsCustom().
Returns:  Nothing.
Notes:	Calls the proper muzzleflash, muzzle smoke, muzzle light code.
Purpose:  FX
]]
--
function SWEP:MuzzleSmoke(spv)
	local retVal = hook.Run("TFA_MuzzleSmoke",self)
	if retVal ~= nil then
		return retVal
	end
	if self.SmokeParticle == nil then
		self.SmokeParticle = self.SmokeParticles[self.DefaultHoldType or self.HoldType]
	end

	if self:GetStat("SmokeParticle") and self:GetStat("SmokeParticle") ~= "" then
		self:UpdateMuzzleAttachment()
		local att = self:GetMuzzleAttachment()
		fx = EffectData()
		fx:SetOrigin(self:GetOwner():GetShootPos())
		fx:SetNormal(self:GetOwner():EyeAngles():Forward())
		fx:SetEntity(self)
		fx:SetAttachment(att)
		TFA.Effects.Create("tfa_muzzlesmoke", fx)
	end
end

function SWEP:MuzzleFlashCustom(spv)
	local retVal = hook.Run("TFA_MuzzleFlash",self)
	if retVal ~= nil then
		return retVal
	end
	local att = self:GetMuzzleAttachment()
	fx = EffectData()
	fx:SetOrigin(self:GetOwner():GetShootPos())
	fx:SetNormal(self:GetOwner():EyeAngles():Forward())
	fx:SetEntity(self)
	fx:SetAttachment(att)
	local mzsil = self:GetStat("MuzzleFlashEffectSilenced")

	if (self:GetSilenced() and mzsil and mzsil ~= "") then
		TFA.Effects.Create(mzsil, fx)
	else
		TFA.Effects.Create(self:GetStat("MuzzleFlashEffect", self.MuzzleFlashEffect or ""), fx)
	end
end

function SWEP:ShootEffectsCustom(ifp)
	if self.DoMuzzleFlash ~= nil then
		self.MuzzleFlashEnabled = self.DoMuzzleFlash
		self.DoMuzzleFlash = nil
	end

	if not self.MuzzleFlashEnabled then return end
	if self:IsFirstPerson() and not self:VMIV() then return end
	if not self:GetOwner().GetShootPos then return end
	ifp = ifp or IsFirstTimePredicted()

	if sp == nil then
		sp = game.SinglePlayer()
	end

	if (SERVER and sp and self.ParticleMuzzleFlash) or (SERVER and not sp) then
		net.Start("tfa_base_muzzle_mp")
		net.WriteEntity(self)

		if (sp) then
			net.Broadcast()
		else
			net.SendOmit(self:GetOwner())
		end

		return
	end

	if (CLIENT and ifp and not sp) or (sp and SERVER) then
		self:UpdateMuzzleAttachment()
		self:MuzzleFlashCustom(sp)
		self:MuzzleSmoke(sp)
	end
end

--[[
Function Name:  CanDustEffect
Syntax: self:CanDustEffect( concise material name ).
Returns:  True/False
Notes:	Used for the impact effect.  Should be used with GetMaterialConcise.
Purpose:  Utility
]]
--
local DustEffects = {
	[MAT_DIRT] = true,
	[MAT_CONCRETE] = true,
	[MAT_PLASTIC] = true,
	[MAT_WOOD] = true
}
function SWEP:CanDustEffect(matv)
	if DustEffects[matv] then return true end

	return false
end

--[[
Function Name:  CanSparkEffect
Syntax: self:CanSparkEffect( concise material name ).
Returns:  True/False
Notes:	Used for the impact effect.  Should be used with GetMaterialConcise.
Purpose:  Utility
]]
--
local SparkEffects = {
	[MAT_METAL] = true,
	[MAT_GRATE] = true,
	[MAT_VENT] = true
}
function SWEP:CanSparkEffect(matv)
	if SparkEffects[matv] then return true end

	return false
end

-- Returns muzzle attachment position for HL2 tracers
function SWEP:GetTracerOrigin(...)
	local att = self:GetMuzzleAttachment()

	local attpos = (self:IsFirstPerson() and self.OwnerViewModel or self):GetAttachment(att)

	if attpos and attpos.Pos then
		return attpos.Pos
	end
end
