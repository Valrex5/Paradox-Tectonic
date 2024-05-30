#===============================================================================
# Summons an Avatar of a Regi.
# Only usable by the avatar of Regigigas.
#===============================================================================

#Prehistoric Age (Regidrago)

class PokeBattle_Move_SummonAvatarRegidrago < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if !user.countsAs?(:REGIGIGAS)# || !user.boss?
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        @battle.pbDisplay(_INTL("The Prehistoric Age manifests.", user.pbThis))
        @battle.summonAvatarBattler(:REGIDRAGO, user.level, user.index % 2)
    end
end

#Ice Age (Regice)

class PokeBattle_Move_SummonAvatarRegice < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if !user.countsAs?(:REGIGIGAS)# || !user.boss?
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        @battle.pbDisplay(_INTL("The Ice Age manifests.", user.pbThis))
        @battle.summonAvatarBattler(:REGICE, user.level, user.index % 2)
    end
end

#Stone Age (Regirock)

class PokeBattle_Move_SummonAvatarRegirock < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if !user.countsAs?(:REGIGIGAS)# || !user.boss?
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        @battle.pbDisplay(_INTL("The Stone Age manifests.", user.pbThis))
        @battle.summonAvatarBattler(:REGIROCK, user.level, user.index % 2)
    end
end

#Iron Age (Registeel)

class PokeBattle_Move_SummonAvatarRegisteel < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if !user.countsAs?(:REGIGIGAS)# || !user.boss?
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        @battle.pbDisplay(_INTL("The Iron Age manifests.", user.pbThis))
        @battle.summonAvatarBattler(:REGISTEEL, user.level, user.index % 2)
    end
end

#Electric Age (Regieleki)

class PokeBattle_Move_SummonAvatarRegieleki < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if !user.countsAs?(:REGIGIGAS)# || !user.boss?
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        @battle.pbDisplay(_INTL("The Electric Age manifests.", user.pbThis))
        @battle.summonAvatarBattler(:REGIELEKI, user.level, user.index % 2)
    end
end

BattleHandlers::MoveImmunityAllyAbility.add(:PRIMEVALGUARD,
proc { |ability, user, target, move, _type, battle, ally, showMessages|
      if showMessages
          battle.pbShowAbilitySplash(target, ability)
          battle.pbDisplay(_INTL("The presence of the titan protects Regigigas!", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

class PokeBattle_AI_REGIGIGAS < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @wholeRound += %i[PREHISTORICAGE ICEAGE STONEAGE IRONAGE ELECTRICAGE]

        @warnedIFFMove.add(:PREHISTORICAGE, {
            :condition => proc { |_move, _user, _target, battle|
                next true
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("The Prehistoric Age is about to commence.",user.pbThis(true))
            },
        })

        @warnedIFFMove.add(:ICEAGE, {
            :condition => proc { |_move, _user, _target, battle|
                next true
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("The Ice Age is about to commence.",user.pbThis(true))
            },
        })

        @warnedIFFMove.add(:STONEAGE, {
            :condition => proc { |_move, _user, _target, battle|
                next true
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("The Stone Age is about to commence.",user.pbThis(true))
            },
        })

        @warnedIFFMove.add(:IRONAGE, {
            :condition => proc { |_move, _user, _target, battle|
                next true
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("The Iron Age is about to commence.",user.pbThis(true))
            },
        })

        @warnedIFFMove.add(:ELECTRICAGE, {
            :condition => proc { |_move, _user, _target, battle|
                next true
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("The Electric Age is about to commence.",user.pbThis(true))
            },
        })
    end
end

class PokeBattle_AI_REGIDRAGO < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:ARCHMYTH)
    end
end

class PokeBattle_AI_REGICE < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:ZAPCANNON)
    end
end

class PokeBattle_AI_REGIROCK < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryOtherTurn(:FLOWSTATE)
    end
end

class PokeBattle_AI_REGISTEEL < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:EVERHONE)
    end
end

class PokeBattle_AI_REGIELEKI < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:THUNDERCAGE)
    end
end