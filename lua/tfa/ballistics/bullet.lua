
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

--[[Bullet Struct:
[BULLET_ID] = {
	["owner"] = Entity, --used for dmginfo SetAttacker
	["inflictor"] = Entity, --used for dmginfo SetInflictor
	["damage"] = Double, --floating point number representing inflicted damage
	["force"] = Double,
	["pos"] = Vector, --vector representing current position
	["velocity"] = Vector, --vector representing movement velocity
	["model"] = String --optional variable representing the given model,
	["bul"] = {} --optional table containing bullet data,
	["smokeparticle"] = String, --smoke particle name from within pcf
	["bulletOverride"] = Bool --disable coming out of gun barrel on clientside
}
]]
local BallisticBullet = {
	["owner"] = NULL,
	["inflictor"] = NULL,
	["damage"] = 0,
	["force"] = 0,
	["pos"] = vector_origin,
	["velocity"] = vector_origin,
	["model"] = "models/bullets/w_pbullet1.mdl",
	["bul"] = {},
	["delete"] = false,
	["smokeparticle"] = "tfa_bullet_smoke_tracer"
}

local traceRes = {}

local traceData = {
	mask = MASK_SHOT,
	collisiongroup = COLLISION_GROUP_NONE,
	ignoreworld = false,
	output = traceRes
}

local MASK_SHOT_NOWATER = MASK_SHOT

--main update block
function BallisticBullet:Update(delta)
	self:_setup()
	if self.delete then return end
	local newPos = self:_getnewPosition(delta)
	newPos = self:_checkWater(delta, newPos)
	self:_accelerate(delta)
	self:_moveSafe(newPos)
end

--internal function for sanity checks, etc.
function BallisticBullet:_setup()
	self.creationTime = self.creationTime or CurTime()

	if (not IsValid(self.owner)) or (not IsValid(self.inflictor)) then
		self:Remove()
	end

	if CurTime() > self.creationTime + TFA.Ballistics.BulletLife then
		self:Remove()
	end

	if self.playerOwned == nil then
		self.playerOwned = self.owner.IsPlayer and self.owner:IsPlayer()
	end

	self.startVelocity = self.startVelocity or self.velocity:Length()
	self.startDamage = self.startDamage or self.damage
end

--internal function for calculating position change
function BallisticBullet:_getnewPosition(delta)
	--verlet
	return self.pos + (self.velocity + TFA.Ballistics.Gravity * delta * 0.5) * delta
end

--internal function for handling water
function BallisticBullet:_checkWater(delta, target)
	local newPos = target
	traceData.start = self.pos
	traceData.endpos = newPos
	traceData.filter = {self.owner, self.inflictor}
	traceData.mask = MASK_WATER
	util.TraceLine(traceData)

	if traceRes.Hit and traceRes.Fraction < 1 and traceRes.Fraction > 0 and not self.Underwater then
		self.Underwater = true
		newPos = traceRes.HitPos + traceRes.Normal
		self.velocity = self.velocity / TFA.Ballistics.WaterEntranceResistance
		local fx = EffectData()
		fx:SetOrigin(newPos)
		local sc = math.sqrt(self.damage / 28) * 6
		fx:SetScale(sc)
		util.Effect("gunshotsplash", fx)
	end

	return newPos
end

--internal function for handling acceleration
local function GetWind()
	local wind = vector_origin

	if StormFox then
		local windSpeed = StormFox.GetNetworkData("Wind") * TFA.Ballistics.UnitScale
		local windAng = Angle(0, StormFox.GetNetworkData("WindAngle"), 0)
		wind = windSpeed * windAng:Forward():GetNormalized()
	end

	return wind
end

function BallisticBullet:_accelerate(delta)
	local dragDensity = self.Underwater and TFA.Ballistics.WaterResistance or TFA.Ballistics.AirResistance
	local drag = -self.velocity:GetNormalized() * self.velocity:Length() * self.velocity:Length() * 0.00006 * dragDensity
	local wind = GetWind()

	if self.Underwater then
		self.velocity = self.velocity / (1 + TFA.Ballistics.WaterResistance * delta)
	end

	self.velocity = self.velocity + (TFA.Ballistics.Gravity + drag + wind) * delta
	self.damage = self.startDamage * math.sqrt(self.velocity:Length() / self.startVelocity)
end

--internal function for moving with collision test
function BallisticBullet:_moveSafe(newPos)
	traceData.start = self.pos
	traceData.endpos = newPos + (newPos - self.pos):GetNormalized()
	traceData.filter = {self.owner, self.inflictor}
	traceData.mask = MASK_SHOT_NOWATER

	--collision trace
	if self.playerOwned then
		self.owner:LagCompensation(true)
	end

	util.TraceLine(traceData)

	if self.playerOwned then
		self.owner:LagCompensation(false)
	end

	--collision check
	if traceRes.Hit and traceRes.Fraction < 1 and traceRes.Fraction > 0 then
		self:Impact(traceRes)
	else
		self.pos = newPos
	end
end

--called when hitting something, or manually if necessary
function BallisticBullet:Impact(tr)
	self.pos = tr.HitPos
	self:Remove()
	if CLIENT and (game.SinglePlayer() or self.owner ~= LocalPlayer()) then return end
	if tr.HitSky then return end
	local vn = self.velocity:GetNormalized()

	local bul = {
		["Damage"] = self.damage,
		["Force"] = self.force,
		["Num"] = 1,
		["Src"] = self.pos - vn * 4,
		["Dir"] = vn * 8,
		["Spread"] = vector_origin,
		["IgnoreEntity"] = self.owner,
		["Attacker"] = self.owner,
		["Distance"] = 8,
		["Tracer"] = 0
	}

	setmetatable(bul, {
		["__index"] = self.bul
	})

	self.owner:FireBullets(bul, true)
