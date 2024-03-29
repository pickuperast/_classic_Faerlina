﻿local mod = DBM:NewMod("Thekal", "DBM-ZG", 1)
local L = mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))

mod:SetCreatureID(14509, 11348, 11347)
mod:SetEncounterID(789)
mod:SetBossHPInfoToHighest()
mod:RegisterCombat("combat")
mod:RegisterKill("yell", L.YellKill)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 24208",
	"SPELL_AURA_APPLIED 21060 12540",
	"SPELL_AURA_REMOVED 21060 12540",
	"SPELL_SUMMON 24813",
	"CHAT_MSG_MONSTER_EMOTE",
	"CHAT_MSG_MONSTER_YELL"
)

local warnSimulKill		= mod:NewAnnounce("WarnSimulKill", 1, 24173)
local warnBlind			= mod:NewTargetAnnounce(21060, 2)
local warnGouge			= mod:NewTargetAnnounce(12540, 2)
local warnPhase2		= mod:NewPhaseAnnounce(2)
local warnAdds			= mod:NewSpellAnnounce(24183, 3)

local specWarnHeal		= mod:NewSpecialWarningInterrupt(24208, "HasInterrupt", nil, nil, 1, 2)

local timerSimulKill	= mod:NewTimer(15, "TimerSimulKill", 24173)
local timerHeal			= mod:NewCastTimer(4, 24208, nil, nil, nil, 4, nil, DBM_CORE_INTERRUPT_ICON)
local timerBlind		= mod:NewTargetTimer(10, 21060, nil, nil, nil, 3)
local timerGouge		= mod:NewTargetTimer(4, 12540, nil, nil, nil, 3)

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(24208) then
		timerHeal:Start()
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHeal:Show(args.sourceName)
			specWarnHeal:Play("kickcast")
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(21060) then     --Blind Daze
		warnBlind:Show(args.destName)
		timerBlind:Start(args.destName)
	elseif args:IsSpellID(12540) and self:IsInCombat() then --Gouge Stun
		warnGouge:Show(args.destName)
		timerGouge:Start(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(21060) then
		timerBlind:Cancel(args.destName)
    elseif args:IsSpellID(12540) then
        timerGouge:Cancel(args.destName)
	end
end

function mod:SPELL_SUMMON(args)
	if args:IsSpellID(24813) then
		warnAdds:Show()
	end
end

local killTime = 0
function mod:CHAT_MSG_MONSTER_EMOTE(msg)
	if msg == L.PriestDied then		-- Starts timer before ressurection of adds.
		self:SendSync("PriestDied")
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellPhase2 then		-- Bossfight (tank and spank)
		self:SendSync("YellPhase2")
	end
end

function mod:OnSync(msg, arg)
	if msg == "PriestDied" then
		if (GetTime() - killTime) > 20 then
			warnSimulKill:Show()
			timerSimulKill:Start()
			killTime = GetTime()
		end
	elseif msg == "YellPhase2" then
		warnPhase2:Show()
		timerSimulKill:Stop()
	end
end
