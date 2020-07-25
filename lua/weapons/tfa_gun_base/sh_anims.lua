
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

SWEP.Locomotion_Data_Queued = nil

local ServersideLooped = {
	[ACT_VM_FIDGET] = true,
	[ACT_VM_FIDGET_EMPTY] = true
}

--[ACT_VM_IDLE] = true,
--[ACT_VM_IDLE_EMPTY] = true,
--[ACT_VM_IDLE_SILENCED] = true
local d, pbr

--[[

]]
--
--Override this after SWEP:Initialize, for example, in attachments
SWEP.BaseAnimations = {
	["draw_first"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_DRAW_DEPLOYED,
		["enabled"] = nil --Manually force a sequence to be enabled
	},
	["draw"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_DRAW
	},
	["draw_empty"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_DRAW_EMPTY
	},
	["draw_silenced"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_DRAW_SILENCED
	},
	["shoot1"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_PRIMARYATTACK
	},
	["shoot1_last"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_PRIMARYATTACK_EMPTY
	},
	["shoot1_empty"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_DRYFIRE
	},
	["shoot1_silenced"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_PRIMARYATTACK_SILENCED
	},
	["shoot1_silenced_empty"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_DRYFIRE_SILENCED or 0
	},
	["shoot1_is"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_PRIMARYATTACK_1
	},
	["shoot2"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_SECONDARYATTACK
	},
	["shoot2_last"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "shoot2_last"
	},
	["shoot2_empty"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_DRYFIRE
	},
	["shoot2_silenced"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "shoot2_silenced"
	},
	["shoot2_is"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_ISHOOT_M203
	},
	["idle"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_IDLE
	},
	["idle_empty"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_IDLE_EMPTY
	},
	["idle_silenced"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_IDLE_SILENCED
	},
	["reload"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_RELOAD
	},
	["reload_empty"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_RELOAD_EMPTY
	},
	["reload_silenced"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_RELOAD_SILENCED
	},
	["reload_shotgun_start"] = {
		["type"] = TFA.Enum.ANIMATION_ACT,
		["value"] = ACT_SHOTGUN_RELOAD_START
	},
	["reload_shotgun_finish"] = {
		["type"] = TFA.Enum.ANIMATION_ACT,
		["value"] = ACT_SHOTGUN_RELOAD_FINISH
	},
	["holster"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_HOLSTER
	},
	["holster_empty"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_HOLSTER_EMPTY
	},
	["holster_silenced"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_HOLSTER_SILENCED
	},
	["silencer_attach"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_ATTACH_SILENCER
	},
	["silencer_detach"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_DETACH_SILENCER
	},
	["rof"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_FIREMODE
	},
	["rof_is"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_IFIREMODE
	},
	["bash"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_HITCENTER
	},
	["bash_silenced"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_HITCENTER2
	},
	["bash_empty"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_MISSCENTER
	},
	["bash_empty_silenced"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_MISSCENTER2
	},
	["inspect"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_FIDGET
	},
	["inspect_empty"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_FIDGET_EMPTY
	},
	["inspect_silenced"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_FIDGET_SILENCED
	}
}

SWEP.Animations = {}

function SWEP:InitializeAnims()
	setmetatable(self.Animations, {
		__index = function(t, k) return self.BaseAnimations[k] end
	})
end

function SWEP:BuildAnimActivities()
	self.AnimationActivities = self.AnimationActivities or {}

	for k, _ in pairs(self.BaseAnimations) do
		local kvt = self:GetStat("Animations." .. k)

		if kvt.value then
			self.AnimationActivities[kvt.value] = k
		end
	end

	for k, _ in pairs(self.Animations) do
		local kvt = self:GetStat("Animations." .. k)

		if kvt.value then
			self.AnimationActivities[kvt.value] = k
		end
	end
end

function SWEP:GetActivityEnabled(act)
	local stat = self:GetStat("SequenceEnabled." .. act)
	if stat then return stat end

	if not self.AnimationActivities then
		self:BuildAnimActivities()
	end

	local keysel = self.AnimationActivities[act] or ""
	local kv = self:GetStat("Animations." .. keysel)
	if not kv then return false end

	if kv["enabled"] then
		return kv["enabled"]
	else
		return false
	end
end

function SWEP:ChooseAnimation(key)
	local kv = self:GetStat("Animations." .. key)
	if not kv then return 0, 0 end
	if not kv["type"] then return 0, 0 end
	if not kv["value"] then return 0, 0 end

	return kv["type"], kv["value"]
end

local sqto, sqro

