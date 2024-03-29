local mod	= DBM:NewMod("Skeram", "DBM-AQ40", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20190518070653")
mod:SetCreatureID(15263)
mod:SetEncounterID(709)
mod:SetModelID(15345)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 785",
	"SPELL_AURA_REMOVED 785",
	"SPELL_CAST_SUCCESS 20449 4801 8195",
	"SPELL_SUMMON 747",
	"UNIT_HEALTH boss1"
)

--TODO, special warning optimizing?
local warnMindControl	= mod:NewTargetNoFilterAnnounce(785, 4)
local warnTeleport		= mod:NewSpellAnnounce(20449, 3)
local warnSummon		= mod:NewSpellAnnounce(747, 3)
local warnSummonSoon	= mod:NewSoonAnnounce(747, 2)

local timerMindControl	= mod:NewBuffActiveTimer(20, 785, nil, nil, nil, 3)

mod:AddBoolOption("SetIconOnMC", true)

local MCTargets = {}
mod.vb.splitCount = 0
mod.vb.MCIcon = 8

function mod:OnCombatStart(delay)
	self.vb.splitCount = 0
	table.wipe(MCTargets)
	self.vb.MCIcon = 8
end

local function warnMCTargets(self)
	warnMindControl:Show(table.concat(MCTargets, "<, >"))
	timerMindControl:Start()
	table.wipe(MCTargets)
	self.vb.MCIcon = 8
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 785 then
		MCTargets[#MCTargets + 1] = args.destName
		self:Unschedule(warnMCTargets)
		if #MCTargets >= 3 then
			warnMCTargets(self)
		else
			self:Schedule(0.5, warnMCTargets, self)
		end
		if self.Options.SetIconOnMC then
			self:SetIcon(args.destName, self.vb.MCIcon)
		end
		self.vb.MCIcon = self.vb.MCIcon - 1
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if self.Options.SetIconOnMC and args.spellId == 785 then
		self:SetIcon(args.destName, 0)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(20449, 4801, 8195) and self:AntiSpam() then
		warnTeleport:Show()
	end
end

function mod:SPELL_SUMMON(args)
	if args.spellId == 747 then
		warnSummon:Show()
	end
end

function mod:UNIT_HEALTH(uId)
	if self:GetUnitCreatureId(uId) == 15263 then
		local percent = UnitHealth(uId) / UnitHealthMax(uId) * 100
		if percent <= 81 and percent >= 77 and self.vb.splitCount < 1 then
			warnSummonSoon:Show()
			self.vb.splitCount = 1
		elseif percent <= 56 and percent >= 52 and self.vb.splitCount < 2 then
			warnSummonSoon:Show()
			self.vb.splitCount = 2
		elseif percent <= 31 and percent >= 27 and self.vb.splitCount < 3 then
			warnSummonSoon:Show()
			self.vb.splitCount = 3
		end
	end
end
