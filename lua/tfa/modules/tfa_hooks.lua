
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

local sp = game.SinglePlayer()

--[[
Hook: PlayerPostThink
Function: Weapon Logic
Used For: Main weapon "think" logic
]]
--
hook.Add("PlayerPostThink", "PlayerTickTFA", function(plyv)
	local wepv = plyv:GetActiveWeapon()

	if IsValid(wepv) and wepv.PlayerThink and wepv.IsTFAWeapon then
		wepv:PlayerThink(plyv)
	end
end)

--[[
Hook: Think
Function: Weapon Logic for NPC
User For: Calling SWEP:Think for NPCs manually
]]
--
if SERVER then
	hook.Add("Think", "NPCTickTFA", function()
		hook.Run("TFA_NPCWeaponThink")
	end)
end

--[[
Hook: Tick
Function: Inspection mouse support
Used For: Enables and disables screen clicker
]]
--
if CLIENT then
	local tfablurintensity
	local its_old = 0
	local ScreenClicker = false
	local att_enabled_cv

	hook.Add("Tick", "TFAInspectionScreenClicker", function()
		if not att_enabled_cv then
			att_enabled_cv = GetConVar("sv_tfa_attachments_enabled")
		end

		if not att_enabled_cv then return end
		tfablurintensity = 0

		if LocalPlayer():IsValid() and IsValid(LocalPlayer():GetActiveWeapon()) and att_enabled_cv:GetBool() then
			local w = LocalPlayer():GetActiveWeapon()

			if not w.Attachments then
				tfablurintensity = 0
			elseif table.Count(w.Attachments) <= 0 then
				tfablurintensity = 0
			else
				tfablurintensity = w.Inspecting and 1 or 0
			end
		end

		if tfablurintensity > its_old and not ScreenClicker then
			gui.EnableScreenClicker(true)
			ScreenClicker = true
		elseif tfablurintensity < its_old and ScreenClicker then
			gui.EnableScreenClicker(false)
			ScreenClicker = false
		end

		its_old = tfablurintensity * 1
	end)
end

--[[
Hook: PreRender
Function: Weapon Logic
Used For: Per-frame weapon "think" logic
]]
--
hook.Add("PreRender", "prerender_tfabase", function()
	local plyv = LocalPlayer()
	if not IsValid(plyv) then return end

	local wepv = plyv:GetActiveWeapon()

	if IsValid(wepv) and wepv.IsTFAWeapon then
		if wepv.PlayerThinkCL then
			wepv:PlayerThinkCL(plyv)
		end

		if sp and CLIENT then
			net.Start("tfaSDLP")
			net.WriteBool(plyv:ShouldDrawLocalPlayer())
			net.SendToServer()
		end
	end
end)

--[[
Hook: AllowPlayerPickup
Function: Prop holding
Used For: Records last held object
]]
--
hook.Add("AllowPlayerPickup", "TFAPickupDisable", function(plyv, ent)
	plyv:SetNW2Entity("LastHeldEntity", ent)
end)

--[[
Hook: PlayerBindPress
Function: Intercept Keybinds
Used For:  Alternate attack, inspection, shotgun interrupts, and more
]]
--
local cv_cm = GetConVar("sv_tfa_cmenu")
local cv_cm_key = GetConVar("sv_tfa_cmenu_key")
local keyv

local function ToggleInspectCommand(plyv)
	if not cv_cm:GetBool() then return end

	if not plyv:IsValid() or plyv:GetViewEntity() ~= plyv then return end

	if plyv:InVehicle() and not plyv:GetAllowWeaponsInVehicle() then return end

	local wepv = plyv:GetActiveWeapon()
	if not IsValid(wepv) or not wepv.ToggleInspect then return end

	wepv:ToggleInspect()

	if SERVER then
		wepv:CallOnClient("ToggleInspect")
	end
end

concommand.Add("tfa_toggleinspect", ToggleInspectCommand)

local function GetInspectionKey()
	if cv_cm_key and cv_cm_key:GetInt() >= 0 then
		keyv = cv_cm_key:GetInt()
	else
		keyv = TFA.BindToKey(input.LookupBinding("+menu_context", true) or "c", KEY_C)
	end

	return keyv
end