function SWEP:GetAnimationRate(ani)
	local rate = 1
	if not ani or ani < 0 or not self:VMIV() then return rate end
	local nm = self.OwnerViewModel:GetSequenceName(self.OwnerViewModel:SelectWeightedSequence(ani))

	if IsValid(self) then
		sqto = self:GetStat("SequenceTimeOverride." .. nm) or self:GetStat("SequenceTimeOverride." .. (ani or "0"))
		sqro = self:GetStat("SequenceRateOverride." .. nm) or self:GetStat("SequenceRateOverride." .. (ani or "0"))

		if sqro then
			rate = rate * sqro
		elseif sqto then
			local t = self:GetActivityLengthRaw(ani, false)

			if t then
				rate = rate * t / sqto
			end
		end
	end

	rate = hook.Run("TFA_AnimationRate", self, ani, rate) or rate

	return rate
end
function SWEP:SendViewModelAnim(act, rate, targ, blend)
	local vm = self.OwnerViewModel

	if rate and not targ then
		rate = math.max(rate, 0.0001)
	end

	if not rate then
		rate = 1
	end

	if targ then
		rate = rate / self:GetAnimationRate(act)
	else
		rate = rate * self:GetAnimationRate(act)
	end

	if act < 0 then return false, act end
	if not self:VMIV() then return false, act end
	local seq = vm:SelectWeightedSequenceSeeded(act, CurTime())

	if seq < 0 then
		if act == ACT_VM_IDLE_EMPTY then
			seq = vm:SelectWeightedSequenceSeeded(ACT_VM_IDLE, CurTime())
		elseif act == ACT_VM_PRIMARYATTACK_EMPTY then
			seq = vm:SelectWeightedSequenceSeeded(ACT_VM_PRIMARYATTACK, CurTime())
		else
			return
		end

		if seq < 0 then return false, act end
	end

	self:SetLastActivity(act)
	self.LastAct = act
	self:ResetEvents()

	if self:GetLastActivity() == act and ServersideLooped[act] then
		self:ChooseIdleAnim()
		d = vm:SequenceDuration(seq)
		pbr = targ and (d / (rate or 1)) or (rate or 1)

		if IsValid(self) then
			if blend == nil then
				blend = self.Idle_Smooth
			end

			self:SetNextIdleAnim(CurTime() + d / pbr - blend)
		end

		if IsFirstTimePredicted() then
			timer.Simple(0, function()
				vm:SendViewModelMatchingSequence(seq)
				d = vm:SequenceDuration()
				pbr = targ and (d / (rate or 1)) or (rate or 1)
				vm:SetPlaybackRate(pbr)

				if IsValid(self) then
					if blend == nil then
						blend = self.Idle_Smooth
					end

					self:SetNextIdleAnim(CurTime() + d / pbr - blend)
					self:SetLastActivity(act)
					self.LastAct = act
				end
			end)
		end
	else
		if seq >= 0 then
			vm:SendViewModelMatchingSequence(seq)
		end

		d = vm:SequenceDuration()
		pbr = targ and (d / (rate or 1)) or (rate or 1)
		vm:SetPlaybackRate(pbr)

		if blend == nil then
			blend = self.Idle_Smooth
		end

		self:SetNextIdleAnim(CurTime() + math.max(d / pbr - blend, self.Idle_Smooth))
	end

	return true, act
end

function SWEP:SendViewModelSeq(seq, rate, targ, blend)
	local seqold = seq
	local vm = self.OwnerViewModel
	if not self:VMIV() then return false, 0 end

	if type(seq) == "string" then
		seq = vm:LookupSequence(seq) or 0
	end

	local act = vm:GetSequenceActivity(seq)

	if self.SequenceRateOverride[seqold] then
		rate = self.SequenceRateOverride[seqold]
		targ = false
	elseif self.SequenceRateOverride[act] then
		rate = self.SequenceRateOverride[act]
		targ = false
	elseif self.SequenceTimeOverride[seqold] then
		rate = self.SequenceTimeOverride[seqold]
		targ = true
	elseif self.SequenceTimeOverride[act] then
		rate = self.SequenceTimeOverride[act]
		targ = true
	end

	if not rate then
		rate = 1
	end

	if targ then
		rate = rate / self:GetAnimationRate(act)
	else
		rate = rate * self:GetAnimationRate(act)
	end

	if seq < 0 then return false, act end
	self:SetLastActivity(act)
	self.LastAct = act
	self:ResetEvents()

	if self:GetLastActivity() == act and ServersideLooped[act] then
		vm:SendViewModelMatchingSequence(act == 0 and 1 or 0)
		vm:SetPlaybackRate(0)
		vm:SetCycle(0)
		self:SetNextIdleAnim(CurTime() + 0.03)

		if IsFirstTimePredicted() then
			timer.Simple(0, function()
				vm:SendViewModelMatchingSequence(seq)
				d = vm:SequenceDuration()
				pbr = targ and (d / (rate or 1)) or (rate or 1)
				vm:SetPlaybackRate(pbr)

				if IsValid(self) then
					if blend == nil then
						blend = self.Idle_Smooth
					end

					self:SetNextIdleAnim(CurTime() + d / pbr - blend)
					self:SetLastActivity(act)
					self.LastAct = act
				end
			end)
		end
	else
		if seq >= 0 then
			vm:SendViewModelMatchingSequence(seq)
		end

		d = vm:SequenceDuration()
		pbr = targ and (d / (rate or 1)) or (rate or 1)
		vm:SetPlaybackRate(pbr)

		if IsValid(self) then
			if blend == nil then
				blend = self.Idle_Smooth
			end

			self:SetNextIdleAnim(CurTime() + d / pbr - blend)
		end
	end

	return true, act
