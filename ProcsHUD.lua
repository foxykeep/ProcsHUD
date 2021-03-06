-----------------------------------------------------------------------------------------------
-- Client Lua Script for ProcsHUD
-- Copyright (c) Foxykeep. All rights reserved
-----------------------------------------------------------------------------------------------

require "Window"

-----------------------------------------------------------------------------------------------
-- ProcsHUD Module Definition
-----------------------------------------------------------------------------------------------
local ProcsHUD = {}

local foxyLib = nil

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local CRITICAL_TIME = 5
local DEFLECT_TIME = 4

local NB_PROC_WINDOWS = 5
local PROC_WINDOW_SIZE = 74

local SETTINGS_FRAME_HEIGHT = 520
local SETTINGS_SPELL_ROW_HEIGHT = 60
local SETTINGS_SPELL_ROW_TOP = 345
local SETTINGS_SPELL_ROW_BOTTOM = 395
local SETTINGS_SPELL_SPECIAL_SETTING_ROW_HEIGHT = 35
local SETTINGS_SPELL_SPECIAL_SETTING_ROW_TOP = 345
local SETTINGS_SPELL_SPECIAL_SETTING_ROW_BOTTOM = 370

ProcsHUD.CodeEnumLanguage = {
	English = 1,
	French = 2,
	German = 3
}

ProcsHUD.CodeEnumProcType = {
	CriticalDmg = 1,
	CriticalDmgOrHeal = 2,
	Deflect = 3,
	NoShield = 4,
	Engineer3070Resource = 5,
	Esper5PP = 6,
	HasCharges = 7,
	Warrior250Resource = 8,
	TakeCriticalDmg = 9
}

ProcsHUD.CodeEnumSpecialSettingType = {
	Punish35SuitPower = 1,
}

ProcsHUD.CodeEnumSpecialSettingWnd = {
	[ProcsHUD.CodeEnumSpecialSettingType.Punish35SuitPower] = "ProcsSettingsWndPunishSetting"
}

ProcsHUD.CodeEnumProcSpellId = {
	-- Engineer
	QuickBurst = 25673,
	Feedback = 26059,
	BioShell = 25538,
	Ricochet = 25626,
	-- Spellslinger
	FlameBurst = 30666,
	Assassinate = 23274,
	-- Warrior
	BreachingStrikes = 18580,
	AtomicSpear = 18360,
	ShieldBurst = 37245,
	Rampage = 37968,
	Grapple = 18363,
	-- Stalker
	Punish = 32336,
	Decimate = 31937,
	-- Medic
	Atomize = 25692,
	DualShock = 47807,
	Collider = 47793,
	MagneticLockdown = 26529,
	-- Esper
	Esper5PP = -1,
	Bolster = 19031,
	ConcentratedBlade = 28756
}

ProcsHUD.CodeEnumProcSpellName = {
	-- Engineer
	[ProcsHUD.CodeEnumProcSpellId.QuickBurst] = "Quick Burst",
	[ProcsHUD.CodeEnumProcSpellId.Feedback] = "Feedback",
	[ProcsHUD.CodeEnumProcSpellId.BioShell] = "Bio Shell T4",
	[ProcsHUD.CodeEnumProcSpellId.Ricochet] = "Ricochet T4",
	-- Spellslinger
	[ProcsHUD.CodeEnumProcSpellId.FlameBurst] = "FlameBurst",
	[ProcsHUD.CodeEnumProcSpellId.Assassinate] = "Assassinate",
	-- Warrior
	[ProcsHUD.CodeEnumProcSpellId.BreachingStrikes] = "Breaching Strikes",
	[ProcsHUD.CodeEnumProcSpellId.AtomicSpear] = "Atomic Spear",
	[ProcsHUD.CodeEnumProcSpellId.ShieldBurst] = "Shield Burst",
	[ProcsHUD.CodeEnumProcSpellId.Rampage] = "Rampage",
	[ProcsHUD.CodeEnumProcSpellId.Grapple] = "Grapple",
	-- Stalker
	[ProcsHUD.CodeEnumProcSpellId.Punish] = "Punish",
	[ProcsHUD.CodeEnumProcSpellId.Decimate] = "Decimate",
	-- Medic
	[ProcsHUD.CodeEnumProcSpellId.Atomize] = "Atomize",
	[ProcsHUD.CodeEnumProcSpellId.DualShock] = "Dual Shock",
	[ProcsHUD.CodeEnumProcSpellId.Collider] = "Collider",
	[ProcsHUD.CodeEnumProcSpellId.MagneticLockdown] = "Magnetic Lockdown",
	-- Esper
	[ProcsHUD.CodeEnumProcSpellId.Esper5PP] = "5 Psy Points",
	[ProcsHUD.CodeEnumProcSpellId.Bolster] = "Bolster",
	[ProcsHUD.CodeEnumProcSpellId.ConcentratedBlade] = "Concentrated Blade"
}

ProcsHUD.CodeEnumProcSpellTooltip = {
	-- Engineer
	[ProcsHUD.CodeEnumProcSpellId.QuickBurst] = nil,
	[ProcsHUD.CodeEnumProcSpellId.Feedback] = nil,
	[ProcsHUD.CodeEnumProcSpellId.BioShell] = "Instant cast of Bio Shell T4\nin the 30-70 volatility range",
	[ProcsHUD.CodeEnumProcSpellId.Ricochet] = "Instant cast of Ricochet T4\nin the 30-70 volatility range",
	-- Spellslinger
	[ProcsHUD.CodeEnumProcSpellId.FlameBurst] = nil,
	[ProcsHUD.CodeEnumProcSpellId.Assassinate] = nil,
	-- Warrior
	[ProcsHUD.CodeEnumProcSpellId.BreachingStrikes] = nil,
	[ProcsHUD.CodeEnumProcSpellId.AtomicSpear] = nil,
	[ProcsHUD.CodeEnumProcSpellId.ShieldBurst] = nil,
	[ProcsHUD.CodeEnumProcSpellId.Rampage] = "Shown when over 250 KE. Useful\nfor the T8 Relentless Strikes",
	[ProcsHUD.CodeEnumProcSpellId.Grapple] = nil,
	-- Stalker
	[ProcsHUD.CodeEnumProcSpellId.Punish] = nil,
	[ProcsHUD.CodeEnumProcSpellId.Decimate] = nil,
	-- Medic
	[ProcsHUD.CodeEnumProcSpellId.Atomize] = nil,
	[ProcsHUD.CodeEnumProcSpellId.DualShock] = nil,
	[ProcsHUD.CodeEnumProcSpellId.Collider] = nil,
	[ProcsHUD.CodeEnumProcSpellId.MagneticLockdown] = nil,
	-- Esper
	[ProcsHUD.CodeEnumProcSpellId.Esper5PP] = "Track when you have 5 Psy Points.",
	[ProcsHUD.CodeEnumProcSpellId.Bolster] = nil,
	[ProcsHUD.CodeEnumProcSpellId.ConcentratedBlade] = nil
}

