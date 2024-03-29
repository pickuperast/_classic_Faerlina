local mod	= DBM:NewMod("Vaelastrasz", "DBM-BWL", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20190516161007")
mod:SetCreatureID(13020)
mod:SetEncounterID(611)
mod:SetModelID(13992)
mod:RegisterCombat("combat")

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 23461",
	"SPELL_AURA_APPLIED 18173",
	"SPELL_AURA_REMOVED 18173"
)

local warnBreath			= mod:NewCastAnnounce(23461, 2, nil, nil, "Tank", 2)
local warnAdrenaline		= mod:NewTargetAnnounce(18173, 2)

local specWarnAdrenaline	= mod:NewSpecialWarningYou(18173, nil, nil, nil, 1, 2)
local yellAdrenaline		= mod:NewYell(18173)

local timerAdrenaline		= mod:NewTargetTimer(20, 18173, nil, nil, nil, 3)
local timerCombatStart		= mod:NewCombatTimer(43)

function mod:SPELL_CAST_START(args)
	if args.spellId == 23461 then
		warnBreath:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 18173 then
		timerAdrenaline:Start(args.destName)
		if args:IsPlayer() then
			specWarnAdrenaline:Show()
			specWarnAdrenaline:Play("targetyou")
			yellAdrenaline:Yell()
		else
			warnAdrenaline:Show(args.destName)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 18173 then
		timerAdrenaline:Stop(args.destName)
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.Event or msg:find(L.Event) then
		timerCombatStart:Start()
	end
end
