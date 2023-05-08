DebugMenuCommands.register("changelog", {
  "parent"      => "main",
  "name"        => _INTL("Changelogs..."),
  "description" => _INTL("Generate species changelogs of various types."),
})

DebugMenuCommands.register("generatechangelogrange", {
  "parent"      => "changelog",
  "name"        => _INTL("Generate species changelog between ids"),
  "description" => _INTL("See the changelog for each species between the Old and New pokemon.txt files for a specific range of IDs."),
  "effect"      => proc { |sprites, viewport|
	firstNumberInput = pbEnterText("First ID number", 0, 3)
	if firstNumberInput.blank?
		next
	end
	firstNumberAttempt = firstNumberInput.to_i
	return nil if firstNumberAttempt == 0
	lastNumberInput = pbEnterText("Last ID number", 0, 3)
	if lastNumberInput.blank?
		next
	end
	lastNumberAttempt = lastNumberInput.to_i
	return nil if lastNumberAttempt == 0
	createChangeLogBetween(firstNumberAttempt,lastNumberAttempt)
  }
})

DebugMenuCommands.register("generatechangelog", {
  "parent"      => "changelog",
  "name"        => _INTL("Generate species changelog"),
  "description" => _INTL("See the changelog for each species between the Old and New pokemon.txt files."),
  "effect"      => proc { |sprites, viewport|
  	createChangeLogBetween(1,9999)
  }
})

DebugMenuCommands.register("generatechangelogpergen", {
  "parent"      => "changelog",
  "name"        => _INTL("Generate changelog per generation"),
  "description" => _INTL("Generate a species changelog per generation of Pokemon"),
  "effect"      => proc { |sprites, viewport|
	if !safeIsDirectory?("Changelogs")
		Dir.mkdir("Changelogs") rescue nil
	end
	for index in 1...GENERATION_END_IDS.length
		startID = GENERATION_END_IDS[index-1] + 1
		endID = GENERATION_END_IDS[index]
		echoln("Creating the changelog between the IDs of #{startID} and #{endID}")
		createChangeLogBetween(startID,endID,"Changelogs/changelog_gen#{index.to_s}.txt")
	end
  }
})

DebugMenuCommands.register("generatefulldexdoc", {
	"parent"      => "changelog",
	"name"        => _INTL("Generate full dex doc"),
	"description" => _INTL("Generate a document that describes all current species details like a dex"),
	"effect"      => proc { |sprites, viewport|
	  if !safeIsDirectory?("Changelogs")
		  Dir.mkdir("Changelogs") rescue nil
	  end
	  generateFullDexDoc
	}
  })

