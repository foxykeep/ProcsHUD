-----------------------------------------------------------------------------------------------
-- Client Lua Script for ProcsHUD
-- Copyright (c) Foxykeep. All rights reserved
-----------------------------------------------------------------------------------------------

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

local CRITICAL_TIME = 5
local DEFLECT_TIME = 4

-- TODO:
-- * add cooldown logic => v1: show only if active and off cooldown
-- * add cooldown logic => v2: show with cooldown overlay
-- * add cooldown logic => v3: make it possible to switch between both with an option
-- * manage different addon area depending on the number of possible spells (SS => 1 | Engi/Stalk/Med => 2 | Warr => 3)
-- * horizontal vs vertical line of icons if multiple?
-- * Show a counter on the icon with the remaining time where the proc is available
-- * movable frame (see CandyBars)
-- * movable frame only if options set
-- * option form: unlock movable frame
-- * option form: activate/deactivate spells. Show only the ones for the class

-----------------------------------------------------------------------------------------------
-- ProcsHUD Initialization
-----------------------------------------------------------------------------------------------

function ProcsHUD:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

	self.lastCriticalTime = 0
	self.tAbilities = {}

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

	Apollo.RegisterEventHandler("CharacterCreated", "OnCharacterCreated", self)

	if GameLib:GetPlayerUnit() then
		self:OnCharacterCreated()
	end
end

-----------------------------------------------------------------------------------------------
-- GotHUD OnDocLoaded
-----------------------------------------------------------------------------------------------
function ProcsHUD:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
		-- Register handlers for events, slash commands and timer, etc.
		Apollo.LoadSprites("Icons.xml", "ProcsHUDSprites")

		self.wndCritical = Apollo.LoadForm(self.xmlDoc, "ProcsEngineerCritical", nil, self)
    	self.wndCritical:Show(true)	
		local sprite = ProcsHUD.CodeEnumProcSpellSprite[ProcsHUD.CodeEnumProcSpellId.QuickBurst]
		Print(sprite)
		self.wndCritical:FindChild("Icon"):SetSprite(sprite)
		--self.wndCritical:FindChild("Icon"):SetFillSprite(sprite)
		--Print(self.wndCritical:FindChild("Icon"))
	end
end

-----------------------------------------------------------------------------------------------
-- Character Creation
-----------------------------------------------------------------------------------------------

function ProcsHUD:OnCharacterCreated()
	Print("OnCharacterCreated")
	local unitPlayer = GameLib.GetPlayerUnit()
	if not unitPlayer then
		return
	elseif unitPlayer:GetClassId() == GameLib.CodeEnumClass.Engineer then
		self:OnCharacterCreatedEngineer()
	-- STOPSHIP create the other classes if needed
	else
		-- Not a valid class
		if self.xmlDoc then
			self.xmlDoc:Destroy()
		end
		return
	end
end

function ProcsHUD:OnCharacterCreatedEngineer()
	Print("OnCharacterCreatedEngineer")
	self:OnCharacterCreatedCommon()

	-- Listen for crit
	Apollo.RegisterEventHandler("CombatLogDamage", "OnDamageDealt", self)

end

function ProcsHUD:OnCharacterCreatedCommon()
	Print("OnCharacterCreatedCommon")
	-- Update our UI every frame
	Apollo.RegisterEventHandler("VarChange_FrameCount", "OnFrame", self)

	-- Listen for ability changes
	Apollo.RegisterEventHandler("PlayerChanged", "OnPlayerChanged", self)
	self:OnPlayerChangedEngineer()	
end

-----------------------------------------------------------------------------------------------
-- Main loop (on every 4 frames)
-----------------------------------------------------------------------------------------------

function ProcsHUD:OnFrame()
	local unitPlayer = GameLib.GetPlayerUnit()
	if not unitPlayer then
		return
	elseif unitPlayer:GetClassId() == GameLib.CodeEnumClass.Engineer then
		self:OnFrameEngineer()
	-- STOPSHIP create the other classes if needed
	else
		-- Not a valid class
		if self.xmlDoc then
			self.xmlDoc:Destroy()
		end
		return
	end
end

function ProcsHUD:OnFrameEngineer()
	-- Manage the critical
	self:ShowOnCriticalEngineer()
end

-----------------------------------------------------------------------------------------------
-- Ability detection
-----------------------------------------------------------------------------------------------

function ProcsHUD:OnPlayerChanged() 
	Print("OnPlayerChanged")
	local unitPlayer = GameLib.GetPlayerUnit()
	if not unitPlayer then
		return
	elseif unitPlayer:GetClassId() == GameLib.CodeEnumClass.Engineer then
		self:OnPlayerChangedEngineer()
	-- STOPSHIP create the other classes if needed
	else
		-- Not a valid class
		if self.xmlDoc then
			self.xmlDoc:Destroy()
		end
		return
	end
end

function ProcsHUD:OnPlayerChangedEngineer() 
	Print("OnPlayerChangedEngineer")
	-- The ability we are looking for is QuickBurst
    self.tAbilities[ProcsHUD.CodeEnumProcSpellId.QuickBurst] = false;
 
    -- Let's test if you have the Spell
    local currentActionSet = ActionSetLib.GetCurrentActionSet()
    if not currentActionSet then
        return
    end
 
    for _, nAbilityId in pairs(currentActionSet) do
        if nAbilityId == ProcsHUD.CodeEnumProcSpellId.QuickBurst then
            self.tAbilities[ProcsHUD.CodeEnumProcSpellId.QuickBurst] = true;
        end
    end

    if self.tAbilities[ProcsHUD.CodeEnumProcSpellId.QuickBurst] then
    	Print("OnPlayerChangedEngineer -- QuickBurst TRUE")
    else
    	Print("OnPlayerChangedEngineer -- QuickBurst FALSE")
    end
end


-----------------------------------------------------------------------------------------------
-- Critical management
-----------------------------------------------------------------------------------------------

function ProcsHUD:OnDamageDealt(tData)
	if tData.unitCaster ~= nil and tData.unitCaster == GameLib.GetPlayerUnit() then
		if tData.eCombatResult == GameLib.CodeEnumCombatResult.Critical then
			self.lastCriticalTime = os.time()
		end
	end
end

function ProcsHUD:ShowOnCriticalEngineer()
	-- Let's test if you have the Quick Burst Ability
	if not self.tAbilities[ProcsHUD.CodeEnumProcSpellId.QuickBurst] then
		--self.wndCritical:Show(false)
		return
	end

	-- We have Quick Burst. Let's check if we scored a critical
	if os.difftime(os.time(), self.lastCriticalTime) < CRITICAL_TIME then	-- the last critical is valid
		-- Let's show the view
		self.wndCritical:Show(true)
		local sprite = ProcsHUD.CodeEnumProcSpellSprite[ProcsHUD.CodeEnumProcSpellId.QuickBurst]
		self.wndCritical:FindChild("Icon"):SetFullSprite(sprite)
	else
		--self.wndCritical:Show(false)
	end
end

-----------------------------------------------------------------------------------------------
-- ProcsHUD Instance
-----------------------------------------------------------------------------------------------
local ProcsHUDInst = ProcsHUD:new()
ProcsHUDInst:Init()