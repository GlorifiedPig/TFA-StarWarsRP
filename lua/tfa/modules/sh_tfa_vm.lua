
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

local st_old, host_ts, cheats, vec, ang
host_ts = GetConVar("host_timescale")
cheats = GetConVar("sv_cheats")
vec = Vector()
ang = Angle()

local sp = game.SinglePlayer()
local IsGameUIVisible = gui and gui.IsGameUIVisible

hook.Add("PreDrawViewModel", "TFACalculateViewmodel", function(vm, ply, wep)
	if not IsValid(wep) or not wep:IsTFA() then return end

	local st = SysTime()
	st_old = st_old or st

	local delta = st - st_old
	st_old = st

	if sp and IsGameUIVisible and IsGameUIVisible() then return end

	delta = delta * game.GetTimeScale() * (cheats:GetBool() and host_ts:GetFloat() or 1)

	wep:Sway(vec, ang, delta)
	wep:CalculateViewModelOffset(delta)
	wep:CalculateViewModelFlip()
end)