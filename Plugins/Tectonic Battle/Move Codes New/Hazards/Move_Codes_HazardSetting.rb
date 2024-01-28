#===============================================================================
# Entry hazard. Lays spikes on the opposing side. (Spikes)
#===============================================================================
class PokeBattle_Move_103 < PokeBattle_Move
    def hazardMove?; return true,2; end
    def aiAutoKnows?(pokemon); return true; end

    def pbMoveFailed?(user, _targets, show_message)
        return false if damagingMove?
        if user.pbOpposingSide.effectAtMax?(:Spikes)
            @battle.pbDisplay(_INTL("But it failed, since there is no room for more Spikes!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        return if damagingMove?
        user.pbOpposingSide.incrementEffect(:Spikes)
    end

    def pbEffectAgainstTarget(_user, target)
        return unless damagingMove?
        return if target.pbOwnSide.effectAtMax?(:Spikes)
        target.pbOwnSide.incrementEffect(:Spikes)
    end

    def getEffectScore(user, target)
        return 0 if damagingMove? && target.pbOwnSide.effectAtMax?(:Spikes)
        return getHazardSettingEffectScore(user, target)
    end
end

#===============================================================================
# Sets spikes, but only if none are present. (Ceaseless Edge)
#===============================================================================
class PokeBattle_Move_13E < PokeBattle_Move_103
    def pbMoveFailed?(user, _targets, show_message)
        return false if damagingMove?
        if user.pbOpposingSide.effectAtMax?(:Spikes)
            @battle.pbDisplay(_INTL("But it failed, since there's already one layer of Spikes!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        return unless damagingMove?
        return if target.pbOwnSide.countEffect(:Spikes) > 0
        target.pbOwnSide.incrementEffect(:Spikes)
    end

    def getEffectScore(user, target)
        return 0 if damagingMove? && target.pbOwnSide.countEffect(:Spikes) > 0
        return getHazardSettingEffectScore(user, target)
    end
end

#===============================================================================
# Returns user to party for swap and lays a layer of spikes. (Caltrop Arts)
#===============================================================================
class PokeBattle_Move_58E < PokeBattle_Move_0EE
    def pbMoveFailed?(user, _targets, show_message)
        return false if damagingMove?
        if user.pbOpposingSide.effectAtMax?(:Spikes)
            @battle.pbDisplay(_INTL("But it failed, since there is no room for more Spikes!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        return if damagingMove?
        user.pbOpposingSide.incrementEffect(:Spikes)
    end

    def pbAdditionalEffect(user, _target)
        return unless damagingMove?
        return if user.pbOpposingSide.effectAtMax?(:Spikes)
        user.pbOpposingSide.incrementEffect(:Spikes)
    end

    def getTargetAffectingEffectScore(user, target)
        return getHazardSettingEffectScore(user, target) unless user.pbOpposingSide.effectAtMax?(:Spikes)
    end
end

#===============================================================================
# If it faints the target, you set Spikes on the their side of the field. (Impaling Spike)
#===============================================================================
class PokeBattle_Move_195 < PokeBattle_Move
    def pbEffectAfterAllHits(_user, target)
        return unless target.damageState.fainted
        target.pbOwnSide.incrementEffect(:Spikes)
    end
end

#===============================================================================
# Only usable by Morpeko. Sets Spikes if Full Belly. (Gut Check)
# If Hangry, doubles in damage and deals Dark-type damage.
#===============================================================================
class PokeBattle_Move_176 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.countsAs?(:MORPEKO)
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbBaseDamage(baseDmg, user, _target)
        if user.form == 1
            baseDmg *= 2
        end
        return baseDmg
    end

    def pbBaseType(user)
        ret = :ELECTRIC
        ret = :DARK if user.form == 1
        return ret
    end

    def pbAdditionalEffect(user, _target)
        return unless user.form == 0
        return if user.pbOpposingSide.effectAtMax?(:Spikes)
        user.pbOpposingSide.incrementEffect(:Spikes)
    end

    def getEffectScore(user, target)
        return 0 unless user.form == 0
        return 0 if damagingMove? && target.pbOwnSide.effectAtMax?(:Spikes)
        return getHazardSettingEffectScore(user, target)
    end
end

#===============================================================================
# Entry hazard. Lays poison spikes on the opposing side (max. 2 layers).
# (Poison Spikes)
#===============================================================================
class PokeBattle_Move_104 < PokeBattle_StatusSpikeMove
    def hazardMove?; return true,5; end
    def initialize(battle, move)
        @spikeEffect = :PoisonSpikes
        super
    end
end

#===============================================================================
# Entry hazard. Lays burn spikes on the opposing side.
# (Flame Spikes)
#===============================================================================
class PokeBattle_Move_551 < PokeBattle_StatusSpikeMove
    def hazardMove?; return true,6; end
    def initialize(battle, move)
        @spikeEffect = :FlameSpikes
        super
    end
end

#===============================================================================
# Entry hazard. Lays frostbite spikes on the opposing side.
# (Frost Spikes)
#===============================================================================
class PokeBattle_Move_569 < PokeBattle_StatusSpikeMove
    def hazardMove?; return true,7; end
    def initialize(battle, move)
        @spikeEffect = :FrostSpikes
        super
    end
end

#===============================================================================
# Entry hazard. Lays stealth rocks on the opposing side. (Stealth Rock)
#===============================================================================
class PokeBattle_Move_105 < PokeBattle_Move
    def hazardMove?; return true,1; end
    def aiAutoKnows?(pokemon); return true; end

    def pbMoveFailed?(user, _targets, show_message)
        return false if damagingMove?
        if user.pbOpposingSide.effectActive?(:StealthRock)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since pointed stones already float around the opponent!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        return if damagingMove?
        user.pbOpposingSide.applyEffect(:StealthRock)
    end

    def pbEffectAgainstTarget(_user, target)
        return unless damagingMove?
        return if target.pbOwnSide.effectActive?(:StealthRock)
        target.pbOwnSide.applyEffect(:StealthRock)
    end

    def getEffectScore(user, target)
        return 0 if damagingMove? && target.pbOwnSide.effectActive?(:StealthRock)
        return getHazardSettingEffectScore(user, target, 12)
    end
end