MultipleForms.register(:DIALGA,{
  "getForm" => proc { |pkmn|
    maps = [49,50,51,72,73]   # Map IDs for Origin Forme
    if pkmn.hasItem?(:ADAMANTORB) || ($game_map && maps.include?($game_map.map_id))
      next 1
    end
    next 0
  }
})

MultipleForms.register(:PALKIA,{
  "getForm" => proc { |pkmn|
    maps = [49,50,51,72,73]   # Map IDs for Origin Forme
    if pkmn.hasItem?(:LUSTROUSORB) || ($game_map && maps.include?($game_map.map_id))
      next 1
    end
    next 0
  }
})