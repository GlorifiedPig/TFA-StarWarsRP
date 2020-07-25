
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

local l_Lerp = function(t, a, b) return a + (b - a) * t end
--[[
local l_mathMin = function(a, b) return (a < b) and a or b end
local l_mathMax = function(a, b) return (a > b) and a or b end
local l_ABS = function(a) return (a < 0) and -a or a end
local l_mathClamp = function(t, a, b) return l_mathMax(l_mathMin(t, b), a) end

local l_mathApproach = function(a, b, delta)
	if a < b then
		return l_mathMin(a + l_ABS(delta), b)
	else
		return l_mathMax(a - l_ABS(delta), b)
	end
end
local l_NormalizeAngle = math.NormalizeAngle
local LerpAngle = LerpAngle

local function util_NormalizeAngles(a)
	a.p = l_NormalizeAngle(a.p)
	a.y = l_NormalizeAngle(a.y)
	a.r = l_NormalizeAngle(a.r)

	return a
end
]]
--
local vm_offset_pos = Vector()
local vm_offset_ang = Angle()
--local fps_max_cvar = GetConVar("fps_max")
local righthanded, shouldflip, cl_vm_flip_cv, cl_vm_nearwall, fovmod_add, fovmod_mult

local cv_fov = GetConVar("fov_desired")

function SWEP:CalculateViewModelFlip()
	if CLIENT and not cl_vm_flip_cv then
		cl_vm_flip_cv = GetConVar("cl_tfa_viewmodel_flip")
		fovmod_add = GetConVar("cl_tfa_viewmodel_offset_fov")
		fovmod_mult = GetConVar("cl_tfa_viewmodel_multiplier_fov")
	end

	if self.ViewModelFlipDefault == nil then
		self.ViewModelFlipDefault = self.ViewModelFlip
	end

	righthanded = true

	if SERVER and self:GetOwner():GetInfoNum("cl_tfa_viewmodel_flip", 0) == 1 then
		righthanded = false
	end

	if CLIENT and cl_vm_flip_cv:GetBool() then
		righthanded = false
	end

	shouldflip = self.ViewModelFlipDefault

	if not righthanded then
		shouldflip = not self.ViewModelFlipDefault
	end

	if self.ViewModelFlip ~= shouldflip then
		self.ViewModelFlip = shouldflip
	end

	self.ViewModelFOV_OG = self.ViewModelFOV_OG or self.ViewModelFOV

	local cam_fov = self.LastTranslatedFOV or cv_fov:GetInt()
	local iron_add = cam_fov * (1 - 90 / cam_fov) * math.max(1 - self:GetStat("Secondary.IronFOV") / 90, 0)

	self.ViewModelFOV = l_Lerp(self.IronSightsProgress, self.ViewModelFOV_OG, self:GetStat("IronViewModelFOV", self.ViewModelFOV_OG)) * fovmod_mult:GetFloat() + fovmod_add:GetFloat() + iron_add * self.IronSightsProgress
end

SWEP.WeaponLength = 0

function SWEP:UpdateWeaponLength()
	if not self:VMIV() then return end
	local vm = self.OwnerViewModel
	local mzpos = self:GetMuzzlePos()
	if not mzpos then return end
	if not mzpos.Pos then return end
	if GetViewEntity and GetViewEntity() ~= self:GetOwner() then return end
	local mzVec = vm:WorldToLocal(mzpos.Pos)
	self.WeaponLength = math.abs(mzVec.x)
end

SWEP.NearWallVector = Vector(0.1, -0.5, -0.2):GetNormalized() * 0.5
SWEP.NearWallVectorADS = Vector(0, 0, 0)

