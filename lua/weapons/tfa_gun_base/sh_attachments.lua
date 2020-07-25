
-- This will likely be refactored in the future. There might be a better method to completely remove attachments, but I do not want errors to be spammed.

local tableCopy = table.Copy
SWEP.Attachments = {} --[MDL_ATTACHMENT] = = { offset = { 0, 0 }, atts = { "sample_attachment_1", "sample_attachment_2" }, sel = 1, order = 1 } --offset will move the offset the display from the weapon attachment when using CW2.0 style attachment display --atts is a table containing the visible attachments --sel allows you to have an attachment pre-selected, and is used internally by the base to show which attachment is selected in each category. --order is the order it will appear in the TFA style attachment menu
SWEP.AttachmentCache = {} --["att_name"] = true
SWEP.AttachmentTableCache = {}
SWEP.AttachmentDependencies = {} --{["si_acog"] = {"bg_rail"}}
SWEP.AttachmentExclusions = {} --{ ["si_iron"] = {"bg_heatshield"} }
SWEP.AttachmentTableOverride = {}

function SWEP:RemoveUnusedAttachments()
	for k, v in pairs(self.Attachments) do
		if v.atts then
			local t = {}
			local i = 1

			for _, b in pairs(v.atts) do
				if TFA.Attachments.Atts[b] then
					t[i] = b
					i = i + 1
				end
			end

			v.atts = tableCopy(t)
		end

		if #v.atts <= 0 then
			self.Attachments[k] = nil
			continue
		end
	end
end