ProcsHUD.CodeEnumProcSpellSprite = {
	-- Engineer
	[ProcsHUD.CodeEnumProcSpellId.QuickBurst] = "ProcsHUDSprites:icon_QuickBurst",
	[ProcsHUD.CodeEnumProcSpellId.Feedback] = "ProcsHUDSprites:icon_Feedback",
	[ProcsHUD.CodeEnumProcSpellId.BioShell] = "ProcsHUDSprites:icon_BioShell",
	[ProcsHUD.CodeEnumProcSpellId.Ricochet] = "ProcsHUDSprites:icon_Ricochet",
	-- Spellslinger
	[ProcsHUD.CodeEnumProcSpellId.FlameBurst] = "ProcsHUDSprites:icon_FlameBurst",
	[ProcsHUD.CodeEnumProcSpellId.Assassinate] = "ProcsHUDSprites:icon_Assassinate",
	-- Warrior
	[ProcsHUD.CodeEnumProcSpellId.BreachingStrikes] = "ProcsHUDSprites:icon_BreachingStrikes",
	[ProcsHUD.CodeEnumProcSpellId.AtomicSpear] = "ProcsHUDSprites:icon_AtomicSpear",
	[ProcsHUD.CodeEnumProcSpellId.ShieldBurst] = "ProcsHUDSprites:icon_ShieldBurst",
	[ProcsHUD.CodeEnumProcSpellId.Rampage] = "ProcsHUDSprites:icon_Rampage",
	[ProcsHUD.CodeEnumProcSpellId.Grapple] = "ProcsHUDSprites:icon_Grapple",
	-- Stalker
	[ProcsHUD.CodeEnumProcSpellId.Punish] = "ProcsHUDSprites:icon_Punish",
	[ProcsHUD.CodeEnumProcSpellId.Decimate] = "ProcsHUDSprites:icon_Decimate",
	-- Medic
	[ProcsHUD.CodeEnumProcSpellId.Atomize] = "ProcsHUDSprites:icon_Atomize",
	[ProcsHUD.CodeEnumProcSpellId.DualShock] = "ProcsHUDSprites:icon_DualShock",
	[ProcsHUD.CodeEnumProcSpellId.Collider] = "ProcsHUDSprites:icon_Collider",
	[ProcsHUD.CodeEnumProcSpellId.MagneticLockdown] = "ProcsHUDSprites:icon_MagneticLockdown",
	-- Esper
	[ProcsHUD.CodeEnumProcSpellId.Esper5PP] = "ProcsHUDSprites:icon_Esper5PP",
	[ProcsHUD.CodeEnumProcSpellId.Bolster] = "ProcsHUDSprites:icon_Bolster",
	[ProcsHUD.CodeEnumProcSpellId.ConcentratedBlade] = "ProcsHUDSprites:icon_ConcentratedBlade"
}

ProcsHUD.CodeEnumProcSpellBuff = {
	-- Engineer
	[ProcsHUD.CodeEnumProcSpellId.QuickBurst] = nil, -- Impossible to track the buff.
	[ProcsHUD.CodeEnumProcSpellId.Feedback] = {
		[ProcsHUD.CodeEnumLanguage.English] = "Feedback",
		[ProcsHUD.CodeEnumLanguage.French] = "Rétroaction",
		[ProcsHUD.CodeEnumLanguage.German] = "Rückkopplung"
	},
	[ProcsHUD.CodeEnumProcSpellId.BioShell] = nil, -- No buff for this proc.
	[ProcsHUD.CodeEnumProcSpellId.Ricochet] = nil, -- No buff for this proc.
	-- Spellslinger
	[ProcsHUD.CodeEnumProcSpellId.FlameBurst] = nil, -- Impossible to track the buff.
	[ProcsHUD.CodeEnumProcSpellId.Assassinate] = nil, -- No buff for this proc.
	-- Warrior
	[ProcsHUD.CodeEnumProcSpellId.BreachingStrikes] = {
		[ProcsHUD.CodeEnumLanguage.English] = "Breaching Strikes",
		[ProcsHUD.CodeEnumLanguage.French] = "Frappes perforantes",
		[ProcsHUD.CodeEnumLanguage.German] = "Durchbrechende Schläge"
	},
	[ProcsHUD.CodeEnumProcSpellId.AtomicSpear] =  nil,  -- Impossible to use. Other buffs with same name.
	[ProcsHUD.CodeEnumProcSpellId.ShieldBurst] = {
		[ProcsHUD.CodeEnumLanguage.English] = "Shield Burst",
		[ProcsHUD.CodeEnumLanguage.French] = "Décharge de bouclier",
		[ProcsHUD.CodeEnumLanguage.German] = "Schildstoß"
	},
	[ProcsHUD.CodeEnumProcSpellId.Rampage] = nil, -- No buff for this proc.
	[ProcsHUD.CodeEnumProcSpellId.Grapple] = nil, -- No buff for this proc.
	-- Stalker
	[ProcsHUD.CodeEnumProcSpellId.Punish] = {
		[ProcsHUD.CodeEnumLanguage.English] = "Punish",
		[ProcsHUD.CodeEnumLanguage.French] = "Punition",
		[ProcsHUD.CodeEnumLanguage.German] = "Übel zurichten"
	},
	[ProcsHUD.CodeEnumProcSpellId.Decimate] = nil, -- Impossible to use. Other buffs with same name.
	-- Medic
	[ProcsHUD.CodeEnumProcSpellId.Atomize] = {
		[ProcsHUD.CodeEnumLanguage.English] = "Clear!",
		[ProcsHUD.CodeEnumLanguage.French] = "Dégagez !",
		[ProcsHUD.CodeEnumLanguage.German] = "Bereinigen!"
	},
	[ProcsHUD.CodeEnumProcSpellId.DualShock] = {
		[ProcsHUD.CodeEnumLanguage.English] = "Clear!",
		[ProcsHUD.CodeEnumLanguage.French] = "Dégagez !",
		[ProcsHUD.CodeEnumLanguage.German] = "Bereinigen!"
	},
	[ProcsHUD.CodeEnumProcSpellId.MagneticLockdown] = {
		[ProcsHUD.CodeEnumLanguage.English] = "Magnetic Lockdown",
		[ProcsHUD.CodeEnumLanguage.French] = "Verrouillage magnétique",
		[ProcsHUD.CodeEnumLanguage.German] = "Magnetische Sicherung"
	},
	[ProcsHUD.CodeEnumProcSpellId.Collider] = nil, -- No buff for this proc.
	-- Esper
	[ProcsHUD.CodeEnumProcSpellId.Esper5PP] = nil, -- No buff for this proc.
	[ProcsHUD.CodeEnumProcSpellId.Bolster] = nil, -- No buff for this proc.
	[ProcsHUD.CodeEnumProcSpellId.ConcentratedBlade] = nil -- No buff for this proc.
}

