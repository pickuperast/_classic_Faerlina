local mod	= DBM:NewMod("Taerar", "DBM-Azeroth")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20190519034518")
mod:SetCreatureID(14890)--121911 TW ID, 14890 classic ID
--mod:SetModelID(17887)
mod:SetZone()

mod:RegisterCombat("combat_yell", L.Pull)


mod:RegisterEventsInCombat(
--	"SPELL_CAST_START 243661 243401",
	"SPELL_CAST_SUCCESS 24814 24813"
--	"SPELL_AURA_APPLIED 243401",
--	"SPELL_AURA_APPLIED_DOSE 243401"
)

--TODO, maybe taunt special warnings for classic version when it matters more.
--TODO, needs valid spellIds for classic
--local warnNoxiousBreath			= mod:NewStackAnnounce(243401, 2, nil, "Tank")
--local warningBellowingRoar		= mod:NewSpellAnnounce(243661, 3)

local specWarnSleepingFog		= mod:NewSpecialWarningDodge(24814, nil, nil, nil, 2, 2)

--local timerNoxiousBreathCD		= mod:NewCDTimer(19.4, 243401, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON)--Iffy
local timerSleepingFogCD		= mod:NewCDTimer(21.9, 24814, nil, nil, nil, 3)
--local timerBellowingRoarCD		= mod:NewCDTimer(7.2, 243661, nil, nil, nil, 2)

--mod:AddReadyCheckOption(48620, false)

function mod:OnCombatStart(delay, yellTriggered)
	if yellTriggered then
		--timerBellowingRoarCD:Start(10.5-delay)
		--timerNoxiousBreathCD:Start(14.3-delay)
		timerSleepingFogCD:Start(21.5-delay)
	end
end

--[[
function mod:SPELL_CAST_START(args)
	if args.spellId == 243661 and self:AntiSpam(3, 1) then
		warningBellowingRoar:Show()
		timerBellowingRoarCD:Start()
	elseif args.spellId == 243401 and self:AntiSpam(3, 2) then
		timerNoxiousBreathCD:Start()
	end
end
--]]

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 24814 or args.spellId == 24813 then
		specWarnSleepingFog:Show()
		specWarnSleepingFog:Play("watchstep")
		timerSleepingFogCD:Start()
	end
end

--[[
function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 243401 then
		local uId = DBM:GetRaidUnitId(args.destName)
		if self:IsTanking(uId) then
			local amount = args.amount or 1
			warnNoxiousBreath:Show(args.destName, amount)
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
--]]
