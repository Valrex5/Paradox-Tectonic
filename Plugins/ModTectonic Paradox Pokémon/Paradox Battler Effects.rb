GameData::BattleEffect.register_effect(:Battler, {
    :id => :Thunderstorm,
    :real_name => "Thunderstorm",
})

GameData::BattleEffect.register_effect(:Battler, {
    :id => :BurningBalwark,
    :real_name => "Burning Balwark",
    :resets_eor	=> true,
    :protection_info => {
        :hit_proc => proc do |user, target, move, _battle|
            user.applyBurn(target) if move.physicalMove? && user.canBurn?(target, false)
        end,
    },
})

GameData::BattleEffect.register_effect(:Battler, {
    :id => :DragRace,
    :real_name => "Drag Race Count",
    :type => :Integer,
    :maximum => 4,
    :resets_on_cancel => true,
    :resets_on_move_start => true,
    :snowballing_move_counter => true,
})
