
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
ENT.PrintName = "Assault Ammo"
ENT.Category = "TFA Ammunition"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Class = ""
ENT.MyModel = "models/Items/BoxMRounds.mdl"
ENT.ImpactSound = "Default.ImpactSoft"
ENT.AmmoCount = 100
ENT.AmmoType = "ar2"
ENT.DrawText = true
ENT.TextColor = Color(5, 5, 5, 255)
ENT.TextPosition = Vector(2, 1.5, 13.4)
ENT.TextAngles = Vector(90, 90, 90)
ENT.ShouldDrawShadow = true
ENT.ImpactSound = "Default.ImpactSoft"
ENT.Damage = 35
ENT.Text = "Assault Ammo"
