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
        baseDmg *= 1.5 if Effectiveness.super_effective?(typeModToCheck(user.battle, type, user, target, move, aiCheck))
        return baseDmg
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. In sunshine, takes 1 turn instead. (Solar Beam)
#===============================================================================
class PokeBattle_Move_TwoTurnAttackCanChooseOne < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} charges power!",user.pbThis))
    end

    def resolutionChoice(user)
        choices = [_INTL("Attack"),_INTL("Charge")]
        choice = @battle.scene.pbShowCommands(_INTL("Should #{user.pbThis(true)} charge the attack?"),choices,0)
    end 

    def resetMoveUsageState
        choice = nil
    end

    def getEffectScore(_user, _target)
        return 100
    end
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