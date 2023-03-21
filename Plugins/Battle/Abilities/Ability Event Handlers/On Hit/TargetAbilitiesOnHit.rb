#########################################
# Weather Abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:SANDBURST,
    proc { |_ability, _user, target, _move, battle, aiChecking, aiNumHits|
        next pbBattleWeatherAbility(:Sandstorm, target, battle, false, true, aiChecking)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:INNERLIGHT,
    proc { |_ability, _user, target, _move, battle, aiChecking, aiNumHits|
        next pbBattleWeatherAbility(:Sun, target, battle, false, true, aiChecking)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:STORMBRINGER,
    proc { |_ability, _user, target, _move, battle, aiChecking, aiNumHits|
        next pbBattleWeatherAbility(:Rain, target, battle, false, true, aiChecking)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:FROSTSCATTER,
    proc { |_ability, _user, target, _move, battle, aiChecking, aiNumHits|
        next pbBattleWeatherAbility(:Hail, target, battle, false, true, aiChecking)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:SUNEATER,
    proc { |_ability, _user, battltargeter, _move, battle, aiChecking, aiNumHits|
        next pbBattleWeatherAbility(:Eclipse, target, battle, false, true, aiChecking)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:LUNARLOYALTY,
    proc { |_ability, _user, target, _move, battle, aiChecking, aiNumHits|
        next pbBattleWeatherAbility(:Moonglow, target, battle, false, true, aiChecking)
    }
)

#########################################
# Stat change abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:GOOEY,
  proc { |_ability, user, target, move, _battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret += getMultiStatDownEffectScore([:SPEED,1], target, user, i)
            end
            next ret
        end
        user.tryLowerStat(:SPEED, target, showAbilitySplash: true)
  }
)

BattleHandlers::TargetAbilityOnHit.copy(:GOOEY, :TANGLINGHAIR)

BattleHandlers::TargetAbilityOnHit.add(:COTTONDOWN,
    proc { |_ability, _user, target, _move, battle, aiChecking, aiNumHits|
        battle.pbShowAbilitySplash(target)
        target.eachOpposing do |b|
            b.tryLowerStat(:SPEED, target)
        end
        target.eachAlly do |b|
            b.tryLowerStat(:SPEED, target)
        end
        battle.pbHideAbilitySplash(target)
    }
  )

BattleHandlers::TargetAbilityOnHit.add(:RATTLED,
  proc { |_ability, user, target, move, _battle, aiChecking, aiNumHits|
        next unless %i[BUG DARK GHOST].include?(move.calcType)
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret += getMultiStatUpEffectScore([:SPEED,1], user, target, i)
            end
            next ret
        end
        target.tryRaiseStat(:SPEED, target, showAbilitySplash: true)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:STAMINA,
  proc { |_ability, user, target, _move, _battle, aiChecking, aiNumHits|
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret += getMultiStatUpEffectScore([:DEFENSE,1], user, target, i)
            end
            next ret
        end
        target.tryRaiseStat(:DEFENSE, target, showAbilitySplash: true)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:GRIT,
    proc { |_ability, _user, target, _move, _battle, aiChecking, aiNumHits|
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret += getMultiStatUpEffectScore([:SPECIAL_DEFENSE,1], user, target, i)
            end
            next ret
        end
        target.tryRaiseStat(:SPECIAL_DEFENSE, target, showAbilitySplash: true)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:ADAPTIVESKIN,
    proc { |_ability, _user, target, move, _battle, aiChecking, aiNumHits|
        statToRaise = nil
        if move.physicalMove?
            statToRaise = :DEFENSE
        else
            statToRaise = :SPECIAL_DEFENSE
        end
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret += getMultiStatUpEffectScore([statToRaise,1], user, target, i)
            end
            next ret
        end
        target.tryRaiseStat(statToRaise, target, showAbilitySplash: true)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:WEAKARMOR,
  proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        if aiChecking
            ret = getMultiStatDownEffectScore([:DEFENSE, 1], user, target)
            ret += getMultiStatUpEffectScore([:SPEED, 2], user, target)
            next ret
        else
            battle.pbShowAbilitySplash(target)
            target.tryLowerStat(:DEFENSE, target)
            target.tryRaiseStat(:SPEED, target, increment: 2)
            battle.pbHideAbilitySplash(target)
        end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WEAKSPIRIT,
    proc { |_ability, _user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        if aiChecking
            ret = getMultiStatDownEffectScore([:SPECIAL_DEFENSE, 1], user, target)
            ret += getMultiStatUpEffectScore([:SPEED, 2], user, target)
            next ret
        else
            battle.pbShowAbilitySplash(target)
            target.tryLowerStat(:SPECIAL_DEFENSE, target)
            target.tryRaiseStat(:SPEED, target, increment: 2)
            battle.pbHideAbilitySplash(target)
        end
    }
)

BattleHandlers::TargetAbilityOnHit.add(:STEAMENGINE,
    proc { |_ability, _user, target, move, _battle, aiChecking, aiNumHits|
        next if move.calcType != :FIRE && move.calcType != :WATER
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret += getMultiStatUpEffectScore([:SPEED,6], user, target, i*6)
            end
            next ret
        end
        target.tryRaiseStat(:SPEED, target, increment: 6, showAbilitySplash: true)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:FORCEREVERSAL,
    proc { |_ability, _user, target, _move, _battle, aiChecking, aiNumHits|
        next unless Effectiveness.resistant?(target.damageState.typeMod)
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret += getMultiStatUpEffectScore([:ATTACK, 1, :SPECIAL_ATTACK, 1], user, target, i)
            end
            next ret
        end
        target.pbRaiseMultipleStatStages([:ATTACK, 1, :SPECIAL_ATTACK, 1], target, showAbilitySplash: true)
    }
)

#########################################
# Damaging abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:IRONBARBS,
  proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
      next unless move.physicalMove?
      next -5 * aiNumHits if aiChecking && user.takesIndirectDamage?
      battle.pbShowAbilitySplash(target)
      if user.takesIndirectDamage?(true)
          battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
          user.applyFractionalDamage(1.0 / 8.0)
      end
      battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.copy(:IRONBARBS, :ROUGHSKIN)

BattleHandlers::TargetAbilityOnHit.add(:FEEDBACK,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?(user)
        next -5 * aiNumHits if aiChecking && user.takesIndirectDamage?
        battle.pbShowAbilitySplash(target)
        if user.takesIndirectDamage?(true)
            battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
            user.applyFractionalDamage(1.0 / 8.0)
        end
        battle.pbHideAbilitySplash(target)
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:ARCCONDUCTOR,
    proc { |_ability, user, target, _move, battle, aiChecking, aiNumHits|
        next unless battle.rainy?
        next -5 * aiNumHits if aiChecking && user.takesIndirectDamage?
        battle.pbShowAbilitySplash(target)
        if user.takesIndirectDamage?(true)
            battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
            user.applyFractionalDamage(1.0 / 6.0)
        end
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:SPINTENSITY,
    proc { |_ability, user, target, _move, battle, aiChecking, aiNumHits|
        next unless target.stages[:SPEED] > 0
        next -5 * target.stages[:SPEED] if aiChecking && user.takesIndirectDamage?
        battle.pbShowAbilitySplash(target)
        battle.pbDisplay(_INTL("#{user.pbThis} catches the full force of #{target.pbThis(true)}'s Speed!"))
        oldStage = target.stages[:SPEED]
        user.applyFractionalDamage(oldStage / 6.0)
        battle.pbCommonAnimation("StatDown", target)
        target.stages[:SPEED] = 0
        battle.pbHideAbilitySplash(target)
    }
)

#########################################
# Move usage abilities
#########################################

# TODO: AI checks from this point forward

BattleHandlers::TargetAbilityOnHit.add(:RELUCTANTBLADE,
  proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if target.fainted?
        battle.forceUseMove(target, :LEAFAGE, user.index, true, nil, nil, true)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WIBBLEWOBBLE,
  proc { |_ability, user, target, _move, battle, aiChecking, aiNumHits|
        next if target.fainted?
        battle.forceUseMove(target, :POWERSPLIT, user.index, true, nil, nil, true)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CONSTRICTOR,
  proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if target.fainted?
        battle.forceUseMove(target, :BIND, user.index, true, nil, nil, true)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:TOTALMIRROR,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        next if target.fainted?
        battle.forceUseMove(target, move.id, user.index, true, nil, nil, true)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:ABOVEITALL,
  proc { |_ability, user, target, _move, battle, aiChecking, aiNumHits|
        next if target.fainted?
        battle.forceUseMove(target, :PARTINGSHOT, user.index, true, nil, nil, true)
  }
)

#########################################
# Status inducing abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:STATIC,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if user.numbed? || battle.pbRandom(100) >= 30
        battle.pbShowAbilitySplash(target)
        user.applyNumb(target) if user.canNumb?(target, true)
        battle.pbHideAbilitySplash(target)
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:LIVEWIRE,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        next if user.numbed? || battle.pbRandom(100) >= 30
        battle.pbShowAbilitySplash(target)
        user.applyNumb(target) if user.canNumb?(target, true)
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:PETRIFYING,
    proc { |_ability, user, target, _move, battle, aiChecking, aiNumHits|
        next if user.numbed? || battle.pbRandom(100) >= 30
        battle.pbShowAbilitySplash(target)
        user.applyNumb(target) if user.canNumb?(target, true)
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:POISONPOINT,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if user.poisoned? || battle.pbRandom(100) >= 30
        battle.pbShowAbilitySplash(target)
        user.applyPoison(target) if user.canPoison?(target, true)
        battle.pbHideAbilitySplash(target)
    }
  )

BattleHandlers::TargetAbilityOnHit.add(:POISONPUNISH,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        next if battle.pbRandom(100) >= 30
        next if user.poisoned?
        battle.pbShowAbilitySplash(target)
        user.applyPoison(target) if user.canPoison?(target, true)
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:SUDDENCHILL,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        next if battle.pbRandom(100) >= 30
        next if user.frostbitten?
        battle.pbShowAbilitySplash(target)
        user.applyFrostbite(target) if user.canFrostbite?(target, true)
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:CHILLEDBODY,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if battle.pbRandom(100) >= 30
        next if user.frostbitten?
        battle.pbShowAbilitySplash(target)
        user.applyFrostbite(target) if user.canFrostbite?(target, true)
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:BEGUILING,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next if target.fainted?
        next if move.physicalMove?
        next if battle.pbRandom(100) >= 30
        next if user.dizzy?
        battle.pbShowAbilitySplash(target)
        user.applyDizzy(target) if user.canDizzy?(target, true)
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:DISORIENT,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next if target.fainted?
        next unless move.physicalMove?
        next if battle.pbRandom(100) >= 30
        next if user.dizzy?
        battle.pbShowAbilitySplash(target)
        user.applyDizzy(target) if user.canDizzy?(target, true)
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:KELPLINK,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if user.leeched? || battle.pbRandom(100) >= 30
        battle.pbShowAbilitySplash(target)
        user.applyLeeched(target) if user.canLeech?(target, true)
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:PLAYVICTIM,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        next if user.leeched? || battle.pbRandom(100) >= 30
        battle.pbShowAbilitySplash(target)
        user.applyLeeched(target) if user.canLeech?(target, true)
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:FLAMEBODY,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if user.burned? || battle.pbRandom(100) >= 30
        battle.pbShowAbilitySplash(target)
        user.applyBurn(target) if user.canBurn?(target, true)
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:FIERYSPIRIT,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        next if user.burned? || battle.pbRandom(100) >= 30
        battle.pbShowAbilitySplash(target)
        user.applyBurn(target) if user.canBurn?(target, true)
        battle.pbHideAbilitySplash(target)
    }
)

#########################################
# Other punishment random triggers
#########################################

BattleHandlers::TargetAbilityOnHit.add(:CURSEDTAIL,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if user.effectActive?(:Curse) || battle.pbRandom(100) >= 30
        battle.pbShowAbilitySplash(target)
        user.applyEffect(:Curse)
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:SEALINGBODY,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next if user.fainted? || user.effectActive?(:Disable) 
        battle.pbShowAbilitySplash(target)
        user.applyEffect(:Disable, 3) if user.canBeDisabled?
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:PERISHBODY,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if user.effectActive?(:PerishSong)
        battle.pbShowAbilitySplash(target)
        battle.pbDisplay(_INTL("Both Pokémon will faint in three turns!"))
        user.applyEffect(:PerishSong, 3)
        target.applyEffect(:PerishSong, 3) unless target.effectActive?(:PerishSong)
        battle.pbHideAbilitySplash(target)
    }
)

#########################################
# Other abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:INNARDSOUT,
    proc { |_ability, user, target, _move, battle, aiChecking, aiNumHits|
            next unless target.fainted? || user.dummy
            if aiChecking
                if user.takesIndirectDamage?
                    next target.aboveHalfHealth? ? 50 : 25
                else
                    next 0
                end
            end
            battle.pbShowAbilitySplash(target)
            if user.takesIndirectDamage?(true)
                battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
                oldHP = user.hp
                damageTaken = target.damageState.hpLost
                damageTaken /= 4 if target.boss?
                user.damageState.displayedDamage = damageTaken
                battle.scene.pbDamageAnimation(user)
                user.pbReduceHP(damageTaken, false)
                user.pbHealthLossChecks(oldHP)
            end
            battle.pbHideAbilitySplash(target)
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:MUMMY,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if user.fainted?
        next if user.unstoppableAbility? || user.ability == ability
        battle.pbShowAbilitySplash(target) if user.opposes?(target)
        oldAbil = user.ability
        battle.pbShowAbilitySplash(user, true, false) if user.opposes?(target)
        user.ability = ability
        battle.pbReplaceAbilitySplash(user) if user.opposes?(target)
        battle.pbDisplay(_INTL("{1}'s Ability became {2}!", user.pbThis, user.abilityName))
        battle.pbHideAbilitySplash(user) if user.opposes?(target)
        battle.pbHideAbilitySplash(target) if user.opposes?(target)
        user.pbOnAbilityChanged(oldAbil) unless oldAbil.nil?
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:INFECTED,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if user.fainted?
        next if user.unstoppableAbility? || user.ability == ability
        next unless user.canChangeType?
        battle.pbShowAbilitySplash(target) if user.opposes?(target)
        oldAbil = user.ability
        battle.pbShowAbilitySplash(user, true, false) if user.opposes?(target)
        user.ability = ability
        battle.pbReplaceAbilitySplash(user) if user.opposes?(target)
        battle.pbDisplay(_INTL("{1}'s Ability became {2}!", user.pbThis, user.abilityName))
        user.applyEffect(:Type3,:GRASS) unless user.pbHasType?(:GRASS)
        battle.pbHideAbilitySplash(user) if user.opposes?(target)
        battle.pbHideAbilitySplash(target) if user.opposes?(target)
        user.pbOnAbilityChanged(oldAbil) unless oldAbil.nil?
    }
)

BattleHandlers::TargetAbilityOnHit.add(:THUNDERSTRUCK,
    proc { |_ability, _user, target, _move, battle, aiChecking, aiNumHits|
        if aiChecking
            return target.pbHasAttackingType?(:ELECTRIC) ? -40 : 0
        else
            target.applyEffect(:Charge,2)
        end
    }
)

BattleHandlers::TargetAbilityOnHit.add(:GULPMISSILE,
    proc { |_ability, user, target, _move, battle, aiChecking, aiNumHits|
        next if target.form == 0
        if target.species == :CRAMORANT
            battle.pbShowAbilitySplash(target)
            gulpform = target.form
            target.form = 0
            battle.scene.pbChangePokemon(target, target.pokemon)
            battle.scene.pbDamageAnimation(user)
            user.applyFractionalDamage(1.0 / 4.0) if user.takesIndirectDamage?(true)
            if gulpform == 1
                user.tryLowerStat(:DEFENSE, target, showAbilitySplash: true)
            elsif gulpform == 2
                msg = nil
                user.applyNumb(target, msg)
            end
            battle.pbHideAbilitySplash(target)
        end
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:ILLUSION,
    proc { |_ability, _user, target, _move, battle, aiChecking, aiNumHits|
        next 10 if aiChecking
        # NOTE: This intentionally doesn't show the ability splash.
        next unless target.illusion?
        target.disableEffect(:Illusion)
        battle.scene.pbChangePokemon(target, target.pokemon)
        battle.pbSetSeen(target)
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:WANDERINGSPIRIT,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if user.fainted?
        abilityBlacklist = [
            :DISGUISE,
            :FLOWERGIFT,
            :GULPMISSILE,
            :ICEFACE,
            :IMPOSTER,
            :RECEIVER,
            :RKSSYSTEM,
            :SCHOOLING,
            :STANCECHANGE,
            :WONDERGUARD,
            :ZENMODE,
            # Abilities that are plain old blocked.
            :NEUTRALIZINGGAS,
        ]
        failed = false
        abilityBlacklist.each do |abil|
            next if user.ability != abil
            failed = true
            break
        end
        next if failed
        oldAbil = -1
        battle.pbShowAbilitySplash(target) if user.opposes?(target)
        oldAbil = user.ability
        battle.pbShowAbilitySplash(user, true, false) if user.opposes?(target)
        user.ability = :WANDERINGSPIRIT
        target.ability = oldAbil
        if user.opposes?(target)
            battle.pbReplaceAbilitySplash(user)
            battle.pbReplaceAbilitySplash(target)
        end
        battle.pbDisplay(_INTL("{1}'s Ability became {2}!", user.pbThis, user.abilityName))
        battle.pbHideAbilitySplash(user)
        battle.pbHideAbilitySplash(target) if user.opposes?(target)
        if oldAbil
            user.pbOnAbilityChanged(oldAbil)
            target.pbOnAbilityChanged(:WANDERINGSPIRIT)
        end
    }
)

BattleHandlers::TargetAbilityOnHit.add(:ROCKCYCLE,
    proc { |_ability, target, battler, move, battle, aiChecking, aiNumHits|
        target.pbOwnSide.incrementEffect(:ErodedRock) if move.physicalMove?
    }
)

BattleHandlers::TargetAbilityOnHit.add(:QUILLERINSTINCT,
    proc { |_ability, _user, target, _move, battle, aiChecking, aiNumHits|
        next if target.pbOpposingSide.effectAtMax?(:Spikes)
        battle.pbShowAbilitySplash(target)
        target.pbOpposingSide.incrementEffect(:Spikes)
        battle.pbHideAbilitySplash(target)
    }
)

# Only does stuff for the AI
BattleHandlers::TargetAbilityOnHit.add(:MULTISCALE,
    proc { |_ability, user, target, move, _battle, aiChecking, aiNumHits|
        if aiChecking && target.hp == target.totalhp
            return 20
        end
    }
)