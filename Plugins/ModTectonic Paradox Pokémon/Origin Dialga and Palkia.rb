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

#===============================================================================
# Starts darkened sun weather. (Noachian Light)
#===============================================================================
class PokeBattle_Move_StartDarkenedSun8 < PokeBattle_WeatherMove
  include EmpoweredMove
  def pbMoveFailed?(user, targets, show_message)
    return false if GameData::Type.exists?(:FIRE) && !user.pbHasType?(:FIRE) && user.canChangeType?
    super
  end

  def initialize(battle, move)
      super
      @weatherType = :DarkenedSun
  end

  def pbEffectGeneral(user)
    super
    transformType(user, :PSYCHIC)
    user.applyEffect(:Type3, :FIRE)
  end
end

#===============================================================================
# Starts brilliant rain weather. (Nouvelle Night)
#===============================================================================
class PokeBattle_Move_StartBrilliantRain8 < PokeBattle_WeatherMove
  include EmpoweredMove
  def pbMoveFailed?(user, targets, show_message)
    return false if GameData::Type.exists?(:FAIRY) && !user.pbHasType?(:FAIRY) && user.canChangeType?
    super
  end

  def initialize(battle, move)
      super
      @weatherType = :BrilliantRain
  end

  def pbEffectGeneral(user)
    super
    transformType(user, :WATER)
    user.applyEffect(:Type3, :FAIRY)
  end
end
