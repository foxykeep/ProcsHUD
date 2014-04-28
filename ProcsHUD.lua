-----------------------------------------------------------------------------------------------
-- Client Lua Script for ProcsHUD
-- Copyright (c) Foxykeep. All rights reserved
-----------------------------------------------------------------------------------------------

-- TODO:
-- * Add cooldown logic => v2: show with cooldown overlay
-- * Add cooldown logic => v3: make it possible to switch between both
-- implementation (hidden or overlay) with an option

-- * Make the proc window movable (see CandyBars)

-- * Show a counter on the proc window showing how long the proc is still
-- active

-- * Options form: unlock movable frame
-- * Options form: activate/deactivate the addon for specific spells.
-- Should show only the spells of your class
-- * Options form: cooldown logic (hidden / overlay)
-- * Options form: enable/disable the proc timer

require "Window"


-----------------------------------------------------------------------------------------------
-- ProcsHUD Module Definition
-----------------------------------------------------------------------------------------------
local ProcsHUD = {}

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
ProcsHUD.CodeEnumProcType = {
	Critical = 1,
	Deflect = 2,
	NoShield = 3
}

ProcsHUD.CodeEnumProcSpellId = {
	-- Engineer
	QuickBurst = 25673,
	Feedback = 26059,
	-- Spellslinger
	FlameBurst = 30666,
	-- Warrior
	BreachingStrikes = 18580,
	AtomicSpear = 18360,
	ShieldBurst = 37245,
	-- Stalker
	Punish = 32336,
	Decimate = 31937,
	-- Medic
	Atomize = 25692,
	DualShock = 47807
}

ProcsHUD.CodeEnumProcSpellName = {
	-- Engineer
	[ProcsHUD.CodeEnumProcSpellId.QuickBurst] = "Quick Burst",
	[ProcsHUD.CodeEnumProcSpellId.Feedback] = "Feedback",
	-- Spellslinger
	[ProcsHUD.CodeEnumProcSpellId.FlameBurst] = "FlameBurst",
	-- Warrior
	[ProcsHUD.CodeEnumProcSpellId.BreachingStrikes] = "Breaching Strikes",
	[ProcsHUD.CodeEnumProcSpellId.AtomicSpear] = "Atomic Spear",
	[ProcsHUD.CodeEnumProcSpellId.ShieldBurst] = "Shield Burst",
	-- Stalker
	[ProcsHUD.CodeEnumProcSpellId.Punish] = "Punish",
	[ProcsHUD.CodeEnumProcSpellId.Decimate] = "Decimate",
	-- Medic
	[ProcsHUD.CodeEnumProcSpellId.Atomize] = "Atomize",
	[ProcsHUD.CodeEnumProcSpellId.DualShock] = "Dual Shock"
}

ProcsHUD.CodeEnumProcSpellSprite = {
	-- Engineer
	[ProcsHUD.CodeEnumProcSpellId.QuickBurst] = "icon_QuickBurst",
	[ProcsHUD.CodeEnumProcSpellId.Feedback] = "icon_Feedback",
	-- Spellslinger
	[ProcsHUD.CodeEnumProcSpellId.FlameBurst] = "icon_FlameBurst",
	-- Warrior
	[ProcsHUD.CodeEnumProcSpellId.BreachingStrikes] = "icon_BreachingStrikes",
	[ProcsHUD.CodeEnumProcSpellId.AtomicSpear] = "icon_AtomicSpear",
	[ProcsHUD.CodeEnumProcSpellId.ShieldBurst] = "icon_ShieldBurst",
	-- Stalker
	[ProcsHUD.CodeEnumProcSpellId.Punish] = "icon_Punish",
	[ProcsHUD.CodeEnumProcSpellId.Decimate] = "icon_Decimate",
	-- Medic
	[ProcsHUD.CodeEnumProcSpellId.Atomize] = "icon_Atomize",
	[ProcsHUD.CodeEnumProcSpellId.DualShock] = "icon_DualShock"
}

