#===============================================================================
# User heals for 1/4ths of their HP and removes hazards from its field. (One With The Earth) (not functional)
#===============================================================================
class PokeBattle_Move_HealUserOneQuartersRemoveHazards < PokeBattle_HealingMove

    def healRatio(_user)
        return 1.0 / 4.0
    end
 
    def pbEffectGeneral(user)
        user.pbOwnSide.eachEffect(true) do |effect, _value, data|
            next unless data.is_hazard?
            user.pbOwnSide.disableEffect(effect)
        end
    end

    def getEffectScore(user, _target)
        score = super
        score += hazardWeightOnSide(user.pbOwnSide) if user.alliesInReserve?
        return score
    end
end

#===============================================================================
# Heals user to full HP. User falls asleep for 2 more rounds, lowers both defenses 4 steps if it misses. (Explosive Nap)
#===============================================================================
class PokeBattle_Move_HealUserFullyAndFallAsleepDownDefenses4IfMisses < PokeBattle_HealingMove
    def healRatio(_user); return 1.0; end

    def pbMoveFailed?(user, targets, show_message)
        if user.asleep?
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already asleep!")) if show_message
            return true
        end
        return true unless user.canSleep?(user, show_message, self, true)
        return true if super
        return false
    end

    def pbMoveFailedAI?(user, targets)
        return true if user.willStayAsleepAI?
        return true unless user.canSleep?(user, false, self, true)
        return true if super
        return false
    end

    def pbEffectGeneral(user)
        user.applySleepSelf(_INTL("{1} slept and became healthy!", user.pbThis), 3)
        super
    end

    def getEffectScore(user, target)
        score = super
        score -= getSleepEffectScore(nil, target) * 0.45
        score += 45 if user.hasStatusNoSleep?
        return score
    end

    def pbCrashDamage(user)
        return unless user.pbLowerMultipleStatSteps([:DEFENSE, 4, :SPECIAL_DEFENSE, 4], user, move: self)
        @battle.pbDisplay(_INTL("{1} is left vulnerable!", user.pbThis))
    end
end

#===============================================================================
# Fails if target acted, boosts special attack (Cold Melody)
#===============================================================================
class PokeBattle_Move_FailsIfTargetActedUpsSpecialAttack < PokeBattle_StatUpMove
    def pbFailsAgainstTarget?(_user, target, show_message)
        if @battle.choices[target.index][0] != :UseMove
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} didn't choose to attack!")) if show_message
            return true
        end
        oppMove = @battle.choices[target.index][2]
        if !oppMove ||
           (oppMove.function != "UseMoveTargetIsAboutToUse" && # Me First
           (target.movedThisRound? || oppMove.statusMove?))
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} already moved this turn!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTargetAI?(user, target)
        if user.ownersPolicies.include?(:PREDICTS_PLAYER)
            return !@battle.aiPredictsAttack?(user,target.index)
        else
            return true unless target.hasDamagingAttack?
            return true if hasBeenUsed?(user)
            return false
        end
    end

    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 1]
    end

    def getEffectScore(user, target)
        return -10
    end

    def shouldShade?(user, target); return false; end
end

#===============================================================================
# Doubles power in Magnet Rise, also removes it. (Zap Crescent)
#===============================================================================
class PokeBattle_Move_DoublesPowerRemovesMagnetRise < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, target)
        baseDmg *= 2 if user.effectActive?(:MagnetRise)
        return baseDmg
    end

    def pbEffectGeneral(user)
        user.disableEffect(:MagnetRise)
    end
end

#===============================================================================
# Power increases by 30 for each consecutive use. (Drag Race)
#===============================================================================
class PokeBattle_Move_DragRace < PokeBattle_SnowballingMove
    def initialize(battle, move)
        @usageCountEffect = :DragRace
        super
    end

    def damageAtCount(baseDmg, count)
        return baseDmg + 30 * count
    end
end