ProcsHUD.CodeEnumProcSpellSpecialSetting = {
	-- Engineer
	[ProcsHUD.CodeEnumProcSpellId.QuickBurst] = nil,
	[ProcsHUD.CodeEnumProcSpellId.Feedback] = nil,
	[ProcsHUD.CodeEnumProcSpellId.BioShell] = nil,
	[ProcsHUD.CodeEnumProcSpellId.Ricochet] = nil,
	-- Spellslinger
	[ProcsHUD.CodeEnumProcSpellId.FlameBurst] = nil,
	[ProcsHUD.CodeEnumProcSpellId.Assassinate] = nil,
	-- Warrior
	[ProcsHUD.CodeEnumProcSpellId.BreachingStrikes] = nil,
	[ProcsHUD.CodeEnumProcSpellId.AtomicSpear] = nil,
	[ProcsHUD.CodeEnumProcSpellId.ShieldBurst] = nil,
	[ProcsHUD.CodeEnumProcSpellId.Rampage] = nil,
	[ProcsHUD.CodeEnumProcSpellId.Grapple] = nil,
	-- Stalker
	[ProcsHUD.CodeEnumProcSpellId.Punish] = ProcsHUD.CodeEnumSpecialSettingType.Punish35SuitPower,
	[ProcsHUD.CodeEnumProcSpellId.Decimate] = nil,
	-- Medic
	[ProcsHUD.CodeEnumProcSpellId.Atomize] = nil,
	[ProcsHUD.CodeEnumProcSpellId.DualShock] = nil,
	[ProcsHUD.CodeEnumProcSpellId.Collider] = nil,
	[ProcsHUD.CodeEnumProcSpellId.MagneticLockdown] = nil,
	-- Esper
	[ProcsHUD.CodeEnumProcSpellId.Esper5PP] = nil,
	[ProcsHUD.CodeEnumProcSpellId.Bolster] = nil,
	[ProcsHUD.CodeEnumProcSpellId.ConcentratedBlade] = nil,
}

-- Values are { spellId, procType, minTierNeeded }
ProcsHUD.ProcSpells = {
	[GameLib.CodeEnumClass.Engineer] = {
		{ ProcsHUD.CodeEnumProcSpellId.QuickBurst, ProcsHUD.CodeEnumProcType.CriticalDmg, 0},
		{ ProcsHUD.CodeEnumProcSpellId.Feedback, ProcsHUD.CodeEnumProcType.Deflect, 0 },
		{ ProcsHUD.CodeEnumProcSpellId.BioShell, ProcsHUD.CodeEnumProcType.Engineer3070Resource, 5 },
		{ ProcsHUD.CodeEnumProcSpellId.Ricochet, ProcsHUD.CodeEnumProcType.Engineer3070Resource, 5 }
	},
	[GameLib.CodeEnumClass.Spellslinger] = {
		{ ProcsHUD.CodeEnumProcSpellId.FlameBurst, ProcsHUD.CodeEnumProcType.CriticalDmg, 0 },
		{ ProcsHUD.CodeEnumProcSpellId.Assassinate, ProcsHUD.CodeEnumProcType.HasCharges, 0 }
	},
	[GameLib.CodeEnumClass.Warrior] = {
		{ ProcsHUD.CodeEnumProcSpellId.BreachingStrikes, ProcsHUD.CodeEnumProcType.CriticalDmg, 0 },
		{ ProcsHUD.CodeEnumProcSpellId.AtomicSpear, ProcsHUD.CodeEnumProcType.Deflect, 0 },
		{ ProcsHUD.CodeEnumProcSpellId.ShieldBurst, ProcsHUD.CodeEnumProcType.NoShield, 0 },
		{ ProcsHUD.CodeEnumProcSpellId.Rampage, ProcsHUD.CodeEnumProcType.Warrior250Resource, 0 },
		{ ProcsHUD.CodeEnumProcSpellId.Grapple, ProcsHUD.CodeEnumProcType.HasCharges, 0 }
	},
	[GameLib.CodeEnumClass.Stalker] = {
		{ ProcsHUD.CodeEnumProcSpellId.Punish, ProcsHUD.CodeEnumProcType.CriticalDmg, 0 },
		{ ProcsHUD.CodeEnumProcSpellId.Decimate, ProcsHUD.CodeEnumProcType.Deflect, 0 }
	},
	[GameLib.CodeEnumClass.Medic] = {
		{ ProcsHUD.CodeEnumProcSpellId.Atomize, ProcsHUD.CodeEnumProcType.CriticalDmg, 0 },
		{ ProcsHUD.CodeEnumProcSpellId.DualShock, ProcsHUD.CodeEnumProcType.CriticalDmgOrHeal, 0 },
		{ ProcsHUD.CodeEnumProcSpellId.Collider, ProcsHUD.CodeEnumProcType.HasCharges, 0 },
		{ ProcsHUD.CodeEnumProcSpellId.MagneticLockdown, ProcsHUD.CodeEnumProcType.TakeCriticalDmg, 5 }
	},
	[GameLib.CodeEnumClass.Esper] = {
		{ ProcsHUD.CodeEnumProcSpellId.Esper5PP, ProcsHUD.CodeEnumProcType.Esper5PP, 0 },
		{ ProcsHUD.CodeEnumProcSpellId.Bolster, ProcsHUD.CodeEnumProcType.HasCharges, 0 },
		{ ProcsHUD.CodeEnumProcSpellId.ConcentratedBlade, ProcsHUD.CodeEnumProcType.HasCharges, 0 }
	}
}

ProcsHUD.CodeEnumCooldownLogic = {
	Hide = 1,
	Overlay = 2
}

ProcsHUD.CodeEnumSounds = {
	-1, 126, 127, 128, 141, 145, 196, 197, 198, 203, 207, 208, 212, 216, 220, 222, 223
}

