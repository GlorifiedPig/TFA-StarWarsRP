
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
	util.AddNetworkString("TFAJoinGroupPopup")

	hook.Add("PlayerSay", "TFAJoinGroupChat", function(ply, text, tc)
		if string.Trim(text) == "!jointfa" then
			net.Start("TFAJoinGroupPopup")
			net.Send(ply)
		end
	end)
end

if CLIENT then

	--[[

	local function comma_value(amount) --Credit to the lua-user.org wiki
		local formatted = amount

		while true do
			local k
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
			if (k == 0) then break end
		end

		return formatted
	end

	local TFA_NAGCOUNT = 0

	hook.Add("TFA_ClientLoad", "TFA_NAG", function()
		TFA.GetGroupMembers("tfa-mods", function(members)
			if not table.HasValue(members,LocalPlayer():SteamID64()) then --They're not a member

				if file.Exists("tfa_nag_v3.txt", "DATA") then
					TFA_NAGCOUNT = tonumber( file.Read("tfa_nag_v3.txt","DATA") )
				end

				local f = file.Open("tfa_nag_v3.txt", "w", "DATA")
				f:Write( tostring( TFA_NAGCOUNT + 1 ) )
				f:Flush()
				f:Close()

				if TFA_NAGCOUNT < 5 then
					chat.AddText(TFA.GetLangString("nag_1"), LocalPlayer():Nick(), TFA.GetLangString("nag_2") .. comma_value( #members + 1 ) .. TFA.GetLangString("nag_3") .. tostring( TFA_NAGCOUNT + 1 ) .. ".")
				end
			else
				if file.Exists("tfa_nag_v3.txt","DATA") then
					file.Delete("tfa_nag_v3.txt")
					chat.AddText(TFA.GetLangString("thank_1"), LocalPlayer():Nick(), TFA.GetLangString("thank_2") .. comma_value( #members ) .. "." )
				end
			end
		end)
	end)
	]]--

	net.Receive("TFAJoinGroupPopup", function()
		gui.OpenURL("http://steamcommunity.com/groups/tfa-mods")
	end)


end
