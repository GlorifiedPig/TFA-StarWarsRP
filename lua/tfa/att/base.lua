
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

if not ATTACHMENT then
	ATTACHMENT = {}
end

ATTACHMENT.Name = "Base Attachment"
ATTACHMENT.ShortName = nil --Abbreviation, 5 chars or less please
ATTACHMENT.Description = {} --TFA.Attachments.Colors["+"], "Does something good", TFA.Attachments.Colors["-"], "Does something bad" }
ATTACHMENT.Icon = nil --Revers to label, please give it an icon though!  This should be the path to a png, like "entities/tfa_ammo_match.png"
ATTACHMENT.WeaponTable = {} --put replacements for your SWEP talbe in here e.g. ["Primary"] = {}

function ATTACHMENT:CanAttach(wep)
	return true --can be overridden per-attachment
end

function ATTACHMENT:Attach(wep)
end

function ATTACHMENT:Detach(wep)
end

if not TFA_ATTACHMENT_ISUPDATING then
	TFAUpdateAttachments()
end