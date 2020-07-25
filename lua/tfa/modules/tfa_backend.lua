
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

--[[Custom Hooks]]--
--TFA_ClientLoad = After player is fully in-game
hook.Add("HUDPaint", "TFA_TRIGGERCLIENTLOAD", function()
	if LocalPlayer():IsValid() then
		hook.Call("TFA_ClientLoad")
		hook.Remove("HUDPaint", "TFA_TRIGGERCLIENTLOAD")
	end
end)

--[[Steam API]]--

local MEMBERCOUNT_STRING_START = "<memberCount>"
local MEMBERCOUNT_STRING_END = "</memberCount>"

local MEMBER_STRING_START = "<members>"
local MEMBER_STRING_END = "</members>"

local function XML_GetMembers( xml )
	local memberstartpos = string.find(xml,MEMBER_STRING_START) + string.len(MEMBER_STRING_START)
	local memberendpos = string.find(xml,MEMBER_STRING_END) - 1
	local res = string.sub(xml,memberstartpos,memberendpos)
	local res_tbl = string.Explode("<steamID64>",res)
	table.remove(res_tbl,1)
	for k,v in ipairs(res_tbl) do
		v = string.Replace(v,"</steamID64>","")
		v = string.Trim(v)
		res_tbl[k] = v
	end
	return res_tbl
end

function TFA.GetGroupMembers(groupname, callback)
	local async_count = 0

	http.Fetch("http://steamcommunity.com/groups/" .. groupname .. "/memberslistxml/?xml=1&p=" .. (async_count + 1) .. "&time=" .. math.Round(CurTime()), function(inner_bodytext)
		async_count = async_count + 1
		local memberstartpos = string.find(inner_bodytext, MEMBERCOUNT_STRING_START) + string.len(MEMBERCOUNT_STRING_START)
		local memberendpos = string.find(inner_bodytext, MEMBERCOUNT_STRING_END) - 1
		local membercount = tonumber(string.sub(inner_bodytext, memberstartpos, memberendpos))
		local pagecount = math.ceil(membercount / 1000)
		local members = XML_GetMembers(inner_bodytext)

		if async_count == pagecount then
			callback(members)
			return
		end

		for i = 2, pagecount do
			http.Fetch("http://steamcommunity.com/groups/" .. groupname .. "/memberslistxml/?xml=1&p=" .. i .. "&time=" .. math.Round(CurTime()), function(outer_bodytext)
				async_count = async_count + 1
				local member_outer = XML_GetMembers(outer_bodytext)

				for _, v in ipairs(member_outer) do
					table.insert(members, #members + 1, v)
				end

				if async_count == pagecount then
					callback(members)
				end
			end)
		end
	end)
end

local GROUPID_STRING_START = "<groupID64>"
local GROUPID_STRING_END = "</groupID64>"

local PRIVACY_STRING_START = "<privacyState>"
local PRIVACY_STRING_END = "</privacyState>"

function TFA.GetUserInGroup(groupname, steamid64, callback ) --Uses public profile data, not private
	http.Fetch("http://steamcommunity.com/groups/" .. groupname .. "/memberslistxml/?xml=1&p=" .. math.Round(CurTime()), function(inner_bodytext)
		local memberstartpos = string.find(inner_bodytext, GROUPID_STRING_START) + string.len(GROUPID_STRING_START)
		local memberendpos = string.find(inner_bodytext, GROUPID_STRING_END) - 1
		local groupid = string.sub(inner_bodytext, memberstartpos, memberendpos)

		http.Fetch("http://steamcommunity.com/profiles/" .. tostring(steamid64) .. "/?xml=1", function( outer_bodytext )
			local psstartpos = string.find(outer_bodytext, PRIVACY_STRING_START) + string.len(PRIVACY_STRING_START)
			local psendpos = string.find(outer_bodytext, PRIVACY_STRING_END) - 1
			local privacystr = string.sub(outer_bodytext, psstartpos, psendpos)
			if string.Trim(privacystr) != "public" then
				TFA.GetGroupMembers( groupname , function(members)
					if table.HasValue(members,LocalPlayer():SteamID64()) then
						callback( true )
					else
						callback( false )
					end
				end)
				return
			end

			if string.find(outer_bodytext,groupid) then
				callback(true)
			else
				callback(false)
			end
		end)
	end)
end
