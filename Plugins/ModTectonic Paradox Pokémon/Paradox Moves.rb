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
# Boosts by 50% if there is moonglow. (Psyblade)
#===============================================================================
class PokeBattle_Move_BoostInMoonglow < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, target)
        baseDmg *= 1.5 if battle.moonGlowing?
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
# Boosts by 33% if the move is super effective. (Collision Course and Electro Drift)
#===============================================================================
class PokeBattle_Move_BoostIfSuperEffective < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, target)
        baseDmg *= 1.33 if Effectiveness.super_effective?(typeModToCheck(user.battle, type, user, target, move, aiCheck))
        return baseDmg
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. In sunshine, takes 1 turn instead. (Solar Beam)
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
end


    def resetMoveUsageState
        @choice = nil
    end 

    def getEffectScore(_user, _target)
        return 100
    end 


#===============================================================================
# Clears hazards, weather and rooms. (Mighty Cleave?)
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
        @battle.endWeather
    end
end

#===============================================================================
# User heals for 1/4ths of their HP and removes hazards from its field. (One With The Earth) (not functional)
#===============================================================================
class PokeBattle_Move_HealUserOneQuartersRemoveHazards < PokeBattle_HealingMove
    def healRatio(_user)
        return 1.0 / 4.0
    end
    def hazardRemovalMove?; return true; end
    def aiAutoKnows?(pokemon); return false; end

    def initialize(battle, move)
        super
        @miscEffects = %i[Mist Safeguard]
    end

    def eachDefoggable(side, isOurSide)
        side.eachEffect(true) do |effect, _value, data|
            if !isOurSide && (data.is_screen? || @miscEffects.include?(effect))
                yield effect, data
            elsif data.is_hazard?
                yield effect, data
            end
        end
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        targetSide = target.pbOwnSide
        ourSide = user.pbOwnSide
        eachDefoggable(targetSide, false) do |_effect, _data|
            return false
        end
        eachDefoggable(ourSide, true) do |_effect, _data|
            return false
        end
    end

    def blowAwayEffect(user, side, effect, data)
        side.disableEffect(effect)
        if data.is_hazard?
            hazardName = data.name
            @battle.pbDisplay(_INTL("{1} absorbed {2}!", user.pbThis, hazardName)) unless data.has_expire_proc?
        end
    end

    def getEffectScore(user, target)
        score = 0
        # Dislike removing hazards that affect the enemy
        score -= 0.8 * hazardWeightOnSide(target.pbOwnSide) if target.alliesInReserve?
        # Like removing hazards that affect us
        score += hazardWeightOnSide(target.pbOpposingSide) if user.alliesInReserve?
        target.pbOwnSide.eachEffect(true) do |effect, value, data|
            next unless data.is_screen? || @miscEffects.include?(effect)
			case value
				when 2
					score += 30
				when 3
					score += 55
				when 4..999
					score += 140
            end	
        end
        return score
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

GameData::BattleEffect.register_effect(:Battler, {
    :id => :DragRace,
    :real_name => "Drag Race Count",
    :type => :Integer,
    :maximum => 4,
    :resets_on_cancel => true,
    :resets_on_move_start => true,
    :snowballing_move_counter => true,
})