#===============================================================================
# Increases the user's Defense and Sp. Defense by 2 step eachs.
# In sunny weather, increases are 4 steps each instead. (Photovoltaic Guard)
#===============================================================================
class PokeBattle_Move_RaiseUserDefSpDef2Or4InSun < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = DEFENDING_STATS_2
    end

    def pbOnStartUse(_user, _targets)
        if @battle.sunny?
            @statUp = [:DEFENSE, 4, :SPECIAL_DEFENSE, 4]
        else
            @statUp = DEFENDING_STATS_2
        end
    end

    def shouldHighlight?(_user, _target)
        return @battle.sunny?
    end
end

#===============================================================================
# Two turn attack. Can be used in one turn with half its power (Atomic Breath)
#===============================================================================
class PokeBattle_Move_TwoTurnAttackCanChooseOne < PokeBattle_TwoTurnMove

    def resolutionChoice(user)
        @choices = [_INTL("Charge"),_INTL("Attack")]
        @choice = @battle.scene.pbShowCommands(_INTL("Should #{user.pbThis(true)} charge the attack?"),@choices,0)
    end 

    def pbChargingTurnMessage(user, _targets)        
        @battle.pbDisplay(_INTL("{1} charges power!",user.pbThis))
    end

    
    def skipChargingTurn?(user)
        return @choice == 1
    end

    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 0.5 if @choice == 1
        return baseDmg
    end

    def resetMoveUsageState
        @choice = nil
    end 

    def getEffectScore(_user, _target)
        return 100
    end 
end 

#===============================================================================
# Boosts by 50% if there is sun. (Hydro Steam)
#===============================================================================
class PokeBattle_Move_BoostInSun < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, target)
        baseDmg *= 1.5 if battle.sunny?
        return baseDmg
    end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# attacks with the user with a physical attack while this effect applies, that Pokémon is
# burned. (Burning Balwark)
#===============================================================================
class PokeBattle_Move_ProtectUserBurnPhysAttacker < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :BurningBalwark
    end

    def getEffectScore(user, target)
        score = super
        # Check only physical attackers
        user.eachPredictedProtectHitter(0) do |b|
            score += getBurnEffectScore(user, b)
        end
        return score
    end
end

#===============================================================================
# Boosts by 50% if there is moonglow. (Psyblade)
#===============================================================================
class PokeBattle_Move_BoostInMoonglow < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, target)
        baseDmg *= 1.5 if battle.moonGlowing?
        return baseDmg
    end
end

#===============================================================================
# Clears hazards and rooms. (Mighty Cleave?)
#===============================================================================
class PokeBattle_Move_RemovesHazardsWeatherRooms < PokeBattle_Move
    def hazardRemovalMove?; return true; end
    def aiAutoKnows?(pokemon); return false; end

    def eachHazard(side, isOurSide)
        side.eachEffect(true) do |effect, _value, data|
            next unless data.is_hazard?
            yield effect, data
        end
    end

    def removeEffect(user, side, effect, data)
        side.disableEffect(effect)
        if data.is_hazard?
            hazardName = data.name
            @battle.pbDisplay(_INTL("{1} destroyed {2}!", user.pbThis, hazardName)) unless data.has_expire_proc?
        end
    end

    def pbEffectGeneral(user)
        targetSide = user.pbOpposingSide
        ourSide = user.pbOwnSide
        eachHazard(targetSide, false) do |effect, data|
            removeEffect(user, targetSide, effect, data)
        end
        eachHazard(ourSide, true) do |effect, data|
            removeEffect(user, ourSide, effect, data)
        end
        @battle.field.eachEffect(true) do |effect, _value, effectData|
            next unless effectData.is_room?
            @battle.field.disableEffect(effect)
        end
    end
end

#===============================================================================
# Boosts by 33% if the move is super effective. (Collision Course and Electro Drift)
#===============================================================================
class PokeBattle_Move_BoostIfSuperEffective < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, target)
        baseDmg *= 1.33 if Effectiveness.super_effective?(target.damageState.typeMod)
        return baseDmg
    end
end