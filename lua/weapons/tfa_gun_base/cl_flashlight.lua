
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
SWEP.FlashlightDistance = 12 * 50 -- default 50 feet
SWEP.FlashlightAttachment = 0
SWEP.FlashlightBrightness = 1
SWEP.FlashlightFOV = 60

local function IsHolstering(wep)
	if IsValid(wep) and TFA.Enum.HolsterStatus[wep:GetStatus()] then return true end

	return false
end

function SWEP:DrawFlashlight(is_vm)
	if not self.FlashlightDotMaterial then
		self.FlashlightDotMaterial = Material(self:GetStat("FlashlightMaterial") or "effects/flashlight001")
	end

	if not IsValid(self:GetOwner()) then return end

	if not self:GetFlashlightEnabled() then
		self:CleanFlashlight()

		return
	end

	if is_vm then
		if not self:VMIV() then
			self:CleanFlashlight()

			return
		end

		targetent = self.OwnerViewModel

		elemname = self:GetStat("Flashlight_VElement", self:GetStat("Flashlight_Element"))

		if elemname and self.VElements[elemname] and IsValid(self.VElements[elemname].curmodel) then
			targetent = self.VElements[elemname].curmodel
		end

		att = self:GetStat("FlashlightAttachment")

		attname = self:GetStat("FlashlightAttachmentName")

		if attname then
			att = targetent:LookupAttachment(attname)
		end

		if (not att) or att <= 0 then
			self:CleanFlashlight()

			return
		end

		angpos = targetent:GetAttachment(att)

		if not angpos then
			self:CleanFlashlight()

			return
		end

		if self.FlashlightISMovement and self.CLIronSightsProgress > 0 then
			local isang = self:GetStat("IronSightsAng")
			angpos.Ang:RotateAroundAxis(angpos.Ang:Right(), isang.y * (self.ViewModelFlip and -1 or 1) * self.CLIronSightsProgress)
			angpos.Ang:RotateAroundAxis(angpos.Ang:Up(), -isang.x * self.CLIronSightsProgress)
		end

		local localProjAng = select(2, WorldToLocal(vector_origin, angpos.Ang, vector_origin, EyeAngles()))
		localProjAng.p = localProjAng.p * self:GetOwner():GetFOV() / self.ViewModelFOV
		localProjAng.y = localProjAng.y * self:GetOwner():GetFOV() / self.ViewModelFOV
		local wsProjAng = select(2, LocalToWorld(vector_origin, localProjAng, vector_origin, EyeAngles())) --reprojection for view angle
		local ply = self:GetOwner()

		if not IsValid(ply.TFAFlashlightGun) and not IsHolstering(self) then
			local lamp = ProjectedTexture()
			ply.TFAFlashlightGun = lamp
			lamp:SetTexture(self.FlashlightDotMaterial:GetString("$basetexture"))
			lamp:SetFarZ(self:GetStat("FlashlightDistance")) -- How far the light should shine
			lamp:SetFOV(self:GetStat("FlashlightFOV"))
			lamp:SetPos(angpos.Pos)
			lamp:SetAngles(angpos.Ang)
			lamp:SetBrightness(self:GetStat("FlashlightBrightness") * (0.9  + 0.1 * math.max(math.sin(CurTime() * 120), math.cos(CurTime() * 40))))
			lamp:SetNearZ(1)
			lamp:SetColor(color_white)
			lamp:SetEnableShadows(true)
			lamp:Update()
		end

		local lamp = ply.TFAFlashlightGun

		if IsValid(lamp) then
			lamp:SetPos(angpos.Pos)
			lamp:SetAngles(wsProjAng)
			lamp:SetBrightness(1.4 + 0.1 * math.max(math.sin(CurTime() * 120), math.cos(CurTime() * 40)))
			lamp:Update()
		end
	else
		targetent = self

		elemname = self:GetStat("Flashlight_WElement", self:GetStat("Flashlight_Element"))

		if elemname and self.WElements[elemname] and IsValid(self.WElements[elemname].curmodel) then
			targetent = self.WElements[elemname].curmodel
		end

		att = self:GetStat("FlashlightAttachmentWorld", self:GetStat("FlashlightAttachment"))

		attname = self:GetStat("FlashlightAttachmentNameWorld", self:GetStat("FlashlightAttachmentName"))

		if attname then
			att = targetent:LookupAttachment(attname)
		end

		if (not att) or att <= 0 then
			self:CleanFlashlight()

			return
		end

		angpos = targetent:GetAttachment(att)

		if not angpos then
			angpos = targetent:GetAttachment(1)
		end

		if not angpos then
			self:CleanFlashlight()

			return
		end

		local ply = self:GetOwner()

		if not IsValid(ply.TFAFlashlightGun) and not IsHolstering(self) then
			local lamp = ProjectedTexture()
			ply.TFAFlashlightGun = lamp
			lamp:SetTexture(self.FlashlightDotMaterial:GetString("$basetexture"))
			lamp:SetFarZ(self:GetStat("FlashlightDistance")) -- How far the light should shine
			lamp:SetFOV(self:GetStat("FlashlightFOV"))
			lamp:SetPos(angpos.Pos)
			lamp:SetAngles(angpos.Ang)
			lamp:SetBrightness(self:GetStat("FlashlightBrightness") * (0.9  + 0.1 * math.max(math.sin(CurTime() * 120), math.cos(CurTime() * 40))))
			lamp:SetNearZ(1)
			lamp:SetColor(color_white)
			lamp:SetEnableShadows(false)
			lamp:Update()
		end

		local lamp = ply.TFAFlashlightGun

		if IsValid(lamp) then
			local lamppos = angpos.Pos
			local ang = angpos.Ang
			lamp:SetPos(lamppos)
			lamp:SetAngles(ang)
			lamp:SetBrightness(self:GetStat("FlashlightBrightness") * (0.9  + 0.1 * math.max(math.sin(CurTime() * 120), math.cos(CurTime() * 40))))
			lamp:Update()
		end
	end
end

function SWEP:CleanFlashlight()
	local ply = self:GetOwner()

	if IsValid(ply) and IsValid(ply.TFAFlashlightGun) then
		ply.TFAFlashlightGun:Remove()
	end
end