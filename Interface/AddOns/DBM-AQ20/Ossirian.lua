local mod	= DBM:NewMod("Ossirian", "DBM-AQ20", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20190518070653")
mod:SetCreatureID(15339)
mod:SetEncounterID(723)
mod:SetModelID(15432)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 25176 25189 25177 25178 25180 25181 25183",
	"SPELL_AURA_REMOVED 25189"
)

local warnSupreme		= mod:NewSpellAnnounce(25176, 3)
local warnCyclone		= mod:NewTargetNoFilterAnnounce(25189, 4)
local warnVulnerable	= mod:NewAnnounce("WarnVulnerable", 3, "Interface\\Icons\\INV_Enchant_EssenceMagicLarge")

local timerCyclone		= mod:NewTargetTimer(10, 25189, nil, nil, nil, 3)
local timerVulnerable	= mod:NewTimer(45, "TimerVulnerable", "Interface\\Icons\\INV_Enchant_EssenceMagicLarge", nil, nil, 6)

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 25176 then
		warnSupreme:Show()
	elseif args.spellId == 25189 then
		warnCyclone:Show(args.destName)
		timerCyclone:Start(args.destName)
	elseif args:IsSpellID(25177, 25178, 25180, 25181, 25183) then
		warnVulnerable:Show(args.spellName)
		timerVulnerable:Show(args.spellName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 25189 then
		timerCyclone:Stop(args.destName)
	end
end