local defaultSettings = {
	cooldownLogic = ProcsHUD.CodeEnumCooldownLogic.Hide,
	activeSpells = {
		-- Engineer
		[ProcsHUD.CodeEnumProcSpellId.QuickBurst] = true,
		[ProcsHUD.CodeEnumProcSpellId.Feedback] = true,
		[ProcsHUD.CodeEnumProcSpellId.BioShell] = true,
		[ProcsHUD.CodeEnumProcSpellId.Ricochet] = true,
		-- Spellslinger
		[ProcsHUD.CodeEnumProcSpellId.FlameBurst] = true,
		[ProcsHUD.CodeEnumProcSpellId.Assassinate] = true,
		-- Warrior
		[ProcsHUD.CodeEnumProcSpellId.BreachingStrikes] = true,
		[ProcsHUD.CodeEnumProcSpellId.AtomicSpear] = true,
		[ProcsHUD.CodeEnumProcSpellId.ShieldBurst] = true,
		[ProcsHUD.CodeEnumProcSpellId.Rampage] = true,
		[ProcsHUD.CodeEnumProcSpellId.Grapple] = true,
		-- Stalker
		[ProcsHUD.CodeEnumProcSpellId.Punish] = true,
		[ProcsHUD.CodeEnumProcSpellId.Decimate] = true,
		-- Medic
		[ProcsHUD.CodeEnumProcSpellId.Atomize] = true,
		[ProcsHUD.CodeEnumProcSpellId.DualShock] = true,
		[ProcsHUD.CodeEnumProcSpellId.Collider] = true,
		[ProcsHUD.CodeEnumProcSpellId.MagneticLockdown] = true,
		-- Esper
		[ProcsHUD.CodeEnumProcSpellId.Esper5PP] = true,
		[ProcsHUD.CodeEnumProcSpellId.Bolster] = true,
		[ProcsHUD.CodeEnumProcSpellId.ConcentratedBlade] = true
	},
	spellSounds = {
		-- Engineer
		[ProcsHUD.CodeEnumProcSpellId.QuickBurst] = -1,
		[ProcsHUD.CodeEnumProcSpellId.Feedback] = -1,
		[ProcsHUD.CodeEnumProcSpellId.BioShell] = -1,
		[ProcsHUD.CodeEnumProcSpellId.Ricochet] = -1,
		-- Spellslinger
		[ProcsHUD.CodeEnumProcSpellId.FlameBurst] = -1,
		[ProcsHUD.CodeEnumProcSpellId.Assassinate] = -1,
		-- Warrior
		[ProcsHUD.CodeEnumProcSpellId.BreachingStrikes] = -1,
		[ProcsHUD.CodeEnumProcSpellId.AtomicSpear] = -1,
		[ProcsHUD.CodeEnumProcSpellId.ShieldBurst] = -1,
		[ProcsHUD.CodeEnumProcSpellId.Rampage] = -1,
		[ProcsHUD.CodeEnumProcSpellId.Grapple] = -1,
		-- Stalker
		[ProcsHUD.CodeEnumProcSpellId.Punish] = -1,
		[ProcsHUD.CodeEnumProcSpellId.Decimate] = -1,
		-- Medic
		[ProcsHUD.CodeEnumProcSpellId.Atomize] = -1,
		[ProcsHUD.CodeEnumProcSpellId.DualShock] = -1,
		[ProcsHUD.CodeEnumProcSpellId.Collider] = -1,
		[ProcsHUD.CodeEnumProcSpellId.MagneticLockdown] = -1,
		-- Esper
		[ProcsHUD.CodeEnumProcSpellId.Esper5PP] = -1,
		[ProcsHUD.CodeEnumProcSpellId.Bolster] = -1,
		[ProcsHUD.CodeEnumProcSpellId.ConcentratedBlade] = -1
	},
	wndProcsPositions = {
		[1] = {250, -37, 324, 37},
		[2] = {330, -37, 404, 37},
		[3] = {250, 43, 324, 117},
		[4] = {330, 43, 404, 117},
		[5] = {410, -37, 484, 37}
	},
	showOnlyInCombat = false,
	showProcFrameBorder = true,
	scale = 1.0,
	specialSettings = {
		[ProcsHUD.CodeEnumSpecialSettingType.Punish35SuitPower] = false
	},
}

-----------------------------------------------------------------------------------------------
-- ProcsHUD Initialization
-----------------------------------------------------------------------------------------------

function ProcsHUD:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    return o
end

function ProcsHUD:InitUserSettings()

end

function ProcsHUD:Init()
	local bHasConfigurateFunction = true
	local strConfigureButtonText = "ProcsHUD"
	local tDependencies = {
		"FoxyLib-1.0"
	}
    Apollo.RegisterAddon(self, bHasConfigurateFunction, strConfigureButtonText, tDependencies)
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
    tSave.activeSpells = foxyLib.DeepCopy(self.userSettings.activeSpells)
    tSave.spellSounds = foxyLib.DeepCopy(self.userSettings.spellSounds)
    tSave.wndProcsPositions = foxyLib.DeepCopy(self.userSettings.wndProcsPositions)
    tSave.showOnlyInCombat = self.userSettings.showOnlyInCombat
    tSave.showProcFrameBorder = self.userSettings.showProcFrameBorder
    tSave.scale = self.userSettings.scale
    tSave.specialSettings = foxyLib.DeepCopy(self.userSettings.specialSettings)

	return tSave
end

function ProcsHUD:OnRestore(eType, tSave)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return
	end

	self.userSettings.cooldownLogic = tSave.cooldownLogic

	self.userSettings.activeSpells = foxyLib.DeepCopy(tSave.activeSpells)
	if tSave.spellSounds then
		self.userSettings.spellSounds = foxyLib.DeepCopy(tSave.spellSounds)
	else
		self.userSettings.spellSounds = foxyLib.DeepCopy(defaultSettings.spellSounds)
	end
	-- Make sure the newly added spells are managed too.
	for _, spellId in pairs(ProcsHUD.CodeEnumProcSpellId) do
		if self.userSettings.activeSpells[spellId] == nil then
			self.userSettings.activeSpells[spellId] = defaultSettings.activeSpells[spellId]
		end
		if not self.userSettings.spellSounds[spellId] then
			self.userSettings.spellSounds[spellId] = defaultSettings.spellSounds[spellId]
		end
	end

	if tSave.wndProcsPositions then
		self.userSettings.wndProcsPositions = foxyLib.DeepCopy(tSave.wndProcsPositions)
		if #self.userSettings.wndProcsPositions == 3 then
			-- We need to add the 4th procs position
			self.userSettings.wndProcsPositions[4] = foxyLib.DeepCopy(defaultSettings.wndProcsPositions[4])
		end
		if #self.userSettings.wndProcsPositions == 4 then
			-- We need to add the 5th procs position
			self.userSettings.wndProcsPositions[5] = foxyLib.DeepCopy(defaultSettings.wndProcsPositions[5])
		end
	else
		self.userSettings.wndProcsPositions = foxyLib.DeepCopy(defaultSettings.wndProcsPositions)
	end

	if tSave.showOnlyInCombat ~= nil then
		self.userSettings.showOnlyInCombat = tSave.showOnlyInCombat
	else
		self.userSettings.showOnlyInCombat = defaultSettings.showOnlyInCombat
	end

	if tSave.showProcFrameBorder ~= nil then
		self.userSettings.showProcFrameBorder = tSave.showProcFrameBorder
	else
		self.userSettings.showProcFrameBorder = defaultSettings.showProcFrameBorder
	end

	if tSave.scale ~= nil then
		self.userSettings.scale = tSave.scale
	else
		self.userSettings.scale = defaultSettings.scale
	end

	if tSave.specialSettings then
		self.userSettings.specialSettings = foxyLib.DeepCopy(tSave.specialSettings)
		for _, specialSettingType in pairs(ProcsHUD.CodeEnumSpecialSettingType) do
			if self.userSettings.specialSettings[specialSettingType] == nil then
				self.userSettings.specialSettings[specialSettingType] = foxyLib.DeepCopy(defaultSettings.specialSettings[specialSettingType])
			end
		end
	else
		self.userSettings.specialSettings = foxyLib.DeepCopy(defaultSettings.specialSettings)
	end


	-- Data saved in future versions must be lazy restored (if present (~= nil), grab from tSave else
	-- grab from defaultSettings).

	self.onRestoreCalled = true
	self:SetupWndProcs()
