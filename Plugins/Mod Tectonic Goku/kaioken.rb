class PokeBattle_Move_Kaioken < PokeBattle_MultiStatUpMove
  def pbMoveFailed?(user, _targets, show_message)
    if !user.countsAs?(:GOKU)
        @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
        return true
    elsif not (user.form == 0 || user.form == 5)
        @battle.pbDisplay(_INTL("But {1} can't use it the way it is now!", user.pbThis(true))) if show_message
        return true
    elsif user.effectActive?(:Kaioken4)
        @battle.pbDisplay(_INTL("But {1} can't go any further!", user.pbThis(true))) if show_message
        return true 
    end
    return false
  end 

  def pbEffectGeneral(user)
    if user.effectActive?(:Kaioken)
      user.disableEffect(:Kaioken)
      user.applyEffect(:Kaioken3)
    elsif user.effectActive?(:Kaioken3)
      user.disableEffect(:Kaioken3)
      user.applyEffect(:Kaioken4)
    elsif user.form == 5
      user.applyEffect(:KaiokenBlue) 
    else
      user.applyEffect(:Kaioken) 
    end 
  end
end

GameData::BattleEffect.register_effect(:Battler, {
    :id => :Kaioken,
    :real_name => "Kaioken",
    :baton_passed => true,
    :apply_proc => proc do |battle, battler, _value|
        battle.pbDisplay(_INTL("{1} uses the Kaioken!", battler.pbThis))
        battler.pbRaiseMultipleStatSteps([:ATTACK, 4, :SPECIAL_ATTACK, 4], battler)
    end,
    :eor_proc => proc do |battle, battler, _value|
        if battler.takesIndirectDamage?
            battle.pbDisplay(_INTL("The Kaioken hurts {1}'s body!", battler.pbThis))
            battler.applyFractionalDamage(KAIO_DAMAGE_FRACTION, false)
        end
    end,
})

GameData::BattleEffect.register_effect(:Battler, {
    :id => :Kaioken3,
    :real_name => "Kaioken x3",
    :baton_passed => true,
    :apply_proc => proc do |battle, battler, _value|
        battle.pbDisplay(_INTL("{1} boosts his Kaioken!", battler.pbThis))
        battler.pbRaiseMultipleStatSteps([:ATTACK, 4, :SPECIAL_ATTACK, 4], battler)
    end,
    :eor_proc => proc do |battle, battler, _value|
        if battler.takesIndirectDamage?
            battle.pbDisplay(_INTL("The Kaioken hurts {1}'s body!", battler.pbThis))
            battler.applyFractionalDamage(KAIO2_DAMAGE_FRACTION, false)
        end
    end,
})

GameData::BattleEffect.register_effect(:Battler, {
    :id => :Kaioken4,
    :real_name => "Kaioken x4",
    :baton_passed => true,
    :apply_proc => proc do |battle, battler, _value|
        battle.pbDisplay(_INTL("{1} boosts his Kaioken even further!", battler.pbThis))
        battler.pbRaiseMultipleStatSteps([:ATTACK, 4, :SPECIAL_ATTACK, 4], battler)
    end,
    :eor_proc => proc do |battle, battler, _value|
        if battler.takesIndirectDamage?
            battle.pbDisplay(_INTL("The Kaioken hurts {1}'s body!", battler.pbThis))
            battler.applyFractionalDamage(KAIO3_DAMAGE_FRACTION, false)
        end
    end,
})

GameData::BattleEffect.register_effect(:Battler, {
    :id => :KaiokenBlue,
    :real_name => "Blue Kaioken",
    :baton_passed => true,
    :apply_proc => proc do |battle, battler, _value|
        battle.pbDisplay(_INTL("{1} uses the Kaioken!", battler.pbThis))
        battler.pbRaiseMultipleStatSteps([:ATTACK, 4, :SPECIAL_ATTACK, 4], battler)
    end,
    :eor_proc => proc do |battle, battler, _value|
        if battler.takesIndirectDamage?
            battle.pbDisplay(_INTL("The Kaioken hurts {1}'s body!", battler.pbThis))
            battler.applyFractionalDamage(KAIOBLUE_DAMAGE_FRACTION, false)
        end
    end,
})

KAIO_DAMAGE_FRACTION = 0.10

KAIO2_DAMAGE_FRACTION = 0.20

KAIO3_DAMAGE_FRACTION = 0.30

KAIOBLUE_DAMAGE_FRACTION = 0.25