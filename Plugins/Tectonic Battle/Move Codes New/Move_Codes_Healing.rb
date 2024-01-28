#===============================================================================
# Heals user by 1/2 of its max HP.
#===============================================================================
class PokeBattle_Move_0D5 < PokeBattle_HalfHealingMove
end

#===============================================================================
# Heals user by 1/2 of its max HP. (Roost)
# User roosts, and its Flying type is ignored for attacks used against it.
#===============================================================================
class PokeBattle_Move_0D6 < PokeBattle_HalfHealingMove
    def pbEffectGeneral(user)
        super
        user.applyEffect(:Roost)
    end
end

#===============================================================================
# Battler in user's position is healed by 1/2 of its max HP, at the end of the
# next round. (Wish)
#===============================================================================
class PokeBattle_Move_0D7 < PokeBattle_Move
    def healingMove?; return true; end

    def pbMoveFailed?(user, _targets, show_message)
        if user.position.effectActive?(:Wish)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since a Wish is already about to come true for #{user.pbThis(true)}!"))
            end
            return true
        end
        return false
    end

    def wishAmount(user)
        return (user.totalhp / 2.0).round
    end

    def pbEffectGeneral(user)
        user.position.applyEffect(:Wish, 2)
        user.position.applyEffect(:WishAmount, wishAmount(user))
        user.position.applyEffect(:WishMaker, user.pokemonIndex)
    end

    def getEffectScore(user, _target)
        score = (user.totalhp / user.level) * 30
        score *= user.levelNerf(false,false,0.5) if user.level <= 30 && !user.pbOwnedByPlayer? # AI nerf
        return score
    end
end

#===============================================================================
# Heals user by an amount depending on the weather. (Synthesis)
#===============================================================================
class PokeBattle_Move_0D8 < PokeBattle_HealingMove
    def healRatio(_user)
        if @battle.sunny?
            return 2.0 / 3.0
        else
            return 1.0 / 2.0
        end
    end

    def shouldHighlight?(_user, _target)
        return @battle.sunny?
    end
end

#===============================================================================
# Heals user by an amount depending on the weather. (Sweet Selene)
#===============================================================================
class PokeBattle_Move_0F9 < PokeBattle_HealingMove
    def healRatio(_user)
        if @battle.moonGlowing?
            return 2.0 / 3.0
        else
            return 1.0 / 2.0
        end
    end

    def shouldHighlight?(_user, _target)
        return @battle.moonGlowing?
    end
end

#===============================================================================
# Heals user to full HP. User falls asleep for 2 more rounds. (Rest)
#===============================================================================
class PokeBattle_Move_0D9 < PokeBattle_HealingMove
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
end

#===============================================================================
# Heals user to 100%. Only usable on first turn. (Fresh Start)
#===============================================================================
class PokeBattle_Move_55B < PokeBattle_HealingMove
    def healRatio(_user)
        return 1.0
    end

    def pbMoveFailed?(user, targets, show_message)
        unless user.firstTurn?
            @battle.pbDisplay(_INTL("But it failed, since it's not #{user.pbThis(true)}'s first turn!")) if show_message
            return true
        end
        return super
    end
end

#===============================================================================
# Rings the user. Ringed Pokémon gain 1/16 of max HP at the end of each round.
# (Aqua Ring)
#===============================================================================
class PokeBattle_Move_0DA < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        return false if damagingMove?
        if user.effectActive?(:AquaRing)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already veiled with water!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        return if damagingMove?
        user.applyEffect(:AquaRing)
    end

    def pbEffectAfterAllHits(user, target)
        return unless damagingMove?
        return if target.damageState.unaffected
        user.applyEffect(:AquaRing)
    end

    def getEffectScore(user, _target)
        return getAquaRingEffectScore(user)
    end
end

#===============================================================================
# Ingrains the user. Ingrained Pokémon gain 1/16 of max HP at the end of each
# round, and cannot flee or switch out. (Ingrain)
#===============================================================================
class PokeBattle_Move_0DB < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.effectActive?(:Ingrain)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s roots are already planted!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.applyEffect(:Ingrain)
    end

    def getEffectScore(user, _target)
		return 0 if user.effects[:PerishSong] > 0
        score = 50
        score += 30 if @battle.pbIsTrapped?(user.index)
        score += 20 if user.firstTurn?
        score += 20 if user.aboveHalfHealth?
        return score
    end