ProcsHUD.ProcSpells = {
	[GameLib.CodeEnumClass.Engineer] = {
		{ ProcsHUD.CodeEnumProcSpellId.QuickBurst, ProcsHUD.CodeEnumProcType.Critical },
		{ ProcsHUD.CodeEnumProcSpellId.Feedback, ProcsHUD.CodeEnumProcType.Deflect }
	},
	[GameLib.CodeEnumClass.Spellslinger] = {
		{ ProcsHUD.CodeEnumProcSpellId.FlameBurst, ProcsHUD.CodeEnumProcType.Critical }
	},
	[GameLib.CodeEnumClass.Warrior] = {
		{ ProcsHUD.CodeEnumProcSpellId.BreachingStrikes, ProcsHUD.CodeEnumProcType.Critical },
		{ ProcsHUD.CodeEnumProcSpellId.AtomicSpear, ProcsHUD.CodeEnumProcType.Deflect }
		-- TODO readd once we have the 3rd window and the noshield detection
		--[[,
		{ ProcsHUD.CodeEnumProcSpellId.ShieldBurst, ProcsHUD.CodeEnumProcType.NoShield }]]--
	},
	[GameLib.CodeEnumClass.Stalker] = {
		{ ProcsHUD.CodeEnumProcSpellId.Punish, ProcsHUD.CodeEnumProcType.Critical },
		{ ProcsHUD.CodeEnumProcSpellId.Decimate, ProcsHUD.CodeEnumProcType.Deflect }
	},
	[GameLib.CodeEnumClass.Medic] = {
		{ ProcsHUD.CodeEnumProcSpellId.Atomize, ProcsHUD.CodeEnumProcType.Critical },
		{ ProcsHUD.CodeEnumProcSpellId.DualShock, ProcsHUD.CodeEnumProcType.Critical }
	}
}

local CRITICAL_TIME = 5
local DEFLECT_TIME = 4

local abilitiesList = nil
local function GetAbilitiesList()
	if abilitiesList == nil then
		abilitiesList = AbilityBook.GetAbilitiesList()
	end
	return abilitiesList
end

-----------------------------------------------------------------------------------------------
-- ProcsHUD Initialization
-----------------------------------------------------------------------------------------------

function ProcsHUD:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

	self.lastCriticalTime = 0
	self.lastDeflectTime = 0

	self.tActiveAbilities = {}
	self.tSpellCache = {}

    return o
end

function ProcsHUD:Init()
    Apollo.RegisterAddon(self)
end

-----------------------------------------------------------------------------------------------
-- ProcsHUD OnLoad
-----------------------------------------------------------------------------------------------

