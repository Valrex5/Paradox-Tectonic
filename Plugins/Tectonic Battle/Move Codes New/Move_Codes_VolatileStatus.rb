#===============================================================================
# The target can no longer use the same move twice in a row. (Torment)
#===============================================================================
class PokeBattle_Move_0B7 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:Torment)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already tormented!"))
            end
            return true
        end
        return true if pbMoveFailedAromaVeil?(user, target, show_message)
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Torment)
    end

    def getTargetAffectingEffectScore(_user, target)
        return 0 if target.hasActiveAbilityAI?(:MENTALBLOCK)
        score = 60
        score += 40 unless target.hasDamagingAttack?
        return score
    end
end

#===============================================================================
# Disables all target's moves that the user also knows. (Imprison)
#===============================================================================
class PokeBattle_Move_0B8 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.effectActive?(:Imprison)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s is already imprisoning shared moves!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.applyEffect(:Imprison)
    end

    def getTargetAffectingEffectScore(_user, _target)
        echoln("The AI will never use Imprison.")
        return -1000
    end
end

#===============================================================================
# For 5 rounds, disables the last move the target used. (Disable)
#===============================================================================
class PokeBattle_Move_0B9 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @disableTurns = 4
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        unless target.canBeDisabled?(true, self)
            @battle.pbDisplay(_INTL("But it failed, since the target can't be disabled!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Disable, @disableTurns)
    end

    def getTargetAffectingEffectScore(_user, target)
        return getDisableEffectScore(target, @disableTurns)
    end
end

#===============================================================================
# For 4 rounds, disables the target's non-damaging moves. (Taunt)
#===============================================================================
class PokeBattle_Move_0BA < PokeBattle_Move
    def ignoresSubstitute?(user); return statusMove?; end

    def initialize(battle, move)
        super
        @tauntTurns = 4
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        if target.effectActive?(:Taunt)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already taunted!")) if show_message
            return true
        end
        return true if pbMoveFailedAromaVeil?(user, target, show_message)
        return false
    end

    def getTauntTurns(target)
        return target.boss? ? @tauntTurns / 2 : @tauntTurns
    end

    def pbEffectAgainstTarget(_user, target)
        return if damagingMove?
        target.applyEffect(:Taunt, getTauntTurns(target))
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        return if target.effectActive?(:Taunt)
        return true if pbMoveFailedAromaVeil?(user, target)
        target.applyEffect(:Taunt, getTauntTurns(target))
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 if target.substituted? && statusMove? && !ignoresSubstitute?(user)
        return 0 if target.hasActiveAbilityAI?(:MENTALBLOCK)
        unkownHate = target.unknownMovesCountAI 
        return 0 unless target.hasStatusMove? || unkownHate == 4
        firstTurnScore = 0
        lastingScore = 0        

        
        # AI taunts if it has no idea what target is doing
        if unkownHate == 4
            firstTurnScore = 50
            lastingScore += 30
        end
        
        # Setup
        if target.hasSetupStatusMove?
           if target.lastRoundMoveCategory == -1 || target.lastRoundMoveCategory == 2 # No point stopping setup that already happened
                firstTurnScore = 50
                lastingScore += 30
            end
        end
        
        # Hazard
        if target.hasUseableStatusHazardMove?
            firstTurnScore = 50
            lastingScore += 30           
        end
        
        # Recovery
        if target.hasRecoveryMove?
            if target.hp <= target.totalhp * 0.7
                firstTurnScore = 50
                lastingScore += 30
            else
                lastingScore += 25
            end
        end

		if @battle.battleAI.userMovesFirst?(self, user, target)
            firstTurnScore *= 2
            firstTurnScore *= 1.3 if user.firstTurn? # Prevent hazards over setting them on lead
        end
        
        lastingScore *= (getTauntTurns(target) - 1)
        score = firstTurnScore + lastingScore
        score = 220 if score >= 220 # AI shouldnt taunt over kills
        return score
    end
end

#===============================================================================
# For 2 rounds, disables the target's non-damaging moves. (Docile Mask)
#===============================================================================
class PokeBattle_Move_0D0 < PokeBattle_Move_0BA
    def initialize(battle, move)
        super
        @tauntTurns = 2
    end
end

#===============================================================================
# For 5 rounds, disables the target's healing moves. (Heal Block)
#===============================================================================
class PokeBattle_Move_0BB < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:HealBlock)
            @battle.pbDisplay(_INTL("But it failed, since the target's healing is already blocked!")) if show_message
            return true
        end
        return true if pbMoveFailedAromaVeil?(user, target, show_message)
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:HealBlock, 5)
    end

    def getTargetAffectingEffectScore(_user, target)
        return 0 if target.hasActiveAbilityAI?(:MENTALBLOCK)
        return 0 unless target.hasHealingMove?
        return 40
    end