local function TFAContextBlock()
	local plyv = LocalPlayer()

	if not plyv:IsValid() or GetViewEntity() ~= plyv then return end

	if plyv:InVehicle() and not plyv:GetAllowWeaponsInVehicle() then return end

	local wepv = plyv:GetActiveWeapon()
	if not IsValid(wepv) then return end

	if plyv:GetInfoNum("cl_tfa_keys_customize", 0) > 0 then return end

	if GetInspectionKey() == TFA.BindToKey(input.LookupBinding("+menu_context", true) or "c", KEY_C) and wepv.ToggleInspect and cv_cm:GetBool() and not plyv:KeyDown(IN_USE) then return false end
end

hook.Add("ContextMenuOpen", "TFAContextBlock", TFAContextBlock)

if CLIENT then
	local kd_old = false

	local function TFAKPThink()
		local plyv = LocalPlayer()

		if not plyv:IsValid() then return end

		local wepv = plyv:GetActiveWeapon()
		if not IsValid(wepv) or not wepv.ToggleInspect then return end

		if plyv:GetInfoNum("cl_tfa_keys_customize", 0) > 0 then return end

		local key = GetInspectionKey()
		local kd = input.IsKeyDown(key)

		if IsValid(vgui.GetKeyboardFocus()) then
			kd = false
		end

		if kd ~= kd_old and kd and cv_cm:GetBool() and not (plyv:KeyDown(IN_USE) and not wepv.Inspecting) then
			plyv:ConCommand("tfa_toggleinspect")
		end

		kd_old = kd
	end

	hook.Add("Think", "TFAInspectionMenu", TFAKPThink)
end

--[[
Hook: KeyPress
Function: Allows player to bash
Used For:  Predicted bashing
]]
--
local cv_lr = GetConVar("sv_tfa_reloads_legacy")

local function KP_Bash(plyv, key)
	if (key == IN_RELOAD) then
		plyv.HasTFAAmmoChek = false
		plyv.LastReloadPressed = CurTime()
	end
end

local reload_threshold = 0.3
hook.Add("KeyPress", "TFABase_KP", KP_Bash)

local function KR_Reload(plyv, key)
	if key == IN_RELOAD and cv_lr and (not cv_lr:GetBool()) and (not plyv:KeyDown(IN_USE)) and CurTime() <= (plyv.LastReloadPressed or CurTime()) + reload_threshold then
		plyv.LastReloadPressed = nil
		plyv.HasTFAAmmoChek = false
		local wepv = plyv:GetActiveWeapon()

		if IsValid(wepv) and wepv.IsTFAWeapon then
			plyv:GetActiveWeapon():Reload(true)
		end
	end
end

hook.Add("KeyRelease", "TFABase_KR", KR_Reload)

local function KD_AmmoCheck(plyv)
	if plyv.HasTFAAmmoChek then return end

	if plyv:KeyDown(IN_RELOAD) and (not plyv:KeyDown(IN_USE)) and CurTime() > (plyv.LastReloadPressed or CurTime()) + reload_threshold then
		local wepv = plyv:GetActiveWeapon()

		if IsValid(wepv) and wepv.IsTFAWeapon then
			plyv.HasTFAAmmoChek = true
			plyv:GetActiveWeapon():CheckAmmo()
		end
	end
end

hook.Add("PlayerTick", "TFABase_KD", KD_AmmoCheck)

local function SC_PBZ(plyv, ucmd)
	if not IsFirstTimePredicted() then return end

	if plyv:GetInfoNum("cl_tfa_keys_bash", 0) > 0 then return end
	if plyv:InVehicle() and not plyv:GetAllowWeaponsInVehicle() then return end

	plyv:TFA_SetZoomKeyDown(ucmd:KeyDown(IN_ZOOM))

	if ucmd:KeyDown(IN_ZOOM) then
		local wepv = plyv:GetActiveWeapon()

		if IsValid(wepv) and wepv.AltAttack then
			wepv:AltAttack()

			if SERVER then
				wepv:CallOnClient("AltAttack", "")
			end

			ucmd:RemoveKey(IN_ZOOM)
		end
	end
end

hook.Add("StartCommand", "TFABashZoom", SC_PBZ)

--[[
Hook: PlayerSpawn
Function: Extinguishes players, zoom cleanup
Used For:  Fixes incendiary bullets post-respawn
]]
--
hook.Add("PlayerSpawn", "TFAExtinguishQOL", function(plyv)
	if IsValid(plyv) and plyv:IsOnFire() then
		plyv:Extinguish()
	end
end)

