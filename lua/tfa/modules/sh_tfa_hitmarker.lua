
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

if SERVER then
	util.AddNetworkString("tfaHitmarker")
	util.AddNetworkString("tfaHitmarker3D")

	return
end

local ScrW, ScrH = ScrW, ScrH

local markers = {}

local enabledcvar = GetConVar("cl_tfa_hud_hitmarker_enabled")
local solidtimecvar = GetConVar("cl_tfa_hud_hitmarker_solidtime")
local fadetimecvar = GetConVar("cl_tfa_hud_hitmarker_fadetime")
local scalecvar = GetConVar("cl_tfa_hud_hitmarker_scale")
local tricross_cvar = GetConVar("cl_tfa_hud_crosshair_triangular")

local rcvar, gcvar, bcvar, acvar

local w, h, pos, sprh
local c = Color(255, 255, 255, 255)

net.Receive("tfaHitmarker", function()
	if not enabledcvar:GetBool() then return end

	local marker = {}
	marker.time = CurTime()

	table.insert(markers, marker)
end)

net.Receive("tfaHitmarker3D", function()
	if not enabledcvar:GetBool() then return end

	local marker = {}
	marker.pos = net.ReadVector()
	marker.time = CurTime()

	table.insert(markers, marker)
end)

local mat_regular = Material("vgui/tfa_hitmarker.png", "smooth mips")
local mat_triang = Material("vgui/tfa_hitmarker_triang.png", "smooth mips")

hook.Add("HUDPaint", "tfaDrawHitmarker", function()
	if not enabledcvar:GetBool() then return end

	if not rcvar then
		rcvar = GetConVar("cl_tfa_hud_hitmarker_color_r")
	end

	if not gcvar then
		gcvar = GetConVar("cl_tfa_hud_hitmarker_color_g")
	end

	if not bcvar then
		bcvar = GetConVar("cl_tfa_hud_hitmarker_color_b")
	end

	if not acvar then
		acvar = GetConVar("cl_tfa_hud_hitmarker_color_a")
	end

	local solidtime = solidtimecvar:GetFloat()
	local fadetime = math.max(fadetimecvar:GetFloat(), 0.001)

	c.r = rcvar:GetFloat()
	c.g = gcvar:GetFloat()
	c.b = bcvar:GetFloat()

	w, h = ScrW(), ScrH()
	sprh = math.floor((h / 1080) * 64 * scalecvar:GetFloat())

	for k, v in pairs(markers) do
		if not v.time then
			markers[k] = nil
			continue
		end

		local alpha = math.Clamp(v.time - CurTime() + solidtime + fadetime, 0, fadetime) / fadetime
		c.a = acvar:GetFloat() * alpha

		if alpha > 0 then
			pos = {x = w * .5, y = h * .5}

			if v.pos then
				pos = v.pos:ToScreen()
			end

			if pos.visible == false then continue end

			surface.SetDrawColor(c)
			surface.SetMaterial(tricross_cvar:GetBool() and mat_triang or mat_regular)
			surface.DrawTexturedRect(pos.x - sprh * .5, pos.y - sprh * .5, sprh, sprh)
		else
			markers[k] = nil
		end
	end
end)
