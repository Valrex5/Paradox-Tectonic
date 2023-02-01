module GameData
    class Ability
        SUN_ABILITIES = %i[DROUGHT INNERLIGHT CHLOROPHYLL SOLARPOWER LEAFGUARD FLOWERGIFT MIDNIGHTSUN
                        HARVEST SUNCHASER HEATSAVOR BLINDINGLIGHT SOLARCELL SUSTAINABLE FINESUGAR REFRESHMENTS
                        HEATVEIL OXYGENATION 
        ]

        RAIN_ABILITIES = %i[DRIZZLE STORMBRINGER SWIFTSWIM RAINDISH HYDRATION TIDALFORCE STORMFRONT
                          DREARYCLOUDS DRYSKIN RAINPRISM STRIKETWICE AQUAPROPULSION OVERWHELM ARCCONDUCTOR
        ]

        SAND_ABILITIES = %i[SANDSTREAM SANDBURST SANDFORCE SANDRUSH SANDSHROUD DESERTSPIRIT
                          SHRAPNELSTORM HARSHHUNTER SANDPOWER
        ]

        HAIL_ABILITIES = %i[SNOWWARNING FROSTSCATTER ICEBODY SNOWSHROUD BLIZZBOXER SLUSHRUSH ICEFACE
                          BITTERCOLD ECTOPARTICLES ICEQUEEN
        ]

        attr_reader :signature_of

        # The highest evolution of a line
        def signature_of=(val)
          @signature_of = val
        end

        def is_signature?()
          return !@signature_of.nil?
        end

        def is_primeval?
          return @id.to_s[/PRIMEVAL/]
        end
    end
  end