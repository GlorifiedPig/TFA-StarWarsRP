
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
end

ENT.Type = "anim"
ENT.Base = "tfa_ammo_base"
ENT.PrintName = "Winchester Ammo"
ENT.Category = "TFA Ammunition"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Class = ""
ENT.MyModel = "models/Items/sniper_round_box.mdl"
ENT.ImpactSound = "Default.ImpactSoft"
ENT.AmmoCount = 50
ENT.AmmoType = "AirboatGun"
ENT.DrawText = true
ENT.TextColor = Color(185, 25, 25, 255)
ENT.TextPosition = Vector(1, -1.45, 1.5)
ENT.TextAngles = Vector(90, 0, 0)
ENT.ShouldDrawShadow = true
ENT.ImpactSound = "Default.ImpactSoft"
ENT.Damage = 30
ENT.Text = ".308"
