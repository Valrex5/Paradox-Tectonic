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