end

local tval

function SWEP:PlayAnimation(data, fade)
	if not self:VMIV() then return end
	if not data then return false, -1 end
	local vm = self.OwnerViewModel

	if data.type == TFA.Enum.ANIMATION_ACT then
		tval = data.value

		if self:Clip1() <= 0 and self.Primary.ClipSize >= 0 then
			tval = data.value_empty or tval
		end

		if self:Clip1() == 1 and self.Primary.ClipSize >= 0 then
			tval = data.value_last or tval
		end

		if self:GetSilenced() then
			tval = data.value_sil or tval
		end

		if self:GetIronSightsDirect() then
			tval = data.value_is or tval

			if self:Clip1() <= 0 and self.Primary.ClipSize >= 0 then
				tval = data.value_is_empty or tval
			end

			if self:Clip1() == 1 and self.Primary.ClipSize >= 0 then
				tval = data.value_is_last or tval
			end

			if self:GetSilenced() then
				tval = data.value_is_sil or tval
			end
		end

		if type(tval) == "string" then
			tval = tonumber(tval) or -1
		end

		if tval and tval > 0 then return self:SendViewModelAnim(tval, 1, false, fade or (data.transition and self.Idle_Blend or self.Idle_Smooth) ) end
	elseif data.type == TFA.Enum.ANIMATION_SEQ then
		tval = data.value

		if self:Clip1() <= 0 and self.Primary.ClipSize >= 0 then
			tval = data.value_empty or tval
		end

		if self:Clip1() == 1 and self.Primary.ClipSize >= 0 then
			tval = data.value_last or tval
		end

		if self:GetSilenced() then
			tval = data.value_sil or tval
		end

		if self:GetIronSightsDirect() then
			tval = data.value_is or tval

			if self:Clip1() <= 0 and self.Primary.ClipSize >= 0 then
				tval = data.value_is_empty or tval
			end

			if self:Clip1() == 1 and self.Primary.ClipSize >= 0 then
				tval = data.value_is_last or tval
			end

			if self:GetSilenced() then
				tval = data.value_is_sil or tval
			end
		end

		if type(tval) == "string" then
			tval = vm:LookupSequence(tval)
		end

		if tval and tval > 0 then return self:SendViewModelSeq(tval, 1, false, fade or (data.transition and self.Idle_Blend or self.Idle_Smooth) ) end
	end
end

local success, tanim, typev
--[[
Function Name:  Locomote
Syntax: self:Locomote( flip ironsights, new is, flip sprint, new sprint, flip walk, new walk).
Returns:
Notes:
Purpose:  Animation / Utility
]]
local tldata

function SWEP:Locomote(flipis, is, flipsp, spr, flipwalk, walk, flipcust, cust)
	if not (flipis or flipsp or flipwalk or flipcust) then return end
	if not (self:GetStatus() == TFA.Enum.STATUS_IDLE or (self:GetStatus() == TFA.Enum.STATUS_SHOOTING and self:CanInterruptShooting())) then return end
	tldata = nil

	if flipis then
		if is and self:GetStat("IronAnimation.in") then
			tldata = self:GetStat("IronAnimation.in") or tldata
		elseif self:GetStat("IronAnimation.out") and not flipsp then
			tldata = self:GetStat("IronAnimation.out") or tldata
		end
	end

	if flipsp then
		if spr and self:GetStat("SprintAnimation.in") then
			tldata = self:GetStat("SprintAnimation.in") or tldata
		elseif self:GetStat("SprintAnimation.out") and not flipis and not spr then
			tldata = self:GetStat("SprintAnimation.out") or tldata
		end
	end

	if flipwalk and not is then
		if walk and self:GetStat("WalkAnimation.in") then
			tldata = self:GetStat("WalkAnimation.in") or tldata
		elseif self:GetStat("WalkAnimation.out") and (not flipis and not flipsp and not flipcust) and not walk then
			tldata = self:GetStat("WalkAnimation.out") or tldata
		end
	end

	if flipcust then
		if cust and self:GetStat("CustomizeAnimation.in") then
			tldata = self:GetStat("CustomizeAnimation.in") or tldata
		elseif self:GetStat("CustomizeAnimation.out") and (not flipis and not flipsp and not flipwalk) and not cust then
			tldata = self:GetStat("CustomizeAnimation.out") or tldata
		end
	end

	--self.Idle_WithHeld = true
	if tldata then return self:PlayAnimation(tldata) end
	--self:SetNextIdleAnim(-1)

	return false, -1
