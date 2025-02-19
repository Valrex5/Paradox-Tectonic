GameData::BattleWeather.register({
  :id        => :DarkenedSun,
  :name      => _INTL("Darkened Sun"),
  :animation => "Eclipse",
})

GameData::BattleWeather.register({
  :id        => :BrilliantRain,
  :name      => _INTL("Brilliant Rain"),
  :animation => "Rainstorm",
})

class PokeBattle_Battle
  def displayResetWeatherMessage
    case @field.weather
    when :DarkenedSun   then pbDisplay(_INTL("The darkened sunshine continues!"))
    when :BrilliantRain then pbDisplay(_INTL("The brilliant rain continues!"))  
    end
  end   
  
  
  def displayFreshWeatherMessage
    case @field.weather
    when :DarkenedSun   then pbDisplay(_INTL("An eclipse covers the shining sun!"))
    when :BrilliantRain then pbDisplay(_INTL("The moon shines behind the storm!"))
    end 
  end   
    
  def endWeather
    return if @field.weather == :None
    case @field.weather
    when :DarkenedSun   then pbDisplay(_INTL("The darkened sun ends."))
    when :BrilliantRain then pbDisplay(_INTL("The brilliant rain ends."))
    end
    oldWeather = @field.weather
    @field.weather	= :None
    @field.weatherDuration = 0
    @field.resetSpecialEffect
    triggerWeatherChangeDialogue(oldWeather, :None)
  end 

  def pbEndPrimordialWeather
    return unless @field.weatherDuration < 0
    case @field.weather
    when :DarkenedSun
      if !pbCheckGlobalAbility(:ORICHALCHUMPRESENCE)
          @field.weatherDuration = 3
          pbDisplay("The darkened sun begins to fade!")
      end
    when :BrilliantRain
      if !pbCheckGlobalAbility(:HADRONSYSTEM) 
          @field.weatherDuration = 3
          pbDisplay("The brilliant rain begins to fade!")  
      end     
    end
  end   

  def primevalWeatherPresent?(showMessages = true)
    case @field.weather
    when :DarkenedSun
      pbDisplay(_INTL("The darkened sun doesn't retreat!")) if showMessages
      return true
    when :BrilliantRain
      pbDisplay(_INTL("The brilliant rain doesn't retreat!")) if showMessages
      return true
    end 
    return false
  end 

  def pbSORWeather(priority)
    curWeather = pbWeather

    @field.specialTimer += 1

    threshold = SPECIAL_EFFECT_WAIT_TURNS
    threshold /= 2 if weatherSpedUp?

    showWeatherMessages = $PokemonSystem.weather_messages == 0

    if @field.specialTimer >= threshold
        case curWeather
        when :DarkenedSun
            primevalVariant = curWeather == :RingEclipse
            if showWeatherMessages
                if primevalVariant
                    pbDisplay(_INTL("The Total Ring Eclipse arrives!"))
                else
                    pbDisplay(_INTL("The Total Eclipse arrives!"))
                end
            end
            pbCommonAnimation("Eclipse")
            anyAffected = false
            debuff = primevalVariant ? ALL_STATS_3 : ALL_STATS_2
            priority.each do |b|
                next if b.fainted?
                next unless b.debuffedByEclipse?
                if primevalVariant
                    pbDisplay(_INTL("{1} is severely panicked!", b.pbThis))
                else
                    pbDisplay(_INTL("{1} is panicked!", b.pbThis))
                end
                b.pbLowerMultipleStatSteps(debuff, b)
                anyAffected = true
            end
            pbDisplay(_INTL("But no one was panicked.")) if showWeatherMessages && !anyAffected
            eachBattler do |b|
                b.eachActiveAbility do |ability|
                    BattleHandlers.triggerTotalEclipseAbility(ability, b, self)
                end
            end
        when :Moonglow, :BloodMoon, :BrilliantRain
            primevalVariant = curWeather == :BloodMoon
            if showWeatherMessages
                if primevalVariant
                    pbDisplay(_INTL("The Full Blood Moon rises!"))
                else
                    pbDisplay(_INTL("The Full Moon rises!"))
                end
            end
            pbAnimation(:Moonglow, @battlers[0], [])
            anyAffected = false
            priority.each do |b|
                next if b.fainted?
                next unless b.flinchedByMoonglow?
                pbDisplay(_INTL("{1} is moonstruck! It'll flinch this turn!", b.pbThis))
                b.pbFlinch
                if primevalVariant
                    b.applyFractionalDamage(1.0/4.0)
                    pbDisplay(_INTL("{1} is afflicted by the nightmarish moon!", b.pbThis))
                end
                anyAffected = true
            end
            pbDisplay(_INTL("But no one was moonstruck.")) if showWeatherMessages && !anyAffected
            eachBattler do |b|
                b.eachActiveAbility do |ability|
                    BattleHandlers.triggerFullMoonAbility(ability, b, self)
                end
            end
        end
        @field.specialTimer = 0
        @field.specialWeatherEffect = true
    else
        @field.specialWeatherEffect = false

        # Special effect happening next turn
        if @field.specialTimer + 1 == threshold && @field.weatherDuration > 1
            if showWeatherMessages
                case curWeather
                when :Eclipse
                    pbDisplay(_INTL("The Total Eclipse is approaching."))
                when :Moonglow
                    pbDisplay(_INTL("The Full Moon is approaching."))
                when :RingEclipse
                    pbDisplay(_INTL("The Total Ring Eclipse is approaching."))
                when :BloodMoon
                    pbDisplay(_INTL("The Full Blood Moon is approaching."))
                end
            end
        end
    end

  def sunny?
    return %i[Sunshine HarshSun DarkenedSun].include?(pbWeather)
  end

  def eclipsed?
    return %i[Eclipse RingEclipse DarkenedSun].include?(pbWeather)
  end

  def rainy?
    return %i[Rainstorm HeavyRain BrilliantRain].include?(pbWeather)
  end 

  def moonGlowing?
    return %i[Moonglow BloodMoon BrilliantRain].include?(pbWeather)
  end   