function SWEP:CalculateNearWall(p, a)
	if not self:OwnerIsValid() then return p, a end

	if not cl_vm_nearwall then
		cl_vm_nearwall = GetConVar("cl_tfa_viewmodel_nearwall")
	end

	if not cl_vm_nearwall or not cl_vm_nearwall:GetBool() then return p, a end

	local sp = self:GetOwner():GetShootPos()
	local ea = self:GetOwner():EyeAngles()
	local et = util.QuickTrace(sp,ea:Forward()*128,{self,self:GetOwner()})--self:GetOwner():GetEyeTrace()
	local dist = et.HitPos:Distance(sp)
	if dist<1 then
		et=util.QuickTrace(sp,ea:Forward()*128,{self,self:GetOwner(),et.Entity})
		dist = et.HitPos:Distance(sp)
	end

	self:UpdateWeaponLength()

	local nw_offset_vec = self:GetIronSights() and self.NearWallVectorADS or self.NearWallVector
	local off = self.WeaponLength - dist

	if off > 0 then
		p = p + nw_offset_vec * off / 2
		local posCompensated = sp * 1
		posCompensated:Add(ea:Right() * nw_offset_vec.x * off / 2 * (self.ViewModelFlip and -1 or 1))
		posCompensated:Add(ea:Forward() * nw_offset_vec.y * off / 2)
		posCompensated:Add(ea:Up() * nw_offset_vec.z * off / 2)
		local angleComp = (et.HitPos - posCompensated):Angle()
		a.x = a.x - math.AngleDifference(angleComp.p, ea.p) / 2
		a.y = a.y + math.AngleDifference(angleComp.y, ea.y) / 2
	end

	return p, a
end

local target_pos, target_ang, adstransitionspeed, hls
local flip_vec = Vector(-1, 1, 1)
local flip_ang = Vector(1, -1, -1)
local cl_tfa_viewmodel_offset_x
local cl_tfa_viewmodel_offset_y, cl_tfa_viewmodel_offset_z, cl_tfa_viewmodel_centered
local intensityWalk, intensityRun, intensityBreath

if CLIENT then
	cl_tfa_viewmodel_offset_x = GetConVar("cl_tfa_viewmodel_offset_x")
	cl_tfa_viewmodel_offset_y = GetConVar("cl_tfa_viewmodel_offset_y")
	cl_tfa_viewmodel_offset_z = GetConVar("cl_tfa_viewmodel_offset_z")
	cl_tfa_viewmodel_centered = GetConVar("cl_tfa_viewmodel_centered")
end

target_pos = Vector()
target_ang = Vector()
local centered_sprintpos = Vector(0, -1, 1)
local centered_sprintang = Vector(-15, 0, 0)
local vmviewpunch_cv

