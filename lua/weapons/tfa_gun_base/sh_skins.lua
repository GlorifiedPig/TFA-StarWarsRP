
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

SWEP.MaterialTable = {}
SWEP.MaterialTable_V = {}
SWEP.MaterialTable_W = {}

function SWEP:InitializeMaterialTable()
	if not self.HasSetMaterialMeta then
		setmetatable(self.MaterialTable_V, {
			["__index"] = function(t,k) return self:GetStat("MaterialTable")[k] end
		})

		setmetatable(self.MaterialTable_W, {
			["__index"] = function(t,k) return self:GetStat("MaterialTable")[k] end
		})

		self.HasSetMaterialMeta = true
	end
end

--if both nil then we can just clear it all
function SWEP:ClearMaterialCache(view, world)
	if view == nil and world == nil then
		self.MaterialCached_V = nil
		self.MaterialCached_W = nil
		self.MaterialCached = nil
		self.SCKMaterialCached_V = nil
		self.SCKMaterialCached_W = nil
	else
		if view then
			self.MaterialCached_V = nil
			self.SCKMaterialCached_V = nil
		end

		if world then
			self.MaterialCached_W = nil
			self.SCKMaterialCached_W = nil
		end
	end
	self:ClearStatCache()
end