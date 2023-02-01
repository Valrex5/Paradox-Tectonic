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
        return false if shouldAbilityApply?(GameData::Ability::SUN_ABILITIES, checkingForAI)
        return true
    end

    def debuffedByRain?(checkingForAI = false)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false if shouldTypeApply?(:WATER, checkingForAI) || shouldTypeApply?(:ELECTRIC, checkingForAI)
        return false if shouldAbilityApply?(GameData::Ability::RAIN_ABILITIES, checkingForAI)
        return true
    end  

    def takesSandstormDamage?(checkingForAI = false)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false unless takesIndirectDamage?
        return false if hasActiveItem?(:SAFETYGOGGLES)
        return false if shouldTypeApply?(:GROUND,checkingForAI) || shouldTypeApply?(:ROCK,checkingForAI)
        return false if shouldAbilityApply?(GameData::Ability::SAND_ABILITIES, checkingForAI)
        return true
    end

    def takesHailDamage?(checkingForAI = false)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false unless takesIndirectDamage?
        return false if hasActiveItem?(:SAFETYGOGGLES)
        return false if shouldTypeApply?(:ICE,checkingForAI) || shouldTypeApply?(:GHOST,checkingForAI)
        return false if shouldAbilityApply?(GameData::Ability::HAIL_ABILITIES, checkingForAI)
        return true
    end

    def debuffedByEclipse?(checkingForAI = false)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false if shouldTypeApply?(:PSYCHIC, checkingForAI) || shouldTypeApply?(:DRAGON, checkingForAI)
        setterAbilities = %i[HARBINGER SUNEATER]
        synergyAbilities = %i[APPREHENSIVE TOTALGRASP EXTREMOPHILE WORLDQUAKE RESONANCE DISTRESSING SHAKYCODE MYTHICSCALES SHATTERING
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
        synergyAbilities = %i[MOONGAZE LUNARLOYALTY LUNATIC MYSTICTAP NEERDOWELL ASTRALBODY NIGHTLIGHT NIGHTLIFE FULLMOONBLADE
                            MALICIOUSGLOW MOONMIRROR NIGHTVISION MOONLIGHTER ONEDGE NIGHTSTALKER WEREWOLF MIDNIGHTTOIL MOONBUBBLE]
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