BattleHandlers::AbilityOnSwitchIn.add(:SAIYANWARRIOR,
  proc { |ability, battler, battle, aiCheck|
      trigger = battler.pbDirectOpposing 
      next unless battler.countsAs?(:GOKU)
      next unless battler.form == 0
      next unless trigger.countsAs?(:REGIGIGAS)
      next unless trigger.boss?
      battler.pbChangeForm(6, _INTL("{1} calms down in the face of the enemy.", battler.pbThis))
  }
)

BattleHandlers::FullMoonAbility.add(:SAIYANWARRIOR,
    proc { |ability, battler, battle|
        next unless battler.species == :GOKU
        next unless battler.form == 0
        battler.pbChangeForm(8, _INTL("{1}'s transforms with exposure to the Full Moon!", battler.pbThis))
    }
)

BattleHandlers::AbilityOnSwitchIn.add(:SAIYANWARRIOR,
  proc { |ability, battler, battle, aiCheck|
    next 0 if aiCheck
    battler.showMyAbilitySplash(ability)
    battler.applyEffect(:GoldenOozaru)
    battler.hideMyAbilitySplash
  }
)

GameData::BattleEffect.register_effect(:Battler, {
    :id => :GoldenOozaru,
    :real_name => "Rampage",
    :trapping => true,
    :apply_proc => proc do |battle, battler, _value|
        battle.pbDisplay(_INTL("{1} won't leave the battle!", battler.pbThis))
    end
})


BattleHandlers::UserAbilityEndOfMove.add(:SAIYANWARRIOR,
  proc { |ability, user, targets, move, battle, _switchedBattlers|
      next unless user.species == :GOKU
      next unless user.form == 9
      next if battle.pbAllFainted?(user.idxOpposingSide)
      numFainted = 0
      targets.each { |b| numFainted += 1 if b.damageState.fainted }
      next if numFainted == 0
      battle.pbShowAbilitySplash(user, ability)
      user.pbChangeForm(10, _INTL("{1} takes control of its power.", user.pbThis))
      user.disableEffect(:GoldenOozaru)
      battle.pbHideAbilitySplash(user)
  }
)