end

#===============================================================================
# Heals target by 1/2 of its max HP. (Heal Pulse)
#===============================================================================
class PokeBattle_Move_0DF < PokeBattle_Move
    def healingMove?; return true; end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.hp == target.totalhp
            @battle.pbDisplay(_INTL("{1}'s HP is full!", target.pbThis)) if show_message
            return true
        elsif !target.canHeal?
            @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
            return true
        end
        return false
    end

    def healingRatio(user)
        if pulseMove? && user.hasActiveAbility?(:MEGALAUNCHER)
            return 3.0 / 4.0
        else
            return 1.0 / 2.0
        end
    end

    def pbEffectAgainstTarget(user, target)
        target.applyFractionalHealing(healingRatio(user))
    end

    def getEffectScore(user, target)
        return target.applyFractionalHealing(healingRatio(user),aiCheck: true)
    end
end

#===============================================================================
# The user dances to restore an ally by 50% max HP. They're cured of any status conditions. (Healthy Cheer)
#===============================================================================
class PokeBattle_Move_126 < PokeBattle_Move_0DF
    def pbFailsAgainstTarget?(_user, target, show_message)
       if !target.canHeal? && !target.pbHasAnyStatus?
            @battle.pbDisplay(_INTL("{1} can't be healed and it has no status conditions!", target.pbThis)) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        super
        healStatus(target)
    end

    def getEffectScore(user, target)
        score = super
        score += 40 if target.pbHasAnyStatus?
        return score
    end
end

