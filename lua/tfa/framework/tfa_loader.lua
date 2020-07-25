
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

if SERVER then AddCSLuaFile() end

TFA = TFA or {}

local do_load = true
local version = 4.571
local version_string = "4.5.7.1"
local changelog = [[
	+ Added localization support. English and Russian locales are bundled by default.
	* Fixed weapons not spawning in TTT (by Anairkoen Schno)
	* Blocked new ammo pickups (SMG grenades) from being pocketed in DarkRP
	* Fixed networked menu not working in Local/P2P servers
]]

local function testFunc()
end

local my_path = debug.getinfo(testFunc)
if my_path and type(my_path) == "table" and my_path.short_src then
	my_path = my_path["short_src"]
else
	my_path = "legacy"
end

if TFA_BASE_VERSION then

	if TFA_BASE_VERSION > version then
		print("You have a newer, conflicting version of TFA Base.")
		print("It's located at: " .. ( TFA_FILE_PATH or "" ) )
		print("Contact the author of that pack, not TFA.")
		do_load = false
	elseif TFA_BASE_VERSION < version then
		print("You have an older, conflicting version of TFA Base.")
		print("It's located at: " .. ( TFA_FILE_PATH or "" ) )
		print("Contact the author of that pack, not TFA.")
	elseif TFA_BASE_VERSION == version then
		print("You have an equal, conflicting version of TFA Base.")
		print("It's located at: " .. ( TFA_FILE_PATH or "" ) )
		print("Contact the author of that pack, not TFA.")
	end

end

if do_load then
	-- luacheck: globals TFA_BASE_VERSION TFA_BASE_VERSION_STRING TFA_BASE_VERSION_CHANGES TFA_FILE_PATH
	TFA_BASE_VERSION = version
	TFA_BASE_VERSION_STRING = version_string
	TFA_BASE_VERSION_CHANGES = changelog
	TFA_FILE_PATH = my_path

	TFA.Enum = TFA.Enum or {}

	local flist = file.Find("tfa/enums/*.lua","LUA")

	for _, filename in pairs(flist) do

		local typev = "SHARED"
		if filename:StartWith("cl_") then
			typev = "CLIENT"
		elseif filename:StartWith("sv_") then
			typev = "SERVER"
		end

		if SERVER and typev ~= "SERVER" then
			AddCSLuaFile( "tfa/enums/" .. filename )
		end

		if ( SERVER and typev ~= "CLIENT" ) or ( CLIENT and typev ~= "SERVER" ) then
			include( "tfa/enums/" .. filename )
			--print("Initialized " .. filename .. " || " .. fileid .. "/" .. #flist )
		end

	end

	flist = file.Find("tfa/modules/*.lua","LUA")

	for _, filename in pairs(flist) do

		local typev = "SHARED"
		if filename:StartWith("cl_") then
			typev = "CLIENT"
		elseif filename:StartWith("sv_") then
			typev = "SERVER"
		end

		if SERVER and typev ~= "SERVER" then
			AddCSLuaFile( "tfa/modules/" .. filename )
		end

		if ( SERVER and typev ~= "CLIENT" ) or ( CLIENT and typev ~= "SERVER" ) then
			include( "tfa/modules/" .. filename )
			--print("Initialized " .. filename .. " || " .. fileid .. "/" .. #flist )
		end

	end

	flist = file.Find("tfa/external/*.lua","LUA")

	for _, filename in pairs(flist) do

		local typev = "SHARED"
		if filename:StartWith("cl_") then
			typev = "CLIENT"
		elseif filename:StartWith("sv_") then
			typev = "SERVER"
		end

		if SERVER and typev ~= "SERVER" then
			AddCSLuaFile( "tfa/external/" .. filename )
		end

		if ( SERVER and typev ~= "CLIENT" ) or ( CLIENT and typev ~= "SERVER" ) then
			include( "tfa/external/" .. filename )
			--print("Initialized " .. filename .. " || " .. fileid .. "/" .. #flist )
		end

	end

end
