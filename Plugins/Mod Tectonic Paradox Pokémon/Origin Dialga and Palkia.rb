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

  def pbEffectGeneral(user)
    @battle.endWeather
    super
    transformType(user, :PSYCHIC)
    user.applyEffect(:Type3, :FIRE)
  end

  def initialize(battle, move)
    super
    @weatherType = :DarkenedSun
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

  def pbEffectGeneral(user)
    @battle.endWeather
    super
    transformType(user, :WATER)
    user.applyEffect(:Type3, :FAIRY)
  end

  def initialize(battle, move)
    super
    @weatherType = :BrilliantRain
end
end

class PokeBattle_AI_DIALGA < PokeBattle_AI_Boss
  def initialize(user, battle)
      super
      @warnedIFFMove.add(:WEATHERBURST, {
          :condition => proc { |_move, _user, _target, battle|
              next battle.pbWeather == :BrilliantRain
              next battle.turnCount > 0 && battle.turnCount % 3 == 0
          },
          :warning => proc { |_move, user, targets, _battle|
              _INTL("{1} takes power from the weird conditions!",user.pbThis)
          },
      })
  end
end

class PokeBattle_AI_PALKIA < PokeBattle_AI_Boss
  def initialize(user, battle)
      super
      @warnedIFFMove.add(:WEATHERBURST, {
          :condition => proc { |_move, _user, _target, battle|
              next battle.pbWeather == :DarkenedSun
              next battle.turnCount > 0 && battle.turnCount % 3 == 0
          },
          :warning => proc { |_move, user, targets, _battle|
              _INTL("{1} takes power from the weird conditions!",user.pbThis)
          },
      })
  end
end