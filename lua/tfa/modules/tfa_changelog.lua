
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

if CLIENT then
	local TFA_DISPLAY_CHANGELOG = false
	local changes = TFA_BASE_VERSION_CHANGES or ""
	local cvar_changelog

	if not file.Exists("tfa_base_version.txt", "DATA") then
		local f = file.Open("tfa_base_version.txt", "w", "DATA")
		f:Write(TFA_BASE_VERSION)
		f:Flush()
		f:Close()
		TFA_DISPLAY_CHANGELOG = true
	end

	local f = file.Open("tfa_base_version.txt", "r", "DATA")

	if f then
		local fileversion = f:ReadLine()
		local fileversionnumber = tonumber(fileversion or "")

		if fileversionnumber and fileversionnumber < TFA_BASE_VERSION then
			TFA_DISPLAY_CHANGELOG = true
			local f2 = file.Open("tfa_base_version.txt", "w", "DATA")
			f2:Write(TFA_BASE_VERSION)
			f2:Flush()
			f2:Close()
		end
	end

	hook.Add("HUDPaint", "TFA_DISPLAY_CHANGELOG", function()
		if LocalPlayer():IsValid() then
			if not cvar_changelog then
				cvar_changelog = GetConVar("sv_tfa_changelog")
			end
			if TFA_DISPLAY_CHANGELOG and cvar_changelog:GetBool() then
				chat.AddText("Updated to TFA Base Version: ")
				chat.AddText(TFA_BASE_VERSION_STRING)
				chat.AddText(changes)
			end

			hook.Remove("HUDPaint", "TFA_DISPLAY_CHANGELOG")
		end
	end)
end
