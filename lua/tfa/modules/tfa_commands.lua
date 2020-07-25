
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

local function CreateReplConVar(cvarname, cvarvalue, description)
	return CreateConVar(cvarname, cvarvalue, CLIENT and {FCVAR_REPLICATED} or {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, description)
end -- replicated only on clients, archive/notify on server

--Serverside Convars

if GetConVar("sv_tfa_changelog") == nil then
	CreateReplConVar("sv_tfa_changelog", "1", "Enable changelog?")
end

if GetConVar("sv_tfa_soundscale") == nil then
	CreateReplConVar("sv_tfa_soundscale", "1", "Scale sound pitch in accordance to timescale?")
end

if GetConVar("sv_tfa_weapon_strip") == nil then
	CreateReplConVar("sv_tfa_weapon_strip", "0", "Allow the removal of empty weapons?")
end

if GetConVar("sv_tfa_spread_legacy") == nil then
	CreateReplConVar("sv_tfa_spread_legacy", "0", "Use legacy spread algorithms?")
end

if GetConVar("sv_tfa_cmenu") == nil then
	CreateReplConVar("sv_tfa_cmenu", "1", "Allow custom context menu?")
end

if GetConVar("sv_tfa_cmenu_key") == nil then
	CreateReplConVar("sv_tfa_cmenu_key", "-1", "Override the inspection menu key?  Uses the KEY enum available on the gmod wiki. -1 to not.")
end

if GetConVar("sv_tfa_range_modifier") == nil then
	CreateReplConVar("sv_tfa_range_modifier", "0.5", "This controls how much the range affects damage.  0.5 means the maximum loss of damage is 0.5.")
end

if GetConVar("sv_tfa_allow_dryfire") == nil then
	CreateReplConVar("sv_tfa_allow_dryfire", "1", "Allow dryfire?")
end

if GetConVar("sv_tfa_penetration_limit") == nil then
	CreateReplConVar("sv_tfa_penetration_limit", "2", "Number of objects we can penetrate through.")
end

if GetConVar("sv_tfa_penetration_hitmarker") == nil then
	CreateReplConVar("sv_tfa_penetration_hitmarker", "1", "Should penetrating bullet send hitmarker to attacker?")
end

if GetConVar("sv_tfa_damage_multiplier") == nil then
	CreateReplConVar("sv_tfa_damage_multiplier", "1", "Multiplier for TFA base projectile damage.")
end

if GetConVar("sv_tfa_damage_mult_min") == nil then
	CreateConVar("sv_tfa_damage_mult_min", "0.95", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "This is the lower range of a random damage factor.")
end

if GetConVar("sv_tfa_damage_mult_max") == nil then
	CreateReplConVar("sv_tfa_damage_mult_max", "1.05", "This is the higher range of a random damage factor.")
end

if GetConVar("sv_tfa_melee_damage_npc") == nil then
	CreateReplConVar("sv_tfa_melee_damage_npc", "1", "Damage multiplier against NPCs using TFA Melees.")
end

if GetConVar("sv_tfa_melee_damage_ply") == nil then
	CreateReplConVar("sv_tfa_melee_damage_ply", "0.65", "Damage multiplier against players using TFA Melees.")
end

if GetConVar("sv_tfa_melee_blocking_timed") == nil then
	CreateReplConVar("sv_tfa_melee_blocking_timed", "1", "Enable timed blocking?")
end

if GetConVar("sv_tfa_melee_blocking_anglemult") == nil then
	CreateReplConVar("sv_tfa_melee_blocking_anglemult", "1", "Players can block attacks in an angle around their view.  This multiplies that angle.")
end

if GetConVar("sv_tfa_melee_blocking_deflection") == nil then
	CreateReplConVar("sv_tfa_melee_blocking_deflection", "1", "For weapons that can deflect bullets ( e.g. certain katans ), can you deflect bullets?  Set to 1 to enable for parries, or 2 for all blocks.")
end

if GetConVar("sv_tfa_melee_blocking_timed") == nil then
	CreateReplConVar("sv_tfa_melee_blocking_timed", "1", "Enable timed blocking?")
end

if GetConVar("sv_tfa_melee_blocking_stun_enabled") == nil then
	CreateReplConVar("sv_tfa_melee_blocking_stun_enabled", "1", "Stun NPCs on block?")
end

if GetConVar("sv_tfa_melee_blocking_stun_time") == nil then
	CreateReplConVar("sv_tfa_melee_blocking_stun_time", "0.65", "How long to stun NPCs on block.")
end

if GetConVar("sv_tfa_melee_doordestruction") == nil then
	CreateReplConVar("sv_tfa_melee_doordestruction", "1", "Allow players to bash open doors?")
end

if GetConVar("sv_tfa_door_respawn") == nil then
	CreateReplConVar("sv_tfa_door_respawn", "-1", "Time for doors to respawn; -1 for never.")
end

local cv_dfc
if GetConVar("sv_tfa_default_clip") == nil then
	cv_dfc = CreateReplConVar("sv_tfa_default_clip", "-1", "How many clips will a weapon spawn with? Negative reverts to default values.")
else
	cv_dfc = GetConVar("sv_tfa_default_clip")
end

local function TFAUpdateDefaultClip()
	local dfc = cv_dfc:GetInt()
	local weplist = weapons.GetList()
	if not weplist or #weplist <= 0 then return end

	for _, v in pairs(weplist) do
		local cl = v.ClassName and v.ClassName or v
		local wep = weapons.GetStored(cl)

		if wep and (wep.IsTFAWeapon or string.find(string.lower(wep.Base and wep.Base or ""), "tfa")) then
			if not wep.Primary then
				wep.Primary = {}
			end

			if not wep.Primary.TrueDefaultClip then
				wep.Primary.TrueDefaultClip = wep.Primary.DefaultClip
			end

			if not wep.Primary.TrueDefaultClip then
				wep.Primary.TrueDefaultClip = 0
			end

			if dfc < 0 then
				wep.Primary.DefaultClip = wep.Primary.TrueDefaultClip
			else
				if wep.Primary.ClipSize and wep.Primary.ClipSize > 0 then
					wep.Primary.DefaultClip = wep.Primary.ClipSize * dfc
				else
					wep.Primary.DefaultClip = wep.Primary.TrueDefaultClip * 1
				end
			end
		end
	end
end

hook.Add("InitPostEntity", "TFADefaultClipPE", TFAUpdateDefaultClip)

if TFAUpdateDefaultClip then
	TFAUpdateDefaultClip()
end

--if GetConVar("sv_tfa_default_clip") == nil then

cvars.AddChangeCallback("sv_tfa_default_clip", function(convar_name, value_old, value_new)
	TFAUpdateDefaultClip()
end, "TFAUpdateDefaultClip")

--end
if GetConVar("sv_tfa_unique_slots") == nil then
	CreateReplConVar("sv_tfa_unique_slots", "1", "Give TFA-based Weapons unique slots? 1 for true, 0 for false. RESTART AFTER CHANGING.")
end

if GetConVar("sv_tfa_spread_multiplier") == nil then
	CreateReplConVar("sv_tfa_spread_multiplier", "1", "Increase for more spread, decrease for less.")
end

if GetConVar("sv_tfa_force_multiplier") == nil then
	CreateReplConVar("sv_tfa_force_multiplier", "1", "Arrow force multiplier (not arrow velocity, but how much force they give on impact).")
end

if GetConVar("sv_tfa_dynamicaccuracy") == nil then
	CreateReplConVar("sv_tfa_dynamicaccuracy", "1", "Dynamic acuracy?  (e.g.more accurate on crouch, less accurate on jumping.")
end

if GetConVar("sv_tfa_ammo_detonation") == nil then
	CreateReplConVar("sv_tfa_ammo_detonation", "1", "Ammo Detonation?  (e.g. shoot ammo until it explodes) ")
end

if GetConVar("sv_tfa_ammo_detonation_mode") == nil then
	CreateReplConVar("sv_tfa_ammo_detonation_mode", "2", "Ammo Detonation Mode?  (0=Bullets,1=Blast,2=Mix) ")
end

if GetConVar("sv_tfa_ammo_detonation_chain") == nil then
	CreateReplConVar("sv_tfa_ammo_detonation_chain", "1", "Ammo Detonation Chain?  (0=Ammo boxes don't detonate other ammo boxes, 1 you can chain them together) ")
end

if GetConVar("sv_tfa_scope_gun_speed_scale") == nil then
	CreateReplConVar("sv_tfa_scope_gun_speed_scale", "0", "Scale player sensitivity based on player move speed?")
end

if GetConVar("sv_tfa_bullet_penetration") == nil then
	CreateReplConVar("sv_tfa_bullet_penetration", "1", "Allow bullet penetration?")
end

if GetConVar("sv_tfa_bullet_doordestruction") == nil then
	CreateReplConVar("sv_tfa_bullet_doordestruction", "1", "Allow players to shoot down doors?")
end

if GetConVar("sv_tfa_bullet_ricochet") == nil then
	CreateReplConVar("sv_tfa_bullet_ricochet", "0", "Allow bullet ricochet?")
end

if GetConVar("sv_tfa_holdtype_dynamic") == nil then
	CreateReplConVar("sv_tfa_holdtype_dynamic", "1", "Allow dynamic holdtype?")
end

if GetConVar("sv_tfa_arrow_lifetime") == nil then
	CreateReplConVar("sv_tfa_arrow_lifetime", "30", "Arrow lifetime.")
end

if GetConVar("sv_tfa_worldmodel_culldistance") == nil then
	CreateReplConVar("sv_tfa_worldmodel_culldistance", "-1", "-1 to leave unculled.  Anything else is feet*16.")
end

if GetConVar("sv_tfa_reloads_legacy") == nil then
	CreateReplConVar("sv_tfa_reloads_legacy", "0", "Enable legacy-style reloading?")
end

if GetConVar("sv_tfa_fx_penetration_decal") == nil then
	CreateReplConVar("sv_tfa_fx_penetration_decal", "1", "Enable decals on the other side of a penetrated object?")
end

local cv_ironsights = GetConVar("sv_tfa_ironsights_enabled")

if cv_ironsights == nil then
	cv_ironsights = CreateReplConVar("sv_tfa_ironsights_enabled", "1", "Enable ironsights? Disabling this still allows scopes.")
end

hook.Add("TFA_GetStat", "TFA_IronsightsConVarToggle", function(wep, stat, val)
	if not IsValid(wep) or stat ~= "data.ironsights" then return end

	if not cv_ironsights:GetBool() and not wep:GetStat("Scoped") and not wep:GetStat("Scoped_3D") then
		return 0
	end
end)

if GetConVar("sv_tfa_sprint_enabled") == nil then
	CreateReplConVar("sv_tfa_sprint_enabled", "1", "Enable sprinting? Disabling this allows shooting while IN_SPEED.")
end

if GetConVar("sv_tfa_reloads_enabled") == nil then
	CreateReplConVar("sv_tfa_reloads_enabled", "1", "Enable reloading? Disabling this allows shooting from ammo pool.")
end

if GetConVar("sv_tfa_attachments_enabled") == nil then
	CreateReplConVar("sv_tfa_attachments_enabled", "1", "Display attachment picker?")
end

if GetConVar("sv_tfa_attachments_alphabetical") == nil then
	CreateReplConVar("sv_tfa_attachments_alphabetical", "0", "Override weapon attachment order to be alphabetical.")
end

if GetConVar("sv_tfa_jamming") == nil then
	CreateReplConVar("sv_tfa_jamming", "1", "Enable jamming mechanics?")
end

if GetConVar("sv_tfa_jamming_mult") == nil then
	CreateReplConVar("sv_tfa_jamming_mult", "1", "Multiply jam chance by this value. You really should modify sv_tfa_jamming_factor_inc rather than this.")
end

if GetConVar("sv_tfa_jamming_factor") == nil then
	CreateReplConVar("sv_tfa_jamming_factor", "1", "Multiply jam factor by this value")
end

if GetConVar("sv_tfa_jamming_factor_inc") == nil then
	CreateReplConVar("sv_tfa_jamming_factor_inc", "1", "Multiply jam factor gain by this value")
end

if GetConVar("sv_tfa_nearlyempty") == nil then
	CreateReplConVar("sv_tfa_nearlyempty", "1", "Enable nearly-empty sounds")
end

--Clientside Convars
if CLIENT then
	if GetConVar("cl_tfa_viewbob_intensity") == nil then
		CreateClientConVar("cl_tfa_viewbob_intensity", 1, true, false, "View bob intensity multiplier")
	end

	if GetConVar("cl_tfa_gunbob_intensity") == nil then
		CreateClientConVar("cl_tfa_gunbob_intensity", 1, true, false, "Gun bob intensity multiplier")
	end

	if GetConVar("cl_tfa_viewmodel_viewpunch") == nil then
		CreateClientConVar("cl_tfa_viewmodel_viewpunch", 1, true, false, "Use viewmodel viewpunch?")
	end

	if GetConVar("cl_tfa_3dscope_quality") == nil then
		CreateClientConVar("cl_tfa_3dscope_quality", -1, true, true, "3D scope quality (leave -1 for autodetected)")
	end

	if GetConVar("cl_tfa_3dscope") == nil then
		CreateClientConVar("cl_tfa_3dscope", 1, true, true, "Enable 3D scopes?")
	else
		cvars.RemoveChangeCallback( "cl_tfa_3dscope", "3DScopeEnabledCB" )
	end

	cvars.AddChangeCallback("cl_tfa_3dscope",function(cv,old,new)
		local lply = LocalPlayer()
		if lply:IsValid() and IsValid(lply:GetActiveWeapon()) then
			local wep = lply:GetActiveWeapon()
			if wep.UpdateScopeType then
				wep:UpdateScopeType( true )
			end
		end
	end,"3DScopeEnabledCB")

	if GetConVar("cl_tfa_scope_sensitivity_3d") == nil then
		CreateClientConVar("cl_tfa_scope_sensitivity_3d", 2, true, true) --0 = no sensitivity mod, 1 = scaled to 2D sensitivity, 2 = compensated, 3 = RT FOV compensated
	else
		cvars.RemoveChangeCallback( "cl_tfa_scope_sensitivity_3d", "3DScopeModeCB" )
	end

	cvars.AddChangeCallback("cl_tfa_scope_sensitivity_3d",function(cv,old,new)
		local lply = LocalPlayer()
		if lply:IsValid() and IsValid(lply:GetActiveWeapon()) then
			local wep = lply:GetActiveWeapon()
			if wep.UpdateScopeType then
				wep:UpdateScopeType( true )
			end
		end
	end,"3DScopeModeCB")

	if GetConVar("cl_tfa_3dscope_overlay") == nil then
		CreateClientConVar("cl_tfa_3dscope_overlay", 0, true, true, "Enable 3D scope shadows?")
	end

	if GetConVar("cl_tfa_scope_sensitivity_autoscale") == nil then
		CreateClientConVar("cl_tfa_scope_sensitivity_autoscale", 100, true, true, "Compensate sensitivity for FOV?")
	end

	if GetConVar("cl_tfa_scope_sensitivity") == nil then
		CreateClientConVar("cl_tfa_scope_sensitivity", 100, true, true)
	end

	if GetConVar("cl_tfa_ironsights_toggle") == nil then
		CreateClientConVar("cl_tfa_ironsights_toggle", 1, true, true, "Toggle ironsights?")
	end

	if GetConVar("cl_tfa_ironsights_resight") == nil then
		CreateClientConVar("cl_tfa_ironsights_resight", 1, true, true, "Keep ironsights after reload or sprint?")
	end

	if GetConVar("cl_tfa_laser_trails") == nil then
		CreateClientConVar("cl_tfa_laser_trails", 1, true, true, "Enable laser dot trails?")
	end

	--Crosshair Params
	if GetConVar("cl_tfa_hud_crosshair_length") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_length", 1, true, false, "Crosshair length")
	end

	if GetConVar("cl_tfa_hud_crosshair_length_use_pixels") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_length_use_pixels", 0, true, false, "Should crosshair length use pixels?")
	end

	if GetConVar("cl_tfa_hud_crosshair_width") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_width", 1, true, false, "Crosshair width")
	end

	if GetConVar("cl_tfa_hud_crosshair_enable_custom") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_enable_custom", 1, true, false, "Enable custom crosshair?")
	end

	if GetConVar("cl_tfa_hud_crosshair_gap_scale") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_gap_scale", 1, true, false, "Crosshair gap scale")
	end

	if GetConVar("cl_tfa_hud_crosshair_dot") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_dot", 0, true, false, "Enable crosshair dot?")
	end

	--Crosshair Color
	if GetConVar("cl_tfa_hud_crosshair_color_r") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_color_r", 225, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_color_g") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_color_g", 225, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_color_b") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_color_b", 225, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_color_a") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_color_a", 200, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_color_team") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_color_team", 1, true, false, "Should crosshair use team color of entity being aimed at?")
	end

	--Crosshair Outline
	if GetConVar("cl_tfa_hud_crosshair_outline_color_r") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_outline_color_r", 5, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_outline_color_g") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_outline_color_g", 5, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_outline_color_b") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_outline_color_b", 5, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_outline_color_a") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_outline_color_a", 200, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_outline_width") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_outline_width", 1, true, false, "Crosshair outline width")
	end

	if GetConVar("cl_tfa_hud_crosshair_outline_enabled") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_outline_enabled", 1, true, false, "Enable crosshair outline?")
	end

	if GetConVar("cl_tfa_hud_crosshair_triangular") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_triangular", 0, true, false, "Enable triangular Crysis-like crosshair?")
	end

	if GetConVar("cl_tfa_hud_hitmarker_enabled") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_enabled", 1, true, false, "Enable hit marker?")
	end

	if GetConVar("cl_tfa_hud_hitmarker_fadetime") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_fadetime", 0.3, true, false, "Hit marker fade time (in seconds)")
	end

	if GetConVar("cl_tfa_hud_hitmarker_solidtime") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_solidtime", 0.1, true, false)
	end

	if GetConVar("cl_tfa_hud_hitmarker_scale") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_scale", 1, true, false, "Hit marker scale")
	end

	if GetConVar("cl_tfa_hud_hitmarker_color_r") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_color_r", 225, true, false)
	end

	if GetConVar("cl_tfa_hud_hitmarker_color_g") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_color_g", 225, true, false)
	end

	if GetConVar("cl_tfa_hud_hitmarker_color_b") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_color_b", 225, true, false)
	end

	if GetConVar("cl_tfa_hud_hitmarker_color_a") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_color_a", 200, true, false)
	end

	if GetConVar("cl_tfa_hud_hitmarker_3d_all") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_3d_all", 0, true, true)
	end

	if GetConVar("cl_tfa_hud_hitmarker_3d_shotguns") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_3d_shotguns", 1, true, true)
	end

	--Other stuff
	if GetConVar("cl_tfa_hud_ammodata_fadein") == nil then
		CreateClientConVar("cl_tfa_hud_ammodata_fadein", 0.2, true, false)
	end

	if GetConVar("cl_tfa_hud_hangtime") == nil then
		CreateClientConVar("cl_tfa_hud_hangtime", 1, true, true)
	end

	if GetConVar("cl_tfa_hud_enabled") == nil then
		CreateClientConVar("cl_tfa_hud_enabled", 1, true, false, "Enable 3D2D hud?")
	end

	if GetConVar("cl_tfa_fx_gasblur") == nil then
		CreateClientConVar("cl_tfa_fx_gasblur", 0, true, true, "Enable muzzle gas blur?")
	end

	if GetConVar("cl_tfa_fx_muzzlesmoke") == nil then
		CreateClientConVar("cl_tfa_fx_muzzlesmoke", 1, true, true, "Enable muzzle smoke trail?")
	end

	if GetConVar("cl_tfa_fx_muzzlesmoke_limited") == nil then
		CreateClientConVar("cl_tfa_fx_muzzlesmoke_limited", 1, true, true, "Limit muzzle smoke trails?")
	end

	if GetConVar("cl_tfa_fx_muzzleflashsmoke") == nil then
		CreateClientConVar("cl_tfa_fx_muzzleflashsmoke", 1, true, true, "Enable muzzleflash smoke?")
	end

	if GetConVar("cl_tfa_legacy_shells") == nil then
		CreateClientConVar("cl_tfa_legacy_shells", 0, true, true, "Use legacy shells?")
	end

	if GetConVar("cl_tfa_fx_ejectionsmoke") == nil then
		CreateClientConVar("cl_tfa_fx_ejectionsmoke", 1, true, true, "Enable shell ejection smoke?")
	end

	if GetConVar("cl_tfa_fx_ejectionlife") == nil then
		CreateClientConVar("cl_tfa_fx_ejectionlife", 15, true, true, "How long shells exist in the world")
	end

	if GetConVar("cl_tfa_fx_impact_enabled") == nil then
		CreateClientConVar("cl_tfa_fx_impact_enabled", 1, true, true, "Enable custom bullet impact effects?")
	end

	if GetConVar("cl_tfa_fx_impact_ricochet_enabled") == nil then
		CreateClientConVar("cl_tfa_fx_impact_ricochet_enabled", 1, true, true, "Enable bullet ricochet effect?")
	end

	if GetConVar("cl_tfa_fx_impact_ricochet_sparks") == nil then
		CreateClientConVar("cl_tfa_fx_impact_ricochet_sparks", 6, true, true, "Enable bullet ricochet sparks?")
	end

	if GetConVar("cl_tfa_fx_impact_ricochet_sparklife") == nil then
		CreateClientConVar("cl_tfa_fx_impact_ricochet_sparklife", 2, true, true)
	end

	if GetConVar("cl_tfa_fx_ads_dof") == nil then
		CreateClientConVar("cl_tfa_fx_ads_dof", 0, true, true, "Enable iron sights DoF (Depth of Field)")
	end

	if GetConVar("cl_tfa_fx_ads_dof_hd") == nil then
		CreateClientConVar("cl_tfa_fx_ads_dof_hd", 0, true, true, "Enable better quality for DoF")
	end

	--viewbob

	if GetConVar("cl_tfa_viewbob_animated") == nil then
		CreateClientConVar("cl_tfa_viewbob_animated", 1, true, false, "Use animated viewbob?")
	end

	--Viewmodel Mods
	if GetConVar("cl_tfa_viewmodel_offset_x") == nil then
		CreateClientConVar("cl_tfa_viewmodel_offset_x", 0, true, false)
	end

	if GetConVar("cl_tfa_viewmodel_offset_y") == nil then
		CreateClientConVar("cl_tfa_viewmodel_offset_y", 0, true, false)
	end

	if GetConVar("cl_tfa_viewmodel_offset_z") == nil then
		CreateClientConVar("cl_tfa_viewmodel_offset_z", 0, true, false)
	end

	if GetConVar("cl_tfa_viewmodel_offset_fov") == nil then
		CreateClientConVar("cl_tfa_viewmodel_offset_fov", 0, true, false)
	end

	if GetConVar("cl_tfa_viewmodel_multiplier_fov") == nil then
		CreateClientConVar("cl_tfa_viewmodel_multiplier_fov", 1, true, false)
	end

	if GetConVar("cl_tfa_viewmodel_flip") == nil then
		CreateClientConVar("cl_tfa_viewmodel_flip", 0, true, false)
	end

	if GetConVar("cl_tfa_viewmodel_centered") == nil then
		CreateClientConVar("cl_tfa_viewmodel_centered", 0, true, false)
	end

	if GetConVar("cl_tfa_viewmodel_nearwall") == nil then
		CreateClientConVar("cl_tfa_viewmodel_nearwall", 1, true, false)
	end

	if GetConVar("cl_tfa_debug_crosshair") == nil then
		CreateClientConVar("cl_tfa_debug_crosshair", 0, false, false, "Debug crosshair (Admin only)")
	end

	if GetConVar("cl_tfa_debug_rt") == nil then
		CreateClientConVar("cl_tfa_debug_rt", 0, false, false, "Debug RT scopes (Admin only)")
	end

	if GetConVar("cl_tfa_debug_cache") == nil then
		CreateClientConVar("cl_tfa_debug_cache", 0, false, false, "Disable stat caching (may cause heavy performance impact!)")
	end

	local function UpdateColorCVars()
		RunConsoleCommand("sv_tfa_apply_player_colors")
	end

	--Reticule Color
	if GetConVar("cl_tfa_reticule_color_r") == nil then
		CreateClientConVar("cl_tfa_reticule_color_r", 255, true, true)
		cvars.AddChangeCallback("cl_tfa_reticule_color_r", UpdateColorCVars, "TFANetworkPlayerColors")
	end

	if GetConVar("cl_tfa_reticule_color_g") == nil then
		CreateClientConVar("cl_tfa_reticule_color_g", 100, true, true)
		cvars.AddChangeCallback("cl_tfa_reticule_color_g", UpdateColorCVars, "TFANetworkPlayerColors")
	end

	if GetConVar("cl_tfa_reticule_color_b") == nil then
		CreateClientConVar("cl_tfa_reticule_color_b", 0, true, true)
		cvars.AddChangeCallback("cl_tfa_reticule_color_b", UpdateColorCVars, "TFANetworkPlayerColors")
	end

	--Laser Color
	if GetConVar("cl_tfa_laser_color_r") == nil then
		CreateClientConVar("cl_tfa_laser_color_r", 255, true, true)
		cvars.AddChangeCallback("cl_tfa_laser_color_r", UpdateColorCVars, "TFANetworkPlayerColors")
	end

	if GetConVar("cl_tfa_laser_color_g") == nil then
		CreateClientConVar("cl_tfa_laser_color_g", 0, true, true)
		cvars.AddChangeCallback("cl_tfa_laser_color_g", UpdateColorCVars, "TFANetworkPlayerColors")
	end

	if GetConVar("cl_tfa_laser_color_b") == nil then
		CreateClientConVar("cl_tfa_laser_color_b", 0, true, true)
		cvars.AddChangeCallback("cl_tfa_laser_color_b", UpdateColorCVars, "TFANetworkPlayerColors")
	end

end
