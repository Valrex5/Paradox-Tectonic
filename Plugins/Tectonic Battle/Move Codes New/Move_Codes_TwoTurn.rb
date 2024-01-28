#===============================================================================
# Two turn attack. Attacks first turn, skips second turn (if successful).
#===============================================================================
class PokeBattle_Move_0C2 < PokeBattle_Move
    def initialize(battle, move)
        super
        @exhaustionTracker = :HyperBeam
    end

    def pbEffectGeneral(user)
        if user.hasActiveItem?(:ENERGYHERB)
            @battle.pbCommonAnimation("UseItem", user)
            @battle.pbDisplay(_INTL("{1} skipped exhaustion due to its Energy Herb!", user.pbThis))
            user.consumeItem(:ENERGYHERB)
        else
            user.applyEffect(@exhaustionTracker, 2)
        end
    end

    def getEffectScore(user, _target)
        return -70 unless user.hasActiveItem?(:ENERGYHERB)
        return 0
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. In sunshine, takes 1 turn instead. (Solar Beam)
#===============================================================================
class PokeBattle_Move_0C4 < PokeBattle_TwoTurnMove
    def immuneToSunDebuff?; return true; end

    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} took in sunlight!", user.pbThis))
    end

    def skipChargingTurn?(user)
        return @battle.sunny?
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. In rain, takes 1 turn instead. (Storm Drive)
#===============================================================================
class PokeBattle_Move_0E6 < PokeBattle_TwoTurnMove
    def immuneToRainDebuff?; return true; end
    
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} took in electricity!", user.pbThis))
    end

    def skipChargingTurn?(user)
        return @battle.rainy?
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Freeze Shock)
# May paralyze the target.
#===============================================================================
class PokeBattle_Move_0C5 < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} became cloaked in a freezing light!", user.pbThis))
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.applyNumb(user) if target.canNumb?(user, false, self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getNumbEffectScore(user, target)
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Ice Burn)
# May burn the target.
#===============================================================================
class PokeBattle_Move_0C6 < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} became cloaked in freezing air!", user.pbThis))
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.applyBurn(user) if target.canBurn?(user, false, self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getBurnEffectScore(user, target)
    end
end

#===============================================================================
# Boosts Sp Atk on 1st Turn and Attacks on 2nd (Meteor Beam)
#===============================================================================
class PokeBattle_Move_191 < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} is overflowing with space power!", user.pbThis))
    end

    def pbChargingTurnEffect(user, _target)
        user.tryRaiseStat(:SPECIAL_ATTACK, user, move: self, increment: 2)
    end

    def getEffectScore(user, target)
        score = super
        score += getMultiStatUpEffectScore([:SPECIAL_ATTACK,2],user,user)
        return score
    end
end

#===============================================================================
# Two turn attack. Ups user's Defense by 4 steps first turn, attacks second turn.
# (Skull Bash)
#===============================================================================
class PokeBattle_Move_0C8 < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} tucked in its head!", user.pbThis))
    end

    def pbChargingTurnEffect(user, _target)
        user.tryRaiseStat(:DEFENSE, user, increment: 4, move: self)
    end

    def getEffectScore(user, target)
        score = super
        score += getMultiStatUpEffectScore([:DEFENSE, 2], user, user)
        return score
    end
end

