module BattleHandlers
	AbilityOnEnemySwitchIn              = AbilityHandlerHash.new
	MoveImmunityAllyAbility           	= AbilityHandlerHash.new

	def self.triggerAbilityOnEnemySwitchIn(ability,switcher,bearer,battle)
		AbilityOnEnemySwitchIn.trigger(ability,switcher,bearer,battle)
	end
	
	def self.triggerAbilityOnSwitchOut(ability,battler,endOfBattle,battle)
		AbilityOnSwitchOut.trigger(ability,battler,endOfBattle,battle)
    end
	
	def self.triggerMoveImmunityAllyAbility(ability,user,target,move,type,battle,ally)
		ret = MoveImmunityAllyAbility.trigger(ability,user,target,move,type,battle,ally)
		return (ret!=nil) ? ret : false
	end
end

#===============================================================================
# StatLossImmunityAbility handlers
#===============================================================================
BattleHandlers::StatLossImmunityAbility.copy(:CLEARBODY,:WHITESMOKE,:STUBBORN)

#===============================================================================
# UserAbilityEndOfMove handlers
#===============================================================================
BattleHandlers::UserAbilityEndOfMove.add(:DEEPSTING,
  proc { |ability,user,targets,move,battle|
    next if !user.takesIndirectDamage?
    
    totalDamageDealt = 0
    targets.each do |target|
      next if target.damageState.unaffected
      totalDamageDealt = target.damageState.totalHPLost
    end
    next if totalDamageDealt <= 0
    amt = (totalDamageDealt/4.0).round
    amt = 1 if amt<1
    user.pbReduceHP(amt,false)
    battle.pbDisplay(_INTL("{1} is damaged by recoil!",user.pbThis))
    user.pbItemHPHealCheck
	user.pbFaint if user.fainted?
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:HUBRIS,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0 || !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user)
    user.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,numFainted,user)
  }
)

BattleHandlers::UserAbilityEndOfMove.copy(:MOXIE,:CHILLINGNEIGH)

BattleHandlers::UserAbilityEndOfMove.copy(:HUBRIS,:GRIMNEIGH)


#===============================================================================
# AbilityOnEnemySwitchIn handlers
#===============================================================================

BattleHandlers::AbilityOnEnemySwitchIn.add(:DETERRANT,
  proc { |ability,switcher,bearer,battle|
    PBDebug.log("[Ability triggered] #{bearer.pbThis}'s #{bearer.abilityName}")
    battle.pbShowAbilitySplash(bearer)
    if switcher.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       switcher.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(user)
      user.pbReduceHP(user.totalhp/8,false)
      battle.pbDisplay(_INTL("{1} was attacked on sight!",user.pbThis))
    end
    battle.pbHideAbilitySplash(bearer)
  }
)

#===============================================================================
# AccuracyCalcUserAbility handlers
#===============================================================================

BattleHandlers::AccuracyCalcUserAbility.add(:SANDSNIPER,
  proc { |ability,mods,user,target,move,type|
    mods[:base_accuracy] = 0 if user.battle.pbWeather == :Sandstorm
  }
)

#===============================================================================
# CriticalCalcUserAbility handlers
#===============================================================================
BattleHandlers::CriticalCalcUserAbility.add(:STAMPEDE,
  proc { |ability,user,target,c|
    next c+user.stages[:SPEED]
  }
)

#===============================================================================
# EOREffectAbility handlers
#===============================================================================
BattleHandlers::EOREffectAbility.add(:ASTRALBODY,
  proc { |ability,battler,battle|
	next unless battle.field.terrain==:Misty
    next if !battler.canHeal?
	battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/16)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# MoveBlockingAbility handlers
#===============================================================================
BattleHandlers::MoveBlockingAbility.add(:KILLJOY,
  proc { |ability,bearer,user,targets,move,battle|
    next move.danceMove?
  }
)

BattleHandlers::MoveBlockingAbility.add(:BADINFLUENCE,
  proc { |ability,bearer,user,targets,move,battle|
    next move.healingMove?
  }
)

#===============================================================================
# AccuracyCalcTargetAbility handlers
#===============================================================================
BattleHandlers::AccuracyCalcUserAllyAbility.add(:OCULAR,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] *= 1.25
  }
)

