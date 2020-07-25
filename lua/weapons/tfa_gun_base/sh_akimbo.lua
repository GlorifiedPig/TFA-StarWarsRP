
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

SWEP.AnimCycle = SWEP.ViewModelFlip and 0 or 1

function SWEP:FixAkimbo()
	if self:GetStat("Akimbo") and self.Secondary.ClipSize > 0 then
		self.Primary.ClipSize = self.Primary.ClipSize + self.Secondary.ClipSize
		self.Secondary.ClipSize = -1
		self.Primary.RPM = self.Primary.RPM * 2
		self.Akimbo_Inverted = self.ViewModelFlip
		self.AnimCycle = self.ViewModelFlip and 0 or 1
		self:ClearStatCache()

		timer.Simple(FrameTime(), function()
			timer.Simple(0.01, function()
				if IsValid(self) and self:OwnerIsValid() then
					self:SetClip1(self.Primary.ClipSize)
				end
			end)
		end)
	end
end

function SWEP:ToggleAkimbo(arg1)
	if self:GetStat("Akimbo") and (IsFirstTimePredicted() or (arg1 and arg1 == "asdf")) then
		self.AnimCycle = 1 - self.AnimCycle
	end

	if SERVER and game.SinglePlayer() then
		self.SetNW2Int = self.SetNW2Int or self.SetNWInt
		self:SetNW2Int("AnimCycle", self.AnimCycle)
	end
end