#===============================================================================
# Two turn attack. Ups user's Special Defense by 4 steps first turn, attacks second turn.
# (Infinite Wing)
#===============================================================================
class PokeBattle_Move_536 < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1}'s wings start glowing!", user.pbThis))
    end

    def pbChargingTurnEffect(user, _target)
        user.tryRaiseStat(:SPECIAL_DEFENSE, user, increment: 4, move: self)
    end

    def getEffectScore(user, target)
        score = super
        score += getMultiStatUpEffectScore([:SPECIAL_DEFENSE, 2], user, user)
        return score
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Fly, Divebomb)
# (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
#===============================================================================
class PokeBattle_Move_0C9 < PokeBattle_TwoTurnMove
    def unusableInGravity?; return true; end

    def pbIsChargingTurn?(user)
        ret = super
        if !user.effectActive?(:TwoTurnAttack) && user.hasActiveAbility?(:SLINKY)
            skipChargingTurn
            return false
        end
        return ret
    end

    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} flew up high!", user.pbThis))
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Dig, Undermine)
# (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
#===============================================================================
class PokeBattle_Move_0CA < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} burrowed its way under the ground!", user.pbThis))
    end

    def pbIsChargingTurn?(user)
        ret = super
        if !user.effectActive?(:TwoTurnAttack) && user.hasActiveAbility?(:SLINKY)
            skipChargingTurn
            return false
        end
        return ret
    end

    def canBecomeReaper?(user)
        return @battle.sandy? && user.species == :GARCHOMP && user.hasActiveAbility?(:SANDSMACABRE) && user.form == 0
    end

    def pbAttackingTurnMessage(user, targets)
        if canBecomeReaper?(user)
            @battle.pbDisplay(_INTL("The ground rumbles violently underneath {1}!", targets[0].pbThis))
            @battle.pbAnimation(:EARTHQUAKE, targets[0], targets, 0)
            user.pbChangeForm(1, _INTL("The Reaper appears!"))
        end
    end

    def getEffectScore(user, _target)
        return 50 if canBecomeReaper?(user)
        return 0
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Dive, Depth Charge)
# (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
#===============================================================================
class PokeBattle_Move_0CB < PokeBattle_TwoTurnMove
    def pbIsChargingTurn?(user)
        ret = super
        if !user.effectActive?(:TwoTurnAttack) && user.hasActiveAbility?(:SLINKY)
            skipChargingTurn
            return false
        end
        return ret
    end

    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} hid underwater!", user.pbThis))
        if user.canGulpMissile?
            user.form = 2
            user.form = 1 if user.hp > (user.totalhp / 2)
            @battle.scene.pbChangePokemon(user, user.pokemon)
        end
    end

    def getEffectScore(user, _target)
        return 40 if user.canGulpMissile?
        return 0
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Bounce)
# May numb the target.
# (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
#===============================================================================
class PokeBattle_Move_0CC < PokeBattle_TwoTurnMove
    def unusableInGravity?; return true; end

    def pbIsChargingTurn?(user)
        ret = super
        if !user.effectActive?(:TwoTurnAttack) && user.hasActiveAbility?(:SLINKY)
            skipChargingTurn
            return false
        end
        return ret
    end

    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} sprang up!", user.pbThis))
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.applyNumb(user) if target.canNumb?(user, false, self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getNumbEffectScore(user, target)
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Shadow Force)
# Is invulnerable during use. Ends target's protections upon hit.
#===============================================================================
class PokeBattle_Move_0CD < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} vanished instantly!", user.pbThis))
    end

    def pbAttackingTurnEffect(_user, target)
        removeProtections(target)
    end
end

#===============================================================================
# Two turn attack. Sets sun first turn, attacks second turn.
# (Absolute Radiance)
#===============================================================================
class PokeBattle_Move_5C4 < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} petitions the sun!", user.pbThis))
    end

    def pbChargingTurnEffect(user, _target)
        @battle.pbStartWeather(user, :Sun, 5, false)
    end

    def getEffectScore(user, _target)
        score = super
        score += getWeatherSettingEffectScore(:Sun, user, battle, 5)
        return score
    end
end

#===============================================================================
# Two turn attack. Sets rain first turn, attacks second turn.
# (Archaen Deluge)
#===============================================================================
class PokeBattle_Move_576 < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} begins the flood!", user.pbThis))
    end

    def pbChargingTurnEffect(user, _target)
        @battle.pbStartWeather(user, :Rain, 5, false)
    end

    def getEffectScore(user, _target)
        score = super
        score += getWeatherSettingEffectScore(:Rain, user, battle, 5)
        return score
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Liftoff)
# (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
#===============================================================================
class PokeBattle_Move_5C5 < PokeBattle_Move_0C9
    include Recoilable

    def recoilFactor; return 0.25; end

    def pbEffectAfterAllHits(user, target)
        return unless @damagingTurn
        super
    end
end