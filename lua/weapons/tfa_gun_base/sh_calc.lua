
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

local is, spr, walk, ist, sprt, walkt, ft, jr_targ
ft = 0.01
SWEP.LastRatio = nil

function SWEP:CalculateRatios(forced)
	local owent = self:GetOwner()
	if not IsValid(owent) or not owent:IsPlayer() then return end
	ft = TFA.FrameTime()
	is = self:GetIronSights()
	spr = self:GetSprinting()
	walk = self:GetWalking()
	ist = is and 1 or 0
	sprt = spr and 1 or 0
	walkt = walk and 1 or 0
	local adstransitionspeed

	if is then
		adstransitionspeed = 12.5 / (self:GetStat("IronSightTime") / 0.3)
	elseif spr or walk then
		adstransitionspeed = 7.5
	else
		adstransitionspeed = 12.5
	end

	if not ( IsFirstTimePredicted() or forced ) then return end
	self.CrouchingRatio = l_mathApproach(self.CrouchingRatio or 0, (owent:Crouching() and owent:OnGround()) and 1 or 0, ft / self.ToCrouchTime)
	self.SpreadRatio = l_mathClamp(self.SpreadRatio - self:GetStat("Primary.SpreadRecovery") * ft, 1, self:GetStat("Primary.SpreadMultiplierMax"))
	self.IronSightsProgress = l_mathApproach(self.IronSightsProgress, ist, (ist - self.IronSightsProgress) * ft * adstransitionspeed)
	self.SprintProgress = l_mathApproach(self.SprintProgress, sprt, (sprt - self.SprintProgress) * ft * adstransitionspeed)
	self.WalkProgress = l_mathApproach(self.WalkProgress, walkt, (walkt - self.WalkProgress) * ft * adstransitionspeed)
	self.ProceduralHolsterProgress = l_mathApproach(self.ProceduralHolsterProgress, sprt, (sprt - self.SprintProgress) * ft * self.ProceduralHolsterTime * 15)
	self.InspectingProgress = l_mathApproach(self.InspectingProgress, self.Inspecting and 1 or 0, ((self.Inspecting and 1 or 0) - self.InspectingProgress) * ft * 10)
	self.CLIronSightsProgress = self.IronSightsProgress --compatibility
	jr_targ = math.min(math.abs(owent:GetVelocity().z) / 500, 1)
	self.JumpRatio = l_mathApproach(self.JumpRatio, jr_targ, (jr_targ - self.JumpRatio) * ft * 20)
end

SWEP.IronRecoilMultiplier = 0.5 --Multiply recoil by this factor when we're in ironsights.  This is proportional, not inversely.
SWEP.CrouchRecoilMultiplier = 0.65 --Multiply recoil by this factor when we're crouching.  This is proportional, not inversely.
SWEP.JumpRecoilMultiplier = 1.3 --Multiply recoil by this factor when we're crouching.  This is proportional, not inversely.
SWEP.WallRecoilMultiplier = 1.1 --Multiply recoil by this factor when we're changing state e.g. not completely ironsighted.  This is proportional, not inversely.
SWEP.ChangeStateRecoilMultiplier = 1.3 --Multiply recoil by this factor when we're crouching.  This is proportional, not inversely.
SWEP.CrouchAccuracyMultiplier = 0.5 --Less is more.  Accuracy * 0.5 = Twice as accurate, Accuracy * 0.1 = Ten times as accurate
SWEP.ChangeStateAccuracyMultiplier = 1.5 --Less is more.  A change of state is when we're in the progress of doing something, like crouching or ironsighting.  Accuracy * 2 = Half as accurate.  Accuracy * 5 = 1/5 as accurate
SWEP.JumpAccuracyMultiplier = 2 --Less is more.  Accuracy * 2 = Half as accurate.  Accuracy * 5 = 1/5 as accurate
SWEP.WalkAccuracyMultiplier = 1.35 --Less is more.  Accuracy * 2 = Half as accurate.  Accuracy * 5 = 1/5 as accurate
SWEP.ToCrouchTime = 0.2
local mult_cvar = GetConVar("sv_tfa_spread_multiplier")
local dynacc_cvar = GetConVar("sv_tfa_dynamicaccuracy")
local ccon, crec
SWEP.JumpRatio = 0

function SWEP:CalculateConeRecoil()
	local dynacc = false
	local isr = self.IronSightsProgress or 0

	if dynacc_cvar:GetBool() and (self:GetStat("Primary.NumShots") <= 1) then
		dynacc = true
	end

	local isr_1 = l_mathClamp(isr * 2, 0, 1)
	local isr_2 = l_mathClamp((isr - 0.5) * 2, 0, 1)
	local acv = self:GetStat("Primary.Spread") or self:GetStat("Primary.Accuracy")
	local recv = self:GetStat("Primary.Recoil") * 5

	if dynacc then
		ccon = l_Lerp(isr_2, l_Lerp(isr_1, acv, acv * self:GetStat("ChangeStateAccuracyMultiplier")), self:GetStat("Primary.IronAccuracy"))
		crec = l_Lerp(isr_2, l_Lerp(isr_1, recv, recv * self:GetStat("ChangeStateRecoilMultiplier")), recv * self:GetStat("IronRecoilMultiplier"))
	else
		ccon = l_Lerp(isr, acv, self:GetStat("Primary.IronAccuracy"))
		crec = l_Lerp(isr, recv, recv * self:GetStat("IronRecoilMultiplier"))
	end

	local crc_1 = l_mathClamp(self.CrouchingRatio * 2, 0, 1)
	local crc_2 = l_mathClamp((self.CrouchingRatio - 0.5) * 2, 0, 1)

	if dynacc then
		ccon = l_Lerp(crc_2, l_Lerp(crc_1, ccon, ccon * self:GetStat("ChangeStateAccuracyMultiplier")), ccon * self:GetStat("CrouchAccuracyMultiplier"))
		crec = l_Lerp(crc_2, l_Lerp(crc_1, crec, self:GetStat("Primary.Recoil") * self:GetStat("ChangeStateRecoilMultiplier")), crec * self:GetStat("CrouchRecoilMultiplier"))
	end

	local ovel = self:GetOwner():GetVelocity():Length2D()
	local vfc_1 = l_mathClamp(ovel / self:GetOwner():GetWalkSpeed(), 0, 2)

	if dynacc then
		ccon = l_Lerp(vfc_1, ccon, ccon * self:GetStat("WalkAccuracyMultiplier"))
		crec = l_Lerp(vfc_1, crec, crec * self:GetStat("WallRecoilMultiplier"))
	end

	local jr = self.JumpRatio

	if dynacc then
		ccon = l_Lerp(jr, ccon, ccon * self:GetStat("JumpAccuracyMultiplier"))
		crec = l_Lerp(jr, crec, crec * self:GetStat("JumpRecoilMultiplier"))
	end

	ccon = ccon * self.SpreadRatio

	if mult_cvar then
		ccon = ccon * mult_cvar:GetFloat()
	end

	return ccon, crec
end