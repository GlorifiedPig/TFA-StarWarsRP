
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

local smokecol = Color(225, 225, 225, 200)
local smokemat = Material("trails/smoke")
smokemat:SetInt("$nocull", 1)

function EFFECT:AddPart()
	local pos, rawdat, norm
	pos = self.startpos
	norm = self.startnormal

	if self.targent and self.targatt then
		--pos = self:GetTracerShootPos(self.startpos, self.targent, self.targatt)
		rawdat = self.targent:GetAttachment(self.targatt)

		if rawdat then
			pos = rawdat.Pos
			norm = rawdat.Ang:Forward()
		end
	end

	local p = {}
	p.position = pos
	p.normal = norm
	p.velocity = p.normal * 5
	p.startlife = CurTime()
	p.lifetime = self.lifetime
	p.radius = self.radius

	if self.vparticles then
		table.insert(self.vparticles, #self.vparticles + 1, p)
	end
end

function EFFECT:ProcessFakeParticles()
	self.stepcount = self.stepcount + 1

	if self.vparticles then
		if CurTime() < self.emittime and self.stepcount % self.partinterval == 0 then
			self:AddPart()
		end

		for k, v in ipairs(self.vparticles) do
			v.position = v.position + v.velocity * FrameTime()
			v.velocity = v.velocity + self.grav * FrameTime()

			if CurTime() > v.startlife + v.lifetime then
				--print("Curtime:"..CurTime())
				--print("Lifetime:"..v.lifetime)
				--print("CTime:"..v.startlife)
				table.remove(self.vparticles, k)
			end
		end

		if #self.vparticles <= 0 then
			return false
		else
			return true
		end
	else
		return true
	end
end

local cv_gr = GetConVar("sv_gravity")

function EFFECT:Init(ef)
	self.lifetime = 1
	self.stepcount = 0
	self.partinterval = 3
	self.emittime = CurTime() + 3
	self.targent = ef:GetEntity()
	self.targatt = ef:GetAttachment()
	self.startpos = ef:GetOrigin()
	self.startnormal = ef:GetNormal()
	self.radius = ef:GetRadius()
	self.grav = Vector(0, 0, cv_gr:GetFloat() * 0.2)
	self.randfac = 1

	if not self.startpos then
		self.startpos = vector_origin

		if LocalPlayer():IsValid() then
			self.startpos = LocalPlayer():GetShootPos()
		end
	end

	if not self.startnormal then
		self.startnormal = vector_origin
	end

	if not self.radius or self.radius == 0 then
		self.radius = 1
	end

	self.vparticles = {}
	self:AddPart()
end

function EFFECT:Think()
	if self.vparticles and #self.vparticles <= 0 then return false end

	return true
end

function EFFECT:DrawBeam()
	render.StartBeam(#self.vparticles)

	for k, v in ipairs(self.vparticles) do
		local alphac = ColorAlpha(smokecol, (1 - (CurTime() - v.startlife) / v.lifetime) * 64)
		render.AddBeam(v.position, v.radius * (1 - k / #self.vparticles), k / #self.vparticles, alphac)
	end

	render.EndBeam()
end

function EFFECT:Render()
	self:ProcessFakeParticles()

	if self.vparticles and #self.vparticles >= 2 then
		render.SetMaterial(smokemat)
		self:DrawBeam()
	end
end