end


-----------------------------------------------------------------------------------------------
-- ProcsHUD OnLoad
-----------------------------------------------------------------------------------------------

function ProcsHUD:OnLoad()
	foxyLib = Apollo.GetPackage("FoxyLib-1.0").tPackage

	-- Initialize the fields
	self.lastCriticalDmgTime = 0
	self.lastCriticalHealTime = 0
	self.lastDeflectTime = 0

	self.lastCooldownLeft = 0

	self.tActiveAbilities = {}
	self.tActiveAbilitiesCurrentTier = {}
	self.tSpellCache = {}
	self.tLastSoundTimestamp = {}

	self.bUnlockFrames = false
	self.userSettings = foxyLib.DeepCopy(defaultSettings)

	self.onRestoreCalled = false
	self.onXmlDocLoadedCalled = false

	self.locale = foxyLib.GetLocale();

	-- Create the form
	self.xmlDoc = XmlDoc.CreateFromFile("ProcsHUD.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)

	Apollo.RegisterEventHandler("AbilityBookChange", "OnAbilityBookChange", self)
	Apollo.RegisterEventHandler("CombatLogDamage", "OnCombatLogDamage", self)
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

		-- Create the Settings spell windows array and the array for the spell settings (Punish Suit Power for example)
		self.tWndSettingsSpells = {}
		self.tWndSettingsSpellSettings = {}

		-- Load the proc frame windows
		self.tWndProcs = {}
		for i = 1, NB_PROC_WINDOWS do
			self.tWndProcs[i] = Apollo.LoadForm(self.xmlDoc, "ProcsIcon", nil, self)
		end
		for i, wndProc in pairs(self.tWndProcs) do
			if not wndProc then
				Apollo.AddAddonErrorText(self, "Could not load the proc frame windows for some reason.")
				return
			end
			wndProc:Show(false)
			wndProc:FindChild("Cooldown"):Show(false)
		end

		-- Load the spell sprites
		Apollo.LoadSprites("Icons.xml", "ProcsHUDSprites")

		-- Register handlers for events, slash commands and timer, etc.
		Apollo.RegisterSlashCommand("procshud", "ShowSettingsUI", self)
		Apollo.RegisterSlashCommand("ProcsHud", "ShowSettingsUI", self)
		Apollo.RegisterSlashCommand("ProcsHUD", "ShowSettingsUI", self)

		self.onXmlDocLoadedCalled = true
		self:SetupWndProcs()
	end
end


-----------------------------------------------------------------------------------------------
-- Ability detection
-----------------------------------------------------------------------------------------------

function ProcsHUD:SetupWndProcs()
	if not self.onRestoreCalled or not self.onXmlDocLoadedCalled then
		return
	end

	-- Settings are restored and the windows are loaded. Let's position the views
	for index, wndProc in pairs(self.tWndProcs) do
		local anchors = self.userSettings.wndProcsPositions[index]
		wndProc:SetAnchorOffsets(anchors[1], anchors[2],
			anchors[1] + PROC_WINDOW_SIZE * self.userSettings.scale,
			anchors[2] + PROC_WINDOW_SIZE * self.userSettings.scale)
		wndProc:SetStyle("Picture", self.userSettings.showProcFrameBorder)
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

    -- Reset the tActivityAbility table
    for spellId, value in pairs(self.tActiveAbilities) do
		self.tActiveAbilities[spellId] = false
		self.tActiveAbilitiesCurrentTier[spellId] = nil
    end
	for _, spell in pairs(tSpells) do
		self:CheckAbility(currentActionSet, spell[1], spell[3])
	end
end

function ProcsHUD:CheckAbility(currentActionSet, spellId, minTierNeeded)
	if spellId < 0 then
		-- Special case for the custom abilities (Esper 5 PP for example)
		self.tActiveAbilities[spellId] = true
		self.tActiveAbilitiesCurrentTier[spellId] = -1
		return
	end

    if not currentActionSet then
        return
    end

    for _, nAbilityId in pairs(currentActionSet) do
        if nAbilityId == spellId then
			local currentTier = self:GetCurrentTier(spellId)
			if currentTier and currentTier >= minTierNeeded then
				self.tActiveAbilities[spellId] = true
				self.tActiveAbilitiesCurrentTier[spellId] = currentTier
			end
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

	if self.userSettings.showOnlyInCombat and not unitPlayer:IsInCombat() then
		-- We want to show only in combat and we are not in combat.
		self:HideAllProcWindows()
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

	-- Manage the procs
	self:ProcessProcs(unitPlayer, tSpells)
end

function ProcsHUD:HideAllProcWindows()
	-- Hide the remaining proc windows. Every index above nbProcs are unused windows
	for index, wndProc in pairs(self.tWndProcs) do
		wndProc:Show(false)
	end
end


-----------------------------------------------------------------------------------------------
-- Procs display management
-----------------------------------------------------------------------------------------------

function ProcsHUD:ProcessProcs(unitPlayer, tSpells)
	if unitPlayer and tSpells then
		for i, spell in pairs(tSpells) do
			self:ProcessProcsForSpell(unitPlayer, i, spell)
		end
	end
end

function ProcsHUD:ProcessProcsForSpell(unitPlayer, wndProcIndex, spell)
	local spellId = spell[1]
	local procType = spell[2]

	local wndProc = self.tWndProcs[wndProcIndex]
	if not wndProc then
		-- We don't have a valid window to display the proc. This should normally never happen.
		Print("We don't have a window to display the proc. Something went really wrong")
		return
	end

	-- Let's check if the user didn't deactivate the spell in the options
	if not self.userSettings.activeSpells[spellId] then
		-- The spell is deactivated in the options. Hide the proc window and return.
		wndProc:Show(false)
		return wndProcIndex
	end

	-- Let's test if you have the spell
	if not self.tActiveAbilities[spellId] then
		-- You don't have the spell in your LAS. Hide the proc window and return.
		wndProc:Show(false)
		return wndProcIndex
	end

	-- Let's check if the spell is not in cooldown
	local cooldownLeft, cooldownTotalDuration, chargesLeft = self:GetSpellCooldown(spellId)
	local numChargesLeft = tonumber(chargesLeft)
	if numChargesLeft then -- it's a valid number
		chargesLeft = numChargesLeft
	end
	if self.userSettings.cooldownLogic == ProcsHUD.CodeEnumCooldownLogic.Hide then
		if cooldownLeft > 0 and chargesLeft == 0 then
			-- The spell is in cooldown and we don't have any charge left (for a spell with charges).
			-- Hide the proc window and return.
			wndProc:Show(false)
			return wndProcIndex
		end
	end

	local shouldShowProc = false
	local tBuffName = ProcsHUD.CodeEnumProcSpellBuff[spellId]
	local buffTrackingDone = false
	if tBuffName ~= nil then
		local buffName = tBuffName[self.locale]
		if buffName ~= nil then
			buffTrackingDone = true
			local tBuffs = unitPlayer:GetBuffs().arBeneficial
			for _, buff in pairs(tBuffs) do
				if buff.splEffect:GetName() == buffName then
					shouldShowProc = true;
					break
				end
			end
			-- If we have found the buff, no need to check the debuffs
			if not shouldShowProc then
				local tBuffs = unitPlayer:GetBuffs().arHarmful
				for _, buff in pairs(tBuffs) do
					if buff.splEffect:GetName() == buffName then
						shouldShowProc = true;
						break
					end
				end
			end
		end
	end

	-- We didn't use the buff tracking. So let's use the old method.
	if not buffTrackingDone then
		if procType == ProcsHUD.CodeEnumProcType.CriticalDmg then -- Let's check if we scored a critical
			shouldShowProc = os.difftime(os.time(), self.lastCriticalDmgTime) < CRITICAL_TIME
		elseif procType == ProcsHUD.CodeEnumProcType.CriticalDmgOrHeal then -- Let's check if we did a critical heal
			local lastCritDmgDelta = os.difftime(os.time(), self.lastCriticalDmgTime)
			local lastCritHealDelta = os.difftime(os.time(), self.lastCriticalHealTime)
			shouldShowProc = lastCritDmgDelta < CRITICAL_TIME or lastCritHealDelta < CRITICAL_TIME
		elseif procType == ProcsHUD.CodeEnumProcType.Deflect then -- Let's check if we deflected a hit
			shouldShowProc = os.difftime(os.time(), self.lastDeflectTime) < DEFLECT_TIME
		elseif procType == ProcsHUD.CodeEnumProcType.NoShield then -- Let's check if we are at 0 shield
			shouldShowProc = foxyLib.NullToZero(unitPlayer:GetShieldCapacity()) == 0
		elseif procType == ProcsHUD.CodeEnumProcType.Engineer3070Resource then -- Let's check if we are in the 30-70 range
			local volatility = foxyLib.NullToZero(unitPlayer:GetResource(1))
			shouldShowProc = volatility >= 30 and volatility <= 70
		elseif procType == ProcsHUD.CodeEnumProcType.Esper5PP then -- Let's check if we have 5 Psy Points
			local psyPoints = foxyLib.NullToZero(unitPlayer:GetResource(1))
			shouldShowProc = psyPoints == 5
		elseif procType == ProcsHUD.CodeEnumProcType.Warrior250Resource then -- Let's check if we have more than 250 KE
			local kineticEnergy = foxyLib.NullToZero(unitPlayer:GetResource(1))
			shouldShowProc = kineticEnergy >= 250
		elseif procType == ProcsHUD.CodeEnumProcType.HasCharges then -- We always show it if we have charges
			shouldShowProc = true
		end
	end

	-- Manage some special settings
	local specialSettingType = ProcsHUD.CodeEnumProcSpellSpecialSetting[spellId]
	if specialSettingType and specialSettingType == ProcsHUD.CodeEnumSpecialSettingType.Punish35SuitPower then
		if self.userSettings.specialSettings[specialSettingType] then -- We show the proc only if we have less than 35 suit power if the user has T8 punish
			local suitPower = foxyLib.NullToZero(unitPlayer:GetResource(3))
			shouldShowProc = shouldShowProc and (suitPower < 35 or self.tActiveAbilitiesCurrentTier[spellId] < 9)
		end
	end

	-- Let's see if we need to show the proc
	if shouldShowProc then
		-- Update the sprite in the proc view
		local sprite = ProcsHUD.CodeEnumProcSpellSprite[spellId]
		wndProc:FindChild("Icon"):SetSprite(sprite)

		-- Show the cooldown if on overlay mode
		local wndProcCooldown = wndProc:FindChild("Cooldown")
		if self.userSettings.cooldownLogic == ProcsHUD.CodeEnumCooldownLogic.Overlay then
			wndProcCooldown:Show(true)
			if cooldownLeft > 0 then
				local cooldownText = ""
				if cooldownLeft > 3600 then
					cooldownText = math.floor(cooldownLeft / 3600) .. "h"
				elseif cooldownLeft > 60 then
					cooldownText = math.floor(cooldownLeft / 60) .. "m"
				elseif cooldownLeft > 10 then
					cooldownText = math.floor(cooldownLeft) .. "s"
				else
					cooldownText = self:FormatFloat(cooldownLeft, 1) .. "s"
				end
				wndProcCooldown:SetText(cooldownText)
			else
				wndProcCooldown:SetText("")
			end
		else
			wndProcCooldown:Show(false)
		end

		if procType == ProcsHUD.CodeEnumProcType.HasCharges and chargesLeft > 0 then
			wndProcCooldown:Show(true)
			wndProcCooldown:SetText(chargesLeft)
		end

		-- Play the sound if we should and we have a valid one
		local spellSound = self.userSettings.spellSounds[spellId]
		if spellSound ~= -1 then
			if cooldownLeft == 0 then
				-- We are in hide mode, so we play the sound only if the wndProc was hidden before.
				if self.userSettings.cooldownLogic == ProcsHUD.CodeEnumCooldownLogic.Hide then
					if not wndProc:IsVisible() then
						self:PlaySound(spellSound, spellId)
					end
				-- We are in Overlay mode, so we play the sound only if the spell was on cooldown before.
				elseif self.userSettings.cooldownLogic == ProcsHUD.CodeEnumCooldownLogic.Overlay then
					if self.lastCooldownLeft > 0 then
						self:PlaySound(spellSound, spellId)
					end
				end
			end
		end
		self.lastCooldownLeft = cooldownLeft

		-- Show the proc view
		wndProc:Show(true)

		-- Increment the wndProcIndex as we have shown a window
		wndProcIndex = wndProcIndex + 1
	else
		wndProc:Show(false)
	end
end

function ProcsHUD:PlaySound(spellSound, spellId)
	local lastSpell = self.tLastSoundTimestamp[spellId]
	if os.difftime(os.time(), lastSpell) > 0.5 then
		self.tLastSoundTimestamp[spellId] = os.time()
		Sound.Play(spellSound)
	end
end


-----------------------------------------------------------------------------------------------
-- Critical detection
-----------------------------------------------------------------------------------------------

function ProcsHUD:OnCombatLogDamage(tData)
	if tData.unitCaster ~= nil and tData.unitCaster == GameLib.GetPlayerUnit() then
		if not tData.bPeriodic and tData.eCombatResult == GameLib.CodeEnumCombatResult.Critical then
			if tData.eDamageType == GameLib.CodeEnumDamageType.Heal or tData.eDamageType == GameLib.CodeEnumDamageType.HealShields then
				self.lastCriticalHealTime = os.time()
			else
				self.lastCriticalDmgTime = os.time()
			end
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
			return charges.fRechargePercentRemaining * charges.fRechargeTime, charges.fRechargeTime, charges.nChargesRemaining
		else
			return 0, 0, charges.nChargesRemaining
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
	if spellId < 0 then
		return nil
	end

	-- Let's check the cache first
	splObject = self.tSpellCache[spellId]
	if splObject then
		return splObject
	end

	local abilities = AbilityBook.GetAbilitiesList()
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

function ProcsHUD:GetCurrentTier(spellId)
	local abilities = AbilityBook.GetAbilitiesList()
	if not abilities then
		return
	end

	for _, v in pairs(abilities) do
		if v.nId == spellId then
			return v.nCurrentTier
		end
	end
end

function ProcsHUD:FormatFloat(float, precision)
	local num = math.floor(float)
	return num .. "." .. math.floor((float - num) * math.pow(10, precision))
end

-----------------------------------------------------------------------------------------------
-- Addon cleanup
-----------------------------------------------------------------------------------------------

function ProcsHUD:FinishAddon()
	if self.wndSettings then
		self.wndSettings:Destroy()
	end

	if self.tWndProcs then
		for _, wndProc in pairs(self.tWndProcs) do
			wndProc:Destroy()
		end
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

function ProcsHUD:OnConfigure()
	self:ShowSettingsUI()
end

function ProcsHUD:ShowSettingsUI()
	local unitPlayer = GameLib.GetPlayerUnit()
	if not unitPlayer then
		-- We don't have the player object yet.
		return
	end

	-- Spells management settings
	local tSpells = ProcsHUD.ProcSpells[unitPlayer:GetClassId()]
	if not tSpells then
		-- Not a class that we manage in this addon. Should never happen as we manage all 6 classes.
		return
	end

	self:SetupSettingsUI(tSpells)

	self.wndSettings:Show(true)
	self.wndSettings:ToFront()
end

function ProcsHUD:SetupSettingsUI(tSpells)
	-- Frames setting
	self.wndSettings:FindChild("ButtonUnlockFrames"):SetCheck(self.bUnlockFrames)
	self.wndSettings:FindChild("ButtonShowProcFrameBorder"):SetCheck(self.userSettings.showProcFrameBorder)

	self.wndSettings:FindChild("ScaleSlider"):SetValue(self.userSettings.scale * 100)
	self.wndSettings:FindChild("ScaleValue"):SetText(self:FormatFloat(self.userSettings.scale, 2))

	-- Cooldown management settings
	if self.userSettings.cooldownLogic == ProcsHUD.CodeEnumCooldownLogic.Hide then
		self.wndSettings:FindChild("ButtonCooldownHideFrame"):SetCheck(true)
	elseif self.userSettings.cooldownLogic == ProcsHUD.CodeEnumCooldownLogic.Overlay then
		self.wndSettings:FindChild("ButtonCooldownOverlay"):SetCheck(true)
	end

	-- Spells management settings
	local wndSettingsBackground = self.wndSettings:FindChild("SettingsBackground")
	local numSpellSetting = 0
	for i, spell in pairs(tSpells) do
		local spellId = spell[1]

		local wndSpell = self.tWndSettingsSpells[i]
		if not wndSpell then
			wndSpell = Apollo.LoadForm(self.xmlDoc, "ProcsSettingsWndSpell", wndSettingsBackground, self)
			local left, top, right, bottom = wndSpell:GetAnchorOffsets()
			local offset = SETTINGS_SPELL_ROW_HEIGHT * (i - 1) + SETTINGS_SPELL_SPECIAL_SETTING_ROW_HEIGHT * numSpellSetting
			wndSpell:SetAnchorOffsets(left, SETTINGS_SPELL_ROW_TOP + offset,
				right, SETTINGS_SPELL_ROW_BOTTOM + offset)
			self.tWndSettingsSpells[i] = wndSpell
		end

		-- Is active
		local wndButtonSpell = wndSpell:FindChild("ButtonSpell")
		wndButtonSpell:SetCheck(self.userSettings.activeSpells[spellId])
		wndButtonSpell:SetData(spellId)

		-- Spell icon + tooltip
		local spellSprite = ProcsHUD.CodeEnumProcSpellSprite[spellId]
		local wndSpellIcon = wndSpell:FindChild("SpellIcon")
		wndSpellIcon:SetSprite(spellSprite)
		local spellObject = self:GetSpellById(spellId)
		if spellObject and Tooltip and Tooltip.GetSpellTooltipForm then
			wndSpellIcon:SetTooltipDoc(nil)
			Tooltip.GetSpellTooltipForm(self, wndSpellIcon, spellObject)
		end

		-- Spell name
		local spellName = ProcsHUD.CodeEnumProcSpellName[spellId]
		local spellTooltip = ProcsHUD.CodeEnumProcSpellTooltip[spellId]
		local wndSpellName = wndSpell:FindChild("SpellName")
		wndSpellName:SetText(spellName)
		if spellTooltip then
			wndSpellName:SetTooltip(spellTooltip)
		end

		-- Spell sound
		local spellSoundComboBox = wndSpell:FindChild("SpellSound")
		spellSoundComboBox:DeleteAll()
		for _, resource in pairs(ProcsHUD.CodeEnumSounds) do
			if resource ~= -1 then
				spellSoundComboBox:AddItem(resource)
			else
				spellSoundComboBox:AddItem("None")
			end
		end
		local selectedSound = self.userSettings.spellSounds[spellId]
		if selectedSound == -1 then
			selectedSound = "None"
		end
		spellSoundComboBox:SelectItemByText(selectedSound)
		spellSoundComboBox:SetData(spellId)

		local wndSpellSoundPlay = wndSpell:FindChild("SpellSoundPlay")
		wndSpellSoundPlay:SetData(spellId)

		-- specialSetting management.
		local specialSetting = ProcsHUD.CodeEnumProcSpellSpecialSetting[spellId]
		if specialSetting then
			local wndSpecialSetting = self.tWndSettingsSpellSettings[i]
			if not wndSpecialSetting then
				wndSpecialSetting = Apollo.LoadForm(self.xmlDoc, ProcsHUD.CodeEnumSpecialSettingWnd[specialSetting],
					wndSettingsBackground, self)
				local left, top, right, bottom = wndSpecialSetting:GetAnchorOffsets()
				local offset = SETTINGS_SPELL_ROW_HEIGHT * i + SETTINGS_SPELL_SPECIAL_SETTING_ROW_HEIGHT * numSpellSetting
				wndSpecialSetting:SetAnchorOffsets(left, SETTINGS_SPELL_SPECIAL_SETTING_ROW_TOP + offset,
					right, SETTINGS_SPELL_SPECIAL_SETTING_ROW_BOTTOM + offset)
				self.tWndSettingsSpellSettings[i] = wndSpecialSetting
				numSpellSetting = numSpellSetting + 1
			end

			-- Let's load the setting per spell
			if specialSetting == ProcsHUD.CodeEnumSpecialSettingType.Punish35SuitPower then
				local wndCheckBox = wndSpecialSetting:FindChild("CheckBox")
				wndCheckBox:SetCheck(self.userSettings.specialSettings[ProcsHUD.CodeEnumSpecialSettingType.Punish35SuitPower])
			end
		end
	end

	-- wndSettings height management
	local left, top, right, bottom = self.wndSettings:GetAnchorOffsets()
	self.wndSettings:SetAnchorOffsets(left, top, right, SETTINGS_FRAME_HEIGHT + SETTINGS_SPELL_ROW_HEIGHT * #tSpells + SETTINGS_SPELL_SPECIAL_SETTING_ROW_HEIGHT * numSpellSetting)
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
	local unitPlayer = GameLib.GetPlayerUnit()
	if not unitPlayer then
		-- We don't have the player object yet.
		return
	end

	-- Spells management settings
	local tSpells = ProcsHUD.ProcSpells[unitPlayer:GetClassId()]
	if not tSpells then
		-- Not a class that we manage in this addon. Impossible normally as we already
		-- check for it before.
		return
	end

	if self.bUnlockFrames then
		-- Make all the proc windows visible, show the 1/2/3 and make them movable
		for index, wndProc in pairs(self.tWndProcs) do
			if index <= #tSpells then -- No reason to show a wndProc which we will not use
				local spellId = tSpells[index][1]
				local spellSprite = ProcsHUD.CodeEnumProcSpellSprite[spellId]
				wndProc:FindChild("Icon"):SetSprite(spellSprite)
				wndProc:FindChild("Cooldown"):Show(false)
				wndProc:Show(true)
				wndProc:SetStyle("IgnoreMouse", false)
				wndProc:SetStyle("Moveable", true)
				if self.userSettings.activeSpells[spellId] then
					wndProc:SetOpacity(1)
				else
					wndProc:SetOpacity(0.3)
				end
			end
		end
	else
		-- Make all procs windows hidden (they will be made visible by the next "on frame"
		-- if needed), hide the 1/2/3 and make them not movable
		for index, wndProc in pairs(self.tWndProcs) do
			wndProc:FindChild("Cooldown"):Show(true)
			wndProc:FindChild("Cooldown"):SetText("")
			wndProc:Show(false)
			wndProc:SetStyle("IgnoreMouse", true)
			wndProc:SetStyle("Moveable", false)
			wndProc:SetOpacity(1)

			-- We also save the new positions to the user settings
			local left, top, right, bottom = wndProc:GetAnchorOffsets()
			self.userSettings.wndProcsPositions[index] = { left, top, right, bottom }
		end
		self:SetupWndProcs()
	end
end

function ProcsHUD:SettingsOnRestorePositions(wndHandler, wndControl, eMouseButton)
	self.userSettings.wndProcsPositions = foxyLib.DeepCopy(defaultSettings.wndProcsPositions)
	self:SetupWndProcs()
end

function ProcsHUD:SettingsOnProcFrameBorderToggle(wndHandler, wndControl, eMouseButton)
	self.userSettings.showProcFrameBorder = self.wndSettings:FindChild("ButtonShowProcFrameBorder"):IsChecked()

	-- The frames are currently visible. So let's save their new position in the case where the user moved them.
	-- Otherwise SetupWndProcs would make them jump back into place.
	if self.bUnlockFrames then
		self:SaveProcFramePosition()
	end
	self:SetupWndProcs()
end

function ProcsHUD:SettingsOnInCombatToggle(wndHandler, wndControl, eMouseButton)
	self.userSettings.showOnlyInCombat = self.wndSettings:FindChild("ButtonOnlyInCombat"):IsChecked()
end

function ProcsHUD:SettingsOnScaleSliderChanged( wndHandler, wndControl, fNewValue, fOldValue )
	self:SaveProcFramePosition()
	local scale = fNewValue / 100
	self.userSettings.scale = scale
	self.wndSettings:FindChild("ScaleValue"):SetText(self:FormatFloat(scale, 2))
	self:SetupWndProcs()
end

function ProcsHUD:SaveProcFramePosition()
	for index, wndProc in pairs(self.tWndProcs) do
		-- We also save the new positions to the user settings
		local left, top, right, bottom = wndProc:GetAnchorOffsets()
		self.userSettings.wndProcsPositions[index] = { left, top, right, bottom }
	end
end

function ProcsHUD:SettingsOnCooldownToggle(wndHandler, wndControl, eMouseButton)
	if self.wndSettings:FindChild("ButtonCooldownHideFrame"):IsChecked() then
		self.userSettings.cooldownLogic = ProcsHUD.CodeEnumCooldownLogic.Hide
	elseif self.wndSettings:FindChild("ButtonCooldownOverlay"):IsChecked() then
		self.userSettings.cooldownLogic = ProcsHUD.CodeEnumCooldownLogic.Overlay
	end
end

function ProcsHUD:SettingsOnSpellToggle(wndHandler, wndControl, eMouseButton)
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

	local spellId = wndControl:GetData()
	self.userSettings.activeSpells[spellId] = wndControl:IsChecked()

	self:UnlockFrames()
end

function ProcsHUD:SettingsOnSpellSoundChanged(wndHandler, wndControl)
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

	local selectedSound = wndControl:GetSelectedText()
	if selectedSound == "None" then
		selectedSound = -1
	end

	local spellId = wndControl:GetData()
	self.userSettings.spellSounds[spellId] = selectedSound
end

function ProcsHUD:SettingsOnSpellSoundPlay(wndHandler, wndControl, eMouseButton)
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

	local spellId = wndControl:GetData()
	local spellSound = self.userSettings.spellSounds[spellId]
	if spellSound ~= -1 then
		Sound.Play(spellSound)
	end
end

function ProcsHUD:SettingsOnPunishToggle(wndHandler, wndControl, eMouseButton)
	local unitPlayer = GameLib.GetPlayerUnit()
	if not unitPlayer then
		-- We don't have the player object yet.
		return
	end

	self.userSettings.specialSettings[ProcsHUD.CodeEnumSpecialSettingType.Punish35SuitPower] = wndControl:IsChecked()
end


-----------------------------------------------------------------------------------------------
-- ProcsHUD Instance
-----------------------------------------------------------------------------------------------
local ProcsHUDInst = ProcsHUD:new()
ProcsHUDInst:Init()