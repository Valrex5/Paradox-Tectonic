BattleHandlers::PriorityBracketChangeAbility.add(:STALL,
  proc { |ability,battler,subPri,battle|
    next -1 if subPri==0
  }
)

BattleHandlers::PriorityBracketChangeAbility.add(:QUICKDRAW,
    proc { |ability,battler,subPri,battle|
      next 1 if subPri<1 && battle.pbRandom(10)<3
    }
)