function ProcsHUD:OnLoad()
	-- Create the form
	self.xmlDoc = XmlDoc.CreateFromFile("ProcsHUD.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)

	Apollo.RegisterEventHandler("AbilityBookChange", "OnAbilityBookChange", self)
	Apollo.RegisterEventHandler("CombatLogDamage", "OnDamageDealt", self)
	Apollo.RegisterEventHandler("AttackMissed", "OnMiss", self)
	Apollo.RegisterEventHandler("VarChange_FrameCount", "OnFrame", self)

	if GameLib:GetPlayerUnit() then
		self:OnAbilityBookChange()
	end
end

-----------------------------------------------------------------------------------------------
-- GotHUD OnDocLoaded
-----------------------------------------------------------------------------------------------
function ProcsHUD:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
		-- Register handlers for events, slash commands and timer, etc.
		Apollo.LoadSprites("Icons.xml", "ProcsHUDSprites")

		self.tWndProcs = {
			Apollo.LoadForm(self.xmlDoc, "ProcsIcon1", nil, self),
			Apollo.LoadForm(self.xmlDoc, "ProcsIcon2", nil, self)
		}
	end
end


-----------------------------------------------------------------------------------------------
-- Ability detection
-----------------------------------------------------------------------------------------------

function ProcsHUD:OnAbilityBookChange()
	local unitPlayer = GameLib.GetPlayerUnit()
	if not unitPlayer then
		return
	end

	local tSpells = ProcsHUD.ProcSpells[unitPlayer:GetClassId()]
	if not tSpells then
		-- Not a class that we manage in this addon
		self:FinishAddon()
		return
	end

	-- Clear the spell cache as the spells may have changed
	for k in pairs(self.tSpellCache) do
		self.tSpellCache[k] = nil
	end

    local currentActionSet = ActionSetLib.GetCurrentActionSet()
	for _, spell in pairs(tSpells) do
		self:CheckAbility(currentActionSet, spell[1])
	end
end

function ProcsHUD:CheckAbility(currentActionSet, spellId)
    self.tActiveAbilities[spellId] = false

    if not currentActionSet then
        return
    end

    for _, nAbilityId in pairs(currentActionSet) do
        if nAbilityId == spellId then
            self.tActiveAbilities[spellId] = true
            return
        end
    end

    Print("[ProcsHUD] CheckAbility " .. spellId .. " " .. self.tActiveAbilities[spellId])
end


-----------------------------------------------------------------------------------------------
-- Main loop (on every 4 frames)
-----------------------------------------------------------------------------------------------

function ProcsHUD:OnFrame()
	local unitPlayer = GameLib.GetPlayerUnit()
	if not unitPlayer then
		-- We don't have the player object yet.
		return
	end

	if not self.tWndProcs then
		-- We have not loaded the proc windows yet.
		return
	end

	local tSpells = ProcsHUD.ProcSpells[unitPlayer:GetClassId()]
	if not tSpells then
		-- Not a class that we manage in this addon
		self:FinishAddon()
		return
	end

	local wndProcIndex = 1

	-- Manage crits (we pass the wndProcIndex and we receive the new wndProcIndex if we display a window)
	wndProcIndex = self:ProcessProcs(wndProcIndex, ProcsHUD.CodeEnumProcType.Critical, tSpells)

	-- Manage deflect hits
	wndProcIndex = self:ProcessProcs(wndProcIndex, ProcsHUD.CodeEnumProcType.Deflect, tSpells)

	-- TODO manage "no shield"

	-- Hide the remaining proc windows. At this point wndProcIndex is the next window to use, so we
	-- need to hide all the remaining windows including the wndProcIndex one.
	for index, wndProc in pairs(self.tWndProcs) do
		if index >= wndProcIndex then
			wndProc:Show(false)
		end
	end
end


-----------------------------------------------------------------------------------------------
-- Critical detection
-----------------------------------------------------------------------------------------------

function ProcsHUD:OnDamageDealt(tData)
	if tData.unitCaster ~= nil and tData.unitCaster == GameLib.GetPlayerUnit() then
		if tData.eCombatResult == GameLib.CodeEnumCombatResult.Critical then
			self.lastCriticalTime = os.time()
		end
	end
end


-----------------------------------------------------------------------------------------------
-- Deflect detection
-----------------------------------------------------------------------------------------------

function ProcsHUD:OnMiss(unitCaster, unitTarget, eMissType)
	if unitTarget ~= nil and unitTarget == GameLib.GetPlayerUnit() then
		if eMissType == GameLib.CodeEnumMissType.Dodge then
			self.lastDeflectTime = os.time()
		end
	end
end


-----------------------------------------------------------------------------------------------
-- Procs display management
-----------------------------------------------------------------------------------------------

function ProcsHUD:ProcessProcs(wndProcIndex, procType, tSpells)
	if wndProcIndex and  procType and tSpells then
		for _, spell in pairs(tSpells) do
			if spell[2] == procType then
				wndProcIndex = self:ProcessProcsForSpell(wndProcIndex, procType, spell[1])
			end
		end
	end

	return wndProcIndex
end

function ProcsHUD:ProcessProcsForSpell(wndProcIndex, procType, spellId)
	local wndProc = self.tWndProcs[wndProcIndex]
	if not wndProc then
		-- We don't have a valid window to display the proc. This should normally never happen.
		Print("We don't have a window to display the proc. Something went really wrong")
		return wndProcIndex
	end

	-- Let's test if you have the spell
	if not self.tActiveAbilities[spellId] then
		-- You don't have the spell in your LAS. Nothing to do here.
		return wndProcIndex
	end

	-- Let's check if the spell is not in cooldown
	local cooldownLeft, cooldownTotalDuration, chargesLeft = self:GetSpellCooldown(spellId)
	-- TODO improve that to show the cooldown
	if cooldownLeft > 0 and chargesLeft == 0 then
		-- The spell is in cooldown and we don't have any charge left (for a spell with charges). Nothing to do here.
		return wndProcIndex
	end

	local shouldShowProc = false
	if procType == ProcsHUD.CodeEnumProcType.Critical then -- Let's check if we scored a critical
		shouldShowProc = os.difftime(os.time(), self.lastCriticalTime) < CRITICAL_TIME
	elseif procType == ProcsHUD.CodeEnumProcType.Deflect then -- Let's check if we deflected a hit
		shouldShowProc = os.difftime(os.time(), self.lastDeflectTime) < DEFLECT_TIME
	else if procType == ProcsHUD.CodeEnumProcType.NoShield
		-- TODO implement
	end

	-- Let's see if we need to show the proc
	if shouldShowProc then
		-- Update the sprite in the proc view
		local sprite = ProcsHUD.CodeEnumProcSpellSprite[spellId]
		wndProc:FindChild("Icon"):SetSprite(sprite)

		-- Show the proc view
		wndProc:Show(true)

		-- Increment the wndProcIndex as we shown a window
		wndProcIndex = wndProcIndex + 1
	end

	return wndProcIndex
end


-----------------------------------------------------------------------------------------------
-- Utility methods cleanup
-----------------------------------------------------------------------------------------------

-- @return {time remaining, duration, remaining charges}
function ProcsHUD:GetSpellCooldown(spellId)
	local splObject = self:GetSpellById(spellId)
	if not splObject then
		Print("GetSpellCooldown called with a non-existing spell " .. spellId)
		return 0, 0, 0
	end

	local charges = splObject:GetAbilityCharges()
	if charges and charges.nChargesMax > 0 then
		-- Special spell with charges
		if charges.fRechargePercentRemaining and charges.fRechargePercentRemaining > 0 then -- We are recharging charges
			return charges.fRechargePercentRemaining * charges.fRechargeTime, charges.fRechargeTime, tostring(charges.nChargesRemaining)
		end
	else
		-- Standard spell with cooldown
		local time = splObject:GetCooldownRemaining()
		if time and time > 0 then -- Time remaining is greater than 0 when on cooldown
			return time, splObject:GetCooldownTime(), 0
		end
	end

	-- If we are here, that means the spell is not on cooldown
	return 0, 0, 0
end

function ProcsHUD:GetSpellById(spellId)
	-- Let's check the cache first
	splObject = tSpellCache[spellId]
	if splObject then
		return splObject
	end

	local abilities = GetAbilitiesList()
	if not abilities then
		return
	end

	for _, v in pairs(abilities) do
		if v.nId == spellId then
			if v.bIsActive and v.nCurrentTier and v.tTiers then
				local tier = v.tTiers[v.nCurrentTier]
				if tier then
					tSpellCache[spellId] = tier.splObject
					return tier.splObject
				end
			end
		end
	end
end


-----------------------------------------------------------------------------------------------
-- Addon cleanup
-----------------------------------------------------------------------------------------------

function ProcsHUD:FinishAddon() {
	if self.xmlDoc then
		self.xmlDoc:Destroy()
	end

	Apollo.RemoveEventHandler("AbilityBookChange", self)
	Apollo.RemoveEventHandler("CombatLogDamage", self)
	Apollo.RemoveEventHandler("AttackMissed", self)
	Apollo.RemoveEventHandler("VarChange_FrameCount", self)
}


-----------------------------------------------------------------------------------------------
-- ProcsHUD Instance
-----------------------------------------------------------------------------------------------
local ProcsHUDInst = ProcsHUD:new()
ProcsHUDInst:Init()