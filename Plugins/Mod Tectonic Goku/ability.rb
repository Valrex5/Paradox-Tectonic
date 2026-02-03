#BattleHandlers::AbilityOnSwitchIn.add(:SAIYANWARRIOR,
#  proc { |ability, battler, battle, aiCheck|
#      trigger = battler.pbDirectOpposing 
#      next unless battler.countsAs?(:GOKU)
#      next unless battler.form == 0
#      next unless trigger.countsAs?(:REGIGIGAS)
#      next unless trigger.boss?
#      battler.pbChangeForm(6, _INTL("{1} calms down in the face of the enemy.", battler.pbThis))
#  }
#)

MultipleForms.register(:GOKU, {
  "getFormOnLeavingBattle" => proc { |pkmn, _battle, _usedInBattle, endBattle|
      next 0 if pkmn.fainted? || endBattle
  },
})

BattleHandlers::AbilityOnSwitchIn.add(:SAIYANWARRIOR,
  proc { |ability, battler, battle, aiCheck, scene|
    next unless battler.species == :GOKU
    next unless battler.form == 0
    next if battler.level < 25
    form0Name = GameData::Species.get_species_form(:GOKU,0).form_name
    form1Name = GameData::Species.get_species_form(:GOKU,1).form_name
    form2Name = GameData::Species.get_species_form(:GOKU,2).form_name
    form3Name = GameData::Species.get_species_form(:GOKU,4).form_name
    form4Name = GameData::Species.get_species_form(:GOKU,6).form_name
    if battler.level >= 25 && battler.level <= 39
      choices = [form0Name,form1Name]
    elsif battler.level >= 40 && battler.level <= 59
      choices = [form0Name,form1Name,form2Name]
    elsif battler.level == 70 && tournamentWon?
      choices = [form0Name,form1Name,form2Name,form3Name,form4Name]
    elsif battler.level >= 60
      choices = [form0Name,form1Name,form2Name,form3Name]
    end 
    if battle.autoTesting
    choice = rand(1)
    elsif !battler.pbOwnedByPlayer? # Trainer AI
    choice = 0
    else
    choice = battle.scene.pbShowCommands(_INTL("What form should it take?"),choices,0)
    end 
    if choice == 3
      @chosenForm = choice + 1
    elsif choice == 4
      @chosenForm = choice + 2
    else
      @chosenForm = choice
    end 
    battler.pbChangeForm(@chosenForm, _INTL("{1} transforms!", battler.pbThis))
  }
)

BattleHandlers::AbilityChangeOnBattlerFainting.add(:SAIYANWARRIOR,
    proc { |ability, battler, fainted, battle|
        next if battler.opposes?(fainted)
        next unless battler.species == :GOKU
        next unless battler.form == 0
        next unless battler.level >= 15
        battler.pbChangeForm(1, _INTL("{1} is filled with rage!", battler.pbThis))
    }
)

BattleHandlers::FullMoonAbility.add(:SAIYANWARRIOR,
    proc { |ability, battler, battle|
        next unless battler.species == :GOKU
        if battler.form == 0 && battler.level >= 20
          battler.pbChangeForm(8, _INTL("{1}'s transforms with exposure to the Full Moon!", battler.pbThis))
        elsif battler.form == 1 && battler.level >= 40
          battler.pbChangeForm(9, _INTL("{1}'s transforms with exposure to the Full Moon!", battler.pbThis))
        end 
    }
)

BattleHandlers::EOREffectAbility.add(:GREATAPE,
  proc { |ability, battler, battle, aiCheck|
    next 0 if aiCheck
    next unless battler.species == :GOKU
    next unless battler.form == 9
    next if battler.effectActive?(:GoldenOozaru)    
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
    end,
    :eor_proc => proc do |battle, battler, _value|
        if battler.takesIndirectDamage?
            battle.pbDisplay(_INTL("{1} damages himself in his rampage!", battler.pbThis))
            battler.applyFractionalDamage(APE_DAMAGE_FRACTION, false)
        end 
    end, 
})

APE_DAMAGE_FRACTION = 0.20

BattleHandlers::UserAbilityEndOfMove.add(:GREATAPE,
  proc { |ability, user, targets, move, battle, _switchedBattlers|
      next unless user.species == :GOKU
      next unless user.form == 9
      next unless user.level >= 50
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

BattleHandlers::EOREffectAbility.add(:ULTRAINSTINCT,
  proc { |ability, battler, battle|
      next unless battler.species == :GOKU
      next unless battler.form == 6
      next unless battler.belowHalfHealth?
      battle.pbShowAbilitySplash(battler, ability)
      battler.pbChangeForm(7, _INTL("{1} calms down in the face of danger.", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
  }
)
      