local function CloneTableRecursive(source, target)
	for k, v in pairs(source) do
		if istable(v) then
			if istable(target[k]) and target[k].functionTable then
				local baseTable = target[k]
				local t, index

				for l, b in pairs(baseTable) do
					if istable(b) then
						t = b
						index = l
					end
				end

				if not t then
					t = {}
				end

				CloneTableRecursive(v, t)

				if index then
					baseTable[index] = t
				else
					table.insert(baseTable, 1, t)
				end
			else
				target[k] = istable(target[k]) and target[k] or {}
				CloneTableRecursive(v, target[k])
			end
		elseif isfunction(v) then
			local temp

			if target[k] and not istable(target[k]) then
				temp = target[k]
			end

			target[k] = istable(target[k]) and target[k] or {}
			local t = target[k]
			t.functionTable = true

			if temp then
				t[#t + 1] = temp
			end

			t[#t + 1] = v
		else
			if istable(target[k]) and target[k].functionTable then
				table.insert(target[k], 1, v)
			else
				target[k] = v
			end
		end
	end
end

function SWEP:BuildAttachmentCache()
	for k, v in pairs(self.Attachments) do
		if v.atts then
			for l, b in pairs(v.atts) do
				self.AttachmentCache[b] = (v.sel == l) and k or false
			end
		end
	end

	table.Empty(self.AttachmentTableCache)

	for attName, sel in pairs(self.AttachmentCache) do
		if not sel then continue end
		if not TFA.Attachments.Atts[attName] then continue end

		local srctbl = TFA.Attachments.Atts[attName].WeaponTable
		if type(srctbl) == "table" then
			CloneTableRecursive(srctbl, self.AttachmentTableCache)
		end

		if type(self.AttachmentTableOverride[attName]) == "table" then
			CloneTableRecursive(self.AttachmentTableOverride[attName], self.AttachmentTableCache)
		end
	end
end

function SWEP:IsAttached(attn)
	return false
end

function SWEP:CanAttach(attn)
	return false
end

function SWEP:GetStatRecursive(srctbl, stbl, ...)
	stbl = tableCopy(stbl)

	for _ = 1, #stbl do
		if #stbl > 1 then
			if srctbl[stbl[1]] then
				srctbl = srctbl[stbl[1]]
				table.remove(stbl, 1)
			else
				return ...
			end
		end
	end

	local val = srctbl[stbl[1]]

	if istable(val) and val.functionTable then
		local t, final, nocache
		nocache = false

		for i = 1, table.Count(val) do
			local v = val[i]

			if isfunction(v) then
				local nct

				if not t then
					t, final, nct = v(self, ...)
				else
					t, final, nct = v(self, t)
				end

				nocache = nocache or nct
				if final then break end
			elseif v then
				t = v
			end
		end

		if t then
			return t, nocache
		else
			return ...
		end
	elseif val ~= nil then
		return val
	else
		return ...
	end
end

SWEP.StatCache_Blacklist = {
	["ViewModelBoneMods"] = true,
	["WorldModelBoneMods"] = true,
	["MaterialTable"] = true,
	["MaterialTable_V"] = true,
	["MaterialTable_W"] = true,
	["Bodygroups_V"] = true,
	["Bodygroups_W"] = true,
	["Skin"] = true
}

local retval
SWEP.StatCache = {}
SWEP.StatCache2 = {}
SWEP.StatStringCache = {}

--[[
local function mtbl(t1, t2)
	local t = tableCopy(t1)

	for k, v in pairs(t2) do
		t[k] = v
	end

	return t
end
]]
--
function SWEP:ClearStatCache(vn)
	if vn then
		self.StatCache[vn] = nil
		self.StatCache2[vn] = nil
	else
		table.Empty(self.StatCache)
		table.Empty(self.StatCache2)
	end
end

local ccv = GetConVar("cl_tfa_debug_cache")

function SWEP:GetStat(stat, default)
	if self.StatStringCache[stat] == nil then
		local t_stbl = string.Explode(".", stat, false)

		for k, v in ipairs(t_stbl) do
			t_stbl[k] = tonumber(v) or v
		end

		self.StatStringCache[stat] = t_stbl
	end

	local stbl = self.StatStringCache[stat]

	if self.StatCache2[stat] ~= nil then
		local finalReturn

		if self.StatCache[stat] ~= nil then
			finalReturn = self.StatCache[stat]
		else
			retval = self:GetStatRecursive(self, stbl)

			if retval ~= nil then
				self.StatCache[stat] = retval
				finalReturn = retval
			else
				finalReturn = istable(default) and tableCopy(default) or default
			end
		end

		finalReturn = hook.Run("TFA_GetStat", self, stat, finalReturn) or finalReturn

		return finalReturn
	else
		if not self:OwnerIsValid() then
			if IsValid(self) then
				local finalReturn = self:GetStatRecursive(self, stbl, istable(default) and tableCopy(default) or default)
				finalReturn = hook.Run("TFA_GetStat", self, stat, finalReturn) or finalReturn

				return finalReturn
			end

			local finalReturn = default
			finalReturn = hook.Run("TFA_GetStat", self, stat, finalReturn) or finalReturn

			return finalReturn
		end

		local cs = self:GetStatRecursive(self, stbl, istable(default) and tableCopy(default) or default)
		local ns, nc
		ns, nc = self:GetStatRecursive(self.AttachmentTableCache, stbl, istable(cs) and tableCopy(cs) or cs)

		if istable(ns) and istable(cs) then
			cs = table.Merge(tableCopy(cs), ns)
		else
			cs = ns
		end

		if (not self.StatCache_Blacklist[stat]) and (not self.StatCache_Blacklist[stbl[1]]) and (not nc) and not (ccv and ccv:GetBool()) then
			self.StatCache[stat] = cs
			self.StatCache2[stat] = true
		end

		local finalReturn = cs
		finalReturn = hook.Run("TFA_GetStat", self, stat, finalReturn) or finalReturn

		return finalReturn
	end
end

local ATTACHMENT_SORTING_DEPENDENCIES = false

function SWEP:ForceAttachmentReqs(attn)
	if not ATTACHMENT_SORTING_DEPENDENCIES then
		ATTACHMENT_SORTING_DEPENDENCIES = true
		local related = {}

		for k, v in pairs(self.AttachmentDependencies) do
			if istable(v) then
				for _, b in pairs(v) do
					if k == attn then
						related[b] = true
					elseif b == attn then
						related[k] = true
					end
				end
			elseif isstring(v) then
				if k == attn then
					related[v] = true
				elseif v == attn then
					related[k] = true
				end
			end
		end

		for k, v in pairs(self.AttachmentExclusions) do
			if istable(v) then
				for _, b in pairs(v) do
					if k == attn then
						related[b] = true
					elseif b == attn then
						related[k] = true
					end
				end
			elseif isstring(v) then
				if k == attn then
					related[v] = true
				elseif v == attn then
					related[k] = true
				end
			end
		end

		for k, v in pairs(self.AttachmentCache) do
			if v and related[k] and not self:CanAttach(k) then
				self:SetTFAAttachment(v, 0, true, true)
			end
		end

		ATTACHMENT_SORTING_DEPENDENCIES = false
	end
end

function SWEP:SetTFAAttachment(cat, id, nw, force)
	if (not self.Attachments[cat]) then return false end
	local attn = self.Attachments[cat].atts[id] or ""
	local attn_old = self.Attachments[cat].atts[self.Attachments[cat].sel or -1] or ""
	if SERVER and id > 0 and not (self:CanAttach(attn) or force) then return false end

	if id ~= self.Attachments[cat].sel then
		local att_old = TFA.Attachments.Atts[self.Attachments[cat].atts[self.Attachments[cat].sel] or -1]

		if att_old then
			att_old:Detach(self)
			hook.Run("TFA_Attachment_Detached", self, attn_old, att_old, cat, id, force)
		end

		local att_neue = TFA.Attachments.Atts[self.Attachments[cat].atts[id] or -1]

		if att_neue then
			att_neue:Attach(self)
			hook.Run("TFA_Attachment_Attached", self, attn, att_neue, cat, id, force)
		end
	end

	self:ClearStatCache()

	if id > 0 then
		self.Attachments[cat].sel = id
	else
		self.Attachments[cat].sel = nil
	end

	self:BuildAttachmentCache()

	if id > 0 then
		self:ForceAttachmentReqs(attn)
	else
		self:ForceAttachmentReqs(attn_old)
	end

	if nw then
		net.Start("TFA_Attachment_Set")
		net.WriteEntity(self)
		net.WriteInt(cat, 8)
		net.WriteInt(id or -1, 7)

		if SERVER then
			net.Broadcast()
		elseif CLIENT then
			net.SendToServer()
		end
	end

	return true
end

function SWEP:Attach(attname)
	if not attname or not IsValid(self) then return false end
	if self.AttachmentCache[attname] == nil then return false end

	for cat, tbl in pairs(self.Attachments) do
		local atts = tbl.atts

		for id, att in ipairs(atts) do
			if att == attname then return self:SetTFAAttachment(cat, id, true, false) end
		end
	end

	return false
end

function SWEP:Detach(attname)
	if not attname or not IsValid(self) then return false end
	local cat = self.AttachmentCache[attname]
	if not cat then return false end

	return self:SetTFAAttachment(cat, 0, true, false)
end

local attachments_sorted_alphabetically = GetConVar("sv_tfa_attachments_alphabetical")

function SWEP:InitAttachments()
	if self.HasInitAttachments then return end
	hook.Run("TFA_PreInitAttachments", self)
	self.HasInitAttachments = true

	for k, v in pairs(self.Attachments) do
		if type(k) == "string" then
			local tatt = self:VMIV() and self.OwnerViewModel:LookupAttachment(k) or self:LookupAttachment(k)

			if tatt > 0 then
				self.Attachments[tatt] = v
			end

			self.Attachments[k] = nil
		elseif (not attachments_sorted_alphabetically) and attachments_sorted_alphabetically:GetBool() then
			local sval = v.atts[v.sel]

			table.sort(v.atts, function(a, b)
				local aname = ""
				local bname = ""
				local att_a = TFA.Attachments.Atts[a]

				if att_a then
					aname = att_a.Name or a
				end

				local att_b = TFA.Attachments.Atts[b]

				if att_b then
					bname = att_b.Name or b
				end

				return aname < bname
			end)

			if sval then
				v.sel = table.KeyFromValue(v.atts, sval) or v.sel
			end
		end
	end

	for k, v in pairs(self.Attachments) do
		if v.sel then
			local vsel = v.sel
			v.sel = nil

			if type(vsel) == "string" then
				vsel = table.KeyFromValue(v.atts, vsel) or tonumber(vsel)

				if not vsel then continue end
			end

			timer.Simple(0, function()
				if IsValid(self) and self.SetTFAAttachment then
					self:SetTFAAttachment(k, vsel, false)
				end
			end)

			if SERVER and game.SinglePlayer() then
				timer.Simple(0.05, function()
					if IsValid(self) and self.SetTFAAttachment then
						self:SetTFAAttachment(k, vsel, true)
					end
				end)
			end
		end
	end

	hook.Run("TFA_PostInitAttachments", self)
	self:RemoveUnusedAttachments()
	self:BuildAttachmentCache()
	hook.Run("TFA_FinalInitAttachments", self)
end

local bgt = {}
SWEP.Bodygroups_V = {}
SWEP.Bodygroups_W = {}

function SWEP:ProcessBodygroups()
	if not self.HasFilledBodygroupTables then
		if self:VMIV() then
			for i = 0, #(self.OwnerViewModel:GetBodyGroups() or self.Bodygroups_V) do
				self.Bodygroups_V[i] = self.Bodygroups_V[i] or 0
			end
		end

		for i = 0, #(self:GetBodyGroups() or self.Bodygroups_W) do
			self.Bodygroups_W[i] = self.Bodygroups_W[i] or 0
		end

		self.HasFilledBodygroupTables = true
	end

	if self:VMIV() then
		bgt = self:GetStat("Bodygroups_V", self.Bodygroups_V)

		for k, v in pairs(bgt) do
			v = self:GetStat("Bodygroups_V." .. k, v)

			if type(v) == "table" then continue end -- BASECLASS OUT

			if type(k) == "string" then
				local _k = self.OwnerViewModel:FindBodygroupByName(k)

				k = _k >= 0 and _k or tonumber(k)
			elseif bgt[self.OwnerViewModel:GetBodygroupName(k)] then
				continue -- bodygroup names have the priority over indexes
			end

			if k and self.OwnerViewModel:GetBodygroup(k) ~= v then
				self.OwnerViewModel:SetBodygroup(k, v)
			end
		end
	end

	bgt = self:GetStat("Bodygroups_W", self.Bodygroups_W)

	for k, v in pairs(bgt) do
		v = self:GetStat("Bodygroups_W." .. k, v)

		if type(v) == "table" then continue end -- BASECLASS OUT

		if type(k) == "string" then
			local _k = self:FindBodygroupByName(k)

			k = _k >= 0 and _k or tonumber(k)
		elseif bgt[self:GetBodygroupName(k)] then
			continue -- bodygroup names have the priority over indexes
		end

		if k and self:GetBodygroup(k) ~= v then
			self:SetBodygroup(k, v)
		end
	end
end

function SWEP:CallAttFunc(funcName, ...)
	for attName, sel in pairs(self.AttachmentCache or {}) do
		if not sel then continue end

		local att = TFA.Attachments.Atts[attName]
		if not att then continue end

		local attFunc = att[funcName]
		if attFunc and type(attFunc) == "function" then
			local _ret1, _ret2, _ret3, _ret4, _ret5, _ret6, _ret7, _ret8, _ret9, _ret10 = attFunc(att, self, ...)

			if _ret1 ~= nil then
				return _ret1, _ret2, _ret3, _ret4, _ret5, _ret6, _ret7, _ret8, _ret9, _ret10
			end
		end
	end

	return nil
end