
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

local att, angpos, attname, elemname, targetent
local col = Color(255, 0, 0, 255)
local pc
local laserline
local laserdot
local laserFOV = 1.5
local traceres

SWEP.LaserDistance = 12 * 50 -- default 50 feet
SWEP.LaserDistanceVisual = 12 * 4 --default 4 feet

local function IsHolstering(wep)
	if IsValid(wep) and TFA.Enum.HolsterStatus[wep:GetStatus()] then return true end

	return false
end

function SWEP:DrawLaser(is_vm)
	if not laserline then
		laserline = Material(self.LaserLine or "cable/smoke")
	end

	if not laserdot then
		laserdot = Material(self.LaserDot or "effects/tfalaserdot")
	end

	local ow = self:GetOwner()
	if not IsValid(ow) then return end
	local f = ow.GetNW2Vector or ow.GetNWVector
	pc = f(ow, "TFALaserColor", vector_origin)
	col.r = pc.x
	col.g = pc.y
	col.b = pc.z

	if is_vm then
		if not self:VMIV() then
			self:CleanLaser()

			return
		end

		targetent = self.OwnerViewModel

		elemname = self:GetStat("LaserSight_VElement", self:GetStat("LaserSight_Element"))

		if elemname and self.VElements[elemname] and IsValid(self.VElements[elemname].curmodel) then
			targetent = self.VElements[elemname].curmodel
		end

		att = self:GetStat("LaserSightAttachment")

		attname = self:GetStat("LaserSightAttachmentName")

		if attname then
			att = targetent:LookupAttachment(attname)
		end

		if (not att) or att <= 0 then
			self:CleanLaser()

			return
		end

		angpos = targetent:GetAttachment(att)

		if not angpos then
			self:CleanLaser()

			return
		end

		if self.LaserDotISMovement and self.CLIronSightsProgress > 0 then
			local isang = self:GetStat("IronSightsAng")
			angpos.Ang:RotateAroundAxis(angpos.Ang:Right(), isang.y * (self.ViewModelFlip and -1 or 1) * self.CLIronSightsProgress)
			angpos.Ang:RotateAroundAxis(angpos.Ang:Up(), -isang.x * self.CLIronSightsProgress)
		end

		local localProjAng = select(2, WorldToLocal(vector_origin, angpos.Ang, vector_origin, EyeAngles()))
		localProjAng.p = localProjAng.p * self:GetOwner():GetFOV() / self.ViewModelFOV
		localProjAng.y = localProjAng.y * self:GetOwner():GetFOV() / self.ViewModelFOV
		local wsProjAng = select(2, LocalToWorld(vector_origin, localProjAng, vector_origin, EyeAngles())) --reprojection for trace angle
		traceres = util.QuickTrace(self:GetOwner():GetShootPos(), wsProjAng:Forward() * 999999, self:GetOwner())

		local ply = self:GetOwner()

		if not IsValid(ply.TFALaserDot) and not IsHolstering(self) then
			local lamp = ProjectedTexture()
			ply.TFALaserDot = lamp
			lamp:SetTexture(laserdot:GetString("$basetexture"))
			lamp:SetFarZ(self.LaserDistance) -- How far the light should shine
			lamp:SetFOV(laserFOV)
			lamp:SetPos(angpos.Pos)
			lamp:SetAngles(angpos.Ang)
			lamp:SetBrightness(5)
			lamp:SetNearZ(1)
			lamp:SetEnableShadows(false)
			lamp:Update()
		end

		local lamp = ply.TFALaserDot

		if IsValid(lamp) then
			local lamppos = EyePos() + EyeAngles():Up() * 4
			local ang = (traceres.HitPos - lamppos):Angle()
			self.laserpos_old = traceres.HitPos
			ang:RotateAroundAxis(ang:Forward(), math.Rand(-180, 180))
			lamp:SetPos(lamppos)
			lamp:SetAngles(ang)
			lamp:SetColor(col)
			lamp:SetFOV(laserFOV * math.Rand(0.9, 1.1))
			lamp:Update()
		end
	else
		targetent = self

		elemname = self:GetStat("LaserSight_WElement", self:GetStat("LaserSight_Element"))

		if elemname and self.WElements[elemname] and IsValid(self.WElements[elemname].curmodel) then
			targetent = self.WElements[elemname].curmodel
		end

		att = self:GetStat("LaserSightAttachmentWorld", self:GetStat("LaserSightAttachment"))

		attname = self:GetStat("LaserSightAttachmentWorldName", self:GetStat("LaserSightAttachmentName"))

		if attname then
			att = targetent:LookupAttachment(attname)
		end

		if (not att) or att <= 0 then
			self:CleanLaser()

			return
		end

		angpos = targetent:GetAttachment(att)

		if not angpos then
			angpos = targetent:GetAttachment(1)
		end

		if not angpos then
			self:CleanLaser()

			return
		end

		local ply = self:GetOwner()

		if not IsValid(ply.TFALaserDot) and not IsHolstering(self) then
			local lamp = ProjectedTexture()
			ply.TFALaserDot = lamp
			lamp:SetTexture(laserdot:GetString("$basetexture"))
			lamp:SetFarZ(self.LaserDistance) -- How far the light should shine
			lamp:SetFOV(laserFOV)
			lamp:SetPos(angpos.Pos)
			lamp:SetAngles(angpos.Ang)
			lamp:SetBrightness(5)
			lamp:SetNearZ(1)
			lamp:SetEnableShadows(false)
			lamp:Update()
		end

		local lamp = ply.TFALaserDot

		if IsValid(lamp) then
			local ang = angpos.Ang
			ang:RotateAroundAxis(ang:Forward(), math.Rand(-180, 180))
			lamp:SetPos(angpos.Pos)
			lamp:SetAngles(ang)
			lamp:SetColor(col)
			lamp:SetFOV(laserFOV * math.Rand(0.9, 1.1))
			lamp:Update()
		end

		traceres = util.QuickTrace(angpos.Pos, angpos.Ang:Forward() * self.LaserDistance, self:GetOwner())
		local hpos = traceres.StartPos + angpos.Ang:Forward() * math.min(traceres.HitPos:Distance(angpos.Pos), self.LaserDistanceVisual )
		render.SetMaterial(laserline)
		render.SetColorModulation(1, 1, 1)
		render.StartBeam(2)
		col.r = math.sqrt(col.r / 255) * 255
		col.g = math.sqrt(col.g / 255) * 255
		col.b = math.sqrt(col.b / 255) * 255
		render.AddBeam(angpos.Pos, self.LaserBeamWidth or 0.25, 0, col)
		col.a = 0
		render.AddBeam(hpos, 0, 0, col)
		render.EndBeam()
	end
end

function SWEP:CleanLaser()
	local ply = self:GetOwner()

	if IsValid(ply) and IsValid(ply.TFALaserDot) then
		ply.TFALaserDot:Remove()
	end
end