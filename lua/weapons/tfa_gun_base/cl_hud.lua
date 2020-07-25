
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

local l_CT = CurTime

local CMIX_MULT = 1
local c1t = {}
local c2t = {}

local function ColorMix(c1, c2, fac, t)
	c1 = c1 or color_white
	c2 = c2 or color_white
	c1t.r = c1.r
	c1t.g = c1.g
	c1t.b = c1.b
	c1t.a = c1.a
	c2t.r = c2.r
	c2t.g = c2.g
	c2t.b = c2.b
	c2t.a = c2.a

	for k, v in pairs(c1t) do
		if t == CMIX_MULT then
			c1t[k] = Lerp(fac, v, (c1t[k] / 255 * c2t[k] / 255) * 255)
		else
			c1t[k] = Lerp(fac, v, c2t[k])
		end
	end

	return Color(c1t.r, c1t.g, c1t.b, c1t.a)
end

local c_red = Color(255, 0, 0, 255)
local c_grn = Color(0, 255, 0, 255)

local hostilenpcmaps = {
	["gm_lasers"] = true,
	["gm_locals"] = true,
	["gm_raid"] = true,
	["gm_slam"] = true
}

local mymap
local cl_tfa_hud_crosshair_color_teamcvar

local function GetTeamColor(ent)
	if not cl_tfa_hud_crosshair_color_teamcvar then
		cl_tfa_hud_crosshair_color_teamcvar = GetConVar("cl_tfa_hud_crosshair_color_team")
	end

	if not cl_tfa_hud_crosshair_color_teamcvar:GetBool() then return color_white end

	if not mymap then
		mymap = game.GetMap()
	end

	local ply = LocalPlayer()
	if not IsValid(ply) then return color_white end

	if ent:IsPlayer() then
		if GAMEMODE.TeamBased then
			if ent:Team() == ply:Team() then
				return c_grn
			else
				return c_red
			end
		end

		return c_red
	end

	if ent:IsNPC() then
		local disp = ent:GetNW2Int("tfa_disposition", -1)

		if disp > 0 then
			if disp == (D_FR or 2) or disp == (D_HT or 1) then
				return c_red
			else
				return c_grn
			end
		end

		if IsFriendEntityName(ent:GetClass()) and not hostilenpcmaps[mymap] then
			return c_grn
		else
			return c_red
		end
	end

	return color_white
end

--[[
local function RoundDecimals(number, decimals)
	local decfactor = math.pow(10, decimals)

	return math.Round(tonumber(number) * decfactor) / decfactor
end
]]
--
--[[
Function Name:  DoInspectionDerma
Syntax: self:DoInspectionDerma( ).
Returns:  Nothing.
Notes:  Used to manage our Derma.
Purpose:  Used to manage our Derma.
]]
--
local TFA_INSPECTIONPANEL
local spacing = 64

local cv_bars_exp = GetConVar("cl_tfa_exp_inspection_newbars") or CreateClientConVar("cl_tfa_exp_inspection_newbars", 0, true, true, "Enable new stat bars in the Inspection menu? (Experimental)")

local function PanelPaintBars(myself, w, h)
	if not myself.Bar or type(myself.Bar) ~= "number" then return end
	myself.Bar = math.Clamp(myself.Bar, 0, 1)

	w = w * 0 + 400--trick linter into letting me replace the argument lol

	local xx, ww, blockw, padw
	xx = w * 0.7
	ww = w - xx

	local bgcol = ColorAlpha(TFA_INSPECTIONPANEL.BackgroundColor or color_white, (TFA_INSPECTIONPANEL.Alpha or 0) / 2)

	if cv_bars_exp and cv_bars_exp:GetBool() then
		draw.RoundedBox(4, xx + 1, 1, ww - 2, h - 2, bgcol)

		local w1, h1 = myself:LocalToScreen(xx + 2, 2)
		local w2, h2 = myself:LocalToScreen(xx - 2 + ww * myself.Bar, h - 2)

		render.SetScissorRect(w1, h1, w2, h2, true)
		draw.RoundedBox(4, xx + 2, 2, ww - 4, h - 4, TFA_INSPECTIONPANEL.SecondaryColor or color_white)
		render.SetScissorRect(0, 0, 0, 0, false)

		return
	end

	blockw = math.floor(ww / 15)
	padw = math.floor(ww / 10)

	myself.Bars = math.Clamp(math.Round(myself.Bar * 10), 0, 10)

	surface.SetDrawColor(bgcol)
	for _ = 0, 9 do
		surface.DrawRect(xx, 2, blockw, h - 5)
		xx = math.floor(xx + padw)
	end

	xx = w * 0.7
	surface.SetDrawColor(TFA_INSPECTIONPANEL.BackgroundColor or color_white)

	for _ = 0, myself.Bars - 1 do
		surface.DrawRect(xx + 1, 3, blockw, h - 5)
		xx = math.floor(xx + padw)
	end

	xx = w * 0.7
	surface.SetDrawColor(TFA_INSPECTIONPANEL.SecondaryColor or color_white)

	for _ = 0, myself.Bars - 1 do
		surface.DrawRect(xx, 2, blockw, h - 5)
		xx = math.floor(xx + padw)
	end
end

