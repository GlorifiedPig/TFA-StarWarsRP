
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

local w, h, cv_dbc, lply

hook.Add("HUDPaint", "tfa_debugcrosshair", function()
	if not cv_dbc then
		cv_dbc = GetConVar("cl_tfa_debug_crosshair")
	end

	if not cv_dbc or not cv_dbc:GetBool() then return end

	if not w then
		w = ScrW()
	end

	if not h then
		h = ScrH()
	end

	if not IsValid(lply) then
		lply = LocalPlayer()
	end

	if not lply:IsValid() then return end
	if not lply:IsAdmin() then return end
	surface.SetDrawColor(color_white)
	surface.DrawRect(w / 2 - 1, h / 2 - 1, 2, 2)
end)