def createChangeLogBetween(firstID,lastID,fileName = "changelog.txt")
	unchanged = []
		
	File.open(fileName,"wb") { |f|
		GameData::SpeciesOld.each do |species_data|
			next if species_data.form != 0
			next if species_data.id_number < firstID
			break if species_data.id_number > lastID
			
			newSpeciesData = GameData::Species.get(species_data.id) || nil
			next if newSpeciesData.nil?
			changeLog = []
			
			# Check for type changes
			oldTypes = [species_data.type1]
			oldTypes.push(species_data.type2) if species_data.type1 != species_data.type2
			
			newTypes = [newSpeciesData.type1]
			newTypes.push(newSpeciesData.type2) if newSpeciesData.type1 != newSpeciesData.type2
			
			oldTypes.each do |oldType|
				changeLog.push("Removed type #{GameData::Type.get(oldType).real_name}") if !newTypes.include?(oldType)
			end
			
			newTypes.each do |newType|
				changeLog.push("Added type #{GameData::Type.get(newType).real_name}") if !oldTypes.include?(newType)
			end
			
			# Check for stat changes
			
			oldBST = 0
			newBST = 0
			GameData::Stat.each_main do |statData|
				s = statData.id
				oldStat = species_data.base_stats[s]
				oldBST += oldStat
				newStat = newSpeciesData.base_stats[s]
				newBST += newStat
				if oldStat != newStat
					difference = (newStat - oldStat)
					difference = "+" + difference.to_s if difference > 0
					spacesString = ""
					statName = statData.real_name_brief
					(12-statName.length).times do
						spacesString += " "
					end
					changeLog.push("#{statName}: #{spacesString}#{oldStat} => #{newStat} (#{difference})")
				end
			end
			bstDiff = (newBST - oldBST)
			bstDiff = "+" + bstDiff.to_s if bstDiff > 0
			changeLog.push("Stat total:   #{oldBST} => #{newBST} (#{bstDiff})") if oldBST != newBST
			
			# Check for ability changes
			[0,1].each do |i|
				if species_data.abilities[i] != newSpeciesData.abilities[i]
					renamed = ABILITY_RENAMES[species_data.abilities[i]] || nil
					if renamed != newSpeciesData.abilities[i]
						if !newSpeciesData.abilities[i].nil?
							newAbilityData = GameData::Ability.get(newSpeciesData.abilities[i])
							newRealName = newAbilityData.real_name
						end
						if species_data.abilities[i].nil?
							if newAbilityData
								newAbilityText = "Ability #{i+1}: Added #{newRealName}"
								newAbilityText += " (Signature)" if newAbilityData.is_signature?
								changeLog.push(newAbilityText)
							end
						else
							oldAbilityData = GameData::Ability.get(species_data.abilities[i])
							oldRealName = oldAbilityData.real_name
							if newSpeciesData.abilities[i].nil?
								changeLog.push("Ability #{i+1}: #{oldRealName} removed")
							else
								replacementAbilityText = "Ability #{i+1}: #{oldRealName} => #{newRealName}"
								replacementAbilityText += " (Signature)" if newAbilityData.is_signature?
								changeLog.push(replacementAbilityText)
							end
						end
						# Write out the description of the new ability if its custom
						if !newSpeciesData.abilities[i].nil? && newAbilityData.tectonic_new
							desc = newAbilityData.description.gsub("%"," percent")
							changeLog.push("\t\"#{desc}\"")
						end
					end
				end
			end
					
			#Check for which specific moves have been changed
			moveRenamesInverted = MOVE_RENAMES.invert
			
			oldMovesLearned = species_data.learnable_moves
			
			newMovesLearned = newSpeciesData.learnable_moves
			
			cutMoves = []

			oldMovesLearned.each do |oldMove|
				moveRename = MOVE_RENAMES[oldMove] || oldMove
				next if newMovesLearned.include?(moveRename)
				next if GameData::Move.get(moveRename).cut
				cutMoves.push(oldMove)
			end
		
			
			if cutMoves.length > 0
				str = "Removed Move#{cutMoves.length > 1 ? "s" : ""}: "
				cutMoves.each_with_index do |move,index|
					str += GameData::Move.get(move).real_name
					if index != cutMoves.length - 1
						str += ", "
					end
				end
				changeLog.push(str)
			end
			
			addedSignatureMoves = []
			
			if newMovesLearned.length > 0
				addedMoves = []

				newMovesLearned.each do |newMove|
					next if oldMovesLearned.include?(newMove)
					next if moveRenamesInverted.key?(newMove) && oldMovesLearned.include?(moveRenamesInverted[newMove])
					
					if GameData::Move.get(newMove).is_signature?
						addedSignatureMoves.push(newMove)
					else
						addedMoves.push(newMove)
					end
				end

				str = "Added Move#{addedMoves.length > 1 ? "s" : ""}: "
				addedMoves.each_with_index do |move,index|
					str += GameData::Move.get(move).real_name
					if index != addedMoves.length - 1
						str += ", "
					end
				end
				changeLog.push(str)
			end

			if addedSignatureMoves.length > 0
				signatureLabel = "Added Signature Move#{addedSignatureMoves.length > 1 ? "s" : ""}:"
				changeLog.push(signatureLabel)
				addedSignatureMoves.each_with_index do |move,index|
					changeLog.concat(describeMoveForChangelog(move))
				end
			end
			
			# Check for evolution changes
			species_data.evolutions.each do |evolutionData|
				next if evolutionData[3]
				method = evolutionData[1]
				parameter = evolutionData[2]
				species = evolutionData[0]
				speciesName = GameData::Species.get(species).real_name
				
				speciesStillThere = false
				newSpeciesData.evolutions.each do |newEvolutionData|
					next if newEvolutionData[3]
					newSpecies = newEvolutionData[0]
					newMethod = newEvolutionData[1]
					newParameter = newEvolutionData[2]
					if species == newSpecies
						speciesStillThere = true
						if method == newMethod
							if parameter != newParameter
								changeLog.push("Evolution to #{speciesName} parameter: #{parameter} => #{newParameter}") 
							end
						else
							descriptor = method.to_s
							descriptor += "(" + parameter.to_s + ")" if !parameter.nil?
							newDescriptor = newMethod.to_s
							newDescriptor += "(" + newParameter.to_s + ")" if !newParameter.nil?
							changeLog.push("Evolution to #{speciesName} method: #{descriptor} => #{newDescriptor}") 
						end
						break
					end
				end
				changeLog.push("Evolution to #{speciesName} cut.") if !speciesStillThere
			end
			
			newSpeciesData.evolutions.each do |newEvolutionData|
				newSpecies = newEvolutionData[0]
				newSpeciesName = GameData::Species.get(newSpecies).real_name
				newMethod = newEvolutionData[1]
				newParameter = newEvolutionData[2]
				didEvoExistBefore = false
				species_data.evolutions.each do |evolutionData|
					didEvoExistBefore = true if newSpecies == evolutionData[0]
				end
				if !didEvoExistBefore
					changeLog.push("Evolution added: #{newSpeciesName}: #{newMethod},#{newParameter}")
				end
			end
			
			# Print out the changelog
			if changeLog.length == 0
				unchanged.push(species_data.id)
			else
				f.write("#{species_data.real_name}:\r\n")
				changeLog.each do |change|
					next if change.nil?
					f.write(change + "\r\n")
				end
				f.write("--------------------------------------------\r\n")
			end
		end
		#f.write("Species that were unchanged: #{unchanged.to_s}")
	}
	pbMessage(_INTL("Species changelog written to #{fileName}"))
