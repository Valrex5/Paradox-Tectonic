BattleHandlers::TotalEclipseAbility.add(:TOTALGRASP,
    proc { |_ability, battler, _battle|
        battler.pbRaiseMultipleStatStages([:ATTACK,1,:DEFENSE,1,:SPECIAL_ATTACK,1,:SPECIAL_DEFENSE,1,:SPEED,1],battler,
             showAbilitySplash: true)
    }
)

BattleHandlers::TotalEclipseAbility.add(:TOLLDANGER,
    proc { |_ability, battler, _battle|
        battle.forceUseMove(battler, :HEALBELL, nil, true, nil, nil, true)
    }
)