function SWEP:CalculateViewModelOffset(delta)
	if self:GetStat("VMPos_Additive") then
		target_pos:Zero()
		target_ang:Zero()
	else
		target_pos = self:GetStat("VMPos") * 1
		target_ang = self:GetStat("VMAng") * 1
	end

	if cl_tfa_viewmodel_centered:GetBool() then
		if self:GetStat("CenteredPos") then
			target_pos.x = self:GetStat("CenteredPos").x
			target_pos.y = self:GetStat("CenteredPos").y
			target_pos.z = self:GetStat("CenteredPos").z

			if self:GetStat("CenteredAng") then
				target_ang.x = self:GetStat("CenteredAng").x
				target_ang.y = self:GetStat("CenteredAng").y
				target_ang.z = self:GetStat("CenteredAng").z
			end
		elseif self:GetStat("IronSightsPos") then
			target_pos.x = self:GetStat("IronSightsPos").x
			target_pos.z = target_pos.z - 3

			if self:GetStat("IronSightsAng") then
				target_ang:Zero()
				target_ang.y = self:GetStat("IronSightsAng").y
			end
		end
	end

	adstransitionspeed = 10
	local is = self:GetIronSights()
	local spr = self:GetSprinting()
	local stat = self:GetStatus()
	hls = (TFA.Enum.HolsterStatus[stat] and self.ProceduralHolsterEnabled) or (TFA.Enum.ReloadStatus[stat] and self.ProceduralReloadEnabled)

	if hls then
		target_pos = self:GetStat("ProceduralHolsterPos") * 1
		target_ang = self:GetStat("ProceduralHolsterAng") * 1

		if self.ViewModelFlip then
			target_pos = target_pos * flip_vec
			target_ang = target_ang * flip_ang
		end

		adstransitionspeed = self:GetStat("ProceduralHolsterTime") * 15
	elseif is and (self.Sights_Mode == TFA.Enum.LOCOMOTION_LUA or self.Sights_Mode == TFA.Enum.LOCOMOTION_HYBRID) then
		target_pos = (self:GetStat("IronSightsPos", self.SightsPos) or self:GetStat("SightsPos", vector_origin)) * 1
		target_ang = (self:GetStat("IronSightsAng", self.SightsAng) or self:GetStat("SightsAng", vector_origin)) * 1
		adstransitionspeed = 15 / (self:GetStat("IronSightTime") / 0.3)
	elseif (spr or self:IsSafety()) and (self.Sprint_Mode == TFA.Enum.LOCOMOTION_LUA or self.Sprint_Mode == TFA.Enum.LOCOMOTION_HYBRID or (self:IsSafety() and not spr)) and stat ~= TFA.Enum.STATUS_FIDGET and stat ~= TFA.Enum.STATUS_BASHING then
		if cl_tfa_viewmodel_centered and cl_tfa_viewmodel_centered:GetBool() then
			target_pos = target_pos + centered_sprintpos
			target_ang = target_ang + centered_sprintang
		elseif self:IsSafety() and self:GetStat("SafetyPos") and not spr then
			target_pos = self:GetStat("SafetyPos") * 1
			target_ang = self:GetStat("SafetyAng") * 1
		else
			target_pos = self:GetStat("RunSightsPos") * 1
			target_ang = self:GetStat("RunSightsAng") * 1
		end

		adstransitionspeed = 7.5
	end

	if cl_tfa_viewmodel_offset_x and not is then
		target_pos.x = target_pos.x + cl_tfa_viewmodel_offset_x:GetFloat()
		target_pos.y = target_pos.y + cl_tfa_viewmodel_offset_y:GetFloat()
		target_pos.z = target_pos.z + cl_tfa_viewmodel_offset_z:GetFloat()
	end

	if self.Inspecting and self.Customize_Mode ~= TFA.Enum.LOCOMOTION_ANI then
		if not self.InspectPos then
			self.InspectPos = self.InspectPosDef * 1

			if self.ViewModelFlip then
				self.InspectPos.x = self.InspectPos.x * -1
			end
		end

		if not self.InspectAng then
			self.InspectAng = self.InspectAngDef * 1

			if self.ViewModelFlip then
				self.InspectAng.x = self.InspectAngDef.x * 1
				self.InspectAng.y = self.InspectAngDef.y * -1
				self.InspectAng.z = self.InspectAngDef.z * -1
			end
		end

		target_pos = self:GetStat("InspectPos") * 1
		target_ang = self:GetStat("InspectAng") * 1
		adstransitionspeed = 10
	end

	target_pos, target_ang = self:CalculateNearWall(target_pos, target_ang)

	if self.VMPos_Additive then
		target_pos.x = target_pos.x + self.VMPos.x
		target_pos.y = target_pos.y + self.VMPos.y
		target_pos.z = target_pos.z + self.VMPos.z
		target_ang.x = target_ang.x + self.VMAng.x
		target_ang.y = target_ang.y + self.VMAng.y
		target_ang.z = target_ang.z + self.VMAng.z
	end

	target_ang.z = target_ang.z + -7.5 * (1 - math.abs(0.5 - self.IronSightsProgress) * 2) * (self:GetIronSights() and 1 or 0.5) * (self.ViewModelFlip and 1 or -1)

	if self:GetHidden() then
		target_pos.z = target_pos.z - 5
	end

	if self:GetStat("BlowbackEnabled") and self.BlowbackCurrentRoot > 0.01 then
		local bbvec = self:GetStat("BlowbackVector")
		target_pos = target_pos + bbvec * self.BlowbackCurrentRoot
		local bbang = self:GetStat("BlowbackAngle") or angle_zero
		bbvec = bbvec * 1
		bbvec.x = bbang.p
		bbvec.y = bbang.y
		bbvec.z = bbang.r
		target_ang = target_ang + bbvec * self.BlowbackCurrentRoot
		bbang = self.BlowbackRandomAngle * (1 - math.max(0, self.IronSightsProgress) * .8)
		bbvec.x = bbang.p
		bbvec.y = bbang.y
		bbvec.z = bbang.r
		target_ang = target_ang + bbvec * self.BlowbackCurrentRoot
		adstransitionspeed = adstransitionspeed + 15 * math.pow(self.BlowbackCurrentRoot, 2)
	end

	if vmviewpunch_cv and not vmviewpunch_cv:GetBool() then
		local vpa = self:GetOwner():GetViewPunchAngles()
		target_ang.x = target_ang.x + vpa.p
		target_ang.y = target_ang.y + vpa.y
		target_ang.z = target_ang.z + vpa.r
	elseif not vmviewpunch_cv then
		vmviewpunch_cv = GetConVar("cl_tfa_viewmodel_viewpunch")
	end

	vm_offset_pos.x = math.Approach(vm_offset_pos.x, target_pos.x, (target_pos.x - vm_offset_pos.x) * delta * adstransitionspeed)
	vm_offset_pos.y = math.Approach(vm_offset_pos.y, target_pos.y, (target_pos.y - vm_offset_pos.y) * delta * adstransitionspeed)
	vm_offset_pos.z = math.Approach(vm_offset_pos.z, target_pos.z, (target_pos.z - vm_offset_pos.z) * delta * adstransitionspeed)
	vm_offset_ang.p = math.ApproachAngle(vm_offset_ang.p, target_ang.x, math.AngleDifference(target_ang.x, vm_offset_ang.p) * delta * adstransitionspeed)
	vm_offset_ang.y = math.ApproachAngle(vm_offset_ang.y, target_ang.y, math.AngleDifference(target_ang.y, vm_offset_ang.y) * delta * adstransitionspeed)
	vm_offset_ang.r = math.ApproachAngle(vm_offset_ang.r, target_ang.z, math.AngleDifference(target_ang.z, vm_offset_ang.r) * delta * adstransitionspeed)

	intensityWalk = math.min(self:GetOwner():GetVelocity():Length2D() / self:GetOwner():GetWalkSpeed(), 1)

	if self.WalkBobMult_Iron and self.IronSightsProgress > 0.01 then
		intensityWalk = intensityWalk * self.WalkBobMult_Iron * self.IronSightsProgress
	else
		intensityWalk = intensityWalk * self.WalkBobMult
	end

	intensityBreath = l_Lerp(self.IronSightsProgress, self:GetStat("BreathScale", 0.2), self:GetStat("IronBobMultWalk", 0.5) * intensityWalk)
	intensityWalk = intensityWalk * (1 - self.IronSightsProgress)
	intensityRun = l_Lerp(self.SprintProgress, 0, self.SprintBobMult)
	local velocity = math.max(self:GetOwner():GetVelocity():Length2D() * self:AirWalkScale() - self:GetOwner():GetVelocity().z * 0.5, 0)
	local rate = math.min(math.max(0.15, math.sqrt(velocity / self:GetOwner():GetRunSpeed()) * 1.75), self:GetSprinting() and 5 or 3)

	self.pos_cached, self.ang_cached = self:WalkBob(vm_offset_pos * 1, vm_offset_ang * 1, math.max(intensityBreath - intensityWalk - intensityRun, 0), math.max(intensityWalk - intensityRun, 0), rate, delta)
