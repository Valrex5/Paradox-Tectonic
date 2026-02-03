#===============================================================================
# Two turn attack. Attacks first turn, skips second turn (if successful).
#===============================================================================
class PokeBattle_Move_DoubleAgainstAvatarsButRecharges < PokeBattle_Move
    def initialize(battle, move)
        super
        @exhaustionTracker = :HyperBeam
    end

    def pbMoveFailed?(user, _targets, show_message)
        if !user.countsAs?(:GOKU)
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        elsif not (user.form == 3 || user.form == 7 || user.form == 10)
            @battle.pbDisplay(_INTL("But {1} can't use it the way it is now!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end     

    def pbEffectGeneral(user)
        unless 
        if user.hasActiveItem?(:ENERGYHERB)
            @battle.pbCommonAnimation("UseItem", user)
            @battle.pbDisplay(_INTL("{1} skipped exhaustion due to its Energy Herb!", user.pbThis))
            user.consumeItem(:ENERGYHERB)
        else
            user.applyEffect(@exhaustionTracker, 2)
        end
    end
  
    def pbEffectAfterAllHits(user, target)
        return if target.boss?
        super
        user.disableEffect(:HyperBeam)
    end

    def getEffectScore(user, _target)
        return -70 unless user.hasActiveItemAI?(:ENERGYHERB)
        return 0
    end

    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.boss?
        return baseDmg
    end
end
end

#===============================================================================
# Varies power with Goku's form (Kamehameha)
#===============================================================================
class PokeBattle_Move_ScalesWithGokuForm < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if !user.countsAs?(:GOKU)
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        elsif user.form == 8 || user.form == 9
            @battle.pbDisplay(_INTL("But {1} can't use it the way it is now!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end 

    def pbBaseDamage(_baseDmg, user, target)
        if user.form == 0
            basePower = 55
        elsif user.form == 1
            basePower = 70  
        elsif user.form == 2
            basePower = 90   
        elsif user.form == 3 || user.form == 5 || user.form == 7
            basePower = 120   
        elsif user.form == 4 || user.form == 6
            basePower = 100   
        elsif user.form == 10
            basePower = 140     
        return basePower
    end
end
end