#===============================================================================
# Restore HP and heals any status conditions of itself and its allies
# (Jungle Healing)
#===============================================================================
class PokeBattle_Move_189 < PokeBattle_Move
    def healingMove?; return true; end

    def pbMoveFailed?(user, targets, show_message)
        jglheal = 0
        for i in 0...targets.length
            jglheal += 1 if (targets[i].hp == targets[i].totalhp || !targets[i].canHeal?) && targets[i].status == :NONE
        end
        if jglheal == targets.length
            @battle.pbDisplay(_INTL("But it failed, since none of #{user.pbThis(true)} or its allies can be healed or have their status conditions removed!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.pbCureStatus
        if target.hp != target.totalhp && target.canHeal?
            hpGain = (target.totalhp / 4.0).round
            target.pbRecoverHP(hpGain)
        end
        super
    end
end

#===============================================================================
# The user restores 1/4 of its maximum HP, rounded half up. If there is and
# adjacent ally, the user restores 1/4 of both its and its ally's maximum HP,
# rounded up. (Life Dew)
#===============================================================================
class PokeBattle_Move_17E < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def healingMove?; return true; end

    def healRatio(_user)
        return 1.0 / 4.0
    end

    def pbMoveFailed?(user, _targets, show_message)
        failed = true
        @battle.eachSameSideBattler(user) do |b|
            next if b.hp == b.totalhp
            failed = false
            break
        end
        if failed
            @battle.pbDisplay(_INTL("But it failed, since there was no one to heal!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.hp == target.totalhp
            @battle.pbDisplay(_INTL("{1}'s HP is full!", target.pbThis)) if show_message
            return true
        elsif !target.canHeal?
            @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        hpGain = (target.totalhp / 4.0).round
        target.pbRecoverHP(hpGain)
    end

    def getEffectScore(_user, target)
        score = 0
        if target.canHeal?
            score += 20
            score += 40 if target.belowHalfHealth?
        end
        return score
    end
end

#===============================================================================
# Heals target by 1/2 of its max HP, or 2/3 of its max HP in moonglow.
# (Floral Healing)
#===============================================================================
class PokeBattle_Move_16E < PokeBattle_Move
    def healingMove?; return true; end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.hp == target.totalhp
            @battle.pbDisplay(_INTL("{1}'s HP is full!", target.pbThis)) if show_message
            return true
        elsif !target.canHeal?
            @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
            return true
        end
        return false
    end

    def healingRatio(user,target)
        if @battle.moonGlowing?
            return 2.0 / 3.0
        else
            return 1.0 / 2.0
        end
    end

    def pbEffectAgainstTarget(user, target)
        target.applyFractionalHealing(healingRatio(user,target))
    end

    def getEffectScore(user, target)
        return target.applyFractionalHealing(healingRatio(user,target),aiCheck: true)
    end

    def shouldHighlight?(_user, _target)
        return @battle.moonGlowing?
    end
end

#===============================================================================
# Heals a target ally for their entire health bar, with overheal. (Paradisiaca)
# But the user must recharge next turn.
#===============================================================================
class PokeBattle_Move_134 < PokeBattle_Move_0C2
    def healingRatio(target); return 1.0; end

    def pbFailsAgainstTarget?(_user, target, show_message)
        unless target.canHeal?(true)
            @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.applyFractionalHealing(healingRatio(target), canOverheal: true)
    end

    def getEffectScore(user, target)
        score = target.applyFractionalHealing(healingRatio(user),aiCheck: true, canOverheal: true)
        score += super
        return score
    end
end

#===============================================================================
# Damages target if target is a foe, or heals target by 1/2 of its max HP if
# target is an ally. (Pollen Puff, Package, Water Spiral)
#===============================================================================
class PokeBattle_Move_16F < PokeBattle_Move
    def pbTarget(user)
        return GameData::Target.get(:NearFoe) if user.effectActive?(:HealBlock)
        return super
    end

    def pbOnStartUse(user, targets)
        @healing = false
        @healing = !user.opposes?(targets[0]) if targets.length > 0
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        return false unless @healing
        if target.substituted? && !ignoresSubstitute?(user)
            @battle.pbDisplay(_INTL("#{target.pbThis} is protected behind its substitute!")) if show_message
            return true
        end
        unless target.canHeal?
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can't be healed!")) if show_message
            return true
        end
        return false
    end

    def damagingMove?(aiCheck = false)
        if aiCheck
            return super
        else
            return false if @healing
            return super
        end
    end

    def pbEffectAgainstTarget(_user, target)
        return unless @healing
        target.applyFractionalHealing(1.0 / 2.0)
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        hitNum = 1 if @healing # Healing anim
        super
    end

    def getEffectScore(user, target)
        return target.applyFractionalHealing(1.0 / 2.0, aiCheck: true) unless user.opposes?(target)
        return 0
    end

    def resetMoveUsageState
        @healing = false
    end
end

#===============================================================================
# User faints. The Pokémon that replaces the user is fully healed (HP and
# status). Fails if user won't be replaced. (Healing Wish)
#===============================================================================
class PokeBattle_Move_0E3 < PokeBattle_Move
    def healingMove?; return true; end

    def pbMoveFailed?(user, _targets, show_message)
        unless @battle.pbCanChooseNonActive?(user.index)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} has no party allies to replace it!"))
            end
            return true
        end
        return false
    end

    def pbSelfKO(user)
        return if user.fainted?
        user.pbReduceHP(user.hp, false)
        user.pbItemHPHealCheck
        user.position.applyEffect(:HealingWish)
    end

    def getEffectScore(user, target)
        score = 80
        score += getSelfKOMoveScore(user, target)
        return score
    end
end

#===============================================================================
# User faints. The Pokémon that replaces the user is fully healed (HP, PP and
# status). Fails if user won't be replaced. (Lunar Dance)
#===============================================================================
class PokeBattle_Move_0E4 < PokeBattle_Move
    def healingMove?; return true; end

    def pbMoveFailed?(user, _targets, show_message)
        unless @battle.pbCanChooseNonActive?(user.index)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} has no party allies to replace it!"))
            end
            return true
        end
        return false
    end

    def pbSelfKO(user)
        return if user.fainted?
        user.pbReduceHP(user.hp, false)
        user.pbItemHPHealCheck
        user.position.applyEffect(:LunarDance)
    end

    def getEffectScore(user, target)
        score = 90
        score += getSelfKOMoveScore(user, target)
        return score
    end
end