end 
end

class PokeBattle_Move
  def pbCalcWeatherDamageMultipliers(user,target,type,multipliers,checkingForAI=false)
      weather = @battle.pbWeather
      case weather
      when :DarkenedSun
          if type == :FIRE || :PSYCHIC 
              damageBonus = weather == :HarshSun ? 0.5 : 0.3
              damageBonus *= 2 if @battle.curseActive?(:CURSE_BOOSTED_SUN)
              multipliers[:final_damage_multiplier] *= (1 + damageBonus)
          elsif applySunDebuff?(user,type,checkingForAI)
              damageReduction = 0.15
              damageReduction *= 2 if @battle.pbCheckGlobalAbility(:BLINDINGLIGHT)
              damageReduction *= 2 if @battle.curseActive?(:CURSE_BOOSTED_SUN)
              multipliers[:final_damage_multiplier] *= (1 - damageReduction)
          end
      when :BrilliantRain
          if type == :WATER || :FAIRY 
              damageBonus = weather == :HeavyRain ? 0.5 : 0.3
              damageBonus *= 2 if @battle.curseActive?(:CURSE_BOOSTED_RAIN)
              multipliers[:final_damage_multiplier] *= (1 + damageBonus)
          elsif applyRainDebuff?(user,type,checkingForAI)
              damageReduction = 0.15
              damageReduction *= 2 if @battle.pbCheckGlobalAbility(:DREARYCLOUDS)
              damageReduction *= 2 if @battle.curseActive?(:CURSE_BOOSTED_RAIN)
              multipliers[:final_damage_multiplier] *= (1 - damageReduction)
          end
      end
  end
end 

class PokeBattle_Move_TypeDependsOnWeatherUsesBetterAttackingStat < PokeBattle_Move

  def pbBaseType(_user)
      ret = :NORMAL
      case @battle.pbWeather
      when :DarkenedSun
          ret = :FIRE if GameData::Type.exists?(:FIRE)
      when :BrilliantRain
          ret = :FAIRY if GameData::Type.exists?(:FAIRY)
      end
      return ret
  end
  def pbCalcTypeModSingle(moveType, defType, user, target)
    ret = super
    if :DarkenedSun 
        psychicEff = Effectiveness.calculate_one(:PSYCHIC, defType) if GameData::Type.exists?(:PSYCHIC)
        ret *= psychicEff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
    end
    if :BrilliantRain 
      waterEff = Effectiveness.calculate_one(:WATER, defType) if GameData::Type.exists?(:WATER)
      ret *= waterEff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
    end
    return ret
end
end