--[[
Hook: SetupMove
Function: Modify movement speed
Used For:  Weapon slowdown, ironsights slowdown
]]
--
local speedmult

hook.Add("SetupMove", "tfa_setupmove", function(plyv, movedata, commanddata)
	local wepv = plyv:GetActiveWeapon()

	if IsValid(wepv) and wepv.IsTFAWeapon then
		wepv.IronSightsProgress = wepv.IronSightsProgress or 0
		speedmult = Lerp(wepv.IronSightsProgress, wepv:GetStat("MoveSpeed"), wepv:GetStat("IronSightsMoveSpeed"))
		movedata:SetMaxClientSpeed(movedata:GetMaxClientSpeed() * speedmult)
		commanddata:SetForwardMove(commanddata:GetForwardMove() * speedmult)
		commanddata:SetSideMove(commanddata:GetSideMove() * speedmult)
	end
end)

--[[
Hook: HUDShouldDraw
Function: Weapon HUD
Used For:  Hides default HUD
]]
--
local cv_he = GetConVar("cl_tfa_hud_enabled")

if CLIENT then
	local TFAHudHide = {
		CHudAmmo = true,
		CHudSecondaryAmmo = true
	}

	hook.Add("HUDShouldDraw", "tfa_hidehud", function(name)
		if (TFAHudHide[name] and cv_he:GetBool()) then
			local ictfa = TFA.PlayerCarryingTFAWeapon()
			if ictfa then return false end
		end
	end)
end

--[[
Hook: InitPostEntity
Function: Patches or removes other hooks that breaking or changing behavior of our weapons in a negative way
Used For: Fixing our stuff
]]
--

local function FixInvalidPMHook()
	hook.Remove("PostDrawViewModel", "Set player hand skin") -- just remove it for now
end

local function PatchSiminovSniperHook()
	if not CLIENT then return end -- that hook is clientside only

	local CMtbl = hook.GetTable()["CreateMove"] or {}

	local SniperCreateMove = CMtbl["SniperCreateMove"] -- getting the original function
	if not SniperCreateMove then return end

	local PatchedSniperCreateMove = function(cmd) -- wrapping their function with our check
		local ply = LocalPlayer()

		if IsValid(ply) and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon().IsTFAWeapon then
			return
		end

		SniperCreateMove(cmd)
	end

	hook.Remove("CreateMove", "SniperCreateMove") -- removing original hook
	hook.Add("CreateMove", "SniperCreateMove_PatchedByTFABase", PatchedSniperCreateMove) -- creating new hook with wrap
end

hook.Add("InitPostEntity", "tfa_unfuckeverything", function()
	FixInvalidPMHook()
	PatchSiminovSniperHook()
end)

--[[
Hook: PlayerSwitchFlashlight
Function: Flashlight toggle
Used For: Switching flashlight on weapon and blocking HEV flashlight
]]
--
hook.Add("PlayerSwitchFlashlight", "tfa_toggleflashlight", function(plyv, toEnable)
	if CLIENT then return end -- this is serverside hook GO AWAY

	if not IsValid(plyv) or not toEnable then return end -- allow disabling HEV flashlight

	local wepv = plyv:GetActiveWeapon()

	if IsValid(wepv) and wepv.IsTFAWeapon and (wepv:GetStat("FlashlightAttachmentName") ~= nil or wepv:GetStat("FlashlightAttachment", 0) > 0) then
		wepv:ToggleFlashlight()

		return false
	end
end)

--[[
Hook: SetupMove
Function: Update players NW2 variable
User For: Walking animation NW2 var
]]
--
hook.Add("SetupMove", "tfa_checkforplayerwalking", function(plyv, mvdatav, cmdv)
	if not IsValid(plyv) or not mvdatav then return end

	if mvdatav:GetForwardSpeed() ~= 0 or mvdatav:GetSideSpeed() ~= 0 then
		if not plyv:GetNW2Bool("TFA_IsWalking") then
			plyv:SetNW2Bool("TFA_IsWalking", true)
		end
	elseif plyv:GetNW2Bool("TFA_IsWalking") then
		plyv:SetNW2Bool("TFA_IsWalking", false)
	end
end)