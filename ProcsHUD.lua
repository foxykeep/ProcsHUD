-----------------------------------------------------------------------------------------------
-- Client Lua Script for ProcsHUD
-- Copyright (c) Foxykeep. All rights reserved
-----------------------------------------------------------------------------------------------

-- TODO:
-- * Add cooldown logic => v2: show with cooldown overlay
-- * Add cooldown logic => v3: make it possible to switch between both

-- * Show a counter on the proc window showing how long the proc is still
-- active

-- * Options form: activate/deactivate the addon for specific spells.
-- Should show only the spells of your class
-- * Options form: cooldown logic (hidden / overlay)
-- * Options form: enable/disable the proc timer
-- * Slider for scaling ?

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

ProcsHUD.CodeEnumCooldownLogic {
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

local defaultSettings = {
	cooldownLogic = ProcsHUD:CodeEnumCooldownLogic:Hide,
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

	self.bUnlockFrames = true;
	self.userSettings = self.deepcopy(defaultSettings)

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

function GotHUD:OnSave(eType)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return
	end

    local tSave = {}
    tSave.cooldownLogic = self.userSettings.cooldownLogic
	tSave.activeSpells = self.deepcopy(self.userSettings.activeSpells)

	return tSave
end

function GotHUD:OnRestore(eType, tSave)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return
	end

	self.userSettings.cooldownLogic = tSave.cooldownLogic
	if tSave.activeSpells ~= nil then
		self.userSettings.activeSpells = self.deepcopy(tSave.activeSpells)
	else
		self.userSettings.activeSpells = self.deepcopy(defaultSettings.activeSpells)
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
		if self.wndSettings == nil then
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

	-- ActionSetLib.GetCurrentActionSet() returns the old LAS when called in
	-- OnAbilityBookChange(). So we start a delay timer.
	Apollo.CreateTimer("AbilityBookChangerTimer", 0.5, false)
end

function ProcsHUD:OnAbilityBookChangerTimer()
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
	if not self.bUnlockFrames then
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
	if wndProcIndex and procType and tSpells then
		for _, spell in pairs(tSpells) do
			if spell[2] == procType then
				-- Let's check if the user didn't deactivate the spell in the options
				if self.userSettings.activeSpells[spell[1]] then
					wndProcIndex = self:ProcessProcsForSpell(wndProcIndex, procType, spell[1])
				end
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

	Apollo.StopTimer("AbilityBookChangerTimer")
}


---------------------------------------------------------------------------------------------------
-- ProcsSettingsUI Functions
---------------------------------------------------------------------------------------------------

function ProcsHUD:ShowSettingsUI()
	self:SetupSettingsUI()

	self.wndSettings:Show(true)
	self.wndSettings:ToFront()
end

function ProcsHUD:SetupSettingsUI()
	self:wndSettings:FindChild("ButtonUnlockFrames"):SetChecked(self.bUnlockFrames)

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
			wndProc:Show(true)
			wndProc:SetStyle("IgnoreMouse", false)
			wndProc:SetStyle("Moveable", true)
		end
	else
		-- Make all procs windows hidden (they will be made visible by the next "on frame"
		-- if needed), hide the 1/2/3 and make them not movable
		for _, wndProc in pairs(self.tWndProcs) do
			wndProc:FindChild("Number"):Show(false)
			wndProc:Show(false)
			wndProc:SetStyle("IgnoreMouse", true)
			wndProc:SetStyle("Moveable", false)
		end
	end
end

function ProcsHUD:SettingsOnCooldownToggle(wndHandler, wndControl, eMouseButton)
	if self.wndSettings:FindChild("ButtonCooldownHideFrame"):IsChecked() then
		self.userSettings.cooldownLogic = ProcsHUD:CodeEnumCooldownLogic:Hide
	elseif self.wndMain:FindChild("ButtonCooldownOverlay"):IsChecked() then
		self.userSettings.cooldownLogic = ProcsHUD:CodeEnumCooldownLogic:Overlay
	end
end

function ProcsHUD:SettingsOnScaleChanged(wndHandler, wndControl, fNewValue, fOldValue)
	-- TODO implement
end


-----------------------------------------------------------------------------------------------
-- Utility Instance
-----------------------------------------------------------------------------------------------

function ProcsHUD.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[ProcsHUD.deepcopy(orig_key)] = ProcsHUD.deepcopy(orig_value)
        end
        setmetatable(copy, ProcsHUD.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


-----------------------------------------------------------------------------------------------
-- ProcsHUD Instance
-----------------------------------------------------------------------------------------------
local ProcsHUDInst = ProcsHUD:new()
ProcsHUDInst:Init()