end


def generateFullDexDoc
	fileName = "fulldexdoc.txt"
	File.open(fileName,"wb") { |f|
		GameData::Species.each do |species_data|
			next if isLegendary?(species_data.id_number)
			next if species_data.form != 0
			dexListing = []

			# Types
			types = [species_data.type1]
			types.push(species_data.type2) if species_data.type1 != species_data.type2
			typesListing = types.length > 1 ? "Types: " : "Type: "
			types.each_with_index do |type, index|
				typesListing += GameData::Type.get(type).real_name
				typesListing += ", " unless index == types.length - 1
			end
			dexListing.push(typesListing)

			# Abilities
			species_data.abilities.each do |abilityID|
				abilityData = GameData::Ability.get(abilityID)
				abilityText = "Ability: #{abilityData.real_name}"
				abilityText += " (Signature)" if abilityData.is_signature?
				dexListing.push(abilityText)

				desc = abilityData.description.gsub("%"," percent")
				dexListing.push("\t\"#{desc}\"")
			end

			# Base stats and total
			dexListing.push("Base stats:")
			baseStatTotal = 0
			GameData::Stat.each_main do |statData|
				statValue = species_data.base_stats[statData.id]
				baseStatTotal += statValue
				statName = statData.real_name_brief
				spacesString = ""
				(6-statName.length).times do
					spacesString += " "
				end
				dexListing.push("\t#{statName}: #{spacesString}#{statValue}")
			end
			dexListing.push("\tTotal:  #{baseStatTotal}")

			# Level up moves
			dexListing.push("Level up learnset:")
			allLevelMoves = []
			signatureMoves = []
			levelUpStr = ""
			species_data.moves.each_with_index do |levelUpEntry, index|
				next if allLevelMoves.include?(levelUpEntry[1])
				moveData = GameData::Move.get(levelUpEntry[1])
				allLevelMoves.push(levelUpEntry[1])
				signatureMoves.push(moveData.id) if moveData.is_signature?

				levelUpTimeStr = "\t"
				levelUpTimeStr += levelUpEntry[0] == 0 ? "Evo" : levelUpEntry[0].to_s
				
				spacesString = ""
				(8-levelUpTimeStr.length).times do
					spacesString += " "
				end
				
				levelUpStr += levelUpTimeStr + ":" + spacesString + moveData.real_name
				levelUpStr += " (Signature)" if moveData.is_signature?
				levelUpStr += "\r\n" unless index == species_data.moves.length - 1
			end
			dexListing.push(levelUpStr)

			# Signature moves
			unless signatureMoves.empty?
				signatureLabel = "Signature Move#{signatureMoves.length > 1 ? "s" : ""}:"
				dexListing.push(signatureLabel)
				signatureMoves.each do |move|
					dexListing.concat(describeMoveForChangelog(move))
				end
			end

			# Tutor moves
			tutorStr = "Tutor moves: "
			tutorOnlyMoves = species_data.learnable_moves - allLevelMoves
			tutorOnlyMoves.each_with_index do |moveID, index|
				tutorStr += GameData::Move.get(moveID).real_name
				tutorStr += ", " unless index == tutorOnlyMoves.length - 1
			end
			dexListing.push(tutorStr)

			# Prevos
			species_data.get_prevolutions.each do |evolution|
				method = evolution[1]
				parameter = evolution[2]
				species = evolution[0]
				evolutionName = GameData::Species.get_species_form(species, species_data.form).real_name
				methodDescription = describeEvolutionMethod(method, parameter)
				dexListing.push(_INTL("Evolves from {1} {2}", evolutionName, methodDescription))
			end

			# Evolutions
			species_data.evolutions.each do |evolutionData|
				next if evolutionData[3]
				method = evolutionData[1]
				parameter = evolutionData[2]
				species = evolutionData[0]
				evolutionName = GameData::Species.get_species_form(species, species_data.form).real_name
				methodDescription = describeEvolutionMethod(method, parameter)
				dexListing.push(_INTL("Evolves into {1} {2}", evolutionName, methodDescription))
			end

			# Tribes
			unless species_data.tribes.empty?
				tribeStr = "Tribes: "
				species_data.tribes.each_with_index do |tribeID, index|
					tribeStr += getTribeName(tribeID)
					tribeStr += ", " unless index == species_data.tribes.length - 1
				end
				dexListing.push(tribeStr)
			end

			# Print out the changelog
			if dexListing.length != 0
				f.write("#{species_data.real_name}:\r\n")
				dexListing.each do |listing|
					next if listing.nil?
					f.write(listing + "\r\n")
				end
				f.write("--------------------------------------------\r\n")
			end
		end
	}
	pbMessage(_INTL("Species changelog written to #{fileName}"))
end

def describeMoveForChangelog(move)
	changelogAdds = []
	moveData = GameData::Move.get(move)
	changelogAdds.push("\t#{moveData.real_name}")
	changelogAdds.push("\t#{moveData.categoryLabel}, #{GameData::Type.get(moveData.type).real_name}-type")
	mainLine = "#{moveData.total_pp} PP"
	mainLine = "#{moveData.accuracy}\% accuracy, " + mainLine if moveData.accuracy > 0
	mainLine = "#{moveData.base_damage} BP, " + mainLine if moveData.base_damage > 0
	mainLine = "\t" + mainLine
	changelogAdds.push(mainLine)
	changelogAdds.push("\t#{moveData.priorityLabel} priority") if moveData.priority != 0
	changelogAdds.push("\t\"#{moveData.description}\"")
	changelogAdds.push("\t#{moveData.tagLabel} move") if moveData.tagLabel
	return changelogAdds
end