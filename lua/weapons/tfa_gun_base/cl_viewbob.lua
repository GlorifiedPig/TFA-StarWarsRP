
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

SWEP.SprintBobMult = 1.5 -- More is more bobbing, proportionally.  This is multiplication, not addition.  You want to make this > 1 probably for sprinting.
SWEP.IronBobMult = 0.0 -- More is more bobbing, proportionally.  This is multiplication, not addition.  You want to make this < 1 for sighting, 0 to outright disable.
SWEP.IronBobMultWalk = 0.2 -- More is more bobbing, proportionally.  This is multiplication, not addition.  You want to make this < 1 for sighting, 0 to outright disable.
SWEP.WalkBobMult = 1 -- More is more bobbing, proportionally.  This is multiplication, not addition.  You may want to disable it when using animated walk.
SWEP.SprintViewBobMult = 4
--[[
Function Name:  CalcView
Syntax: Don't ever call this manually.
Returns:  Nothing.
Notes:  Used to calculate view angles.
Purpose:  Feature
]]
--"
--[[

local ta = Angle()
local v = Vector()

local m_AD = math.AngleDifference
local m_NA = math.NormalizeAngle

local l_LA = function(t,a1,a2)
	ta.p = m_NA( a1.p + m_AD(a2.p,a1.p)  * t )
	ta.y = m_NA( a1.y + m_AD(a2.y,a1.y)  * t )
	ta.r = m_NA( a1.r + m_AD(a2.r,a1.r)  * t )
	return ta
end

local l_LV = function(t,v1,v2)
	v = v1  + ( v2 - v1 ) * t
	return v * 1
end
]]
--
SWEP.ViewHolProg = 0
SWEP.AttachmentViewOffset = Angle(0, 0, 0)
SWEP.ProceduralViewOffset = Angle(0, 0, 0)
--local procedural_fadeout = 0.6
local procedural_vellimit = 5
local l_Lerp = Lerp
local l_mathApproach = math.Approach
local l_mathClamp = math.Clamp
local viewbob_intensity_cvar, viewbob_animated_cvar
viewbob_intensity_cvar = GetConVar("cl_tfa_viewbob_intensity")
viewbob_animated_cvar = GetConVar("cl_tfa_viewbob_animated")
local oldangtmp
local mzang_fixed
local mzang_fixed_last
local mzang_velocity = Angle()
local progress = 0
local targint, targbool

