##############################################
# TYPE REWARDS (54 of them)
##############################################
typeThreshold = [10,25,50]
typeRewards = [[:EXPCANDYM,8],[:EXPCANDYL,4],[:EXPCANDYXL,2]]

PokEstate::LoadDataDependentAwards += proc {
    # For every type, create three award event subscribers at different thresholds
    GameData::Type.each do |type|
        next if type.pseudo_type
        next if type.id == :MUTANT
        typeThreshold.each_with_index do |threshold,thresholdIndex|
            id = ("TYPE" + type.id.to_s + "AWARD" + thresholdIndex.to_s).to_sym
            PokEstate::GrantAwards.add(id,
                proc { |pokedex|
                    next typeReward(type.id,threshold,typeRewards[thresholdIndex])
                }
            )
        end
    end
}

##############################################
# TRIBE REWARDS (44 of them)
##############################################
tribeThreshold = [15,30]
tribeRewards = [[:EXPCANDYM,6],[:EXPCANDYL,3]]

PokEstate::LoadDataDependentAwards += proc {
    # For every type, create three award event subscribers at different thresholds
    GameData::Tribe.each do |tribe|
        tribeThreshold.each_with_index do |threshold,thresholdIndex|
            id = ("TRIBE" + tribe.id.to_s + "AWARD" + thresholdIndex.to_s).to_sym
            PokEstate::GrantAwards.add(id,
                proc { |pokedex|
                    next tribeReward(tribe.id,threshold,tribeRewards[thresholdIndex])
                }
            )
        end
    end
}

##############################################
# ROUTE REWARDS (45  of them)
##############################################
# 0
SMALL_ROUTES_CASABA = [
]

# 13
SMALL_ROUTES_PRE_SURF = [
    56, # Novo Town
    25, # Grouz
    36, # Grouz Mine
    326, # Carnation Graves
    6, # LuxTech Campus
    40, # Gigalith's Guts
    120, # Hollowed Layer
    214, # Team Chasm HQ
    37, # Svait
    117, # Ice Cave
    122, # LuxTech Sewers
    121, # Kilna Ascent
    8, # Velenz
    129, # Barren Crater
]

# 7
SMALL_ROUTES_POST_SURF = [
    155, # Prizca West
    223, # Battle Plaza Underground
    220, # Ancient Sewers
    34, # Battle Plaza
    187, # Prizca East
    217, # Sweetrock Harbor
    316, # Sandstone Estuary
]
 
# 5
MEDIUM_ROUTES_CASABA = [
    136, # Casaba Villa
    138, # Scenic Trail
    30, # Windy Way
    51, # Foreclosed Tunnel
    26, # Bluepoint Grotto
]

# 6
MEDIUM_ROUTES_PRE_SURF =
[
    59, # Feebas' Fin
    60, # Shipping Lane
    3, # The Shelf
    55, # Lingering Delta
    11, # Eleig River Crossing
    7, # Repora Forest
]

# 7
MEDIUM_ROUTES_POST_SURF = [
    130, # Canal Desert
    186, # Frostflow Farms
    216, # Highland Lake
    193, # Volcanic Shore
    196, # Boiling Cave
    288, # Underground River
    218, # Abyssal Cavern
]

# 1
BIG_ROUTES_CASABA = [
    38, # Bluepoint Beach
]

# 2
BIG_ROUTES_PRE_SURF = [
    53, # The Shelf
    301, # County Park
]

# 2
BIG_ROUTES_POST_SURF = [
    185, # Eleig Stretch
    211, # Split Peaks
]