end

#===============================================================================
# For 4 rounds, the target must use the same move each round. (Encore)
#===============================================================================
class PokeBattle_Move_0BC < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            "0BC", # Encore
            # Struggle
            "002", # Struggle
            # Moves that affect the moveset
            "05C",   # Mimic
            "05D",   # Sketch
            "069",   # Transform
            # Moves that call other moves
            "0AE", # Mirror Move
            "0AF",   # Copycat
            "0B0",   # Me First
            "0B3",   # Nature Power
            "0B4",   # Sleep Talk
            "0B5",   # Assist
            "0B6", # Metronome
        ]
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:Encore)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already locked into an encore!")) if show_message
            return true
        end
        unless target.lastRegularMoveUsed
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} hasn't used a move yet!")) if show_message
            return true
        end
        if @moveBlacklist.include?(GameData::Move.get(target.lastRegularMoveUsed).function_code)
            @battle.pbDisplay(_INTL("But it failed, since {1} can't be locked into {2}!",
                  target.pbThis(true), GameData::Move.get(target.lastRegularMoveUsed).name)) if show_message
            return true
        end
        if target.effectActive?(:ShellTrap)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is setting a Shell Trap!")) if show_message
            return true
        end
        if target.effectActive?(:Masquerblade)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is hiding a Masquerblade!")) if show_message
            return true
        end
        return true if pbMoveFailedAromaVeil?(user, target, show_message)
        canEncore = false
        target.eachMove do |m|
            next if m.id != target.lastRegularMoveUsed
            next if m.pp == 0 && m.total_pp > 0
            canEncore = true
            break
        end
        unless canEncore
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} last used move has no more PP!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Encore, 4)
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 if target.hasActiveAbilityAI?(:MENTALBLOCK)
        score = 60
        score += 40 if @battle.pbIsTrapped?(target.index)
        userSpeed = user.pbSpeed(true, move: self)
        targetSpeed = target.pbSpeed(true)
        if userSpeed > targetSpeed
            return 0 if target.lastRegularMoveUsed.nil?
            moveData = GameData::Move.get(target.lastRegularMoveUsed)
            if moveData.category == 2 && %i[User BothSides].include?(moveData.target)
                score += 100
            elsif moveData.category != 2 && moveData.target == :NearOther &&
                  Effectiveness.ineffective?(pbCalcTypeMod(moveData.type, target, user))
                score += 100
            end
        end
        return score
    end
end

#===============================================================================
# For 4 rounds, disables the target's off-type moves. (Bar)
#===============================================================================
class PokeBattle_Move_0C7 < PokeBattle_Move
    def ignoresSubstitute?(_user); return statusMove?; end

    def initialize(battle, move)
        super
        @barredTurns = 4
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        if target.effectActive?(:Barred)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already barred!")) if show_message
            return true
        end
        return true if pbMoveFailedAromaVeil?(user, target, show_message)
        return false
    end

    def getBarTurns(target)
        return target.boss? ? @barredTurns / 2 : @barredTurns
    end

    def pbEffectAgainstTarget(_user, target)
        return if damagingMove?
        target.applyEffect(:Barred, getBarTurns(target))
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        return if target.effectActive?(:Barred)
        return true if pbMoveFailedAromaVeil?(user, target)
        target.applyEffect(:Barred, getBarTurns(target))
    end

    def getTargetAffectingEffectScore(_user, target)
        return 0 if target.substituted? && statusMove?
        return 0 if target.hasActiveAbilityAI?(:MENTALBLOCK)
        return 0 unless target.hasOffTypeMove?
        return 40 + getBarTurns(target) * 20
    end
end

#===============================================================================
# Target will lose 1/4 of max HP at end of each round, while asleep. (Nightmare)
#===============================================================================
class PokeBattle_Move_10F < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        unless target.asleep?
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} isn't asleep!")) if show_message
            return true
        end
        if target.effectActive?(:Nightmare)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already afflicted by a Nightmare!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Nightmare)
    end

    def getTargetAffectingEffectScore(_user, target)
        score = 100
        score += 50 if target.aboveHalfHealth?
        return score
    end
end

#===============================================================================
# Decrease 6 steps of speed and weakens target to fire moves. (Tar Shot)
#===============================================================================
class PokeBattle_Move_186 < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        if !target.pbCanLowerStatStep?(:SPEED, target, self) && target.effectActive?(:TarShot)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already covered in tar and can't have their Speed lowered!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        return if target.damageState.substitute
        target.tryLowerStat(:SPEED, user, move: self, increment: 6)
        target.applyEffect(:TarShot)
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        score += getMultiStatDownEffectScore([:SPEED, 6], user, target)
        score += 50 unless target.effectActive?(:TarShot)
        return score
    end
end