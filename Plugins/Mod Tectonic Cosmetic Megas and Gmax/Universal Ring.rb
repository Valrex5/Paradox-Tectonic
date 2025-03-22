ItemHandlers::UseOnPokemon.add(:UNIVERSALRING,proc { |item,pkmn,scene|
	species = pkmn.species
	validSpecies = %i[VENUSAUR CHARIZARD BLASTOISE ALAKAZAM GENGAR TYRANITAR BLAZIKEN AGGRON PIDGEOT SLOWBRO SCEPTILE SWAMPERT SALAMENCE METAGROSS LATIAS LATIOS DIANCIE MACHAMP SNORLAX MELMETAL CORVIKNIGHT ORBEETLE COALOSSAL FLAPPLE APPLETUN HATTERENE GRIMMSNARL RILLABOOM CINDERACE INTELEON ETERNATUS GRENINJA URSHIFU]
	if validSpecies.include?(species)
		possibleForms = []
		possibleFormNames = []
		GameData::Species.each do |species_data|
			next unless species_data.species == species
			next if species_data.form == pkmn.form
			possibleForms.push(species_data)
			possibleFormNames.push(species_data.form_name)
		end
		possibleFormNames.push(_INTL("Cancel"))
		choice = pbMessage(_INTL("Which form shall the Pokemon take?"),possibleFormNames,possibleFormNames.length)
		if choice < possibleForms.length
			pbSceneDefaultDisplay(_INTL("#{pkmn.name} swapped to #{possibleFormNames[choice]}!"),scene)
			
			showPokemonChanges(pkmn) {
				pkmn.form = possibleForms[choice].form
			}
		end
		next true
	else
		pbSceneDefaultDisplay(_INTL("Cannot use this item on that Pokemon."),scene)
		next false
	end
})