local function TextShadowPaint(myself, w, h)
	if not myself.TextColor then
		myself.TextColor = ColorAlpha(color_white, 0)
	end

	draw.NoTexture()
	draw.SimpleText(myself.Text, myself.Font, 2, 2, ColorAlpha(color_black, myself.TextColor.a), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText(myself.Text, myself.Font, 0, 0, myself.TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

local function kmtofeet(km)
	return km * 3280.84
end

local function feettokm(feet)
	return feet / 3280.84
end

local function feettosource(feet)
	return feet * 16
end

local function sourcetofeet(u)
	return u / 16
end

local pad = 4
local infotextpad = "  "
local INSPECTION_BACKGROUND = TFA.Attachments.Colors["background"]
local INSPECTION_ACTIVECOLOR = TFA.Attachments.Colors["active"]
local INSPECTION_PRIMARYCOLOR = TFA.Attachments.Colors["primary"]
local INSPECTION_SECONDARYCOLOR = TFA.Attachments.Colors["secondary"]
local worstaccuracy = 0.045
local bestrpm = 1200
local worstmove = 0.8
local bestdamage = 100
local bestrange = feettosource(kmtofeet(1))
local worstrecoil = 1

SWEP.AmmoTypeStrings = {
	-- ["pistol"] = "Generic Pistol",
	-- ["smg1"] = "Generic SMG",
	-- ["ar2"] = "Generic Rifle",
	-- ["buckshot"] = "Generic Shotgun",
	-- ["357"] = "Generic Revolver",
	-- ["SniperPenetratedRound"] = "Generic Sniper"
}

local att_enabled_cv = GetConVar("sv_tfa_attachments_enabled")

function SWEP:GenerateInspectionDerma()
	TFA_INSPECTIONPANEL = vgui.Create("DPanel")
	TFA_INSPECTIONPANEL:SetSize(ScrW(), ScrH())

	TFA_INSPECTIONPANEL.Think = function(myself, w, h)
		local ply = LocalPlayer()

		if not IsValid(ply) then
			myself:Remove()

			return
		end

		local wep = ply:GetActiveWeapon()

		if not IsValid(wep) or not wep.IsTFAWeapon or wep.InspectingProgress <= 0.01 then
			myself:Remove()

			return
		end

		myself.Player = ply
		myself.Weapon = wep
	end

	TFA_INSPECTIONPANEL.Paint = function(myself, w, h)
		local wep = self

		if IsValid(wep) then
			myself.Alpha = wep.InspectingProgress * 255
			myself.PrimaryColor = ColorAlpha(INSPECTION_PRIMARYCOLOR, TFA_INSPECTIONPANEL.Alpha)
			myself.SecondaryColor = ColorAlpha(INSPECTION_SECONDARYCOLOR, TFA_INSPECTIONPANEL.Alpha)
			myself.BackgroundColor = ColorAlpha(INSPECTION_BACKGROUND, TFA_INSPECTIONPANEL.Alpha)
			myself.ActiveColor = ColorAlpha(INSPECTION_ACTIVECOLOR, TFA_INSPECTIONPANEL.Alpha)

			if not myself.SideBar then
				myself.SideBar = surface.GetTextureID("vgui/inspectionhud/sidebar")
			end

			if not myself.Hex then
				myself.Hex = surface.GetTextureID("vgui/inspectionhud/hex")
			end
		end
	end

	--Derma_DrawBackgroundBlur( myself, SysTime()-wep.InspectingProgress )
	--draw.NoTexture()
	--surface.SetDrawColor(ColorAlpha(INSPECTION_BACKGROUND,TFA_INSPECTIONPANEL.Alpha*0.25))
	--surface.DrawRect(0,0,w,h)
	local screenwidth, screenheight = ScrW(), ScrH()
	local hv = math.Round(screenheight * 0.8)
	local contentpanel = vgui.Create("DPanel", TFA_INSPECTIONPANEL)
	contentpanel:SetPos(32, (screenheight - hv) / 2)
	contentpanel:DockPadding(32 + pad, pad, pad, pad)
	contentpanel:SetSize(screenwidth - 32, hv)

	contentpanel.Paint = function(myself, w, h)
		local mycol = TFA_INSPECTIONPANEL.SecondaryColor
		if not mycol then return end
		surface.SetDrawColor(mycol)
		surface.SetTexture(TFA_INSPECTIONPANEL.SideBar or 1)
		surface.DrawTexturedRect(0, 0, 32, h)

		if IsValid(self) then
			surface.DrawTexturedRectUV(ScrW() - 32 - 32 - 32, 0, 32, h, 1, 0, 0, 1)
		end
	end

	local lbound = 32 + pad
	local titletext = contentpanel:Add("DPanel")
	titletext.Text = self.PrintName or "TFA Weapon"

	titletext.Think = function(myself)
		myself.TextColor = TFA_INSPECTIONPANEL.PrimaryColor
	end

	titletext.Font = "TFA_INSPECTION_TITLE"
	titletext:Dock(TOP)
	titletext:SetSize(screenwidth - lbound, spacing)
	titletext.Paint = TextShadowPaint
	local typetext = contentpanel:Add("DPanel")
	typetext.Text = self:GetStat("Type_Displayed") or self:GetType()

	typetext.Think = function(myself)
		myself.TextColor = TFA_INSPECTIONPANEL.PrimaryColor
	end

	typetext.Font = "TFA_INSPECTION_DESCR"
	typetext:Dock(TOP)
	typetext:SetSize(screenwidth - lbound, 32)
	typetext.Paint = TextShadowPaint
	--Space things out for block1
	local spacer = contentpanel:Add("DPanel")
	spacer:Dock(TOP)
	spacer:SetSize(screenwidth - lbound, spacing)
	spacer.Paint = function() end
	--First stat block
	local descriptiontext = contentpanel:Add("DPanel")
	descriptiontext.Text = (self.Description or self.Category) or self.Base

	descriptiontext.Think = function(myself)
		myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
	end

	descriptiontext.Font = "TFA_INSPECTION_SMALL"
	descriptiontext:Dock(TOP)
	descriptiontext:SetSize(screenwidth - lbound, 24)
	descriptiontext.Paint = TextShadowPaint
	local myauthor = self.Author
	local authortext = contentpanel:Add("DPanel")

	if not myauthor or string.Trim(myauthor) == "" then
		myauthor = "The Forgotten Architect"
	end

	authortext.Text = infotextpad .. language.GetPhrase("tfa.inspect.creator"):format(myauthor)

	authortext.Think = function(myself)
		myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
	end

	authortext.Font = "TFA_INSPECTION_SMALL"
	authortext:Dock(TOP)
	authortext:SetSize(screenwidth - lbound, 24)
	authortext.Paint = TextShadowPaint

	if self.Manufacturer and string.Trim(self.Manufacturer) ~= "" then
		local makertext = contentpanel:Add("DPanel")
		makertext.Text = infotextpad .. language.GetPhrase("tfa.inspect.manufacturer"):format(self.Manufacturer)

		makertext.Think = function(myself)
			myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
		end

		makertext.Font = "TFA_INSPECTION_SMALL"
		makertext:Dock(TOP)
		makertext:SetSize(screenwidth - lbound, 24)
		makertext.Paint = TextShadowPaint
	end

	local clip = self:GetStat("Primary.ClipSize")

	if clip > 0 then
		local capacitytext = contentpanel:Add("DPanel")
		capacitytext.Text = infotextpad .. language.GetPhrase("tfa.inspect.capacity"):format(clip .. (self:CanChamber() and (self:GetStat("Akimbo") and " + 2" or " + 1") or ""))

		capacitytext.Think = function(myself)
			myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
		end

		capacitytext.Font = "TFA_INSPECTION_SMALL"
		capacitytext:Dock(TOP)
		capacitytext:SetSize(screenwidth - lbound, 24)
		capacitytext.Paint = TextShadowPaint
	end

	local an = game.GetAmmoName(self:GetPrimaryAmmoType())

	if an and an ~= "" and string.len(an) > 1 then
		local ammotypetext = contentpanel:Add("DPanel")
		ammotypetext.Text = infotextpad .. language.GetPhrase("tfa.inspect.ammotype"):format(language.GetPhrase(self.AmmoTypeStrings[self:GetStat("Primary.Ammo")] or "tfa.ammo." .. self:GetStat("Primary.Ammo"):lower()))

		ammotypetext.Think = function(myself)
			myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
		end

		ammotypetext.Font = "TFA_INSPECTION_SMALL"
		ammotypetext:Dock(TOP)
		ammotypetext:SetSize(screenwidth - lbound, 24)
		ammotypetext.Paint = TextShadowPaint
	end

	if self.Purpose and string.Trim(self.Purpose) ~= "" then
		local purpose = contentpanel:Add("DPanel")
		purpose.Text = infotextpad .. language.GetPhrase("tfa.inspect.purpose"):format(self.Purpose)

		purpose.Think = function(myself)
			myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
		end

		purpose.Font = "TFA_INSPECTION_SMALL"
		purpose:Dock(TOP)
		purpose:SetSize(screenwidth - lbound, 24)
		purpose.Paint = TextShadowPaint
	end

	--Bottom block (bars and such)
	local statspanel = contentpanel:Add("DPanel")
	statspanel:SetSize(screenwidth - lbound, 192)
	statspanel.Paint = function() end
	statspanel:Dock(BOTTOM)

	-- Condition

	if self:CanBeJammed() then
		local conditionpanel = statspanel:Add("DPanel")
		conditionpanel:SetSize(400, 24)

		local condition = 1 - self:GetJamFactor() * .01

		conditionpanel.Think = function(myself)
			if not IsValid(self) then return end
			myself.Bar = condition
		end

		conditionpanel.Paint = PanelPaintBars
		conditionpanel:Dock(TOP)
		local conditiontext = conditionpanel:Add("DPanel")

		conditiontext.Think = function(myself)
			myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
			myself.Text = language.GetPhrase("tfa.inspect.condition"):format(math.Clamp(math.Round(condition * 100), 0, 100))
		end

		conditiontext.Font = "TFA_INSPECTION_SMALL"
		conditiontext:Dock(LEFT)
		conditiontext:SetSize(screenwidth - lbound, 24)
		conditiontext.Paint = TextShadowPaint
	end

	--Accuracy
	local accuracypanel = statspanel:Add("DPanel")
	accuracypanel:SetSize(400, 24)

	accuracypanel.Think = function(myself)
		if not IsValid(self) then return end
		local accval
		local waccval = worstaccuracy
		local spread = self:GetStat("Primary.Spread")

		if self:GetStat("data.ironsights") ~= 0 then
			local iacc = self:GetStat("Primary.IronAccuracy", spread)
			accval = (iacc * 2 + spread) / 3

			if iacc < 0.005 then
				accval = 0
			end
		else
			accval = spread
		end

		myself.Bar = 1 - accval / waccval
	end

	accuracypanel.Paint = PanelPaintBars
	accuracypanel:Dock(TOP)
	local accuracytext = accuracypanel:Add("DPanel")

	accuracytext.Think = function(myself)
		if not IsValid(self) then return end
		local spread = self:GetStat("Primary.Spread")
		local accuracystr = language.GetPhrase("tfa.inspect.stat.accuracy"):format(math.Round(spread * 180))

		if self:GetStat("data.ironsights") ~= 0 then
			accuracystr = accuracystr .. " || " .. math.Round(self:GetStat("Primary.IronAccuracy", spread) * 180) .. "°"
		end

		myself.Text = accuracystr
		myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
	end

	accuracytext.Font = "TFA_INSPECTION_SMALL"
	accuracytext:Dock(LEFT)
	accuracytext:SetSize(screenwidth - lbound, 24)
	accuracytext.Paint = TextShadowPaint
	--Firerate
	local fireratepanel = statspanel:Add("DPanel")
	fireratepanel:SetSize(400, 24)

	fireratepanel.Think = function(myself)
		if not IsValid(self) then return end
		local rpmstat = self:GetStat("Primary.RPM_Displayed") or self:GetStat("Primary.RPM")
		myself.Bar = rpmstat / bestrpm
	end

	fireratepanel.Paint = PanelPaintBars
	fireratepanel:Dock(TOP)
	local fireratetext = fireratepanel:Add("DPanel")

	fireratetext.Think = function(myself)
		if not IsValid(self) then return end
		local rpmstat = self:GetStat("Primary.RPM_Displayed") or self:GetStat("Primary.RPM")
		local fireratestr = language.GetPhrase("tfa.inspect.stat.rpm"):format(rpmstat)
		myself.Text = fireratestr
		myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
	end

	fireratetext.Font = "TFA_INSPECTION_SMALL"
	fireratetext:Dock(LEFT)
	fireratetext:SetSize(screenwidth - lbound, 24)
	fireratetext.Paint = TextShadowPaint
	--Mobility
	local mobilitypanel = statspanel:Add("DPanel")
	mobilitypanel:SetSize(400, 24)

	mobilitypanel.Think = function(myself)
		if not IsValid(self) then return end
		myself.Bar = (self:GetStat("MoveSpeed") - worstmove) / (1 - worstmove)
	end

	mobilitypanel.Paint = PanelPaintBars
	mobilitypanel:Dock(TOP)
	local mobilitytext = mobilitypanel:Add("DPanel")

	mobilitytext.Think = function(myself)
		if not IsValid(self) then return end
		myself.Text = language.GetPhrase("tfa.inspect.stat.mobility"):format(math.Round(self:GetStat("MoveSpeed") * 100))
		myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
	end

	mobilitytext.Font = "TFA_INSPECTION_SMALL"
	mobilitytext:Dock(LEFT)
	mobilitytext:SetSize(screenwidth - lbound, 24)
	mobilitytext.Paint = TextShadowPaint
	--Damage
	local damagepanel = statspanel:Add("DPanel")
	damagepanel:SetSize(400, 24)

	damagepanel.Think = function(myself)
		if not IsValid(self) then return end
		myself.Bar = (self:GetStat("Primary.Damage") * math.Round(self:GetStat("Primary.NumShots") * 0.75)) / bestdamage
	end

	damagepanel.Paint = PanelPaintBars
	damagepanel:Dock(TOP)
	local damagetext = damagepanel:Add("DPanel")

	damagetext.Think = function(myself)
		if not IsValid(self) then return end
		local dmgstr = language.GetPhrase("tfa.inspect.stat.damage"):format(math.Round(self:GetStat("Primary.Damage")))

		if self:GetStat("Primary.NumShots") ~= 1 then
			dmgstr = dmgstr .. "x" .. math.Round(self:GetStat("Primary.NumShots"))
		end

		myself.Text = dmgstr
		myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
	end

	damagetext.Font = "TFA_INSPECTION_SMALL"
	damagetext:Dock(LEFT)
	damagetext:SetSize(screenwidth - lbound, 24)
	damagetext.Paint = TextShadowPaint
	--Range
	local rangepanel = statspanel:Add("DPanel")
	rangepanel:SetSize(400, 24)

	rangepanel.Think = function(myself)
		if not IsValid(self) then return end
		myself.Bar = self:GetStat("Primary.Range") / bestrange
	end

	rangepanel.Paint = PanelPaintBars
	rangepanel:Dock(TOP)
	local rangetext = rangepanel:Add("DPanel")
	rangetext.Text = ""

	rangetext.Think = function(myself)
		if not IsValid(self) then return end
		myself.Text = language.GetPhrase("tfa.inspect.stat.range"):format(math.Round(feettokm(sourcetofeet(self:GetStat("Primary.Range"))) * 100) / 100)
		myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
	end

	rangetext.Font = "TFA_INSPECTION_SMALL"
	rangetext:Dock(LEFT)
	rangetext:SetSize(screenwidth - lbound, 24)
	rangetext.Paint = TextShadowPaint
	--Stability
	local stabilitypanel = statspanel:Add("DPanel")
	stabilitypanel:SetSize(400, 24)

	stabilitypanel.Think = function(myself)
		if not IsValid(self) then return end
		myself.Bar = (1 - math.abs(self:GetStat("Primary.KickUp") + self:GetStat("Primary.KickDown")) / 2 / worstrecoil)
	end

	stabilitypanel.Paint = PanelPaintBars
	stabilitypanel:Dock(TOP)
	local stabilitytext = stabilitypanel:Add("DPanel")
	stabilitytext.Text = ""

	stabilitytext.Think = function(myself)
		if not IsValid(self) then return end
		myself.Text = language.GetPhrase("tfa.inspect.stat.stability"):format(math.Clamp(math.Round((1 - math.abs(self:GetStat("Primary.KickUp") + self:GetStat("Primary.KickDown")) / 2 / 1) * 100), 0, 100))
		myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
	end

	stabilitytext.Font = "TFA_INSPECTION_SMALL"
	stabilitytext:Dock(LEFT)
	stabilitytext:SetSize(screenwidth - lbound, 24)
	stabilitytext.Paint = TextShadowPaint

	-- Bash damage
	if self.BashBase and self:GetStat("Secondary.CanBash") ~= false then
		local bashdamagepanel = statspanel:Add("DPanel")
		bashdamagepanel:SetSize(400, 24)

		bashdamagepanel.Think = function(myself)
			if not IsValid(self) then return end
			myself.Bar = self:GetStat("Secondary.BashDamage", 0) / bestdamage
		end

		bashdamagepanel.Paint = PanelPaintBars
		bashdamagepanel:Dock(TOP)
		local bashdamagetext = bashdamagepanel:Add("DPanel")

		bashdamagetext.Think = function(myself)
			if not IsValid(self) then return end
			myself.Text = language.GetPhrase("tfa.inspect.stat.bashdamage"):format(math.Round(self:GetStat("Secondary.BashDamage", 0)))
			myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
		end

		bashdamagetext.Font = "TFA_INSPECTION_SMALL"
		bashdamagetext:Dock(LEFT)
		bashdamagetext:SetSize(screenwidth - lbound, 24)
		bashdamagetext.Paint = TextShadowPaint
	end

	if not att_enabled_cv then
		att_enabled_cv = GetConVar("sv_tfa_attachments_enabled")
	end

	local scrollpanel

	if (not att_enabled_cv) or att_enabled_cv:GetBool() then
		if self.Attachments then
			scrollpanel = contentpanel:Add("DScrollPanel")
			scrollpanel:SetPos(0, 0)
			scrollpanel:SetSize(ScrW() - spacing - 26, math.floor(contentpanel:GetTall()))
			local vbar = scrollpanel:GetVBar()
			scrollpanel:SetWide(scrollpanel:GetWide() + vbar:GetWide())

			vbar.Paint = function(myself, w, h)
				if not TFA_INSPECTIONPANEL then return end
				surface.SetDrawColor(TFA_INSPECTIONPANEL.BackgroundColor.r, TFA_INSPECTIONPANEL.BackgroundColor.g, TFA_INSPECTIONPANEL.BackgroundColor.b, TFA_INSPECTIONPANEL.BackgroundColor.a / 2)
				surface.DrawRect(0, 0, 5, h)
			end

			vbar.btnUp.Paint = function(myself, w, h)
				if not TFA_INSPECTIONPANEL then return end
				surface.SetDrawColor(TFA_INSPECTIONPANEL.PrimaryColor.r, TFA_INSPECTIONPANEL.PrimaryColor.g, TFA_INSPECTIONPANEL.PrimaryColor.b, TFA_INSPECTIONPANEL.PrimaryColor.a)
				surface.DrawRect(0, 0, 5, h)
			end

			vbar.btnDown.Paint = function(myself, w, h)
				if not TFA_INSPECTIONPANEL then return end
				surface.SetDrawColor(TFA_INSPECTIONPANEL.PrimaryColor.r, TFA_INSPECTIONPANEL.PrimaryColor.g, TFA_INSPECTIONPANEL.PrimaryColor.b, TFA_INSPECTIONPANEL.PrimaryColor.a)
				surface.DrawRect(0, 0, 5, h)
			end

			vbar.btnGrip.Paint = function(myself, w, h)
				if not TFA_INSPECTIONPANEL then return end
				surface.SetDrawColor(TFA_INSPECTIONPANEL.PrimaryColor.r, TFA_INSPECTIONPANEL.PrimaryColor.g, TFA_INSPECTIONPANEL.PrimaryColor.b, TFA_INSPECTIONPANEL.PrimaryColor.a)
				surface.DrawRect(0, 0, 5, h)
			end
		end

		--[[

			myself.PrimaryColor = ColorAlpha(INSPECTION_PRIMARYCOLOR, TFA_INSPECTIONPANEL.Alpha)
			myself.SecondaryColor = ColorAlpha(INSPECTION_SECONDARYCOLOR, TFA_INSPECTIONPANEL.Alpha)
			myself.BackgroundColor = ColorAlpha(INSPECTION_BACKGROUND, TFA_INSPECTIONPANEL.Alpha)
			myself.ActiveColor = ColorAlpha(INSPECTION_ACTIVECOLOR, TFA_INSPECTIONPANEL.Alpha)
	]]
		--
		self:GenerateVGUIAttachmentTable()
		local i = 0
		local prevCat
		local lineY = 0
		local scrollWide = scrollpanel:GetWide()
		local lastTooltipPanel

		local iconsize = math.Round(TFA.ScaleH(TFA.Attachments.IconSize))
		local catspacing = math.Round(TFA.ScaleH(TFA.Attachments.CategorySpacing))
		local padding = math.Round(TFA.ScaleH(TFA.Attachments.UIPadding))

		for k, v in pairs(self.VGUIAttachments) do
			if k ~= "BaseClass" then
				if prevCat then
					local isContinuing = prevCat == (v.cat or k)
					lineY = lineY + (isContinuing and iconsize + padding or catspacing)

					if not isContinuing then
						lastTooltipPanel = nil
					end
				end

				prevCat = v.cat or k
				local testpanel = TFA_INSPECTIONPANEL:Add("TFAAttachmentPanel")
				testpanel:SetParent(scrollpanel)
				testpanel:SetContentPanel(scrollpanel)
				i = i + 1
				testpanel:SetWeapon(self)
				testpanel:SetAttachment(k)
				testpanel:SetCategory(v.cat or k)
				testpanel:Initialize()
				lastTooltipPanel = lastTooltipPanel or testpanel:InitializeTooltip()
				testpanel:SetupTooltip(lastTooltipPanel)
				testpanel:PopulateIcons()
				testpanel:SetPos(scrollWide - testpanel:GetWide() - 32, lineY)
			end
		end
	end
	--[[
	testpanel:SetSize(128+4*2, spacing)
	testpanel:SetPos( ScrW() / 2, ScrH() / 2 )
	testpanel.Paint = function(myself,w,h)
		draw.NoTexture()
		surface.SetDrawColor(color_white)
		surface.DrawRect(0,0,w,h)
	end
	]]
	--
end

function SWEP:DoInspectionDerma()
	self.InspectingProgress = self.InspectingProgress or 0

	if not IsValid(TFA_INSPECTIONPANEL) and self.InspectingProgress > 0.01 then
		self:GenerateInspectionDerma()
	end

	if not IsValid(TFA_INSPECTIONPANEL) then return end
	if not self:OwnerIsValid() then return end
end

local crosscol = Color(255, 255, 255, 255)
local crossa_cvar = GetConVar("cl_tfa_hud_crosshair_color_a")
local outa_cvar = GetConVar("cl_tfa_hud_crosshair_outline_color_a")
local crosscustomenable_cvar = GetConVar("cl_tfa_hud_crosshair_enable_custom")
local crossr_cvar = GetConVar("cl_tfa_hud_crosshair_color_r")
local crossg_cvar = GetConVar("cl_tfa_hud_crosshair_color_g")
local crossb_cvar = GetConVar("cl_tfa_hud_crosshair_color_b")
local crosslen_cvar = GetConVar("cl_tfa_hud_crosshair_length")
local crosshairwidth_cvar = GetConVar("cl_tfa_hud_crosshair_width")
local drawdot_cvar = GetConVar("cl_tfa_hud_crosshair_dot")
local clen_usepixels = GetConVar("cl_tfa_hud_crosshair_length_use_pixels")
local outline_enabled_cvar = GetConVar("cl_tfa_hud_crosshair_outline_enabled")
local outr_cvar = GetConVar("cl_tfa_hud_crosshair_outline_color_r")
local outg_cvar = GetConVar("cl_tfa_hud_crosshair_outline_color_g")
local outb_cvar = GetConVar("cl_tfa_hud_crosshair_outline_color_b")
local outlinewidth_cvar = GetConVar("cl_tfa_hud_crosshair_outline_width")
local hudenabled_cvar = GetConVar("cl_tfa_hud_enabled")
local cgapscale_cvar = GetConVar("cl_tfa_hud_crosshair_gap_scale")
local tricross_cvar = GetConVar("cl_tfa_hud_crosshair_triangular")

--[[
Function Name:  DrawHUD
Syntax: self:DrawHUD( ).
Returns:  Nothing.
Notes:  Used to draw the HUD.  Can you read?
Purpose:  HUD
]]
--
function SWEP:DrawHUD()
	-- Inspection Derma
	self:DoInspectionDerma()
	-- 3D2D Ammo
	self:DrawHUDAmmo() --so it's swappable easily
end

function SWEP:DrawHUDBackground()
	--Scope Overlay
	if self.IronSightsProgress > self:GetStat("ScopeOverlayThreshold") and self:GetStat("Scoped") then
		self:DrawScopeOverlay()
	end
end

function SWEP:DrawHUD3D2D()
end

SWEP.CLAmmoProgress = 0
local targ, lactive = 0, -1
local targbool = false
local hudhangtime_cvar = GetConVar("cl_tfa_hud_hangtime")
local hudfade_cvar = GetConVar("cl_tfa_hud_ammodata_fadein")
local lfm, fm = 0, 0
SWEP.TextCol = Color(255, 255, 255, 255) --Primary text color
SWEP.TextColContrast = Color(32, 32, 32, 255) --Secondary Text Color (used for shadow)

function SWEP:DrawHUDAmmo()
	local stat = self:GetStatus()

	if self:GetStat("BoltAction") then
		if stat == TFA.Enum.STATUS_SHOOTING then
			if not self.LastBoltShoot then
				self.LastBoltShoot = l_CT()
			end
		elseif self.LastBoltShoot then
			self.LastBoltShoot = nil
		end
	end

	if not hudenabled_cvar:GetBool() then return end

	fm = self:GetFireMode()
	targbool = (not TFA.Enum.HUDDisabledStatus[stat]) or fm ~= lfm
	targbool = targbool or (stat == TFA.Enum.STATUS_SHOOTING and self.LastBoltShoot and l_CT() > self.LastBoltShoot + self.BoltTimerOffset)
	targbool = targbool or (self:GetStat("PumpAction") and (stat == TFA.GetStatus("pump") or (stat == TFA.Enum.STATUS_SHOOTING and self:Clip1() == 0)))
	targbool = targbool or (stat == TFA.GetStatus("fidget"))

	targ = targbool and 1 or 0
	lfm = fm

	if targ == 1 then
		lactive = l_CT()
	elseif l_CT() < lactive + hudhangtime_cvar:GetFloat() then
		targ = 1
	elseif self:GetOwner():KeyDown(IN_RELOAD) then
		targ = 1
	end

	self.CLAmmoProgress = math.Approach(self.CLAmmoProgress, targ, (targ - self.CLAmmoProgress) * FrameTime() * 2 / hudfade_cvar:GetFloat())
	local myalpha = 225 * self.CLAmmoProgress
	if myalpha < 1 then return end
	local amn = self:GetStat("Primary.Ammo")
	if not amn then return end
	if amn == "none" or amn == "" then return end
	local mzpos = self:GetMuzzlePos()

	if self:GetStat("Akimbo") then
		self.MuzzleAttachmentRaw = self.MuzzleAttachmentRaw2 or 1
	end

	if self:GetHidden() then return end

	local xx, yy

	if mzpos and mzpos.Pos then
		local pos = mzpos.Pos
		local textsize = self.textsize and self.textsize or 1
		local pl = LocalPlayer() and LocalPlayer() or self:GetOwner()
		local ang = pl:EyeAngles() --(angpos.Ang):Up():Angle()
		ang:RotateAroundAxis(ang:Right(), 90)
		ang:RotateAroundAxis(ang:Up(), -90)
		ang:RotateAroundAxis(ang:Forward(), 0)
		pos = pos + ang:Right() * (self.textupoffset and self.textupoffset or -2 * (textsize / 1))
		pos = pos + ang:Up() * (self.textfwdoffset and self.textfwdoffset or 0 * (textsize / 1))
		pos = pos + ang:Forward() * (self.textrightoffset and self.textrightoffset or -1 * (textsize / 1))
		cam.Start3D()
		local postoscreen = pos:ToScreen()
		cam.End3D()
		xx = postoscreen.x
		yy = postoscreen.y
	else -- fallback to pseudo-3d if no muzzle
		xx, yy = ScrW() * .65, ScrH() * .6
	end

	local v, newx, newy, newalpha = hook.Run("TFA_DrawHUDAmmo", self, xx, yy, myalpha)
	if v ~= nil then
		if v then
			xx = newx or xx
			yy = newy or yy
			myalpha = newalpha or myalpha
		else
			return
		end
	end

	if self.InspectingProgress < 0.01 and self:GetStat("Primary.Ammo") ~= "" and self:GetStat("Primary.Ammo") ~= 0 then
		local str, clipstr

		if self:GetStat("Primary.ClipSize") and self:GetStat("Primary.ClipSize") ~= -1 then
			clipstr = language.GetPhrase("tfa.hud.ammo.clip1")

			if self:GetStat("Akimbo") and self:GetStat("AkimboHUD") ~= false then
				str = clipstr:format(math.ceil(self:Clip1() / 2))

				if (self:Clip1() > self:GetStat("Primary.ClipSize")) then
					str = clipstr:format(math.ceil(self:Clip1() / 2) - 1 .. " + " .. (math.ceil(self:Clip1() / 2) - math.ceil(self:GetStat("Primary.ClipSize") / 2)))
				end
			else
				str = clipstr:format(self:Clip1())

				if (self:Clip1() > self:GetStat("Primary.ClipSize")) then
					str = clipstr:format(self:GetStat("Primary.ClipSize") .. " + " .. (self:Clip1() - self:GetStat("Primary.ClipSize")))
				end
			end

			draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
			draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
			str = language.GetPhrase("tfa.hud.ammo.reserve1"):format(self:Ammo1())
			yy = yy + TFA.Fonts.SleekHeight
			xx = xx - TFA.Fonts.SleekHeight / 3
			draw.DrawText(str, "TFASleekMedium", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
			draw.DrawText(str, "TFASleekMedium", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
			yy = yy + TFA.Fonts.SleekHeightMedium
			xx = xx - TFA.Fonts.SleekHeightMedium / 3
		else
			str = language.GetPhrase("tfa.hud.ammo1"):format(self:Ammo1())
			draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
			draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
			yy = yy + TFA.Fonts.SleekHeightMedium
			xx = xx - TFA.Fonts.SleekHeightMedium / 3
		end

		str = string.upper(self:GetFireModeName() .. (#self:GetStat("FireModes") > 2 and " | +" or ""))

		if self:IsJammed() then
			str = str .. "\n" .. language.GetPhrase("tfa.hud.jammed")
		end

		draw.DrawText(str, "TFASleekSmall", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
		draw.DrawText(str, "TFASleekSmall", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
		yy = yy + TFA.Fonts.SleekHeightSmall
		xx = xx - TFA.Fonts.SleekHeightSmall / 3

		if self:GetStat("Akimbo") and self:GetStat("AkimboHUD") ~= false then
			local angpos2 = self:GetOwner():ShouldDrawLocalPlayer() and self:GetAttachment(2) or self.OwnerViewModel:GetAttachment(2)

			if angpos2 then
				local pos2 = angpos2.Pos
				local ts2 = pos2:ToScreen()

				xx, yy = ts2.x, ts2.y
			else
				xx, yy = ScrW() * .35, ScrH() * .6
			end

			if self:GetStat("Primary.ClipSize") and self:GetStat("Primary.ClipSize") ~= -1 then
				clipstr = language.GetPhrase("tfa.hud.ammo.clip1")

				str = clipstr:format(math.floor(self:Clip1() / 2))

				if (math.floor(self:Clip1() / 2) > math.floor(self:GetStat("Primary.ClipSize") / 2)) then
					str = clipstr:format(math.floor(self:Clip1() / 2) - 1 .. " + " .. (math.floor(self:Clip1() / 2) - math.floor(self:GetStat("Primary.ClipSize") / 2)))
				end

				draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
				draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
				str = language.GetPhrase("tfa.hud.ammo.reserve1"):format(self:Ammo1())
				yy = yy + TFA.Fonts.SleekHeight
				xx = xx - TFA.Fonts.SleekHeight / 3
				draw.DrawText(str, "TFASleekMedium", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
				draw.DrawText(str, "TFASleekMedium", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
				yy = yy + TFA.Fonts.SleekHeightMedium
				xx = xx - TFA.Fonts.SleekHeightMedium / 3
			else
				str = language.GetPhrase("tfa.hud.ammo1"):format(self:Ammo1())
				draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
				draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
				yy = yy + TFA.Fonts.SleekHeightMedium
				xx = xx - TFA.Fonts.SleekHeightMedium / 3
			end

			str = string.upper(self:GetFireModeName() .. (#self.FireModes > 2 and " | +" or ""))
			draw.DrawText(str, "TFASleekSmall", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
			draw.DrawText(str, "TFASleekSmall", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
		end

		if self:GetStat("Secondary.Ammo") and self:GetStat("Secondary.Ammo") ~= "" and self:GetStat("Secondary.Ammo") ~= "none" and self:GetStat("Secondary.Ammo") ~= 0 and not self:GetStat("Akimbo") then
			if self:GetStat("Secondary.ClipSize") and self:GetStat("Secondary.ClipSize") ~= -1 then
				clipstr = language.GetPhrase("tfa.hud.ammo.clip2")
				str = (self:Clip2() > self:GetStat("Secondary.ClipSize")) and clipstr:format(self:GetStat("Secondary.ClipSize") .. " + " .. (self:Clip2() - self:GetStat("Primary.ClipSize"))) or clipstr:format(self:Clip2())
				draw.DrawText(str, "TFASleekSmall", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
				draw.DrawText(str, "TFASleekSmall", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
				str = language.GetPhrase("tfa.hud.ammo.reserve2"):format(self:Ammo2())
				yy = yy + TFA.Fonts.SleekHeightSmall
				xx = xx - TFA.Fonts.SleekHeightSmall / 3
				draw.DrawText(str, "TFASleekSmall", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
				draw.DrawText(str, "TFASleekSmall", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
			else
				str = language.GetPhrase("tfa.hud.ammo2"):format(self:Ammo2())
				draw.DrawText(str, "TFASleekSmall", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
				draw.DrawText(str, "TFASleekSmall", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
			end
		end
	end
end

function SWEP:DoDrawCrosshair(x, y)
	if not self.DrawCrosshairDefault then return true end
	if self:GetHolding() then return true end

	local stat = self:GetStatus()

	if not crosscustomenable_cvar:GetBool() then
		return TFA.Enum.ReloadStatus[stat] or math.min(1 - self.IronSightsProgress, 1 - self.SprintProgress, 1 - self.InspectingProgress) <= 0.5
	end

	self.clrelp = self.clrelp or 0
	self.clrelp = math.Approach(self.clrelp, TFA.Enum.ReloadStatus[stat] and 0 or 1, ((TFA.Enum.ReloadStatus[stat] and 0 or 1) - self.clrelp) * FrameTime() * 15)
	local crossa = crossa_cvar:GetFloat() * math.pow(math.min(1 - ((self.IronSightsProgress and not self.DrawCrosshairIS) and self.IronSightsProgress or 0), 1 - self.SprintProgress, 1 - self.InspectingProgress, self.clrelp), 2)
	local outa = outa_cvar:GetFloat() * math.pow(math.min(1 - ((self.IronSightsProgress and not self.DrawCrosshairIS) and self.IronSightsProgress or 0), 1 - self.SprintProgress, 1 - self.InspectingProgress, self.clrelp), 2)
	local ply = LocalPlayer()
	if not ply:IsValid() or self:GetOwner() ~= ply then return false end

	local v = hook.Run("TFA_DrawCrosshair", self, x, y)

	if v ~= nil then
		return v
	end

	if not ply.interpposx then
		ply.interpposx = ScrW() / 2
	end

	if not ply.interpposy then
		ply.interpposy = ScrH() / 2
	end

	local s_cone = self:CalculateConeRecoil()

	-- If we're drawing the local player, draw the crosshair where they're aiming
	-- instead of in the center of the screen.
	if (self:GetOwner():ShouldDrawLocalPlayer() and not ply:GetNW2Bool("ThirtOTS", false)) then
		local tr = util.GetPlayerTrace(self:GetOwner())
		tr.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_MONSTER + CONTENTS_WINDOW + CONTENTS_DEBRIS + CONTENTS_GRATE + CONTENTS_AUX -- This controls what the crosshair will be projected onto.
		local trace = util.TraceLine(tr)
		local coords = trace.HitPos:ToScreen()
		coords.x = math.Clamp(coords.x, 0, ScrW())
		coords.y = math.Clamp(coords.y, 0, ScrH())
		ply.interpposx = math.Approach(ply.interpposx, coords.x, (ply.interpposx - coords.x) * FrameTime() * 7.5)
		ply.interpposy = math.Approach(ply.interpposy, coords.y, (ply.interpposy - coords.y) * FrameTime() * 7.5)
		x, y = ply.interpposx, ply.interpposy
		-- Center of screen
	end

	if not self.selftbl then
		self.selftbl = {ply, self}
	end

	local crossr, crossg, crossb, crosslen, crosshairwidth, drawdot, teamcol
	local targent = util.QuickTrace(ply:GetShootPos(), ply:EyeAngles():Forward() * 0x7FFF, self.selftbl).Entity
	teamcol = GetTeamColor(targent)
	crossr = crossr_cvar:GetFloat()
	crossg = crossg_cvar:GetFloat()
	crossb = crossb_cvar:GetFloat()
	crosslen = crosslen_cvar:GetFloat() * 0.01
	crosscol.r = crossr
	crosscol.g = crossg
	crosscol.b = crossb
	crosscol.a = crossa
	crosscol = ColorMix(crosscol, teamcol, 1, CMIX_MULT)
	crossr = crosscol.r
	crossg = crosscol.g
	crossb = crosscol.b
	crossa = crosscol.a
	crosshairwidth = crosshairwidth_cvar:GetFloat()
	drawdot = drawdot_cvar:GetBool()
	local scale = (s_cone * 90) / self:GetOwner():GetFOV() * ScrH() / 1.44 * cgapscale_cvar:GetFloat()
	local gap = math.Round(scale / 2) * 2
	local length

	if not clen_usepixels:GetBool() then
		length = gap + ScrH() * 1.777 * crosslen
	else
		length = gap + crosslen * 100
	end

	local lmatrix, rmatrix

	if tricross_cvar:GetBool() then
		lmatrix = Matrix()
		lmatrix:SetTranslation(Vector(x - gap, y + gap, 0))
		lmatrix:SetAngles(Angle(0, -135, 0))

		rmatrix = Matrix()
		rmatrix:SetTranslation(Vector(x + gap, y + gap, 0))
		rmatrix:SetAngles(Angle(0, 135, 0))
	end

	--Outline
	if outline_enabled_cvar:GetBool() then
		local outr, outg, outb, outlinewidth
		outr = outr_cvar:GetFloat()
		outg = outg_cvar:GetFloat()
		outb = outb_cvar:GetFloat()
		outlinewidth = outlinewidth_cvar:GetFloat()
		surface.SetDrawColor(outr, outg, outb, outa)
		surface.DrawRect(math.Round(x - outlinewidth) - crosshairwidth / 2, math.Round(y - length - outlinewidth) - crosshairwidth / 2, math.Round(outlinewidth * 2) + crosshairwidth, math.Round(length - gap + outlinewidth * 2) + crosshairwidth) -- Top

		if tricross_cvar:GetBool() then
			local ourlinew, outlinel = math.Round(outlinewidth * 2) + crosshairwidth, math.Round(length - gap) + outlinewidth + crosshairwidth

			render.PushFilterMag(TEXFILTER.ANISOTROPIC)
			render.PushFilterMin(TEXFILTER.ANISOTROPIC)
			surface.DisableClipping(true)

			cam.PushModelMatrix(lmatrix)
			surface.DrawRect(-ourlinew * .5, -outlinel, ourlinew, outlinel + outlinewidth)
			cam.PopModelMatrix()

			cam.PushModelMatrix(rmatrix)
			surface.DrawRect(-ourlinew * .5, -outlinel, ourlinew, outlinel + outlinewidth)
			cam.PopModelMatrix()

			surface.DisableClipping(false)
			render.PopFilterMag()
			render.PopFilterMin()
		else
			surface.DrawRect(math.Round(x - length - outlinewidth) - crosshairwidth / 2, math.Round(y - outlinewidth) - crosshairwidth / 2, math.Round(length - gap + outlinewidth * 2) + crosshairwidth, math.Round(outlinewidth * 2) + crosshairwidth) -- Left
			surface.DrawRect(math.Round(x + gap - outlinewidth) - crosshairwidth / 2, math.Round(y - outlinewidth) - crosshairwidth / 2, math.Round(length - gap + outlinewidth * 2) + crosshairwidth, math.Round(outlinewidth * 2) + crosshairwidth) -- Right
			surface.DrawRect(math.Round(x - outlinewidth) - crosshairwidth / 2, math.Round(y + gap - outlinewidth) - crosshairwidth / 2, math.Round(outlinewidth * 2) + crosshairwidth, math.Round(length - gap + outlinewidth * 2) + crosshairwidth) -- Bottom
		end

		if drawdot then
			surface.DrawRect(math.Round(x - outlinewidth) - crosshairwidth / 2, math.Round(y - outlinewidth) - crosshairwidth / 2, math.Round(outlinewidth * 2) + crosshairwidth, math.Round(outlinewidth * 2) + crosshairwidth) --Dot
		end
	end

	--Main Crosshair
	surface.SetDrawColor(crossr, crossg, crossb, crossa)
	surface.DrawRect(math.Round(x) - crosshairwidth / 2, math.Round(y - length) - crosshairwidth / 2, crosshairwidth, math.Round(length - gap) + crosshairwidth) -- Top

	if tricross_cvar:GetBool() then
		local xhl = math.Round(length - gap) + crosshairwidth

		render.PushFilterMag(TEXFILTER.ANISOTROPIC)
		render.PushFilterMin(TEXFILTER.ANISOTROPIC)
		surface.DisableClipping(true)

		cam.PushModelMatrix(lmatrix)
		surface.DrawRect(-crosshairwidth * .5, -xhl, crosshairwidth, xhl)
		cam.PopModelMatrix()

		cam.PushModelMatrix(rmatrix)
		surface.DrawRect(-crosshairwidth * .5, -xhl, crosshairwidth, xhl)
		cam.PopModelMatrix()

		surface.DisableClipping(false)
		render.PopFilterMag()
		render.PopFilterMin()
	else
		surface.DrawRect(math.Round(x - length) - crosshairwidth / 2, math.Round(y) - crosshairwidth / 2, math.Round(length - gap) + crosshairwidth, crosshairwidth) -- Left
		surface.DrawRect(math.Round(x + gap) - crosshairwidth / 2, math.Round(y) - crosshairwidth / 2, math.Round(length - gap) + crosshairwidth, crosshairwidth) -- Right
		surface.DrawRect(math.Round(x) - crosshairwidth / 2, math.Round(y + gap) - crosshairwidth / 2, crosshairwidth, math.Round(length - gap) + crosshairwidth) -- Bottom
	end

	if drawdot then
		surface.DrawRect(math.Round(x) - crosshairwidth / 2, math.Round(y) - crosshairwidth / 2, crosshairwidth, crosshairwidth) --dot
	end

	return true
end

local w, h

function SWEP:DrawScopeOverlay()
	if hook.Run("TFA_DrawScopeOverlay", self) == true then return end

	local tbl = nil

	if self:GetStat("Secondary.UseACOG") then
		tbl = TFA_SCOPE_ACOG
	end

	if self:GetStat("Secondary.UseMilDot") then
		tbl = TFA_SCOPE_MILDOT
	end

	if self:GetStat("Secondary.UseSVD") then
		tbl = TFA_SCOPE_SVD
	end

	if self:GetStat("Secondary.UseParabolic") then
		tbl = TFA_SCOPE_PARABOLIC
	end

	if self:GetStat("Secondary.UseElcan") then
		tbl = TFA_SCOPE_ELCAN
	end

	if self:GetStat("Secondary.UseGreenDuplex") then
		tbl = TFA_SCOPE_GREENDUPLEX
	end

	if self:GetStat("Secondary.UseAimpoint") then
		tbl = TFA_SCOPE_AIMPOINT
	end

	if self:GetStat("Secondary.UseMatador") then
		tbl = TFA_SCOPE_MATADOR
	end

	if self:GetStat("Secondary.ScopeTable") then
		tbl = self:GetStat("Secondary.ScopeTable")
	end

	if not tbl then
		tbl = TFA_SCOPE_MILDOT
	end

	w, h = ScrW(), ScrH()

	for k, v in pairs(tbl) do
		local dimension = h

		if k == "ScopeBorder" then
			if istable(v) then
				surface.SetDrawColor(v)
			else
				surface.SetDrawColor(color_black)
			end

			surface.DrawRect(0, 0, w / 2 - dimension / 2, dimension)
			surface.DrawRect(w / 2 + dimension / 2, 0, w / 2 - dimension / 2, dimension)
		elseif k == "ScopeMaterial" then
			surface.SetMaterial(v)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(w / 2 - dimension / 2, (h - dimension) / 2, dimension, dimension)
		elseif k == "ScopeOverlay" then
			surface.SetMaterial(v)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(0, 0, w, h)
		elseif k == "ScopeCrosshair" then
			local t = type(v)

			if t == "IMaterial" then
				surface.SetMaterial(v)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRect(w / 2 - dimension / 4, h / 2 - dimension / 4, dimension / 2, dimension / 2)
			elseif t == "table" then
				if not v.cached then
					v.cached = true
					v.r = v.r or v.x or v[1] or 0
					v.g = v.g or v.y or v[2] or v[1] or 0
					v.b = v.b or v.z or v[3] or v[1] or 0
					v.a = v.a or v[4] or 255
					v.s = v.Scale or v.scale or v.s or 0.25
				end

				surface.SetDrawColor(v.r, v.g, v.b, v.a)

				if v.Material then
					surface.SetMaterial(v.Material)
					surface.DrawTexturedRect(w / 2 - dimension * v.s / 2, h / 2 - dimension * v.s / 2, dimension * v.s, dimension * v.s)
				elseif v.Texture then
					surface.SetTexture(v.Texture)
					surface.DrawTexturedRect(w / 2 - dimension * v.s / 2, h / 2 - dimension * v.s / 2, dimension * v.s, dimension * v.s)
				else
					surface.DrawRect(w / 2 - dimension * v.s / 2, h / 2, dimension * v.s, 1)
					surface.DrawRect(w / 2, h / 2 - dimension * v.s / 2, 1, dimension * v.s)
				end
			end
		else
			if k == "scopetex" then
				dimension = dimension * self:GetStat("ScopeScale") ^ 2 * TFA_SCOPE_SCOPESCALE
			elseif k == "reticletex" then
				dimension = dimension * (self:GetStat("ReticleScale") and self:GetStat("ReticleScale") or 1) ^ 2 * (TFA_SCOPE_RETICLESCALE and TFA_SCOPE_RETICLESCALE or 1)
			else
				dimension = dimension * self:GetStat("ReticleScale") ^ 2 * TFA_SCOPE_DOTSCALE
			end

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetTexture(v)
			surface.DrawTexturedRect(w / 2 - dimension / 2, (h - dimension) / 2, dimension, dimension)
		end
	end
end

local fsin, icon
local matcache = {}
function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	surface.SetDrawColor(255, 255, 255, alpha)

	icon = self:GetStat("WepSelectIcon_Override") or self.WepSelectIcon

	if not icon then
		self:IconFix()
		return
	end

	if type(icon) == "IMaterial" then
		surface.SetMaterial(icon)
	elseif type(icon) == "string" then
		matcache[icon] = matcache[icon] or Material(icon, "smooth noclamp")
		surface.SetMaterial(matcache[icon])
	else
		surface.SetTexture(icon)
	end

	fsin = self.BounceWeaponIcon and math.sin( l_CT() * 10 ) * 5 or 0

	-- Borders
	y = y + 10
	x = x + 10
	wide = wide - 20

	surface.DrawTexturedRect(x + fsin, y - fsin, wide - fsin * 2, wide / 2 + fsin)

	self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
end