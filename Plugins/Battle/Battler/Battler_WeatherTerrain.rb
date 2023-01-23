class PokeBattle_Battler
    def affectedByTerrain?(checkingForAI = false)
        return false if airborne?(checkingForAI)
        return false if semiInvulnerable?
        return true
    end

    def affectedByWeatherDownsides?(checkingForAI = false)
        return false if inTwoTurnAttack?("0CA", "0CB")   # Dig, Dive
        return false if shouldAbilityApply?(%i[STOUT WEATHERSENSES TERRITORIAL METALCOVER], checkingForAI)
        return false if hasActiveItem?(:UTILITYUMBRELLA)
        return false if @battle.pbCheckAlliedAbility(:HIGHRISE, @index)
        return true
    end

    def debuffedBySun?(checkingForAI = false)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false if shouldTypeApply?(:FIRE, checkingForAI) || shouldTypeApply?(:GRASS, checkingForAI)
        setterAbilities = %i[DROUGHT INNERLIGHT]
        synergyAbilities = %i[CHLOROPHYLL SOLARPOWER LEAFGUARD FLOWERGIFT MIDNIGHTSUN HARVEST SUNCHASER HEATSAVOR
                              BLINDINGLIGHT SOLARCELL ROAST FINESUGAR REFRESHMENTS HEATVEIL]
        return false if shouldAbilityApply?(setterAbilities,
checkingForAI) || shouldAbilityApply?(synergyAbilities, checkingForAI)
        return true
    end

    def debuffedByRain?(checkingForAI = false)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false if shouldTypeApply?(:WATER, checkingForAI) || shouldTypeApply?(:ELECTRIC, checkingForAI)
        setterAbilities = %i[DRIZZLE STORMBRINGER]
        synergyAbilities = %i[SWIFTSWIM RAINDISH HYDRATION TIDALFORCE STORMFRONTRAINPRISM DREARYCLOUDS DRYSKIN
                              RAINPRISM]
        return false if shouldAbilityApply?(setterAbilities,
checkingForAI) || shouldAbilityApply?(synergyAbilities, checkingForAI)
        return true
    end

    def takesSandstormDamage?(checkingForAI = false)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false unless takesIndirectDamage?
        return false if hasActiveItem?(:SAFETYGOGGLES)
        return false if shouldTypeApply?(:GROUND,checkingForAI) || shouldTypeApply?(:ROCK,	checkingForAI)
        setterAbilities = %i[SANDSTREAM SANDBURST]
        synergyAbilities = %i[OVERCOAT SANDFORCE SANDRUSH SANDSHROUD DESERTSPIRITBURROWER SHRAPNELSTORM HARSHHUNTER]
        return false if shouldAbilityApply?(setterAbilities,
checkingForAI) || shouldAbilityApply?(synergyAbilities, checkingForAI)
        return true
    end

    def takesHailDamage?(checkingForAI = false)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false unless takesIndirectDamage?
        return false if hasActiveItem?(:SAFETYGOGGLES)
        return false if shouldTypeApply?(:ICE, checkingForAI) || shouldTypeApply?(:GHOST,	checkingForAI)
        setterAbilities = %i[SNOWWARNING FROSTSCATTER]
        synergyAbilities = %i[OVERCOAT ICEBODY SNOWSHROUD BLIZZBOXER SLUSHRUSH ICEFACEBITTERCOLD ECTOPARTICLES]
        return false if shouldAbilityApply?(setterAbilities,
checkingForAI) || shouldAbilityApply?(synergyAbilities, checkingForAI)
        return true
    end

    def debuffedByEclipse?(checkingForAI = false)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false if shouldTypeApply?(:PSYCHIC, checkingForAI) || shouldTypeApply?(:DRAGON, checkingForAI)
        setterAbilities = %i[HARBINGER SUNEATER]
        synergyAbilities = %i[APPREHENSIVE TOTALGRASP EXTREMOPHILE WORLDQUAKE RESONANCE DISTRESSING SHAKYCODE MYTHICSCALES
                              STARSALIGN WARPINGEFFECT TOLLDANGER DRAMATICLIGHTING CALAMITY ANARCHIC MENDINGTONES PEARLSEEKER]
        return false if shouldAbilityApply?(setterAbilities,checkingForAI) ||
            shouldAbilityApply?(synergyAbilities, checkingForAI)
        return true
    end

    def flinchedByMoonlight?(checkingForAI = false)
        return false if shouldAbilityApply?(:INNERFOCUS, checkingForAI)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false if shouldTypeApply?(:FAIRY, checkingForAI) || shouldTypeApply?(:DARK, checkingForAI)
        setterAbilities = %i[MOONGAZE LUNARLOYALTY]
        synergyAbilities = %i[]
        return false if shouldAbilityApply?(setterAbilities,checkingForAI) ||
            shouldAbilityApply?(synergyAbilities, checkingForAI)
        return true
    end

    def takesShadowSkyDamage?
        return false if fainted?
        return false if shadowPokemon?
        return true
    end
end
