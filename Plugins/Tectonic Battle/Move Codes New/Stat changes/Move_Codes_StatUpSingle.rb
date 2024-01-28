#===============================================================================
# Increases the user's Attack by 1 step.
#===============================================================================
class PokeBattle_Move_5D8 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 1]
    end
end

#===============================================================================
# Increases the user's Attack by 2 step.
#===============================================================================
class PokeBattle_Move_01C < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2]
    end
end

#===============================================================================
# Increases the user's Attack by 3 steps.
#===============================================================================
class PokeBattle_Move_5D9 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 3]
    end
end

#===============================================================================
# Increases the user's Attack by 4 steps. (Swords Dance)
#===============================================================================
class PokeBattle_Move_02E < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 4]
    end
end

#===============================================================================
# Increases the user's Attack by 5 steps.
#===============================================================================
class PokeBattle_Move_ < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 5]
    end
end

#===============================================================================
# Increases the user's Defense by 1 step.
#===============================================================================
class PokeBattle_Move_5DA < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:DEFENSE, 1]
    end
end

#===============================================================================
# Increases the user's Defense by 2 steps.
#===============================================================================
class PokeBattle_Move_01D < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:DEFENSE, 2]
    end
end

#===============================================================================
# Increases the user's Defense by 3 steps.
#===============================================================================
class PokeBattle_Move_5DB < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:DEFENSE, 3]
    end
end

#===============================================================================
# Increases the user's Defense by 4 steps. (Barrier, Iron Defense)
#===============================================================================
class PokeBattle_Move_02F < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:DEFENSE, 4]
    end
end

#===============================================================================
# Increases the user's Defense by 5 steps. (Cotton Guard)
#===============================================================================
class PokeBattle_Move_038 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:DEFENSE, 5]
    end	
end

#===============================================================================
# Increases the user's Speed by 1 step.
#===============================================================================
class PokeBattle_Move_5E0 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPEED, 1]
    end
end

#===============================================================================
# Increases the user's Speed by 2 steps.
#===============================================================================
class PokeBattle_Move_01F < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPEED, 2]
    end
end

#===============================================================================
# Increases the user's Speed by 3 steps.
#===============================================================================
class PokeBattle_Move_5E1 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPEED, 3]
    end
end

#===============================================================================
# Increases the user's Speed by 4 steps. (Agility, Rock Polish)
#===============================================================================
class PokeBattle_Move_030 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPEED, 4]
    end

    def getEffectScore(user, target)
        score = super
        score += 40 if user.hasActiveAbilityAI?(:STAMPEDE)
        return score
    end
end

#===============================================================================
# Increases the user's Speed by 5 steps.
#===============================================================================
class PokeBattle_Move_ < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPEED, 5]
    end

    def getEffectScore(user, target)
        score = super
        score += 50 if user.hasActiveAbilityAI?(:STAMPEDE)
        return score
    end
end

#===============================================================================
# Increases the user's Sp. Atk by 1 step.
#===============================================================================
class PokeBattle_Move_5DC < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 1]
    end
end

#===============================================================================
# Increases the user's Sp. Atk by 2 step.
#===============================================================================
class PokeBattle_Move_020 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2]
    end
end

#===============================================================================
# Increases the user's Sp. Atk by 3 steps.
#===============================================================================
class PokeBattle_Move_5DD < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 3]
    end
end

#===============================================================================
# Increases the user's Special Attack by 4 steps. (Dream Dance)
#===============================================================================
class PokeBattle_Move_032 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 4]
    end
end

#===============================================================================
# Increases the user's Special Attack by 5 steps. (Tail Glow)
#===============================================================================
class PokeBattle_Move_039 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 5]
    end
end

#===============================================================================
# Increases the user's Sp. Def by 1 step.
#===============================================================================
class PokeBattle_Move_5DE < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_DEFENSE, 1]
    end
end

#===============================================================================
# Increases the user's Sp. Def by 2 steps.
#===============================================================================
class PokeBattle_Move_ < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_DEFENSE, 3]
    end
end

#===============================================================================
# Increases the user's Sp. Def by 3 steps.
#===============================================================================
class PokeBattle_Move_5DF < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_DEFENSE, 3]
    end
end

#===============================================================================
# Increases the user's Special Defense by 4 steps. (Amnesia)
#===============================================================================
class PokeBattle_Move_033 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_DEFENSE, 4]
    end
end

#===============================================================================
# Increases the user's Sp. Def by 5 steps. (Mucus Armor)
#===============================================================================
class PokeBattle_Move_57B < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_DEFENSE, 5]
    end	
end

#===============================================================================
# Increases the user's critical hit rate by 2 stages. (Focus Energy)
#===============================================================================
class PokeBattle_Move_023 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.effectAtMax?(:FocusEnergy)
            @battle.pbDisplay(_INTL("But it failed, since it cannot get any more pumped!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.incrementEffect(:FocusEnergy, 2)
    end

    def getEffectScore(user, _target)
        return getCriticalRateBuffEffectScore(user, 2)
    end
end