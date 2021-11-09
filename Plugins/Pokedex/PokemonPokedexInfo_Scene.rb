class PokemonPokedexInfo_Scene
  def pbStartScene(dexlist,index,region,battle=false,linksEnabled=false)
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @dexlist = dexlist
    @index   = index
    @region  = region
    @page = battle ? 2 : 1
	@linksEnabled = linksEnabled
	@evolutionIndex = -1
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
	@moveInfoDisplayBitmap   	= AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/Rework/move_info_display"))
    @sprites = {}
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["infosprite"] = PokemonSprite.new(@viewport)
    @sprites["infosprite"].setOffset(PictureOrigin::Center)
    @sprites["infosprite"].x = 104
    @sprites["infosprite"].y = 136
    @mapdata = pbLoadTownMapData
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    mappos = (map_metadata) ? map_metadata.town_map_position : nil
    if @region < 0                                 # Use player's current region
      @region = (mappos) ? mappos[0] : 0                      # Region 0 default
    end
    @sprites["areamap"] = IconSprite.new(0,0,@viewport)
    @sprites["areamap"].setBitmap("Graphics/Pictures/#{@mapdata[@region][1]}")
    @sprites["areamap"].x += (Graphics.width-@sprites["areamap"].bitmap.width)/2
    @sprites["areamap"].y += (Graphics.height+32-@sprites["areamap"].bitmap.height)/2
    for hidden in Settings::REGION_MAP_EXTRAS
      if hidden[0]==@region && hidden[1]>0 && $game_switches[hidden[1]]
        pbDrawImagePositions(@sprites["areamap"].bitmap,[
           ["Graphics/Pictures/#{hidden[4]}",
              hidden[2]*PokemonRegionMap_Scene::SQUAREWIDTH,
              hidden[3]*PokemonRegionMap_Scene::SQUAREHEIGHT]
        ])
      end
    end
    @sprites["areahighlight"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["areaoverlay"] = IconSprite.new(0,0,@viewport)
    @sprites["areaoverlay"].setBitmap("Graphics/Pictures/Pokedex/overlay_area")
    @sprites["formfront"] = PokemonSprite.new(@viewport)
    @sprites["formfront"].setOffset(PictureOrigin::Center)
    @sprites["formfront"].x = 130
    @sprites["formfront"].y = 158
    @sprites["formback"] = PokemonSprite.new(@viewport)
    @sprites["formback"].setOffset(PictureOrigin::Bottom)
    @sprites["formback"].x = 382   # y is set below as it depends on metrics
    @sprites["formicon"] = PokemonSpeciesIconSprite.new(nil, @viewport)
    @sprites["formicon"].setOffset(PictureOrigin::Center)
    @sprites["formicon"].x = 82
    @sprites["formicon"].y = 328
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow",8,28,40,2,@viewport)
    @sprites["uparrow"].x = 242
    @sprites["uparrow"].y = 268
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = false
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow",8,28,40,2,@viewport)
    @sprites["downarrow"].x = 242
    @sprites["downarrow"].y = 348
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = false
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
	
	# Create the move extra info display
	@moveInfoDisplay = SpriteWrapper.new(@viewport)
    @moveInfoDisplay.bitmap = @moveInfoDisplayBitmap.bitmap
    @moveInfoDisplay.x      = Graphics.width - @moveInfoDisplayBitmap.width - 16
    @moveInfoDisplay.y      = Graphics.height - @moveInfoDisplayBitmap.height - 16
    @sprites["moveInfoDisplay"] = @moveInfoDisplay
	# Create overlay for selected move's extra info (shows move's BP, description)
    @extraInfoOverlay = BitmapSprite.new(@moveInfoDisplayBitmap.bitmap.width,@moveInfoDisplayBitmap.height,@viewport)
    @extraInfoOverlay.x = @moveInfoDisplay.x
    @extraInfoOverlay.y = @moveInfoDisplay.y
    pbSetNarrowFont(@extraInfoOverlay.bitmap)
    @sprites["extraInfoOverlay"] = @extraInfoOverlay
	@selectedMoveType = 
	
    @scroll = -1
	@title = "Undefined"
	pbSetSystemFont(@sprites["overlay"].bitmap)
    pbUpdateDummyPokemon
    @available = pbGetAvailableForms
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @typebitmap.dispose
    @viewport.dispose
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbUpdateDummyPokemon
    @species = @dexlist[@index][0]
    @gender, @form = $Trainer.pokedex.last_form_seen(@species)
    species_data = GameData::Species.get_species_form(@species, @form)
	@title = species_data.real_form_name ? "#{species_data.real_name} (#{species_data.real_form_name})" : species_data.real_name
    @sprites["infosprite"].setSpeciesBitmap(@species,@gender,@form)
    if @sprites["formfront"]
      @sprites["formfront"].setSpeciesBitmap(@species,@gender,@form)
    end
    if @sprites["formback"]
      @sprites["formback"].setSpeciesBitmap(@species,@gender,@form,false,false,true)
      @sprites["formback"].y = 256
      @sprites["formback"].y += species_data.back_sprite_y * 2
    end
    if @sprites["formicon"]
      @sprites["formicon"].pbSetParams(@species,@gender,@form)
    end
  end

  def pbGetAvailableForms
    ret = []
    multiple_forms = false
    # Find all genders/forms of @species that have been seen
    GameData::Species.each do |sp|
      next if sp.species != @species
      next if sp.form != 0 && (!sp.real_form_name || sp.real_form_name.empty?)
      next if sp.pokedex_form != sp.form
      multiple_forms = true if sp.form > 0
      case sp.gender_ratio
      when :AlwaysMale, :AlwaysFemale, :Genderless
        real_gender = (sp.gender_ratio == :AlwaysFemale) ? 1 : 0
        next if !$Trainer.pokedex.seen_form?(@species, real_gender, sp.form) && !Settings::DEX_SHOWS_ALL_FORMS
        real_gender = 2 if sp.gender_ratio == :Genderless
        ret.push([sp.form_name, real_gender, sp.form])
      else   # Both male and female
        for real_gender in 0...2
          next if !$Trainer.pokedex.seen_form?(@species, real_gender, sp.form) && !Settings::DEX_SHOWS_ALL_FORMS
          ret.push([sp.form_name, real_gender, sp.form])
          break if sp.form_name && !sp.form_name.empty?   # Only show 1 entry for each non-0 form
        end
      end
    end
    # Sort all entries
    ret.sort! { |a, b| (a[2] == b[2]) ? a[1] <=> b[1] : a[2] <=> b[2] }
    # Create form names for entries if they don't already exist
    ret.each do |entry|
      if !entry[0] || entry[0].empty?   # Necessarily applies only to form 0
        case entry[1]
        when 0 then entry[0] = _INTL("Male")
        when 1 then entry[0] = _INTL("Female")
        else
          entry[0] = (multiple_forms) ? _INTL("One Form") : _INTL("Genderless")
        end
      end
      entry[1] = 0 if entry[1] == 2   # Genderless entries are treated as male
    end
    return ret
  end
  
  def drawPage(page)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    # Make certain sprites visible
	@sprites["infosprite"].visible    = (@page==1)
    @sprites["areamap"].visible       = false if @sprites["areamap"] #(@page==7) if @sprites["areamap"]
    @sprites["areahighlight"].visible = false if @sprites["areahighlight"] #(@page==7) if @sprites["areahighlight"]
    @sprites["areaoverlay"].visible   = false if @sprites["areaoverlay"] #(@page==7) if @sprites["areaoverlay"]
    @sprites["formfront"].visible     = (@page==10) if @sprites["formfront"]
    @sprites["formback"].visible      = (@page==10) if @sprites["formback"]
    @sprites["formicon"].visible      = (@page==10) if @sprites["formicon"]
	@sprites["moveInfoDisplay"].visible = @page==6 || @page ==7  if @sprites["moveInfoDisplay"]
	@sprites["extraInfoOverlay"].visible = @page==6 || @page ==7 if @sprites["extraInfoOverlay"]
	@sprites["extraInfoOverlay"].bitmap.clear if @sprites["extraInfoOverlay"]
	# Draw page title
	overlay = @sprites["overlay"].bitmap
	base = Color.new(219, 240, 240)
	shadow   = Color.new(88, 88, 80)
	pageTitles = ["INFO", "ABILITIES", "STATS", "DEF. MATCHUPS", "ATK. MATCHUPS", "LEVEL UP MOVES", "TUTOR MOVES", "EVOLUTIONS", "AREA", "FORMS", "ANALYSIS"]
	pageTitle = pageTitles[page-1]
	drawFormattedTextEx(overlay, 50, 2, Graphics.width, "<outln2>#{pageTitle}</outln2>", base, shadow, 18)
	xPos = 240
	xPos -= 14 if @page >= 10
	drawFormattedTextEx(overlay, xPos, 2, Graphics.width, "<outln2>[#{page}/#{10}]</outln2>", base, shadow, 18)
    # Draw page-specific information
    case page
    when 1; drawPageInfo
    when 2; drawPageAbilities
    when 3; drawPageStats
	when 4; drawPageMatchups
	when 5; drawPageMatchups2
    when 6; drawPageLevelUpMoves
	when 7; drawPageTutorMoves
    when 8; drawPageEvolution
	when 9; drawPageArea
	when 10; drawPageForms
	when 11; drawPageDEBUG
    end
  end

  def drawPageInfo
	@sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_info"))
	overlay = @sprites["overlay"].bitmap
	base   = Color.new(88, 88, 80)
	shadow = Color.new(168, 184, 184)
	imagepos = []
	if @brief
	  imagepos.push([_INTL("Graphics/Pictures/Pokedex/overlay_info"), 0, 0])
	end
	species_data = GameData::Species.get_species_form(@species, @form)
	# Write various bits of text
	indexText = "???"
	if @dexlist[@index][4] > 0
	  indexNumber = @dexlist[@index][4]
	  indexNumber -= 1 if @dexlist[@index][5]
	  indexText = sprintf("%03d", indexNumber)
	end
	textpos = [
	   [_INTL("{1}{2} {3}", indexText, " ", species_data.name),
		  246, 36, 0, Color.new(248, 248, 248), Color.new(0, 0, 0)],
	   [_INTL("Height"), 314, 152, 0, base, shadow],
	   [_INTL("Weight"), 314, 184, 0, base, shadow]
	]
	if $Trainer.owned?(@species)
	  # Show the owned icon
	  imagepos.push(["Graphics/Pictures/Pokedex/icon_own", 212, 44])
	end
	# Write the category
	textpos.push([_INTL("{1} Pokémon", species_data.category), 246, 68, 0, base, shadow])
	# Write the height and weight
	height = species_data.height
	weight = species_data.weight
	if System.user_language[3..4] == "US"   # If the user is in the United States
		inches = (height / 0.254).round
		pounds = (weight / 0.45359).round
		textpos.push([_ISPRINTF("{1:d}'{2:02d}\"", inches / 12, inches % 12), 460, 152, 1, base, shadow])
		textpos.push([_ISPRINTF("{1:4.1f} lbs.", pounds / 10.0), 494, 184, 1, base, shadow])
	else
		textpos.push([_ISPRINTF("{1:.1f} m", height / 10.0), 470, 152, 1, base, shadow])
		textpos.push([_ISPRINTF("{1:.1f} kg", weight / 10.0), 482, 184, 1, base, shadow])
	end
	# Draw the Pokédex entry text
	drawTextEx(overlay, 40, 244, Graphics.width - (40 * 2), 4,   # overlay, x, y, width, num lines
			 species_data.pokedex_entry, base, shadow)
	# Draw the footprint
	footprintfile = GameData::Species.footprint_filename(@species, @form)
	if footprintfile
		footprint = RPG::Cache.load_bitmap("",footprintfile)
		overlay.blt(226, 138, footprint, footprint.rect)
		footprint.dispose
	end
	# Draw the type icon(s)
	type1 = species_data.type1
	type2 = species_data.type2
	type1_number = GameData::Type.get(type1).id_number
	type2_number = GameData::Type.get(type2).id_number
	type1rect = Rect.new(0, type1_number * 32, 96, 32)
	type2rect = Rect.new(0, type2_number * 32, 96, 32)
	overlay.blt(296, 120, @typebitmap.bitmap, type1rect)
	overlay.blt(396, 120, @typebitmap.bitmap, type2rect) if type1 != type2
	# Draw all text
	pbDrawTextPositions(overlay, textpos)
	# Draw all images
	pbDrawImagePositions(overlay, imagepos)
  end
  
  def drawPageAbilities
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_abilities"))
    overlay = @sprites["overlay"].bitmap
    formname = ""
    base = Color.new(64,64,64)
    shadow = Color.new(176,176,176)
    for i in @available
      if i[2]==@form
        drawTextEx(overlay,30,54,450,1,_INTL("Abilities of {1}",@title),base,shadow)
        fSpecies = GameData::Species.get_species_form(@species,i[2])
        abilities = fSpecies.abilities
        #ability 1
        drawTextEx(overlay,30,92,450,1,"Ability 1",base,shadow)
        if (abilities[0])
		  ability1 = GameData::Ability.get(abilities[0])
          drawTextEx(overlay,30,128,450,1,ability1.real_name,base,shadow)
          drawTextEx(overlay,30,160,450,2,ability1.real_description,base,shadow)
        else
          drawTextEx(overlay,30,128,450,1,"None",base,shadow)
        end
        #ability 1
        drawTextEx(overlay,30,92+142,450,1,"Ability 2",base,shadow)
        if (abilities[1])
          ability2 = GameData::Ability.get(abilities[1])
          drawTextEx(overlay,30,128+142,450,1,ability2.real_name,base,shadow)
          drawTextEx(overlay,30,160+142,450,2,ability2.real_description,base,shadow)
        else
          drawTextEx(overlay,30,128+142,450,1,"None",base,shadow)
        end
      end
    end
  end
  
  def genderRateToString(gender)
    case gender
    when :AlwaysMale;         return "Male"
    when :FemaleOneEighth;    return "7/8 Male"
    when :Female25Percent;    return "3/4 Male"
    when :Female50Percent;    return "50/50"
    when :Female75Percent;    return "3/4 Fem."
    when :FemaleSevenEighths; return "7/8 Fem."
    when :AlwaysFemale;       return "Female"
    when :Genderless;         return "None"
    end
    return "No data"
  end
  
  def growthRateToString(growthRate)
    case growthRate
      when :Medium;      return "Medium"
      when :Erratic;     return "Erratic"
      when :Fluctuating; return "Flux"
      when :Parabolic;  return "Med. Slow"
      when :Fast;        return "Fast"
      when :Slow;        return "Slow"
    end
  end
  
  def drawPageStats
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_stats"))
    overlay = @sprites["overlay"].bitmap
    formname = ""
    base = Color.new(64,64,64)
    shadow = Color.new(176,176,176)
	baseStatNames = ["HP","Attack","Defense","Sp. Atk","Sp. Def", "Speed"]
    otherStatNames = ["Gender Rate", "Growth Rate", "Catch Dif.", "Exp. Grant"]
    for i in @available
      if i[2]==@form
        formname = i[0]
        drawTextEx(overlay,30,54,450,1,_INTL("Stats of {1}",@title),base,shadow)
        fSpecies = GameData::Species.get_species_form(@species,i[2])
        
        #Base stats
        drawTextEx(overlay,30,90,450,1,"Base Stats",base,shadow)
        baseStats = fSpecies.base_stats
        total = 0
        baseStats.each_with_index do |stat, index|
          next if !stat
          total += stat[1]
          # Draw stat line
          drawTextEx(overlay,30,130+32*index,450,1,baseStatNames[index],base,shadow)
          drawTextEx(overlay,136,130+32*index,450,1,stat[1].to_s,base,shadow)
        end
        drawTextEx(overlay,30,130+32*6+14,450,1,"Total",base,shadow)
        drawTextEx(overlay,136,130+32*6+14,450,1,total.to_s,base,shadow)
        # Other stats
        drawTextEx(overlay,250,90,450,1,"Other Stats",base,shadow)
        otherStats = []
        genderRate = fSpecies.gender_ratio
        genderRateString = genderRateToString(genderRate)
        otherStats.push(genderRateString)
        growthRate = fSpecies.growth_rate
        growthRateString = growthRateToString(growthRate)
        otherStats.push(growthRateString)
        rareness = fSpecies.catch_rate
		
		if rareness>= 250
	      otherStats.push("F")
		elsif rareness>= 230
	      otherStats.push("D-")
		elsif rareness>= 210
	      otherStats.push("D")
		elsif rareness>= 190
	      otherStats.push("D+")
		elsif rareness>= 170
	      otherStats.push("C-")
		elsif rareness>= 150
	      otherStats.push("C")
	    elsif rareness>= 130
	      otherStats.push("C+")
	    elsif rareness>= 110
	      otherStats.push("B-")
        elsif rareness>= 90
          otherStats.push("B")
        elsif rareness >= 70
          otherStats.push("B+")
        elsif rareness >= 50
          otherStats.push("A-")
        elsif rareness >= 30
          otherStats.push("A")
        elsif rareness >= 10
          otherStats.push("A+")
        else
          otherStats.push("S")
        end

        otherStats.push(fSpecies.base_exp)
        
        otherStats.each_with_index do |stat, index|
          next if !stat
          # Draw stat line
          drawTextEx(overlay,230,130+32*index,450,1,otherStatNames[index],base,shadow)
          drawTextEx(overlay,378,130+32*index,450,1,stat.to_s,base,shadow)
        end
		
		map_id = checkForZooMap(fSpecies.species.to_s)
		placementMap = "None"
		placementMap = (pbGetMessage(MessageTypes::MapNames,map_id) rescue nil) if map_id != -1
		drawTextEx(overlay,230,274,450,1,"Zoo Section",base,shadow)
		drawTextEx(overlay,230,306,450,1,placementMap,base,shadow)
      end
    end
  end
  
  def drawPageMatchups
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_matchups"))
    overlay = @sprites["overlay"].bitmap
    formname = ""
    base = Color.new(64,64,64)
    shadow = Color.new(176,176,176)
	xLeft = 36
    for i in @available
      if i[2]==@form
        formname = i[0]
        drawTextEx(overlay,xLeft,54,450,1,_INTL("Defending Matchups of {1}",@title),base,shadow)
        fSpecies = GameData::Species.get_species_form(@species,i[2])
		
		#type1 = GameData::Type.get(fSpecies.type1)
		#type2 = GameData::Type.get(fSpecies.type2)
        
		immuneTypes = []
		resistentTypes = []
		weakTypes = []
		
		GameData::Type.each do |t|
			next if t.pseudo_type
			
			effect = Effectiveness.calculate(t.id,fSpecies.type1,fSpecies.type2)
			
			if Effectiveness.ineffective?(effect)
				immuneTypes.push(t)
			elsif Effectiveness.not_very_effective?(effect)
				resistentTypes.push(t)
			elsif Effectiveness.super_effective?(effect)
				weakTypes.push(t)
			end
		end
		
		#Draw the types the pokemon is weak to
		drawTextEx(overlay,xLeft,80,450,1,_INTL("Weak:"),base,shadow)
		if weakTypes.length == 0
			drawTextEx(overlay,xLeft,110,450,1,_INTL("None"),base,shadow)
		else
			weakTypes.each_with_index do |t,index|
				#drawTextEx(overlay,30,110+30*index,450,1,_INTL("{1}",t.real_name),base,shadow)
				type_number = GameData::Type.get(t).id_number
				typerect = Rect.new(0, type_number*32, 96, 32)
				overlay.blt(xLeft, 110+36*index, @typebitmap.bitmap, typerect)
			end
		end
		
		#Draw the types the pokemon resists
		resistOffset = 112
		drawTextEx(overlay,xLeft+resistOffset,80,450,1,_INTL("Resist:"),base,shadow)
		if resistentTypes.length == 0
			drawTextEx(overlay,xLeft+resistOffset,110,450,1,_INTL("None"),base,shadow)
		else
			resistentTypes.each_with_index do |t,index|
				#drawTextEx(overlay,150,110+30*index,450,1,_INTL("{1}",t.real_name),base,shadow)
				type_number = GameData::Type.get(t).id_number
				typerect = Rect.new(0, type_number*32, 96, 32)
				overlay.blt(xLeft+resistOffset + (index >= 7 ? 100 : 0), 110+36*(index % 7), @typebitmap.bitmap, typerect)
			end
		end
		
		#Draw the types the pokemon is immune to
		immuneOffset = 324
		drawTextEx(overlay,xLeft+immuneOffset,80,450,1,_INTL("Immune:"),base,shadow)
		if immuneTypes.length == 0
			drawTextEx(overlay,xLeft+immuneOffset,110,450,1,_INTL("None"),base,shadow)
		else
			immuneTypes.each_with_index do |t,index|
				#drawTextEx(overlay,310,110+30*index,450,1,_INTL("{1}",t.real_name),base,shadow)
				type_number = GameData::Type.get(t).id_number
				typerect = Rect.new(0, type_number*32, 96, 32)
				overlay.blt(xLeft+immuneOffset, 110+36*index, @typebitmap.bitmap, typerect)
			end
		end
      end
    end
  end
  
  def drawPageMatchups2
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_matchups"))
    overlay = @sprites["overlay"].bitmap
    formname = ""
    base = Color.new(64,64,64)
    shadow = Color.new(176,176,176)
	xLeft = 36
    for i in @available
      if i[2]==@form
        formname = i[0]
        drawTextEx(overlay,xLeft,54,450,1,_INTL("Attacking Matchups of {1}",@title),base,shadow)
        fSpecies = GameData::Species.get_species_form(@species,i[2])
		
		immuneTypes = []
		resistentTypes = []
		weakTypes = []
		
		GameData::Type.each do |t|
			next if t.pseudo_type
			
			effect1 = Effectiveness.calculate(fSpecies.type1,t.id,t.id)
			effect2 = Effectiveness.calculate(fSpecies.type2,t.id,t.id)
			effect = [effect1,effect2].max
			
			if Effectiveness.ineffective?(effect)
				immuneTypes.push(t)
			elsif Effectiveness.not_very_effective?(effect)
				resistentTypes.push(t)
			elsif Effectiveness.super_effective?(effect)
				weakTypes.push(t)
			end
		end
		
		#Draw the types the pokemon is super effective against
		drawTextEx(overlay,xLeft,80,450,1,_INTL("Super:"),base,shadow)
		if weakTypes.length == 0
			drawTextEx(overlay,xLeft,110,450,1,_INTL("None"),base,shadow)
		else
			weakTypes.each_with_index do |t,index|
				#drawTextEx(overlay,30,110+30*index,450,1,_INTL("{1}",t.real_name),base,shadow)
				type_number = GameData::Type.get(t).id_number
				typerect = Rect.new(0, type_number*32, 96, 32)
				overlay.blt(xLeft + (index >= 7 ? 100 : 0), 110+36*(index % 7), @typebitmap.bitmap, typerect)
			end
		end
		
		#Draw the types the pokemon can't deal but NVE damage to
		resistOffset = 212
		drawTextEx(overlay,xLeft+resistOffset,80,450,1,_INTL("Not Very:"),base,shadow)
		if resistentTypes.length == 0
			drawTextEx(overlay,xLeft+resistOffset,110,450,1,_INTL("None"),base,shadow)
		else
			resistentTypes.each_with_index do |t,index|
				type_number = GameData::Type.get(t).id_number
				typerect = Rect.new(0, type_number*32, 96, 32)
				overlay.blt(xLeft+resistOffset, 110+36*index, @typebitmap.bitmap, typerect)
			end
		end
		
		#Draw the types the pokemon can't deal but immune damage to
		immuneOffset = 324
		drawTextEx(overlay,xLeft+immuneOffset,80,450,1,_INTL("No Effect:"),base,shadow)
		if immuneTypes.length == 0
			drawTextEx(overlay,xLeft+immuneOffset,110,450,1,_INTL("None"),base,shadow)
		else
			immuneTypes.each_with_index do |t,index|
				#drawTextEx(overlay,310,110+30*index,450,1,_INTL("{1}",t.real_name),base,shadow)
				type_number = GameData::Type.get(t).id_number
				typerect = Rect.new(0, type_number*32, 96, 32)
				overlay.blt(xLeft+immuneOffset, 110+36*index, @typebitmap.bitmap, typerect)
			end
		end
      end
    end
  end
  
  def getFormattedMoveName(move)
    fSpecies = GameData::Species.get_species_form(@species,@form)
	move_data = GameData::Move.get(move)
	moveName = move_data.real_name
	if move_data.category < 2 # Is a damaging move
		if [fSpecies.type1,fSpecies.type2].include?(move_data.type) # Is STAB for the main pokemon
			moveName = "<b>#{moveName}</b>"
		elsif isAnyEvolutionOfType(fSpecies,move_data.type)
			moveName = "<i>#{moveName}</i>"
		end
	end
	return moveName
  end
  
  def isAnyEvolutionOfType(species_data,type)
	ret = false
	species_data.get_evolutions.each do |evolution_data|
		evoSpecies_data = GameData::Species.get_species_form(evolution_data[0],@form)
		ret = true if [evoSpecies_data.type1,evoSpecies_data.type2].include?(type)
		ret = true if isAnyEvolutionOfType(evoSpecies_data,type) # Recursion!!
	end
	return ret
  end
  
  def drawPageLevelUpMoves
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_moves"))
    overlay = @sprites["overlay"].bitmap
    formname = ""
    base = Color.new(64,64,64)
    shadow = Color.new(176,176,176)
	selected_move = nil
	xLeft = 36
    for i in @available
      if i[2]==@form
        formname = i[0]
        drawTextEx(overlay,xLeft,54,450,1,_INTL("Level Up Moves for {1}",@title),base,shadow)
        fSpecies = GameData::Species.get_species_form(@species,i[2])
        learnset = fSpecies.moves
        displayIndex = 0
        @scrollableListLength = learnset.length
        learnset.each_with_index do |learnsetEntry,index|
          next if index<@scroll
          level = learnsetEntry[0]
          move = learnsetEntry[1]
          return if !move || !level
          levelLabel = level.to_s
          if level == 0
            levelLabel = "E"
          end
          # Draw stat line
		  color = base 
		  if index == @scroll
			color = Color.new(255,100,80)
			selected_move = move
		  end
		  moveName = getFormattedMoveName(move)
		  drawTextEx(overlay,xLeft,84+30*displayIndex,450,1,levelLabel,color,shadow)
          drawFormattedTextEx(overlay,xLeft+30,84+30*displayIndex,450,moveName,color,shadow)
          displayIndex += 1
          break if displayIndex >= 9
        end
      end
    end
	
	drawMoveInfo(selected_move)
  end
  
  def drawPageEvolution
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_evolution"))
    overlay = @sprites["overlay"].bitmap
    formname = ""
    base = Color.new(64,64,64)
    shadow = Color.new(176,176,176)
	xLeft = 36
    for i in @available
      if i[2]==@form
        formname = i[0]
        fSpecies = GameData::Species.get_species_form(@species,i[2])
		
		coordinateY = 54
		prevoTitle = _INTL("Pre-Evolutions of {1}",@title)
		drawTextEx(overlay,(Graphics.width-prevoTitle.length*10)/2,coordinateY,450,1,prevoTitle,base,shadow)
		coordinateY += 34
		index = 0
		
		# Show pre-volutions
		prevolutions = fSpecies.get_prevolutions
		if prevolutions.length == 0
			drawTextEx(overlay,xLeft,coordinateY,450,1,_INTL("None"),base,shadow)
			coordinateY += 30
		else
			prevolutions.each do |evolution|
			  method = evolution[1]
			  parameter = evolution[2]
			  species = evolution[0]
			  return if !method || !species
			  evolutionName = GameData::Species.get_species_form(species,i[2]).real_name
			  methodDescription = describeEvolutionMethod(method,parameter)
			  # Draw preevolution description
			  color = index == @evolutionIndex ? Color.new(255,100,80) : base
			  drawTextEx(overlay,xLeft,coordinateY,450,2,_INTL("Evolves from {1} {2}",evolutionName,methodDescription),color,shadow)
			  coordinateY += 30
			  coordinateY += 30 if method != :Level
			  index += 1
			end
		end
		
		evoTitle = _INTL("Evolutions of {1}",@title)
		drawTextEx(overlay,(Graphics.width-evoTitle.length*10)/2,coordinateY,450,1,evoTitle,base,shadow)
		coordinateY += 34
		
		# Show evolutions
		evolutions = fSpecies.get_evolutions
		
		if evolutions.length == 0
			drawTextEx(overlay,xLeft,coordinateY,450,1,_INTL("None"),base,shadow)
			coordinateY += 30
		elsif @species == :EEVEE
			drawTextEx(overlay,xLeft,coordinateY,450,6,_INTL("Evolves into Vaporeon with a Water Stone," + 
				"Jolteon with a Thunder Stone, Flareon with a Fire Stone, Espeon with a Sun Stone," +
				"Umbreon with a Dusk Stone, Leafeon with a Leaf Stone, Glaceon with an Ice Stone," +
				", Sylveon with a Dawn Stone, and Giganteon with a Shiny Stone."
			),base,shadow)
		else
			evosOfEvos = {}
			evolutions.each do |evolution|
			  method = evolution[1]
			  parameter = evolution[2]
			  species = evolution[0]
			  return if !method || !species
			  speciesData = GameData::Species.get_species_form(species,i[2])
			  evolutionName = speciesData.real_name
			  evosOfEvos[evolutionName] = speciesData.get_evolutions()
			  methodDescription = describeEvolutionMethod(method,parameter)
			  # Draw evolution description
			  color = index == @evolutionIndex ? Color.new(255,100,80) : base
			  drawTextEx(overlay,xLeft,coordinateY,450,2,_INTL("Evolves into {1} {2}",evolutionName,methodDescription),color,shadow)
			  coordinateY += 30
			  coordinateY += 30 if method != :Level
			  index += 1
			end
			
			evosOfEvos.each do |fromSpecies,evolutions|
			  evolutions.each do |evolution|
				  method = evolution[1]
				  parameter = evolution[2]
				  species = evolution[0]
				  return if !method || !species
				  speciesData = GameData::Species.get_species_form(species,i[2])
				  evolutionName = speciesData.real_name
				  methodDescription = describeEvolutionMethod(method,parameter)
				  # Draw evolution description
				  color = index == @evolutionIndex ? Color.new(255,100,80) : base
				  drawTextEx(overlay,xLeft,coordinateY,450,2,_INTL("Evolves into {1} {2} (through {3})",evolutionName,methodDescription,fromSpecies),color,shadow)
				  coordinateY += 60
				  index += 1
			  end
			end
        end
		
		@evolutionsArray = prevolutions.concat(evolutions)
      end
    end
  end

=begin
  def drawPageTMMoves
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_moves"))
    overlay = @sprites["overlay"].bitmap
    formname = "" 
    base = Color.new(64,64,64)
    shadow = Color.new(176,176,176)

	selected_move = nil
	xLeft = 36
    for i in @available
      if i[2]==@form
        formname = i[0]
        drawTextEx(overlay,xLeft,54,450,1,_INTL("TM Moves for {1}",@title),base,shadow)
        fSpecies = GameData::Species.get_species_form(@species,i[2])
        compatibleMoves = fSpecies.tutor_moves
        @scrollableListLength = compatibleMoves.length
        displayIndex = 0
        compatibleMoves.each_with_index do |move,index|
          next if index < @scroll
		  color = base
		  if index == @scroll
			color = Color.new(255,100,80)
			selected_move = move
		  end
		  moveName = getFormattedMoveName(move)
          drawFormattedTextEx(overlay,xLeft,84+30*displayIndex,450,moveName,color,shadow)
          displayIndex += 1
          break if displayIndex >= 9
        end
      end
    end
	
	drawMoveInfo(selected_move)
  end
=end
  
  def drawPageTutorMoves
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_moves"))
    overlay = @sprites["overlay"].bitmap
    formname = "" 
    base = Color.new(64,64,64)
    shadow = Color.new(176,176,176)

	selected_move = nil
	xLeft = 36
    for i in @available
      if i[2]==@form
        formname = i[0]
        drawTextEx(overlay,xLeft,54,450,1,_INTL("Tutorable Moves for {1}",@title),base,shadow)
        species_data = GameData::Species.get_species_form(@species,i[2])
		firstSpecies = species_data
		while GameData::Species.get(firstSpecies.get_previous_species()) != firstSpecies do
			firstSpecies = GameData::Species.get(firstSpecies.get_previous_species())
		end
        compatibleMoves = firstSpecies.egg_moves + species_data.tutor_moves
		compatibleMoves.uniq!
		compatibleMoves.compact!
		compatibleMoves.sort! { |a,b|
			movaAData = GameData::Move.get(a)
			movaBData = GameData::Move.get(b)

			if movaAData.category != movaBData.category
				next movaAData.category <=> movaBData.category
			end
			
			next a <=> b
		}
        @scrollableListLength = compatibleMoves.length
        displayIndex = 0
        compatibleMoves.each_with_index do |move,index|
          next if index < @scroll
		  color = base
		  if index == @scroll
			color = Color.new(255,100,80)
			selected_move = move
		  end
		  moveName = getFormattedMoveName(move)
          drawFormattedTextEx(overlay,xLeft,84+30*displayIndex,450,moveName,color,shadow)
          displayIndex += 1
          break if displayIndex >= 9
        end
      end
    end
	
	drawMoveInfo(selected_move)
  end
  
  def drawMoveInfo(selected_move)
	if selected_move != nil
		# Extra move info display
		@extraInfoOverlay.bitmap.clear
		overlay = @extraInfoOverlay.bitmap
		selected_move = GameData::Move.get(selected_move)
		
		# Write power and accuracy values for selected move
		# Write various bits of text
		base   = Color.new(248,248,248)
		shadow = Color.new(104,104,104)
		textpos = [
		   [_INTL("CATEGORY"),20,0,0,base,shadow],
		   [_INTL("POWER"),20,32,0,base,shadow],
		   [_INTL("ACCURACY"),20,64,0,base,shadow]
		]
		
		base = Color.new(64,64,64)
		shadow = Color.new(176,176,176)
		case selected_move.base_damage
		when 0 then textpos.push(["---", 220, 32, 1, base, shadow])   # Status move
		when 1 then textpos.push(["???", 220, 32, 1, base, shadow])   # Variable power move
		else        textpos.push([selected_move.base_damage.to_s, 220, 32, 1, base, shadow])
		end
		if selected_move.accuracy == 0
		  textpos.push(["---", 220, 64, 1, base, shadow])
		else
		  textpos.push(["#{selected_move.accuracy}%", 220 + overlay.text_size("%").width, 64, 1, base, shadow])
		end
		# Draw all text
		pbDrawTextPositions(overlay, textpos)
		# Draw selected move's damage category icon
		imagepos = [["Graphics/Pictures/category", 170, 8, 0, selected_move.category * 28, 64, 28]]
		pbDrawImagePositions(overlay, imagepos)
		# Draw selected move's description
		drawTextEx(overlay,8,108,210,5,selected_move.description,base,shadow)
		
		#Draw the move's type
		type_number = GameData::Type.get(selected_move.type).id_number
		typerect = Rect.new(0, type_number*32, 96, 32)
		@sprites["overlay"].bitmap.blt(340, 60, @typebitmap.bitmap, typerect)
	end
  end
  
  def getEncounterableAreas(species)
    areas = []
	GameData::Encounter.each_of_version($PokemonGlobal.encounter_version) do |enc_data|
		next if !pbFindEncounter(enc_data.types, species)
		name = (pbGetMessage(MessageTypes::MapNames,enc_data.map) rescue nil) || "???"
		areas.push(name)
	end
	areas.uniq!
	return areas
  end

  def drawPageArea
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_area"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(88,88,80)
    shadow = Color.new(168,184,184)
	
	xLeft = 36
	for i in @available
      if i[2]==@form
		# Determine which areas the pokemon can be encountered in
		areas = getEncounterableAreas(@species)
		
		# Draw the areas the pokemon can be encountered in
		coordinateY = 54
		drawTextEx(overlay,xLeft,coordinateY,450,1,_INTL("Encounterable Areas for {1}",@title),base,shadow)
		coordinateY += 30
		if areas.length == 0
			drawTextEx(overlay,xLeft,coordinateY,450,1,"None",base,shadow)
		else
			areas.each do |area_name|
				drawTextEx(overlay,xLeft,coordinateY,450,1,area_name,base,shadow)
				coordinateY += 30
			end
		end
		
		# Determine which areas the pokemon's pre-evos can be encountered in
		prevo_areas = []
		fSpecies = GameData::Species.get_species_form(@species,i[2])
		prevolutions = fSpecies.get_prevolutions
		currentPrevo = prevolutions.length > 0 ? prevolutions[0] : nil
		while currentPrevo != nil
			currentPrevoSpecies = currentPrevo[0]
			currentPrevoSpeciesName = GameData::Species.get(currentPrevoSpecies).name
			prevosAreas = getEncounterableAreas(currentPrevoSpecies)
			prevosAreas.each do |area_name|
				prevo_areas.push([area_name,currentPrevoSpeciesName])
			end
			
			# Find the prevo of the prevo
			prevosfSpecies = GameData::Species.get_species_form(currentPrevoSpecies,0)
			prevolutions = prevosfSpecies.get_prevolutions
			currentPrevo = prevolutions.length > 0 ? prevolutions[0] : nil
		end
		prevo_areas.uniq!
		
		if prevo_areas.length != 0
			# Draw the areas the pokemon's pre-evos can be encountered in
			coordinateY += 60
			drawTextEx(overlay,xLeft,coordinateY,450,1,_INTL("Encounter Areas for Pre-Evolutions",@title),base,shadow)
			coordinateY += 30
			if prevo_areas.length == 0
				drawTextEx(overlay,xLeft,coordinateY,450,1,"None",base,shadow)
			else
				prevo_areas.each do |area_name,prevo_name|
					drawTextEx(overlay,xLeft,coordinateY,450,1,"#{area_name} (#{prevo_name})",base,shadow)
					coordinateY += 30
				end
			end
		end
	  end
	end
  end
  
  def drawPageForms
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_forms"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(88,88,80)
    shadow = Color.new(168,184,184)
    # Write species and form name
    formname = ""
    for i in @available
      if i[1]==@gender && i[2]==@form
        formname = i[0]; break
      end
    end
    textpos = [
       [GameData::Species.get(@species).name,Graphics.width/2,Graphics.height-94,2,base,shadow],
       [formname,Graphics.width/2,Graphics.height-62,2,base,shadow],
    ]
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
  end

  def pbGoToPrevious
    newindex = @index
    while newindex>0
      newindex -= 1
      if !isLegendary(@dexlist[newindex][0]) || $Trainer.seen?(@dexlist[newindex][0])
        @index = newindex
        break
      end
    end
  end

  def pbGoToNext
    newindex = @index
    while newindex<@dexlist.length-1
      newindex += 1
      if !isLegendary(@dexlist[newindex][0]) || $Trainer.seen?(@dexlist[newindex][0])
        @index = newindex
        break
      end
    end
  end

  def pbChooseForm
    index = 0
    for i in 0...@available.length
      if @available[i][1]==@gender && @available[i][2]==@form
        index = i
        break
      end
    end
    oldindex = -1
    loop do
      if oldindex!=index
        $Trainer.pokedex.set_last_form_seen(@species, @available[index][1], @available[index][2])
        pbUpdateDummyPokemon
        drawPage(@page)
        @sprites["uparrow"].visible   = (index>0)
        @sprites["downarrow"].visible = (index<@available.length-1)
        oldindex = index
      end
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::UP)
        pbPlayCursorSE
        index = (index+@available.length-1) % @available.length
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE
        index = (index+1) % @available.length
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        break
      end
    end
    @sprites["uparrow"].visible   = false
    @sprites["downarrow"].visible = false
  end
  
  def pbScroll
	@scroll = 0
	drawPage(@page)
    loop do
      Graphics.update
      Input.update
      pbUpdate
	  doRefresh = false
      if Input.repeat?(Input::UP) && @scroll > 0
        pbPlayCursorSE
        @scroll -= 1
		doRefresh = true
      elsif Input.repeat?(Input::DOWN) && @scroll < @scrollableListLength-1
        pbPlayCursorSE
        @scroll += 1
		doRefresh = true
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
		@scroll = -1
		drawPage(@page)
        break
      end
	  if doRefresh
        drawPage(@page)
      end
    end
  end
  
  def pbScrollEvolutions
	@evolutionIndex = 0
	drawPage(@page)
	loop do
      Graphics.update
      Input.update
      pbUpdate
	  dorefresh = false
      if Input.repeat?(Input::UP) && @evolutionIndex > 0
        pbPlayCursorSE
        @evolutionIndex -= 1
		dorefresh = true
      elsif Input.repeat?(Input::DOWN) && @evolutionIndex < @evolutionsArray.length - 1
        pbPlayCursorSE
        @evolutionIndex += 1
		dorefresh = true
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::USE)
		pbPlayDecisionSE
		otherSpecies = @evolutionsArray[@evolutionIndex][0]
		return otherSpecies
      end
	  if dorefresh
        drawPage(@page)
      end
    end
	return nil
  end
  
  def drawPageDEBUG
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_evolution"))
    overlay = @sprites["overlay"].bitmap
    formname = ""
    base = Color.new(64,64,64)
    shadow = Color.new(176,176,176)
	xLeft = 36
    for i in @available
      if i[2]==@form
        formname = i[0]
        fSpecies = GameData::Species.get_species_form(@species,i[2])
		
		coordinateY = 54
		
		drawTextEx(overlay,xLeft,coordinateY,450,1,_INTL("Analysis of {1}",@title),base,shadow)
		coordinateY += 34
		
		# Effective HP
		
		phep = fSpecies.base_stats[:HP] * fSpecies.base_stats[:DEFENSE]
		shep = fSpecies.base_stats[:HP] * fSpecies.base_stats[:SPECIAL_DEFENSE]
		phep /= 100
		shep /= 100
		effectiveHPs = "PEHP, SEHP: #{phep},#{shep}"
		drawTextEx(overlay,xLeft,coordinateY,450,1,effectiveHPs,base,shadow)
		coordinateY += 32
		
		# Speed tier
		
		numberFaster = 0
		total = 0
		mySpeed = fSpecies.base_stats[:SPEED]
		GameData::Species.each do |otherSpeciesData|
			next if otherSpeciesData.form != 0
			next if otherSpeciesData.get_evolutions.length > 0
			next if isLegendary(otherSpeciesData.id) || isQuarantined(otherSpeciesData.id)
			if mySpeed > otherSpeciesData.base_stats[:SPEED]
				numberFaster += 1
			end
			total += 1
		end
		
		fasterThanPercentOfMetaGame = numberFaster.to_f / total.to_f
		fasterThanPercentOfMetaGame = (fasterThanPercentOfMetaGame*10000).floor / 100.0
		drawTextEx(overlay,xLeft,coordinateY,450,1,"Faster than #{fasterThanPercentOfMetaGame}% of final evos",base,shadow)
		coordinateY += 32
		
		# Pokeball catch chance
		totalHP = calcHPGlobal(fSpecies.base_stats[:HP],40,8)
		currentHP = (totalHP * 0.15).floor
		chanceToCatch = theoreticalCaptureChance(:NONE,currentHP,totalHP,fSpecies.catch_rate)
		chanceToCatch = (chanceToCatch*10000).floor / 100.0
		drawTextEx(overlay,xLeft,coordinateY,450,1,"#{chanceToCatch}% chance to catch at level 40, %15 health",base,shadow)
		coordinateY += 32
		
		# Coverage types
		
		moves = []
		fSpecies.moves.each do |learnsetEntry|
			moves.push(learnsetEntry[1])
		end
		
		moves.concat(fSpecies.egg_moves)
		moves.concat(fSpecies.tutor_moves)
		moves.uniq!
		moves.compact!
		
		typesOfCoverage = []
		moves.each do |move|
			moveData = GameData::Move.get(move)
			next if moveData.category == 2
			next unless moveData.base_damage >= 80
			typesOfCoverage.push(moveData.type)
		end
		typesOfCoverage.uniq!
		typesOfCoverage.compact!
	
		drawTextEx(overlay,xLeft,coordinateY,450,1,"BnB coverage: #{typesOfCoverage[0..[2,typesOfCoverage.length].min].to_s}",base,shadow)
		coordinateY += 32
		for index in 1..10
			break if typesOfCoverage.length <= 5 * index
			drawTextEx(overlay,xLeft,coordinateY,450,1,"#{typesOfCoverage[(5 * index)...[(5 * (index+1)),typesOfCoverage.length].min].to_s}",base,shadow)
			coordinateY += 32
		end
		
		# Metagame coverage
		numberCovered = 0
		GameData::Species.each do |otherSpeciesData|
			next if otherSpeciesData.form != 0
			next if otherSpeciesData.get_evolutions.length > 0
			next if isLegendary(otherSpeciesData.id) || isQuarantined(otherSpeciesData.id)

			typesOfCoverage.each do |coverageType|
				effect = Effectiveness.calculate(coverageType,otherSpeciesData.type1,otherSpeciesData.type2)
			
				if Effectiveness.super_effective?(effect)
					numberCovered += 1
					break
				end
			end
		end
		
		coversPercentOfMetaGame = numberCovered.to_f / total.to_f
		coversPercentOfMetaGame = (coversPercentOfMetaGame*10000).floor / 100.0
		drawTextEx(overlay,xLeft,coordinateY,450,1,"Covers #{coversPercentOfMetaGame}% of final evos",base,shadow)
		coordinateY += 32
      end
    end
  end

  def pbScene
    GameData::Species.play_cry_from_species(@species, @form)
	highestLeftRepeat = 0
	highestRightRepeat = 0
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::ACTION)
		if @page == 1
			GameData::Species.play_cry_from_species(@species, @form)
		end
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
		if @page==1
          pbPlayCloseMenuSE
          break
        elsif @page==6 || @page == 7   # Move lists
		  pbPlayDecisionSE
          pbScroll
          dorefresh = true
		elsif @page==8 && @evolutionsArray.length > 0   # Evolutions
		  if @linksEnabled
			pbPlayDecisionSE
			  newSpecies = pbScrollEvolutions()
			  if newSpecies
				return newSpecies
			  end
			  @evolutionIndex = -1
			  dorefresh = true
		  else
			pbPlayBuzzerSE
		  end
		elsif @page==10
			if @available.length>1
				pbPlayDecisionSE
				pbChooseForm
				dorefresh = true
			end
        end
      elsif Input.repeat?(Input::UP)
        oldindex = @index
        pbGoToPrevious
        if @index!=oldindex
		  @scroll = -1
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          (@page==1) ? GameData::Species.play_cry_from_species(@species, @form) : pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.repeat?(Input::DOWN)
        oldindex = @index
        pbGoToNext
        if @index!=oldindex
		  @scroll = -1
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          (@page==1) ? GameData::Species.play_cry_from_species(@species, @form) : pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.repeat?(Input::LEFT)
		highestRightRepeat = 0
		repeats = 1 + Input.time?(Input::LEFT) / 100000
        if  repeats > highestLeftRepeat
			highestLeftRepeat = repeats
			oldpage = @page
			@page -= 1
			@page = 1 if @page<1
			if @page!=oldpage
			  @scroll = -1
			  pbPlayCursorSE
			  dorefresh = true
			end
		end
    elsif Input.repeat?(Input::RIGHT)
		highestLeftRepeat = 0
        repeats = 1 + Input.time?(Input::RIGHT) / 100000
		if repeats > highestRightRepeat
			highestRightRepeat = repeats
			oldpage = @page
			@page += 1
			@page = 10 if @page>10
			if @page!=oldpage
			  @scroll = -1
			  pbPlayCursorSE
			  dorefresh = true
			end
		end
	elsif Input.pressex?(:NUMBER_1)
	  dorefresh = true if moveToPage(1)
	elsif Input.pressex?(:NUMBER_2)
	  dorefresh = true if moveToPage(2)
	elsif Input.pressex?(:NUMBER_3)
	  dorefresh = true if moveToPage(3)
	elsif Input.pressex?(:NUMBER_4)
	  dorefresh = true if moveToPage(4)
	elsif Input.pressex?(:NUMBER_5)
	  dorefresh = true if moveToPage(5)
	elsif Input.pressex?(:NUMBER_6)
	  dorefresh = true if moveToPage(6)
	elsif Input.pressex?(:NUMBER_7)
	  dorefresh = true if moveToPage(7)
	elsif Input.pressex?(:NUMBER_8)
	  dorefresh = true if moveToPage(8)
	elsif Input.pressex?(:NUMBER_9)
	  dorefresh = true if moveToPage(9)
	elsif Input.pressex?(:NUMBER_0)
	  dorefresh = true if moveToPage(10)
	elsif Input.press?(Input::ACTION) && $DEBUG
		@scroll = -1
		pbPlayCursorSE
		@page = 11
		dorefresh = true
	else
		highestLeftRepeat = 0
		highestRightRepeat = 0
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @index
  end
  
  def moveToPage(pageNum)
	oldpage = @page
	@page = pageNum
	@page = 1 if @page<1
	@page = 10 if @page>10
	if @page!=oldpage
	  @scroll = -1
	  pbPlayCursorSE
	  return true
	end
	return false
  end

  def pbSceneBrief
    GameData::Species.play_cry_from_species(@species,@form)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::A)
        pbSEStop
		GameData::Species.play_cry_from_species(@species,@form)
      elsif Input.trigger?(Input::B)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE
        break
      end
    end
  end
end