end

--Render
local cv_bullet_style, cv_tracers_adv

if CLIENT then
	CreateClientConVar("cl_tfa_ballistics_mp", "1", true, false, "Receive bullet data from other players?")
	cv_bullet_style = CreateClientConVar("cl_tfa_ballistics_fx_bullet", "1", true, false, "Display bullet models for each TFA ballistics bullet?")
	CreateClientConVar("cl_tfa_ballistics_fx_tracers_style", "1", true, false, "Style of tracers for TFA ballistics? 0=disable,1=smoke")
	CreateClientConVar("cl_tfa_ballistics_fx_tracers_mp", "1", true, false, "Enable tracers for other TFA ballistics users?")
	cv_tracers_adv = CreateClientConVar("cl_tfa_ballistics_fx_tracers_adv", "1", true, false, "Enable advanced tracer calculations for other users? This corrects smoke trail to their barrel")
	--[[
	cv_receive = GetConVar("cl_tfa_ballistics_mp")
	cv_bullet_style = GetConVar("cl_tfa_ballistics_fx_bullet")
	cv_tracers_style = GetConVar("cl_tfa_ballistics_fx_tracers_style")
	cv_tracers_mp = GetConVar("cl_tfa_ballistics_fx_tracers_mp")
	cv_tracers_adv = GetConVar("cl_tfa_ballistics_fx_tracers_adv")
	]]
	--
end

local DEFANGPOS = {
	Pos = vector_origin,
	Ang = angle_zero
}

function BallisticBullet:Render()
	if SERVER then return end
	if self.delete then return end

	if not self.curmodel then
		self.curmodel = ClientsideModel(self.model, RENDERGROUP_OPAQUE)
		self.curmodel:SetNoDraw(true)
	end

	if IsValid(self.curmodel) and (cv_bullet_style:GetBool() or self.smokeparticle ~= "") then
		local fpos, fang

		if self.customPosition then
			fpos = self.pos
			fang = self.velocity:Angle()
		else
			if self.owner == GetViewEntity() or self.owner == LocalPlayer() then
				local spos, sang = self.pos, self.velocity:Angle()
				self.curmodel:SetPos(spos)
				self.curmodel:SetAngles(sang)

				if not self.vOffsetPos then
					local att

					if self.inflictor.GetMuzzleAttachment and self.inflictor:GetMuzzleAttachment() then
						att = self.inflictor:GetMuzzleAttachment()
					else
						att = self.inflictor.MuzzleAttachmentRaw or 1
					end

					if LocalPlayer():ShouldDrawLocalPlayer() then
						local npos = LocalPlayer():GetActiveWeapon():GetAttachment(att) or DEFANGPOS
						self.vOffsetPos = self.curmodel:WorldToLocal(npos.Pos)
						self.vOffsetAng = self.curmodel:WorldToLocalAngles(npos.Ang)
					else
						local npos = LocalPlayer():GetViewModel():GetAttachment(att) or DEFANGPOS
						self.vOffsetPos = self.curmodel:WorldToLocal(npos.Pos)
						self.vOffsetAng = self.curmodel:WorldToLocalAngles(npos.Ang)
					end
				end

				fpos = self.curmodel:LocalToWorld(self.vOffsetPos)
				fang = self.curmodel:LocalToWorldAngles(self.vOffsetAng)
			elseif self.owner:IsPlayer() and cv_tracers_adv:GetBool() then
				local spos, sang = self.pos, self.velocity:Angle()
				self.curmodel:SetPos(spos)
				self.curmodel:SetAngles(sang)

				if not self.vOffsetPos then
					local npos = self.owner:GetActiveWeapon():GetAttachment(1) or DEFANGPOS
					self.vOffsetPos = self.curmodel:WorldToLocal(npos.Pos)
					self.vOffsetAng = self.curmodel:WorldToLocalAngles(npos.Ang)
				end

				fpos = self.curmodel:LocalToWorld(self.vOffsetPos)
				fang = self.curmodel:LocalToWorldAngles(self.vOffsetAng)
			else
				fpos = self.pos
				fang = self.velocity:Angle()
			end
		end

		self.curmodel:SetPos(fpos)
		self.curmodel:SetAngles(fang)

		if cv_bullet_style:GetBool() then
			self.curmodel:SetupBones()
			self.curmodel:DrawModel()
		end
	end

	if self.smokeparticle ~= "" and not self.cursmoke then
		self.cursmoke = CreateParticleSystem(self.curmodel, self.smokeparticle, PATTACH_ABSORIGIN_FOLLOW, 1)
		self.cursmoke:StartEmission()
	elseif self.cursmoke then
		self.cursmoke:SetSortOrigin(self.owner:GetShootPos())

		if self.Underwater then
			self.cursmoke:StopEmission()
			self.cursmoke = nil
			self.smokeparticle = ""
		end
	end
end

function BallisticBullet:Remove()
	if self.cursmoke then
		self.cursmoke:StopEmission()
		self.cursmoke = nil
	end

	if self.curmodel and self.curmodel.Remove then
		self.curmodel:Remove()
		self.curmodel = nil
	end

	self.delete = true
end

local CopyTable = table.Copy

function TFA.Ballistics:Bullet(t)
	local b = CopyTable(t or {})

	setmetatable(b, {
		["__index"] = BallisticBullet
	})

	return b
end