function SWEP:CalcView(ply, pos, ang, fov)
	if not ang then return end
	if ply ~= LocalPlayer() then return end
	local vm = ply:GetViewModel()
	if not IsValid(vm) then return end
	if not CLIENT then return end
	local ftv = math.max(TFA.FrameTime(), 0.001)
	local viewbobintensity = viewbob_intensity_cvar:GetFloat() * 0.5
	local holprog = TFA.Enum.HolsterStatus[self:GetStatus()] and 1 or 0
	self.ViewHolProg = math.Approach(self.ViewHolProg, holprog, ftv / 5)

	oldangtmp = ang * 1

	if self.CameraAngCache and viewbob_animated_cvar:GetBool() then
		self.CameraAttachmentScale = self.CameraAttachmentScale or 1
		ang:RotateAroundAxis(ang:Right(), (self.CameraAngCache.p + self.CameraOffset.p) * viewbobintensity * -self.CameraAttachmentScale)
		ang:RotateAroundAxis(ang:Up(), (self.CameraAngCache.y + self.CameraOffset.y) * viewbobintensity * self.CameraAttachmentScale)
		ang:RotateAroundAxis(ang:Forward(), (self.CameraAngCache.r + self.CameraOffset.r) * viewbobintensity * self.CameraAttachmentScale)
		-- - self.MZReferenceAngle--WorldToLocal( angpos.Pos, angpos.Ang, angpos.Pos, oldangtmp + self.MZReferenceAngle )
		--* progress )
		--self.ProceduralViewOffset.p = l_mathApproach(self.ProceduralViewOffset.p, 0 , l_mathClamp( procedural_pitchrestorefac - math.min( math.abs( self.ProceduralViewOffset.p ), procedural_pitchrestorefac ) ,1,procedural_pitchrestorefac)*ftv/5 )
		--self.ProceduralViewOffset.y = l_mathApproach(self.ProceduralViewOffset.y, 0 , l_mathClamp( procedural_pitchrestorefac - math.min( math.abs( self.ProceduralViewOffset.y ), procedural_pitchrestorefac ) ,1,procedural_pitchrestorefac)*ftv/5 )
		--self.ProceduralViewOffset.r = l_mathApproach(self.ProceduralViewOffset.r, 0 , l_mathClamp( procedural_pitchrestorefac - math.min( math.abs( self.ProceduralViewOffset.r ), procedural_pitchrestorefac ) ,1,procedural_pitchrestorefac)*ftv/5 )
	else
		local vb_d, vb_r, vb_s, idraw, ireload, ihols, stat
		stat = self:GetStatus()
		idraw = stat == TFA.GetStatus("draw")
		ihols = TFA.Enum.HolsterStatus[stat]
		ireload = TFA.Enum.ReloadStatus[stat]
		vb_d = viewbob_animated_cvar:GetBool()
		vb_r = viewbob_animated_cvar:GetBool()
		vb_s = viewbob_animated_cvar:GetBool()
		targbool = (vb_d and idraw) or (vb_r and ireload) or (self.GetBashing and self:GetBashing()) or (vb_s and stat == TFA.Enum.STATUS_SHOOTING and (self.ViewBob_Shoot or not self:CanInterruptShooting())) or stat == TFA.GetStatus("pump")
		targbool = targbool and not (ihols and self.ProceduralHolsterEnabled)
		targint = targbool and 1 or 0

		if stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_END or stat == TFA.Enum.STATUS_RELOADING or stat == TFA.GetStatus("pump") or (stat == TFA.Enum.STATUS_RELOADING_WAIT and not self.Shotgun) or stat == TFA.Enum.STATUS_SHOOTING or (idraw and vb_d) then
			targint = math.min(targint, 1 - math.pow(math.max(vm:GetCycle() - 0.5, 0) * 2, 2))
		end

		progress = l_Lerp(ftv * 15, progress, targint)
		local att = self.MuzzleAttachmentRaw or vm:LookupAttachment(self.MuzzleAttachment)

		if not att then
			att = 1
		end

		local angpos = vm:GetAttachment(att)

		if angpos then
			mzang_fixed = vm:WorldToLocalAngles(angpos.Ang)
			mzang_fixed:Normalize()
		end

		self.ProceduralViewOffset:Normalize()

		if mzang_fixed_last then
			local delta = mzang_fixed - mzang_fixed_last
			delta:Normalize()
			mzang_velocity = mzang_velocity + delta * (2 * (1 - self.ViewHolProg))
			mzang_velocity.p = l_mathApproach(mzang_velocity.p, -self.ProceduralViewOffset.p * 2, ftv * 20)
			mzang_velocity.p = l_mathClamp(mzang_velocity.p, -procedural_vellimit, procedural_vellimit)
			self.ProceduralViewOffset.p = self.ProceduralViewOffset.p + mzang_velocity.p * ftv
			self.ProceduralViewOffset.p = l_mathClamp(self.ProceduralViewOffset.p, -90, 90)
			mzang_velocity.y = l_mathApproach(mzang_velocity.y, -self.ProceduralViewOffset.y * 2, ftv * 20)
			mzang_velocity.y = l_mathClamp(mzang_velocity.y, -procedural_vellimit, procedural_vellimit)
			self.ProceduralViewOffset.y = self.ProceduralViewOffset.y + mzang_velocity.y * ftv
			self.ProceduralViewOffset.y = l_mathClamp(self.ProceduralViewOffset.y, -90, 90)
			mzang_velocity.r = l_mathApproach(mzang_velocity.r, -self.ProceduralViewOffset.r * 2, ftv * 20)
			mzang_velocity.r = l_mathClamp(mzang_velocity.r, -procedural_vellimit, procedural_vellimit)
			self.ProceduralViewOffset.r = self.ProceduralViewOffset.r + mzang_velocity.r * ftv
			self.ProceduralViewOffset.r = l_mathClamp(self.ProceduralViewOffset.r, -90, 90)
		end

		self.ProceduralViewOffset.p = l_mathApproach(self.ProceduralViewOffset.p, 0, (1 - progress) * ftv * -self.ProceduralViewOffset.p)
		self.ProceduralViewOffset.y = l_mathApproach(self.ProceduralViewOffset.y, 0, (1 - progress) * ftv * -self.ProceduralViewOffset.y)
		self.ProceduralViewOffset.r = l_mathApproach(self.ProceduralViewOffset.r, 0, (1 - progress) * ftv * -self.ProceduralViewOffset.r)
		mzang_fixed_last = mzang_fixed
		local ints = viewbob_intensity_cvar:GetFloat() * 1.25
		ang:RotateAroundAxis(ang:Right(), l_Lerp(progress, 0, -self.ProceduralViewOffset.p) * ints)
		ang:RotateAroundAxis(ang:Up(), l_Lerp(progress, 0, self.ProceduralViewOffset.y / 2) * ints)
		ang:RotateAroundAxis(ang:Forward(), Lerp(progress, 0, self.ProceduralViewOffset.r / 3) * ints)
	end

	return pos, LerpAngle(math.pow(self.ViewHolProg, 2), ang, oldangtmp), fov
end