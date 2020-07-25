
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

local nvec = Vector()

local function SetPlayerColors(ply)
	if not IsValid(ply) then return end

	local _SetNWVector = ply.SetNW2Vector or ply.SetNWVector

	nvec.x = ply:GetInfoNum("cl_tfa_laser_color_r", 255)
	nvec.y = ply:GetInfoNum("cl_tfa_laser_color_g", 0)
	nvec.z = ply:GetInfoNum("cl_tfa_laser_color_b", 0)
	_SetNWVector(ply, "TFALaserColor", nvec)

	nvec.x = ply:GetInfoNum("cl_tfa_reticule_color_r", 255)
	nvec.y = ply:GetInfoNum("cl_tfa_reticule_color_g", 0)
	nvec.z = ply:GetInfoNum("cl_tfa_reticule_color_b", 0)
	_SetNWVector(ply, "TFAReticuleColor", nvec)
end

hook.Add("PlayerSpawn", "TFANetworkColors_Spawn", SetPlayerColors)
concommand.Add("sv_tfa_apply_player_colors", SetPlayerColors)

if not matproxy then return end

matproxy.Add({
	name = "PlayerWeaponColorStatic",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
	end,
	bind = function(self, mat, ent)
		if (not IsValid(ent)) then return end
		local owner = ent:GetOwner()
		if (not IsValid(owner) or not owner:IsPlayer()) then return end
		local col = owner:GetWeaponColor()
		if (not isvector(col)) then return end
		mat:SetVector(self.ResultTo, col * 1)
	end
})

local cvec = Vector()

matproxy.Add({
	name = "TFALaserColor",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
	end,
	bind = function(self, mat, ent)
		local owner

		if (IsValid(ent)) then
			owner = ent:GetOwner()

			if not IsValid(owner) then
				owner = ent:GetParent()
			end

			if IsValid(owner) and owner:IsWeapon() then
				owner = owner:GetOwner() or owner:GetOwner()
			end

			if not (IsValid(owner) and owner:IsPlayer()) then
				owner = GetViewEntity()
			end
		else
			owner = GetViewEntity()
		end

		if (not IsValid(owner) or not owner:IsPlayer()) then return end
		local c

		if owner.GetNW2Vector then
			c = owner:GetNW2Vector("TFALaserColor") or cvec
		else
			c = owner:GetNWVector("TFALaserColor") or cvec
		end

		cvec.x = math.sqrt(c.r / 255) --sqrt for gamma
		cvec.y = math.sqrt(c.g / 255)
		cvec.z = math.sqrt(c.b / 255)
		mat:SetVector(self.ResultTo, cvec)
	end
})

local cvec_r = Vector()

matproxy.Add({
	name = "TFAReticuleColor",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
	end,
	bind = function(self, mat, ent)
		local owner

		if (IsValid(ent)) then
			owner = ent:GetOwner()

			if not IsValid(owner) then
				owner = ent:GetParent()
			end

			if IsValid(owner) and owner:IsWeapon() then
				owner = owner:GetOwner() or owner:GetOwner()
			end

			if not (IsValid(owner) and owner:IsPlayer()) then
				owner = GetViewEntity()
			end
		else
			owner = GetViewEntity()
		end

		if (not IsValid(owner) or not owner:IsPlayer()) then return end
		local c

		if owner.GetNW2Vector then
			c = owner:GetNW2Vector("TFAReticuleColor") or cvec_r
		else
			c = owner:GetNWVector("TFAReticuleColor") or cvec_r
		end

		cvec_r.x = c.r / 255
		cvec_r.y = c.g / 255
		cvec_r.z = c.b / 255
		mat:SetVector(self.ResultTo, cvec_r)
	end
})

matproxy.Add({
	name = "TFA_RTScope",
	init = function(self, mat, values)
		self.RTMaterial = Material("!tfa_rtmaterial")
	end,
	bind = function(self, mat, ent)
		if not self.RTMaterial then
			self.RTMaterial = Material("!tfa_rtmaterial")
		end

		mat:SetTexture("$basetexture", self.RTMaterial:GetTexture("$basetexture"))
	end
})