#===============================================================================
#other handlers
#==============================================================================
BattleHandlers::TargetAbilityAfterMoveUse.add(:ADRENALINERUSH,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if target.damageState.initialHP<target.totalhp/2 || target.hp>=target.totalhp/2
	target.pbRaiseStatStageByAbility(:SPEED,2,target) if target.pbCanRaiseStatStage?(:SPEED,target)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:SCHADENFREUDE,
  proc { |ability,battler,targets,move,battle|
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0 || !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/4)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:HEATSAVOR,
  proc { |ability,weather,battler,battle|
    next unless [:Sun, :HarshSun].include?(weather)
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/16)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:POSITIVEOUTLOOK,
  proc { |ability,user,target,move,mults,baseDmg,type|
			mults[:base_damage_multiplier] *= 1.50 	if user.pbHasType?(:ELECTRIC) && move.specialMove?
  }
)

BattleHandlers::DamageCalcTargetAllyAbility.add(:NEGATIVEOUTLOOK,
  proc { |ability,user,target,move,mults,baseDmg,type|
	mults[:final_damage_multiplier] *= (2.0/3.0) if target.pbHasType?(:ELECTRIC) && move.specialMove?
	 }
)

BattleHandlers::MoveImmunityAllyAbility.add(:GARGANTUAN,
  proc { |ability,user,target,move,type,battle,ally|
	condition = false
	condition = user.index!=target.index && move.pbTarget(user).num_targets >1
    next false if !condition
	battle.pbShowAbilitySplash(ally)
	battle.pbDisplay(_INTL("{1} was shielded from {2} by {3}'s huge size!",target.pbThis,move.name,ally.pbThis(false)))
	battle.pbHideAbilitySplash(ally)
	next true
  }
)

BattleHandlers::CriticalCalcTargetAbility.copy(:BATTLEARMOR,:IMPERVIOUS)

BattleHandlers::StatLossImmunityAbility.add(:IMPERVIOUS,
  proc { |ability,battler,stat,battle,showMessages|
    next false if stat!=:DEFENSE && stat!=:SPECIAL_DEFENSE
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",battler.pbThis,GameData::Stat.get(stat).name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",battler.pbThis,
           battler.abilityName,GameData::Stat.get(stat).name))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:HARSH,
  proc { |ability,user,target,c|
    next 99 if target.burned?
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:FROSTSONG,
  proc { |ability,user,move,type|
    next unless move.soundMove?
    next unless GameData::Type.exists?(:ICE)
    move.powerBoost = true
    next :ICE
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:GILD,
  proc { |ability,user,targets,move,battle|
    next if battle.futureSight
    next if !move.pbDamagingMove?
    next if battle.wildBattle? && user.opposes?
    targets.each do |b|
      next if b.damageState.unaffected || b.damageState.substitute
      next if !b.item
      next if b.unlosableItem?(b.item) || user.unlosableItem?(b.item)
      battle.pbShowAbilitySplash(user)
      if b.hasActiveAbility?(:STICKYHOLD)
        battle.pbShowAbilitySplash(b) if user.opposes?(b)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1}'s item cannot be gilded!",b.pbThis))
        end
        battle.pbHideAbilitySplash(b) if user.opposes?(b)
        next
      end
      itemName = target.itemName
      target.pbRemoveItem(false)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} turned {2}'s {3} into gold!",user.pbThis,
           b.pbThis(true),itemName))
      else
        battle.pbDisplay(_INTL("{1} turned {2}'s {3} into gold with {4}!",user.pbThis,
           b.pbThis(true),itemName,user.abilityName))
      end
      if user.pbOwnedByPlayer?
        battle.field.effects[PBEffects::PayDay] += 5*user.level
      end
      battle.pbDisplay(_INTL("Coins were scattered everywhere!"))
      battle.pbHideAbilitySplash(user)
      break
    end
  }
)