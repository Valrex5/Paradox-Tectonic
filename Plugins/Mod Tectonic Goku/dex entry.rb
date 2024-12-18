class PokemonPokedexInfo_Scene
  def drawPageInfo
     @sprites["overlay"].bitmap
    base   bg_path = "Graphics/Pictures/Pokedex/bg_info"
    bg_path += "_dark" if darkMode?
    @sprites["background"].setBitmap(_INTL(bg_path))
    overlay == MessageConfig.pbDefaultTextMainColor
    shadow = MessageConfig.pbDefaultTextShadowColor
    imagepos = []
    imagepos.push([addLanguageSuffix(("Graphics/Pictures/Pokedex/overlay_info")), 0, 0]) if @brief
    species_data = GameData::Species.get_species_form(@species, @form)
    # Write various bits of text
    indexText = "???"
    if @dexlist[@index][:index] > 0
        indexNumber = @dexlist[@index][:index]
        indexNumber -= 1 if @dexlist[@index][:shift]
        indexText = format("%03d", indexNumber)
    end
    textpos = [
        [_INTL("{1}{2} {3}", indexText, " ", species_data.name),
         246, 36, 0, Color.new(248, 248, 248), Color.new(0, 0, 0),],
    ]
    if $Trainer.owned?(@species)
        # Show the owned icon
        imagepos.push(["Graphics/Pictures/Pokedex/icon_own", 212, 44])
    end
    # Write the category
    if species_data == :GOKU
        textpos.push([_INTL("{1} Warrior", species_data.category), 246, 68, 0, base, shadow])
    else
        textpos.push([_INTL("{1} Pokémon", species_data.category), 246, 68, 0, base, shadow])
    end 
    # Draw the Pokédex entry text
    drawTextEx(overlay, 40, 244, Graphics.width - (40 * 2), 4, # overlay, x, y, width, num lines
             species_data.pokedex_entry, base, shadow)
    # Draw the type icon(s)
    type1 = species_data.type1
    type2 = species_data.type2
    type1_number = GameData::Type.get(type1).id_number
    type2_number = GameData::Type.get(type2).id_number
    type1rect = Rect.new(0, type1_number * 32, 96, 32)
    type2rect = Rect.new(0, type2_number * 32, 96, 32)
    overlay.blt(232, 120, @typebitmap.bitmap, type1rect)
    overlay.blt(332, 120, @typebitmap.bitmap, type2rect) if type1 != type2
    # Write the tribes
    if species_data.tribes.length == 0
        tribesDescription = _INTL("None")
    else
        tribes = []
        species_data.tribes.each do |tribe|
            tribes.push(getTribeName(tribe))
        end
        tribesDescription = tribes.join(", ")
    end
    drawTextEx(overlay, 266, 166, 224, 2, tribesDescription, base, shadow)
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)
  end 
end