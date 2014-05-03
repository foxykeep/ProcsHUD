-----------------------------------------------------------------------------------------------
-- Client Lua Script for ProcsHUD
-- Copyright (c) Foxykeep. All rights reserved
-----------------------------------------------------------------------------------------------

-- TODO:
-- * Add cooldown logic => v2: show with cooldown overlay

-- * Show a counter on the proc window showing how long the proc is still
-- active

-- * Add tooltips on the spells in the options

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
		{ ProcsHUD.CodeEnumProcSpellId.AtomicSpear, ProcsHUD.CodeEnumProcType.Deflect },
		{ ProcsHUD.CodeEnumProcSpellId.ShieldBurst, ProcsHUD.CodeEnumProcType.NoShield }
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

ProcsHUD.CodeEnumCooldownLogic = {
	Hide = 1,
	Overlay = 2
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

local function DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function NullToZero(d)
	if d == nil then
		return 0
	end
	return d
end

local defaultSettings = {
	cooldownLogic = ProcsHUD.CodeEnumCooldownLogic.Hide,
	activeSpells = {
		-- Engineer
		[ProcsHUD.CodeEnumProcSpellId.QuickBurst] = true,
		[ProcsHUD.CodeEnumProcSpellId.Feedback] = true,
		-- Spellslinger
		[ProcsHUD.CodeEnumProcSpellId.FlameBurst] = true,
		-- Warrior
		[ProcsHUD.CodeEnumProcSpellId.BreachingStrikes] = true,
		[ProcsHUD.CodeEnumProcSpellId.AtomicSpear] = true,
		[ProcsHUD.CodeEnumProcSpellId.ShieldBurst] = true,
		-- Stalker
		[ProcsHUD.CodeEnumProcSpellId.Punish] = true,
		[ProcsHUD.CodeEnumProcSpellId.Decimate] = true,
		-- Medic
		[ProcsHUD.CodeEnumProcSpellId.Atomize] = true,
		[ProcsHUD.CodeEnumProcSpellId.DualShock] = true,
	}
}

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

	self.bUnlockFrames = false;
	self.userSettings = DeepCopy(defaultSettings)

    return o
end

function ProcsHUD:InitUserSettings()

end

function ProcsHUD:Init()
    Apollo.RegisterAddon(self)
end


-----------------------------------------------------------------------------------------------
-- ProcsHUD Save & Restore settings
-----------------------------------------------------------------------------------------------

function ProcsHUD:OnSave(eType)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return nil
	end

    local tSave = {}
    tSave.cooldownLogic = self.userSettings.cooldownLogic
	tSave.activeSpells = DeepCopy(self.userSettings.activeSpells)

	return tSave
end

function ProcsHUD:OnRestore(eType, tSave)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return
	end

	self.userSettings.cooldownLogic = tSave.cooldownLogic
	if tSave.activeSpells ~= nil then
		self.userSettings.activeSpells = DeepCopy(tSave.activeSpells)
	else
		self.userSettings.activeSpells = DeepCopy(defaultSettings.activeSpells)
	end
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

	Apollo.RegisterTimerHandler("AbilityBookChangerTimer", "OnAbilityBookChangerTimer", self)

	if GameLib:GetPlayerUnit() then
		self:OnAbilityBookChange()
	end
end

-----------------------------------------------------------------------------------------------
-- GotHUD OnDocLoaded
-----------------------------------------------------------------------------------------------
function ProcsHUD:OnDocLoaded()
	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
		-- Load the settings window
	    self.wndSettings = Apollo.LoadForm(self.xmlDoc, "ProcsSettingsUI", nil, self)
		if not self.wndSettings then
			Apollo.AddAddonErrorText(self, "Could not load the settings window for some reason.")
			return
		end
		self.wndSettings:Show(false)

		-- Get the Settings spell windows
		self.tWndSettingsSpells = {
			self.wndSettings:FindChild("WndSpell1"),
			self.wndSettings:FindChild("WndSpell2"),
			self.wndSettings:FindChild("WndSpell3")
		}
		if not self.tWndSettingsSpells[1] or not self.tWndSettingsSpells[2] or not self.tWndSettingsSpells[3] then
			Apollo.AddAddonErrorText(self, "Could not load the settings window for some reason.")
			return
		end

		-- Load the proc frame windows
		self.tWndProcs = {
			Apollo.LoadForm(self.xmlDoc, "ProcsIcon1", nil, self),
			Apollo.LoadForm(self.xmlDoc, "ProcsIcon2", nil, self),
			Apollo.LoadForm(self.xmlDoc, "ProcsIcon3", nil, self)
		}
		if not self.tWndProcs[1] or not self.tWndProcs[2] or not self.tWndProcs[3] then
			Apollo.AddAddonErrorText(self, "Could not load the proc frame windows for some reason.")
			return
		end
		for _, wndProc in pairs(self.tWndProcs) do
			wndProc:Show(false)
			wndProc:FindChild("Number"):Show(false)
			wndProc:FindChild("Cooldown"):Show(false)
		end

		-- Load the spell sprites
		Apollo.LoadSprites("Icons.xml", "ProcsHUDSprites")

		-- Register handlers for events, slash commands and timer, etc.
		Apollo.RegisterSlashCommand("procshud", "ShowSettingsUI", self)
		Apollo.RegisterSlashCommand("ProcsHud", "ShowSettingsUI", self)
		Apollo.RegisterSlashCommand("ProcsHUD", "ShowSettingsUI", self)
	end
end


-----------------------------------------------------------------------------------------------
-- Ability detection
-----------------------------------------------------------------------------------------------

function ProcsHUD:OnAbilityBookChange()
	-- ActionSetLib.GetCurrentActionSet() returns the old LAS when called in
	-- OnAbilityBookChange(). So we start a delay timer.
	Apollo.CreateTimer("AbilityBookChangerTimer", 1, false)
end

function ProcsHUD:OnAbilityBookChangerTimer()
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
end


-----------------------------------------------------------------------------------------------
-- Main loop (on every 4 frames)
-----------------------------------------------------------------------------------------------

function ProcsHUD:OnFrame()
	if self.bUnlockFrames then
		-- We are in "Move frames" mode. We don't draw the normal procs in this case
		return
	end

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

	-- Manage crit procs (we pass the wndProcIndex and we receive the new wndProcIndex if we display a window)
	wndProcIndex = self:ProcessProcs(unitPlayer, wndProcIndex, ProcsHUD.CodeEnumProcType.Critical, tSpells)

	-- Manage deflect hit procs
	wndProcIndex = self:ProcessProcs(unitPlayer, wndProcIndex, ProcsHUD.CodeEnumProcType.Deflect, tSpells)

	-- Manage no shield procs
	wndProcIndex = self:ProcessProcs(unitPlayer, wndProcIndex, ProcsHUD.CodeEnumProcType.NoShield, tSpells)

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

function ProcsHUD:ProcessProcs(unitPlayer, wndProcIndex, procType, tSpells)
	if wndProcIndex > 0 and procType and tSpells then
		for _, spell in pairs(tSpells) do
			if spell[2] == procType then
				-- Let's check if the user didn't deactivate the spell in the options
				if self.userSettings.activeSpells[spell[1]] then
					wndProcIndex = self:ProcessProcsForSpell(unitPlayer, wndProcIndex, procType, spell[1])
				end
			end
		end
	end

	return wndProcIndex
end

function ProcsHUD:ProcessProcsForSpell(unitPlayer, wndProcIndex, procType, spellId)
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
	if self.userSettings.cooldownLogic == ProcsHUD.CodeEnumCooldownLogic.Hide then
		if cooldownLeft > 0 and chargesLeft == 0 then
			-- The spell is in cooldown and we don't have any charge left (for a spell with charges). Nothing to do here.
			return wndProcIndex
		end
	end

	local shouldShowProc = false
	if procType == ProcsHUD.CodeEnumProcType.Critical then -- Let's check if we scored a critical
		shouldShowProc = os.difftime(os.time(), self.lastCriticalTime) < CRITICAL_TIME
	elseif procType == ProcsHUD.CodeEnumProcType.Deflect then -- Let's check if we deflected a hit
		shouldShowProc = os.difftime(os.time(), self.lastDeflectTime) < DEFLECT_TIME
	elseif procType == ProcsHUD.CodeEnumProcType.NoShield then -- Let's check if we are at 0 shield
		shouldShowProc = NullToZero(unitPlayer:GetShieldCapacity()) == 0
	end

	-- Let's see if we need to show the proc
	if shouldShowProc then
		-- Update the sprite in the proc view
		local sprite = ProcsHUD.CodeEnumProcSpellSprite[spellId]
		wndProc:FindChild("Icon"):SetSprite(sprite)

		local wndProcCooldown = wndProc:FindChild("Cooldown")
		if self.userSettings.cooldownLogic == ProcsHUD.CodeEnumCooldownLogic.Overlay then
			wndProcCooldown:Show(true)
			if cooldownLeft > 0 then
				local cooldownText = ""
				if cooldownLeft > 3600 then
					cooldownText = math.floor(cooldownLeft / 3600) .. "h"
				elseif cooldownLeft > 60 then
					cooldownText = math.floor(cooldownLeft / 60) .. "m"
				else
					cooldownText = math.floor(cooldownLeft) .. "s"
				end
				wndProcCooldown:SetText(cooldownText)
			else
				wndProcCooldown:SetText("")
			end
		else
			wndProcCooldown:Show(false)
		end

		-- Show the proc view
		wndProc:Show(true)

		-- Increment the wndProcIndex as we have shown a window
		wndProcIndex = wndProcIndex + 1
	end

	return wndProcIndex
end


-----------------------------------------------------------------------------------------------
-- Spell methods
-----------------------------------------------------------------------------------------------

-- @return {time remaining, duration, remaining charges}
function ProcsHUD:GetSpellCooldown(spellId)
	local splObject = self:GetSpellById(spellId)
	if not splObject then
		-- GetSpellCooldown called with a non-existing spell
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
	splObject = self.tSpellCache[spellId]
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
					self.tSpellCache[spellId] = tier.splObject
					return tier.splObject
				end
			end
		end
	end
end


-----------------------------------------------------------------------------------------------
-- Addon cleanup
-----------------------------------------------------------------------------------------------

function ProcsHUD:FinishAddon()
	if self.xmlDoc then
		self.xmlDoc:Destroy()
	end

	Apollo.RemoveEventHandler("AbilityBookChange", self)
	Apollo.RemoveEventHandler("CombatLogDamage", self)
	Apollo.RemoveEventHandler("AttackMissed", self)
	Apollo.RemoveEventHandler("VarChange_FrameCount", self)

	Apollo.StopTimer("AbilityBookChangerTimer")
end


---------------------------------------------------------------------------------------------------
-- ProcsSettingsUI Functions
---------------------------------------------------------------------------------------------------

function ProcsHUD:ShowSettingsUI()
	local unitPlayer = GameLib.GetPlayerUnit()
	if not unitPlayer then
		-- We don't have the player object yet.
		return
	end

	-- Spells management settings
	local tSpells = ProcsHUD.ProcSpells[unitPlayer:GetClassId()]
	if not tSpells then
		-- Not a class that we manage in this addon
		Print("Esper doesn't have spells usable only after Procs. As a result, ProcsHUD is disabled for Esper characters.")
		return
	end

	self:SetupSettingsUI(tSpells)

	self.wndSettings:Show(true)
	self.wndSettings:ToFront()
end

function ProcsHUD:SetupSettingsUI(tSpells)
	-- Unlock Frames setting
	self.wndSettings:FindChild("ButtonUnlockFrames"):SetCheck(self.bUnlockFrames)

	-- Cooldown management settings
	if self.userSettings.cooldownLogic == ProcsHUD.CodeEnumCooldownLogic.Hide then
		self.wndSettings:FindChild("ButtonCooldownHideFrame"):SetCheck(true)
	elseif self.userSettings.cooldownLogic == ProcsHUD.CodeEnumCooldownLogic.Overlay then
		self.wndSettings:FindChild("ButtonCooldownOverlay"):SetCheck(true)
	end

	-- Spells management settings
	for i, spell in pairs(tSpells) do
		local spellId = spell[1]

		local wndSpell = self.tWndSettingsSpells[i]
		wndSpell:Show(true)

		wndSpell:FindChild("ButtonSpell"):SetCheck(self.userSettings.activeSpells[spellId])

		local spellSprite = ProcsHUD.CodeEnumProcSpellSprite[spellId]
		wndSpell:FindChild("SpellIcon"):SetSprite(spellSprite)
		local spellName = ProcsHUD.CodeEnumProcSpellName[spellId]
		wndSpell:FindChild("SpellName"):SetText(spellName)

		-- TODO add a tooltip with the spell info like in the AbilityBuilder
	end

	-- Hide the remaining spell rows
	for i=#tSpells+1, 3 do
		local wndSpell = self.tWndSettingsSpells[i]
		wndSpell:Show(false)
	end
end

function ProcsHUD:SettingsOnClose(wndHandler, wndControl, eMouseButton)
	self.wndSettings:Show(false)

	-- Lock the frames when closing the settings
	self.bUnlockFrames = false;
	self:UnlockFrames()
end

function ProcsHUD:SettingsOnUnlockFramesToggle(wndHandler, wndControl, eMouseButton)
	local bUnlockFrames = self.wndSettings:FindChild("ButtonUnlockFrames"):IsChecked()

	if self.bUnlockFrames ~= bUnlockFrames then
		self.bUnlockFrames = bUnlockFrames
		self:UnlockFrames()
	end
end

function ProcsHUD:UnlockFrames()
	if self.bUnlockFrames then
		-- Make all the proc windows visible, show the 1/2/3 and make them movable
		for _, wndProc in pairs(self.tWndProcs) do
			wndProc:FindChild("Icon"):SetSprite("")
			wndProc:FindChild("Number"):Show(true)
			wndProc:FindChild("Cooldown"):Show(false)
			wndProc:Show(true)
			wndProc:SetStyle("IgnoreMouse", false)
			wndProc:SetStyle("Moveable", true)
		end
	else
		-- Make all procs windows hidden (they will be made visible by the next "on frame"
		-- if needed), hide the 1/2/3 and make them not movable
		for _, wndProc in pairs(self.tWndProcs) do
			wndProc:FindChild("Number"):Show(false)
			wndProc:FindChild("Cooldown"):Show(true)
			wndProc:FindChild("Cooldown"):SetText("")
			wndProc:Show(false)
			wndProc:SetStyle("IgnoreMouse", true)
			wndProc:SetStyle("Moveable", false)
		end
	end
end

function ProcsHUD:SettingsOnCooldownToggle(wndHandler, wndControl, eMouseButton)
	if self.wndSettings:FindChild("ButtonCooldownHideFrame"):IsChecked() then
		self.userSettings.cooldownLogic = ProcsHUD.CodeEnumCooldownLogic.Hide
	elseif self.wndSettings:FindChild("ButtonCooldownOverlay"):IsChecked() then
		self.userSettings.cooldownLogic = ProcsHUD.CodeEnumCooldownLogic.Overlay
	end
end

function ProcsHUD:SettingsOnSpell1Toggle(wndHandler, wndControl, eMouseButton)
	self:SettingsToggleSpell(1)
end

function ProcsHUD:SettingsOnSpell2Toggle(wndHandler, wndControl, eMouseButton)
	self:SettingsToggleSpell(2)
end

function ProcsHUD:SettingsOnSpell3Toggle(wndHandler, wndControl, eMouseButton)
	self:SettingsToggleSpell(3)
end

function ProcsHUD:SettingsToggleSpell(wndSpellIndex)
	local unitPlayer = GameLib.GetPlayerUnit()
	if not unitPlayer then
		-- We don't have the player object yet.
		return
	end

	-- Spells management settings
	local tSpells = ProcsHUD.ProcSpells[unitPlayer:GetClassId()]
	if not tSpells then
		-- Not a class that we manage in this addon. This should never happen as we show the
		-- settings UI only for the class we manage.
		return
	end

	local isSpellActive = self.tWndSettingsSpells[wndSpellIndex]:FindChild("ButtonSpell"):IsChecked()

	local spellId = tSpells[wndSpellIndex][1]
	self.userSettings.activeSpells[spellId] = isSpellActive
end


-----------------------------------------------------------------------------------------------
-- ProcsHUD Instance
-----------------------------------------------------------------------------------------------
local ProcsHUDInst = ProcsHUD:new()
ProcsHUDInst:Init()