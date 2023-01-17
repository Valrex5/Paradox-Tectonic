# None!

BattleHandlers::TotalEclipseAbility.add(:TOTALGRASP,
    proc { |_ability, battler, _battle|
        battler.pbRaiseMultipleStatStages([:ATTACK,1,:DEFENSE,1,:SPECIAL_ATTACK,1,:SPECIAL_DEFENSE,1,:SPEED,1],
             showAbilitySplash: true)
    }
)