PokEstate::LoadDataDependentAwards += proc {
    # SMALL ROUTES #
    SMALL_ROUTES_CASABA.each do |routeID|
        routeName = pbGetMapNameFromId(routeID)
        id = ("ROUTE" + routeName + "AWARD").to_sym
        PokEstate::GrantAwards.add(id,
            proc { |pokedex|
                if pokedex.allOwnedFromRoute?(routeID)
                    next [[:EXPCANDYS,5],_INTL("all species on {1}",routeName)]
                end
                next
            }
        )
    end

    SMALL_ROUTES_PRE_SURF.each do |routeID|
        routeName = pbGetMapNameFromId(routeID)
        id = ("ROUTE" + routeName + "AWARD").to_sym
        PokEstate::GrantAwards.add(id,
            proc { |pokedex|
                if pokedex.allOwnedFromRoute?(routeID)
                    next [[:EXPCANDYM,3],_INTL("all species on {1}",routeName)]
                end
                next
            }
        )
    end

    SMALL_ROUTES_POST_SURF.each do |routeID|
        routeName = pbGetMapNameFromId(routeID)
        id = ("ROUTE" + routeName + "AWARD").to_sym
        PokEstate::GrantAwards.add(id,
            proc { |pokedex|
                if pokedex.allOwnedFromRoute?(routeID)
                    next [[:EXPCANDYL,2],_INTL("all species on {1}",routeName)]
                end
                next
            }
        )
    end

    # MEDIUM ROUTES #

    MEDIUM_ROUTES_CASABA.each do |routeID|
        routeName = pbGetMapNameFromId(routeID)
        id = ("ROUTE" + routeName + "AWARD").to_sym
        PokEstate::GrantAwards.add(id,
            proc { |pokedex|
                if pokedex.allOwnedFromRoute?(routeID)
                    next [[:EXPCANDYS,10],_INTL("all species on {1}",routeName)]
                end
                next
            }
        )
    end

    MEDIUM_ROUTES_PRE_SURF.each do |routeID|
        routeName = pbGetMapNameFromId(routeID)
        id = ("ROUTE" + routeName + "AWARD").to_sym
        PokEstate::GrantAwards.add(id,
            proc { |pokedex|
                if pokedex.allOwnedFromRoute?(routeID)
                    next [[:EXPCANDYM,6],_INTL("all species on {1}",routeName)]
                end
                next
            }
        )
    end

    MEDIUM_ROUTES_POST_SURF.each do |routeID|
        routeName = pbGetMapNameFromId(routeID)
        id = ("ROUTE" + routeName + "AWARD").to_sym
        PokEstate::GrantAwards.add(id,
            proc { |pokedex|
                if pokedex.allOwnedFromRoute?(routeID)
                    next [[:EXPCANDYL,4],_INTL("all species on {1}",routeName)]
                end
                next
            }
        )
    end

    # BIG ROUTES #

    BIG_ROUTES_CASABA.each do |routeID|
        routeName = pbGetMapNameFromId(routeID)
        id = ("ROUTE" + routeName + "AWARD").to_sym
        PokEstate::GrantAwards.add(id,
            proc { |pokedex|
                if pokedex.allOwnedFromRoute?(routeID)
                    next [[:EXPCANDYS,15],_INTL("all species on {1}",routeName)]
                end
                next
            }
        )
    end

    BIG_ROUTES_PRE_SURF.each do |routeID|
        routeName = pbGetMapNameFromId(routeID)
        id = ("ROUTE" + routeName + "AWARD").to_sym
        PokEstate::GrantAwards.add(id,
            proc { |pokedex|
                if pokedex.allOwnedFromRoute?(routeID)
                    next [[:EXPCANDYM,9],_INTL("all species on {1}",routeName)]
                end
                next
            }
        )
    end

    BIG_ROUTES_POST_SURF.each do |routeID|
        routeName = pbGetMapNameFromId(routeID)
        id = ("ROUTE" + routeName + "AWARD").to_sym
        PokEstate::GrantAwards.add(id,
            proc { |pokedex|
                if pokedex.allOwnedFromRoute?(routeID)
                    next [[:EXPCANDYL,6],_INTL("all species on {1}",routeName)]
                end
                next
            }
        )
    end

    # HUGE ROUTES #

    PokEstate::GrantAwards.add("MENAGERIEREWARD",
        proc { |pokedex|
            if pokedex.allOwnedFromRoute?(213)
                next [[:EXPCANDYXL,10],_INTL("all species in the Velenz Menagerie")]
            end
            next
        }
    )

    PokEstate::GrantAwards.add("OCEANFISHINGREWARD",
        proc { |pokedex|
            if pokedex.allOwnedFromRoute?(213)
                next [[:EXPCANDYXL,10],_INTL("all species in the Ocean Fishing Contest")]
            end
            next
        }
    )
}
