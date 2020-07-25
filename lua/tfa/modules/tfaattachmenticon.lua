
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
	AddCSLuaFile()

	return
end

local padding = TFA.Attachments.UIPadding
local PANEL = {}
PANEL.Wep = nil
PANEL.ID = nil
PANEL.Att = nil --Weapon attachment
PANEL.Attachment = nil --Actual TFA attachment table

function PANEL:Init()
	self.Wep = nil --Weapon Entity
	self.ID = nil --Attachment ID
	self.Att = nil --Attachment Category
	self.Attachment = nil --TFA Attachment Name
	self:SetMouseInputEnabled(true)
	self:SetZPos( 500 )
end

function PANEL:SetWeapon(wep)
	if IsValid(wep) then
		self.Wep = wep
	end
end

function PANEL:SetGunAttachment(att)
	if att ~= nil then
		self.Att = att
	end
end

function PANEL:SetAttachment(att)
	self.Attachment = att
end

function PANEL:SetID(id)
	if id ~= nil then
		self.ID = id
	end
end

function PANEL:GetSelected()
	if not IsValid(self.Wep) then return false end
	if not self.Att then return end
	if not self.ID then return end
	if not self.Wep.Attachments[self.Att] then return end

	return self.Wep.Attachments[self.Att].sel == self.ID
end

function PANEL:AttachSound( attached )
	if self.Attachment and TFA.Attachments.Atts[self.Attachment] then
		local att = TFA.Attachments.Atts[self.Attachment]

		local snd = attached and att.AttachSound or att.DetachSound

		if snd and IsValid(self.Wep) then
			self.Wep:EmitSound(snd)

			return
		end
	end

	chat.PlaySound()
end

function PANEL:OnMousePressed()
	if not IsValid(self.Wep) or ( not self.Attachment ) or self.Attachment == "" then return end

	if self:GetSelected() then
		self.Wep:SetTFAAttachment( self.Att, -1, true )
		self:AttachSound( false )
	elseif self.Wep.Attachments[self.Att] and self.Wep:CanAttach(self.Attachment) then
		self.Wep:SetTFAAttachment( self.Att, self.ID, true )
		self:AttachSound( true )
	end
end

surface.CreateFont("TFAAttachmentIconFont", {
	font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 12,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("TFAAttachmentIconFontTiny", {
	font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 10,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

local function abbrev( str )
	local tbl = string.Explode(" ",str,false)
	local retstr = ""
	for k,v in ipairs(tbl) do
		local tmpstr = string.sub(v,1,1)
		retstr = retstr .. ( ( k == 1 ) and string.upper( tmpstr ) or string.lower( tmpstr ) )
	end
	return retstr
end

function PANEL:Paint(w, h)
	if not IsValid(self.Wep) then return end
	if self.Attachment == nil then return end
	if not TFA.Attachments.Atts[self.Attachment] then self:SetMouseInputEnabled(false) return end
	local sel = self:GetSelected()
	local col = sel and TFA.Attachments.Colors["active"] or TFA.Attachments.Colors["background"]

	if not sel and not self.Wep:CanAttach(self.Attachment) then
		col = TFA.Attachments.Colors["error"]
	end

	draw.RoundedBox(0, 0, 0, w, h, ColorAlpha( col, self.Wep.InspectingProgress * 225))

	if not TFA.Attachments.Atts[self.Attachment].Icon then
		TFA.Attachments.Atts[self.Attachment].Icon = "entities/tfa_qmark.png"
	end

	if not TFA.Attachments.Atts[self.Attachment].Icon_Cached then
		TFA.Attachments.Atts[self.Attachment].Icon_Cached = Material( TFA.Attachments.Atts[self.Attachment].Icon, "noclamp smooth" )
	end

	surface.SetDrawColor(ColorAlpha(color_white, self.Wep.InspectingProgress * 255))
	surface.SetMaterial(TFA.Attachments.Atts[self.Attachment].Icon_Cached)
	surface.DrawTexturedRect(padding, padding, w - padding * 2, h - padding * 2)
	if not TFA.Attachments.Atts[self.Attachment].ShortName then
		TFA.Attachments.Atts[self.Attachment].ShortName = abbrev( TFA.Attachments.Atts[self.Attachment].Name or "")
	end
	draw.SimpleText( string.upper( TFA.Attachments.Atts[self.Attachment].ShortName ) , "TFAAttachmentIconFontTiny", padding / 4, h, ColorAlpha(TFA.Attachments.Colors["primary"], self.Wep.InspectingProgress * ( sel and 192 or 64 ) ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end

vgui.Register("TFAAttachmentIcon", PANEL, "Panel")