end

--[[
Function Name:  ChooseDrawAnim
Syntax: self:ChooseDrawAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]
SWEP.IsFirstDeploy = true

function SWEP:ChooseDrawAnim()
	if not self:VMIV() then return end
	--self:ResetEvents()
	tanim = ACT_VM_DRAW
	success = true

	if self.IsFirstDeploy and CurTime() > (self.LastDeployAnim or CurTime()) + 0.1 then
		self.IsFirstDeploy = false
	end

	if self:GetActivityEnabled(ACT_VM_DRAW_EMPTY) and (self:Clip1() == 0) then
		typev, tanim = self:ChooseAnimation("draw_empty")
	elseif (self:GetActivityEnabled(ACT_VM_DRAW_DEPLOYED) or self.FirstDeployEnabled) and self.IsFirstDeploy then
		typev, tanim = self:ChooseAnimation("draw_first")
	elseif self:GetActivityEnabled(ACT_VM_DRAW_SILENCED) and self:GetSilenced() then
		typev, tanim = self:ChooseAnimation("draw_silenced")
	else
		typev, tanim = self:ChooseAnimation("draw")
	end

	self.LastDeployAnim = CurTime()

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

function SWEP:ResetFirstDeploy()
	self.IsFirstDeploy = true
	self.LastDeployAnim = math.huge
end

--[[
Function Name:  ChooseInspectAnim
Syntax: self:ChooseInspectAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]
--

function SWEP:ChooseInspectAnim()
	if not self:VMIV() then return end

	if self:GetActivityEnabled(ACT_VM_FIDGET_SILENCED) and self:GetSilenced() then
		typev, tanim = self:ChooseAnimation("inspect_silenced")
	elseif self:GetActivityEnabled(ACT_VM_FIDGET_EMPTY) and self.Primary.ClipSize > 0 and math.Round(self:Clip1()) == 0 then
		typev, tanim = self:ChooseAnimation("inspect_empty")
	elseif self.InspectionActions then
		tanim = self.InspectionActions[self:SharedRandom(1, #self.InspectionActions, "Inspect")]
	elseif self:GetActivityEnabled(ACT_VM_FIDGET) then
		typev, tanim = self:ChooseAnimation("inspect")
	else
		typev, tanim = self:ChooseAnimation("idle")
		success = false
	end

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

--[[
Function Name:  ChooseHolsterAnim
Syntax: self:ChooseHolsterAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseHolsterAnim()
	if not self:VMIV() then return end

	if self:GetActivityEnabled(ACT_VM_HOLSTER_SILENCED) and self:GetSilenced() then
		typev, tanim = self:ChooseAnimation("holster_silenced")
	elseif self:GetActivityEnabled(ACT_VM_HOLSTER_EMPTY) and (self:Clip1() == 0) then
		typev, tanim = self:ChooseAnimation("holster_empty")
	elseif self:GetActivityEnabled(ACT_VM_HOLSTER) then
		typev, tanim = self:ChooseAnimation("holster")
	else
		local _
		_, tanim = self:ChooseIdleAnim()

		return false, tanim
	end

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

--[[
Function Name:  ChooseProceduralReloadAnim
Syntax: self:ChooseProceduralReloadAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Uses some holster code
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseProceduralReloadAnim()
	if not self:VMIV() then return end

	if not self.DisableIdleAnimations then
		self:SendViewModelAnim(ACT_VM_IDLE)
	end

	return true, ACT_VM_IDLE
end

--[[
Function Name:  ChooseReloadAnim
Syntax: self:ChooseReloadAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseReloadAnim()
	if not self:VMIV() then return false, 0 end
	if self.ProceduralReloadEnabled then return false, 0 end

	if self:GetActivityEnabled(ACT_VM_RELOAD_SILENCED) and self:GetSilenced() then
		typev, tanim = self:ChooseAnimation("reload_silenced")
	elseif self:GetActivityEnabled(ACT_VM_RELOAD_EMPTY) and (self:Clip1() == 0 or self:IsJammed())and not self.Shotgun then
		typev, tanim = self:ChooseAnimation("reload_empty")
	else
		typev, tanim = self:ChooseAnimation("reload")
	end

	local fac = 1

	if self.Shotgun and self.ShellTime then
		fac = self.ShellTime
	end

	self.AnimCycle = self.ViewModelFlip and 0 or 1

	if SERVER and game.SinglePlayer() then
		self.SetNW2Int = self.SetNW2Int or self.SetNWInt
		self:SetNW2Int("AnimCycle", self.AnimCycle)
	end

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim, fac, fac ~= 1)
	else
		return self:SendViewModelSeq(tanim, fac, fac ~= 1)
	end
end

--[[
Function Name:  ChooseReloadAnim
Syntax: self:ChooseReloadAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseShotgunReloadAnim()
	if not self:VMIV() then return end

	if self:GetActivityEnabled(ACT_VM_RELOAD_SILENCED) and self:GetSilenced() then
		typev, tanim = self:ChooseAnimation("reload_silenced")
	elseif self:GetActivityEnabled(ACT_VM_RELOAD_EMPTY) and self.ShotgunEmptyAnim and (self:Clip1() == 0 or self:IsJammed()) then
		typev, tanim = self:ChooseAnimation("reload_empty")
	elseif self.SequenceEnabled[ACT_SHOTGUN_RELOAD_START] then
		typev, tanim = self:ChooseAnimation("reload_shotgun_start")
	else
		local _
		_, tanim = self:ChooseIdleAnim()

		return false, tanim
	end

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

function SWEP:ChooseShotgunPumpAnim()
	if not self:VMIV() then return end
	typev, tanim = self:ChooseAnimation("reload_shotgun_finish")

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

--[[
Function Name:  ChooseIdleAnim
Syntax: self:ChooseIdleAnim().
Returns:  True,  Which action?
Notes:  Requires autodetection for full features.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseIdleAnim()
	if not self:VMIV() then return end
	--if self.Idle_WithHeld then
	--	self.Idle_WithHeld = nil
	--	return
	--end

	if TFA.Enum.ShootLoopingStatus[self:GetShootStatus()] then
		return self:ChooseLoopShootAnim()
	end

	if self.Idle_Mode ~= TFA.Enum.IDLE_BOTH and self.Idle_Mode ~= TFA.Enum.IDLE_ANI then return end

	--self:ResetEvents()
	if self:GetIronSights() then
		if self.Sights_Mode == TFA.Enum.LOCOMOTION_LUA then
			return self:ChooseFlatAnim()
		else
			return self:ChooseADSAnim()
		end
	elseif self:GetSprinting() and self.Sprint_Mode ~= TFA.Enum.LOCOMOTION_LUA then
		return self:ChooseSprintAnim()
	elseif self:GetWalking() and self.Walk_Mode ~= TFA.Enum.LOCOMOTION_LUA then
		return self:ChooseWalkAnim()
	elseif self:GetCustomizing() and self.Customize_Mode ~= TFA.Enum.LOCOMOTION_LUA then
		return self:ChooseCustomizeAnim()
	end

	if self:GetActivityEnabled(ACT_VM_IDLE_SILENCED) and self:GetSilenced() then
		typev, tanim = self:ChooseAnimation("idle_silenced")
	elseif (self.Primary.ClipSize > 0 and self:Clip1() == 0) or (self.Primary.ClipSize <= 0 and self:Ammo1() == 0) then
		--self:GetActivityEnabled( ACT_VM_IDLE_EMPTY ) and (self:Clip1() == 0) then
		if self:GetActivityEnabled(ACT_VM_IDLE_EMPTY) then
			typev, tanim = self:ChooseAnimation("idle_empty")
		else --if not self:GetActivityEnabled( ACT_VM_PRIMARYATTACK_EMPTY ) then
			typev, tanim = self:ChooseAnimation("idle")
		end
	else
		typev, tanim = self:ChooseAnimation("idle")
	end

	--else
	--	return
	--end
	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

function SWEP:ChooseFlatAnim()
	if not self:VMIV() then return end
	--self:ResetEvents()
	typev, tanim = self:ChooseAnimation("idle")

	if self:GetActivityEnabled(ACT_VM_IDLE_SILENCED) and self:GetSilenced() then
		typev, tanim = self:ChooseAnimation("idle_silenced")
	elseif self:GetActivityEnabled(ACT_VM_IDLE_EMPTY) and ((self.Primary.ClipSize > 0 and self:Clip1() == 0) or (self.Primary.ClipSize <= 0 and self:Ammo1() == 0)) then
		typev, tanim = self:ChooseAnimation("idle_empty")
	end

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim, 0.000001)
	else
		return self:SendViewModelSeq(tanim, 0.000001)
	end
end

function SWEP:ChooseADSAnim()
	local a, b, c = self:PlayAnimation(self:GetStat("IronAnimation.loop"))

	--self:SetNextIdleAnim(CurTime() + 1)
	if not a then
		local _
		_, b, c = self:ChooseFlatAnim()
		a = false
	end

	return a, b, c
end

function SWEP:ChooseSprintAnim()
	return self:PlayAnimation(self:GetStat("SprintAnimation.loop"))
end

function SWEP:ChooseWalkAnim()
	return self:PlayAnimation(self:GetStat("WalkAnimation.loop"))
end

function SWEP:ChooseLoopShootAnim()
	return self:PlayAnimation(self:GetStat("ShootAnimation.loop"))
end

function SWEP:ChooseCustomizeAnim()
	return self:PlayAnimation(self:GetStat("CustomizeAnimation.loop"))
end

--[[
Function Name:  ChooseShootAnim
Syntax: self:ChooseShootAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseShootAnim(ifp)
	ifp = ifp or IsFirstTimePredicted()
	if not self:VMIV() then return end

	if self:GetStat("ShootAnimation.loop") and self.Primary.Automatic then
		if self.LuaShellEject and ifp then
			self:EventShell()
		end

		if TFA.Enum.ShootReadyStatus[self:GetShootStatus()] then
			self:SetShootStatus(TFA.Enum.SHOOT_START)
			local inan = self:GetStat("ShootAnimation.in")
			if not inan then
				inan = self:GetStat("ShootAnimation.loop")
			end
			return self:PlayAnimation(inan)
		end

		return
	end

	if self:GetIronSights() and (self.Sights_Mode == TFA.Enum.LOCOMOTION_ANI or self.Sights_Mode == TFA.Enum.LOCOMOTION_HYBRID) and self:GetStat("IronAnimation.shoot") then
		if self.LuaShellEject and ifp then
			self:EventShell()
		end

		return self:PlayAnimation(self:GetStat("IronAnimation.shoot"))
	end

	if not self.BlowbackEnabled or (not self:GetIronSights() and self.Blowback_Only_Iron) then
		success = true

		if self.LuaShellEject and (ifp or game.SinglePlayer()) then
			self:EventShell()
		end

		if self:GetActivityEnabled(ACT_VM_PRIMARYATTACK_SILENCED) and self:GetSilenced() then
			typev, tanim = self:ChooseAnimation("shoot1_silenced")
		elseif self:Clip1() <= self.Primary.AmmoConsumption and self:GetActivityEnabled(ACT_VM_PRIMARYATTACK_EMPTY) and self.Primary.ClipSize >= 1 and not self.ForceEmptyFireOff then
			typev, tanim = self:ChooseAnimation("shoot1_last")
		elseif self:Ammo1() <= self.Primary.AmmoConsumption and self:GetActivityEnabled(ACT_VM_PRIMARYATTACK_EMPTY) and self.Primary.ClipSize < 1 and not self.ForceEmptyFireOff then
			typev, tanim = self:ChooseAnimation("shoot1_last")
		elseif self:Clip1() == 0 and self:GetActivityEnabled(ACT_VM_DRYFIRE) and not self.ForceDryFireOff then
			typev, tanim = self:ChooseAnimation("shoot1_empty")
		elseif self:GetStat("Akimbo") and self:GetActivityEnabled(ACT_VM_SECONDARYATTACK) and ((self.AnimCycle == 0 and not self.Akimbo_Inverted) or (self.AnimCycle == 1 and self.Akimbo_Inverted)) then
			typev, tanim = self:ChooseAnimation((self:GetIronSights() and self:GetActivityEnabled(ACT_VM_ISHOOT_M203)) and "shoot2_is" or "shoot2")
		elseif self:GetIronSights() and self:GetActivityEnabled(ACT_VM_PRIMARYATTACK_1) then
			typev, tanim = self:ChooseAnimation("shoot1_is")
		else
			typev, tanim = self:ChooseAnimation("shoot1")
		end

		if typev ~= TFA.Enum.ANIMATION_SEQ then
			return self:SendViewModelAnim(tanim)
		else
			return self:SendViewModelSeq(tanim)
		end
	else
		if game.SinglePlayer() and SERVER then
			self:CallOnClient("BlowbackFull", "")
		end

		if ifp then
			self:BlowbackFull(ifp)
		end

		if self.Blowback_Shell_Enabled and (ifp or game.SinglePlayer()) then
			self:EventShell()
		end

		self:SendViewModelAnim(ACT_VM_BLOWBACK)

		return true, ACT_VM_IDLE
	end
end

function SWEP:BlowbackFull()
	if IsValid(self) then
		self.BlowbackCurrent = 1
		self.BlowbackCurrentRoot = 1
		self.BlowbackRandomAngle = Angle(math.Rand(.1, .2), math.Rand(-.5, .5), math.Rand(-1, 1))
	end
end

--[[
Function Name:  ChooseSilenceAnim
Syntax: self:ChooseSilenceAnim( true if we're silencing, false for detaching the silencer).
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.  This is played when you silence or unsilence a gun.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseSilenceAnim(val)
	if not self:VMIV() then return end
	--self:ResetEvents()
	typev, tanim = self:ChooseAnimation("idle_silenced")
	success = false

	if val then
		if self:GetActivityEnabled(ACT_VM_ATTACH_SILENCER) then
			typev, tanim = self:ChooseAnimation("silencer_attach")
			success = true
		end
	elseif self:GetActivityEnabled(ACT_VM_DETACH_SILENCER) then
		typev, tanim = self:ChooseAnimation("silencer_detach")
		success = true
	end

	if not success then
		local _
		_, tanim = self:ChooseIdleAnim()

		return false, tanim
	end

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

--[[
Function Name:  ChooseDryFireAnim
Syntax: self:ChooseDryFireAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.  set SWEP.ForceDryFireOff to false to properly use.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseDryFireAnim()
	if not self:VMIV() then return end
	--self:ResetEvents()
	typev, tanim = self:ChooseAnimation("shoot1_empty")
	success = true

	if self:GetActivityEnabled(ACT_VM_DRYFIRE_SILENCED) and self:GetSilenced() and not self.ForceDryFireOff then
		typev, tanim = self:ChooseAnimation("shoot1_silenced_empty")
		--self:ChooseIdleAnim()
	else
		if self:GetActivityEnabled(ACT_VM_DRYFIRE) and not self.ForceDryFireOff then
			typev, tanim = self:ChooseAnimation("shoot1_empty")
		else
			success = false
			local _
			_, tanim = nil, nil

			return success, tanim
		end
	end

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

--[[
Function Name:  ChooseROFAnim
Syntax: self:ChooseROFAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.  Called when we change the firemode.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseROFAnim()
	if not self:VMIV() then return end

	--self:ResetEvents()
	if self:GetIronSights() and self:GetActivityEnabled(ACT_VM_IFIREMODE) then
		typev, tanim = self:ChooseAnimation("rof_is")
		success = true
	elseif self:GetActivityEnabled(ACT_VM_FIREMODE) then
		typev, tanim = self:ChooseAnimation("rof")
		success = true
	else
		success = false
		local _
		_, tanim = nil, nil

		return success, tanim
	end

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

--[[
Function Name:  ChooseBashAnim
Syntax: self:ChooseBashAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.  Called when we bash.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseBashAnim()
	if not self:VMIV() then return end

	typev, tanim = nil, nil
	success = false

	local isempty = self:GetStat("Primary.ClipSize") > 0 and self:Clip1() == 0

	if self:GetSilenced() and self:GetActivityEnabled(ACT_VM_HITCENTER2) then
		if self:GetActivityEnabled(ACT_VM_MISSCENTER2) and isempty then
			typev, tanim = self:ChooseAnimation("bash_empty_silenced")
			success = true
		else
			typev, tanim = self:ChooseAnimation("bash_silenced")
			success = true
		end
	elseif self:GetActivityEnabled(ACT_VM_MISSCENTER) and isempty then
		typev, tanim = self:ChooseAnimation("bash_empty")
		success = true
	elseif self:GetActivityEnabled(ACT_VM_HITCENTER) then
		typev, tanim = self:ChooseAnimation("bash")
		success = true
	end

	if not success then
		return success, tanim
	end

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

--[[THIRDPERSON]]
--These holdtypes are used in ironsights.  Syntax:  DefaultHoldType=NewHoldType
SWEP.IronSightHoldTypes = {
	pistol = "revolver",
	smg = "rpg",
	grenade = "melee",
	ar2 = "rpg",
	shotgun = "ar2",
	rpg = "rpg",
	physgun = "physgun",
	crossbow = "ar2",
	melee = "melee2",
	slam = "camera",
	normal = "fist",
	melee2 = "magic",
	knife = "fist",
	duel = "duel",
	camera = "camera",
	magic = "magic",
	revolver = "revolver"
}

--These holdtypes are used while sprinting.  Syntax:  DefaultHoldType=NewHoldType
SWEP.SprintHoldTypes = {
	pistol = "normal",
	smg = "passive",
	grenade = "normal",
	ar2 = "passive",
	shotgun = "passive",
	rpg = "passive",
	physgun = "normal",
	crossbow = "passive",
	melee = "normal",
	slam = "normal",
	normal = "normal",
	melee2 = "melee",
	knife = "fist",
	duel = "normal",
	camera = "slam",
	magic = "normal",
	revolver = "normal"
}

--These holdtypes are used in reloading.  Syntax:  DefaultHoldType=NewHoldType
SWEP.ReloadHoldTypes = {
	pistol = "pistol",
	smg = "smg",
	grenade = "melee",
	ar2 = "ar2",
	shotgun = "shotgun",
	rpg = "ar2",
	physgun = "physgun",
	crossbow = "crossbow",
	melee = "pistol",
	slam = "smg",
	normal = "pistol",
	melee2 = "pistol",
	knife = "pistol",
	duel = "duel",
	camera = "pistol",
	magic = "pistol",
	revolver = "revolver"
}

--These holdtypes are used in reloading.  Syntax:  DefaultHoldType=NewHoldType
SWEP.CrouchHoldTypes = {
	ar2 = "ar2",
	smg = "smg",
	rpg = "ar2"
}

SWEP.IronSightHoldTypeOverride = "" --This variable overrides the ironsights holdtype, choosing it instead of something from the above tables.  Change it to "" to disable.
SWEP.SprintHoldTypeOverride = "" --This variable overrides the sprint holdtype, choosing it instead of something from the above tables.  Change it to "" to disable.
SWEP.ReloadHoldTypeOverride = "" --This variable overrides the reload holdtype, choosing it instead of something from the above tables.  Change it to "" to disable.
local dynholdtypecvar = GetConVar("sv_tfa_holdtype_dynamic")
SWEP.mht_old = ""
local mht

function SWEP:ProcessHoldType()
	mht = self:GetStat("HoldType") or "ar2"

	if mht ~= self.mht_old or not self.DefaultHoldType then
		self.DefaultHoldType = mht
		self.SprintHoldType = nil
		self.IronHoldType = nil
		self.ReloadHoldType = nil
		self.CrouchHoldType = nil
	end

	self.mht_old = mht

	if not self.SprintHoldType then
		self.SprintHoldType = self.SprintHoldTypes[self.DefaultHoldType] or "passive"

		if self.SprintHoldTypeOverride and self.SprintHoldTypeOverride ~= "" then
			self.SprintHoldType = self.SprintHoldTypeOverride
		end
	end

	if not self.IronHoldType then
		self.IronHoldType = self.IronSightHoldTypes[self.DefaultHoldType] or "rpg"

		if self.IronSightHoldTypeOverride and self.IronSightHoldTypeOverride ~= "" then
			self.IronHoldType = self.IronSightHoldTypeOverride
		end
	end

	if not self.ReloadHoldType then
		self.ReloadHoldType = self.ReloadHoldTypes[self.DefaultHoldType] or "ar2"

		if self.ReloadHoldTypeOverride and self.ReloadHoldTypeOverride ~= "" then
			self.ReloadHoldType = self.ReloadHoldTypeOverride
		end
	end

	if not self.SetCrouchHoldType then
		self.SetCrouchHoldType = true
		self.CrouchHoldType = self.CrouchHoldTypes[self.DefaultHoldType]

		if self.CrouchHoldTypeOverride and self.CrouchHoldTypeOverride ~= "" then
			self.CrouchHoldType = self.CrouchHoldTypeOverride
		end
	end

	local curhold, targhold, stat
	curhold = self:GetHoldType()
	targhold = self.DefaultHoldType
	stat = self:GetStatus()

	if dynholdtypecvar:GetBool() then
		if self:OwnerIsValid() and self:GetOwner():Crouching() and self.CrouchHoldType then
			targhold = self.CrouchHoldType
		else
			if self:GetIronSights() then
				targhold = self.IronHoldType
			end

			if TFA.Enum.ReloadStatus[stat] then
				targhold = self.ReloadHoldType
			end
		end
	end

	if self:GetSprinting() or TFA.Enum.HolsterStatus[stat] or self:IsSafety() then
		targhold = self.SprintHoldType
	end

	if targhold ~= curhold then
		self:SetHoldType(targhold)
	end
end