end

--[[
Function Name:  Sway
Syntax: self:Sway( ang ).
Returns:  New angle.
Notes:  This is used for calculating the swep viewmodel sway.
Purpose:  Main SWEP function
]]
--
local rft, eyeAngles, viewPunch, oldEyeAngles, delta, motion, counterMotion, compensation, fac, positionCompensation, swayRate, wiggleFactor, flipFactor
--swayRate = 10
local gunswaycvar = GetConVar("cl_tfa_gunbob_intensity")

function SWEP:Sway(pos, ang, ftv)
	--sanity check
	if not self:OwnerIsValid() then return pos, ang end
	--convar
	fac = gunswaycvar:GetFloat() * 3 * ((1 - (self.IronSightsProgress or 0)) * 0.85 + 0.15)
	flipFactor = (self.ViewModelFlip and -1 or 1)
	--init vars
	delta = delta or Angle()
	motion = motion or Angle()
	counterMotion = counterMotion or Angle()
	compensation = compensation or Angle()

	if ftv then
		--grab eye angles
		eyeAngles = self:GetOwner():EyeAngles()
		viewPunch = self:GetOwner():GetViewPunchAngles()
		eyeAngles.p = eyeAngles.p - viewPunch.p
		eyeAngles.y = eyeAngles.y - viewPunch.y
		oldEyeAngles = oldEyeAngles or eyeAngles
		--calculate delta
		wiggleFactor = (1 - self:GetStat("MoveSpeed")) / 0.6 + 0.15
		swayRate = math.pow(self:GetStat("MoveSpeed"), 1.5) * 10
		rft = math.Clamp(ftv, 0.001, 1 / 20)
		local clampFac = 1.1 - math.min((math.abs(motion.p) + math.abs(motion.y) + math.abs(motion.r)) / 20, 1)
		delta.p = math.AngleDifference(eyeAngles.p, oldEyeAngles.p) / rft / 120 * clampFac
		delta.y = math.AngleDifference(eyeAngles.y, oldEyeAngles.y) / rft / 120 * clampFac
		delta.r = math.AngleDifference(eyeAngles.r, oldEyeAngles.r) / rft / 120 * clampFac
		oldEyeAngles = eyeAngles
		--calculate motions, based on Juckey's methods
		counterMotion = LerpAngle(rft * (swayRate * (0.75 + math.max(0, 0.5 - wiggleFactor))), counterMotion, -motion)
		compensation.p = math.AngleDifference(motion.p, -counterMotion.p)
		compensation.y = math.AngleDifference(motion.y, -counterMotion.y)
		motion = LerpAngle(rft * swayRate, motion, delta + compensation)
	end

	--modify position/angle
	positionCompensation = 0.2 + 0.2 * (self.IronSightsProgress or 0)
	pos:Add(-motion.y * positionCompensation * 0.66 * fac * ang:Right() * flipFactor) --compensate position for yaw
	pos:Add(-motion.p * positionCompensation * fac * ang:Up()) --compensate position for pitch
	ang:RotateAroundAxis(ang:Right(), motion.p * fac)
	ang:RotateAroundAxis(ang:Up(), -motion.y * 0.66 * fac * flipFactor)
	ang:RotateAroundAxis(ang:Forward(), counterMotion.r * 0.5 * fac * flipFactor)

	return pos, ang
