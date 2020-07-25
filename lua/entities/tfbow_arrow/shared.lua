
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

ENT.Type = "anim"
ENT.PrintName = "TFBow Arrow"
ENT.Author = "TheForgottenArchitect"
ENT.Contact = "Don't"
ENT.Purpose = "Arrow Entity"
ENT.Instructions = "Spawn this with a velocity, get rich"

local function GetBoneCenter(ent, bone)
	local bonechildren = ent:GetChildBones(bone)

	if #bonechildren <= 0 then
		return ent:GetBonePosition(bone)
	else
		local bonepos = ent:GetBonePosition(bone)
		local tmppos = bonepos

		if tmppos then
			for i = 1, #bonechildren do
				local childpos = ent:GetBonePosition(bonechildren[i])

				if childpos then
					tmppos = (tmppos + childpos) / 2
				end
			end
		else
			return ent:GetPos()
		end

		return tmppos
	end
end

function ENT:GetClosestBonePos(ent, pos)
	local i, count, dist, ppos, cbone
	i = 1
	count = ent:GetBoneCount()
	cbone = 0
	dist = 99999999
	ppos = ent:GetPos()

	while (i < count) do
		local bonepos = GetBoneCenter(ent, i)

		if bonepos:Distance(pos) < dist then
			dist = bonepos:Distance(pos)
			cbone = i
			ppos = bonepos
		end

		i = i + 1
	end

	return ppos, cbone
end

local cv_al = GetConVar("sv_tfa_arrow_lifetime")
local cv_ht = GetConVar("host_timescale")

function ENT:Initialize()
	if SERVER then
		if not IsValid(self.myowner) then
			self.myowner = self:GetOwner()

			if not IsValid(self.myowner) then
				self.myowner = self
			end
		end

		timer.Simple(0, function()
			if self.model then
				self:SetModel(self.model)
			end
		end)

		if cv_al:GetInt() ~= -1 then
			timer.Simple( cv_al:GetFloat() + 5, function()
				if IsValid(self) then
					self:Remove()
				end
			end)
		end

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local phys = self:GetPhysicsObject()

		if (phys:IsValid()) then
			phys:Wake()

			if self.velocity then
				phys:SetVelocityInstantaneous(self.velocity)
			end

			phys:EnableCollisions(false)
			self:StartMotionController()
			self:PhysicsUpdate(phys, 0.1 * cv_ht:GetFloat() )
		end
	end

	self:SetNW2Vector("lastpos", self:GetPos())

	if not self.mydamage then
		self.mydamage = 60
	end

	if not self.gun then
		if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
			self:UpdateGun()
		else
			timer.Simple(0, function()
				if IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
					self:UpdateGun()
				end
			end)
		end
	end
end

function ENT:UpdateGun()
	local wep = self:GetOwner():GetActiveWeapon()

	if IsValid(wep) then
		self.gun = wep:GetClass()
	end
end

local wl,tracedata,tr

local cv_fm = GetConVar("sv_tfa_force_multiplier")

function ENT:HitCB(a,b,c)
	c:SetDamageType(bit.bor(DMG_NEVERGIB, DMG_CLUB))

	if IsValid(self) and IsValid(self:GetOwner()) then
		if b.HitWorld then
			local arrowstuck = ents.Create("tfbow_arrow_stuck")
			arrowstuck:SetModel(self:GetModel())
			arrowstuck.gun = self.gun
			arrowstuck:SetPos(tr.HitPos)
			local phys = self:GetPhysicsObject()
			arrowstuck:SetAngles((phys:GetVelocity()):Angle())
			arrowstuck:Spawn()
		else
			if IsValid(b.Entity) then
				if (not b.Entity:IsWorld()) then
					local arrowstuck = ents.Create("tfbow_arrow_stuck_clientside")
					arrowstuck:SetModel(self:GetModel())
					arrowstuck:SetPos(tr.HitPos)
					local ang = self:GetAngles()
					arrowstuck.gun = self.gun
					arrowstuck:SetAngles(ang)
					arrowstuck.targent = tr.Entity
					arrowstuck.targphysbone = tr.PhysicsBone
					arrowstuck:Spawn()
				else
					local arrowstuck = ents.Create("tfbow_arrow_stuck")
					arrowstuck:SetModel(self:GetModel())
					arrowstuck.gun = self.gun
					arrowstuck:SetPos(tr.HitPos)
					arrowstuck:SetAngles(self:GetAngles())
					arrowstuck:Spawn()
				end
			end
		end

		self:Remove()
	elseif IsValid(self) then
		self:Remove()
	end
end

function ENT:Think()
	wl = self:WaterLevel()

	if not self.prevwaterlevel then
		self.prevwaterlevel = wl
	end

	if self.prevwaterlevel ~= wl and wl - self.prevwaterlevel >= 1 then
		--print(wl)
		local ef = EffectData()
		ef:SetOrigin(self:GetPos())
		util.Effect("watersplash", ef)
	end

	self.prevwaterlevel = wl

	if wl >= 2 then
		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:SetVelocity(phys:GetVelocity() * math.sqrt(9 / 10))
		end
	end

	tracedata = {}
	tracedata.start = self:GetNW2Vector("lastpos", self:GetPos())
	tracedata.endpos = self:GetPos()
	tracedata.mask = MASK_SOLID
	tracedata.filter = {self.myowner, self:GetOwner(), self}
	tr = util.TraceLine(tracedata)

	--self:SetAngles((((tracedata.endpos-tracedata.start):GetNormalized()+self:GetAngles():Forward())/2):Angle())
	if (tr.Hit and tr.Fraction < 1 and tr.Fraction > 0) then
		debugoverlay.Line(tracedata.start, tr.HitPos, 10, Color(255, 0, 0, 255), true)
		debugoverlay.Cross(tr.HitPos, 5, 10, Color(255, 0, 0, 255), true)

		if SERVER then
			--[[
			local bul ={}
			bul.Attacker=self:GetOwner() and self:GetOwner() or self:GetOwner()
			bul.Spread=vector_origin
			bul.Src=tracedata.start
			bul.Force=self.mydamage*0.25*GetConVarNumber("sv_tfbow_force_multiplier",1)
			bul.Damage=self.mydamage
			bul.Tracer	= 0							-- Show a tracer on every x bullets
			bul.TracerName = "None"
			bul.Dir=((tr.HitPos-bul.Src):GetNormalized())

			bul.Attacker:FireBullets( bul )
			]]
			--
			local bul = {}
			bul.Attacker = self:GetOwner() and self:GetOwner() or self:GetOwner()
			bul.Spread = vector_origin
			bul.Src = tracedata.start
			bul.Force = self.mydamage * 0.25 * cv_fm:GetFloat()
			bul.Damage = self.mydamage
			bul.Tracer = 0 -- Show a tracer on every x bullets
			bul.TracerName = "None"
			bul.Dir = (tr.HitPos - bul.Src):GetNormalized()

			bul.Callback = function(a, b, c)
				self:HitCB(a,b,c)
			end

			bul.Attacker:FireBullets(bul)
		end

		return
	end

	self:SetNW2Vector("lastpos", self:GetPos())
end