end

--local vmfov
--local bbvec
function SWEP:AirWalkScale()
	return (self:OwnerIsValid() and self:GetOwner():IsOnGround()) and 1 or 0.2
end

function SWEP:GetViewModelPosition(pos, ang)
	if not self.pos_cached then return pos, ang end
	ang:RotateAroundAxis(ang:Right(), self.ang_cached.p)
	ang:RotateAroundAxis(ang:Up(), self.ang_cached.y)
	ang:RotateAroundAxis(ang:Forward(), self.ang_cached.r)
	pos:Add(ang:Right() * self.pos_cached.x)
	pos:Add(ang:Forward() * self.pos_cached.y)
	pos:Add(ang:Up() * self.pos_cached.z)
	pos, ang = self:Sway(pos, ang)
	return self:SprintBob(pos, ang, l_Lerp(self.SprintProgress, 0, self.SprintBobMult))
end

local onevec = Vector(1, 1, 1)

local function RBP(vm)
	local bc = vm:GetBoneCount()
	if not bc or bc <= 0 then return end

	for i = 0, bc do
		vm:ManipulateBoneScale(i, onevec)
		vm:ManipulateBoneAngles(i, angle_zero)
		vm:ManipulateBonePosition(i, vector_origin)
	end
end

function SWEP:ResetViewModelModifications()
	if not self:VMIV() then return end

	local vm = self.OwnerViewModel

	RBP(vm)

	vm:SetSkin(0)

	local matcount = #(vm:GetMaterials() or {})

	for i = 0, matcount do
		vm:SetSubMaterial(i, "")
	end

	for i = 0, #(vm:GetBodyGroups() or {}) - 1 do
		vm:SetBodygroup(i, 0)
	end
end
