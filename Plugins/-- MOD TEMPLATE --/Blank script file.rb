ItemHandlers::UseOnPokemon.add(:IMPERFECTBRACELET,proc { |item,pkmn,scene|
	species = pkmn.species
	validSpecies = %i[VENUSAUR CHARIZARD BLASTOISE ALAKAZAM GENGAR TYRANITAR BLAZIKEN AGGRON PIDGEOT SLOWBRO SCEPTILE SWAMPERT GLALIE SALAMENCE METAGROSS LATIAS LATIOS DIANCIE MACHAMP SNORLAX MELMETAL CORVIKNIGHT ORBEETLE COALOSSAL FLAPPLE APPLETUN HATTERENE GRIMMSNARL RILLABOOM CINDERACE INTELEON ETERNATUS GRENINJA]
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


def getFormSelectionChoices(species,currentForm=0)
	possibleForms = []
	possibleFormNames = []
	GameData::Species.each do |species_data|
		next unless species_data.species == species
		next if species_data.form == currentForm
		possibleForms.push(species_data)
		possibleFormNames.push(species_data.form_name)
	end
	possibleFormNames.push(_INTL("Cancel"))
	return possibleForms, possibleFormNames
end

ItemHandlers::UseOnPokemon.add(:IMPERFECTBRACELET,proc { |item,pkmn,scene|
if !pkmn.isSpecies?(:URSHIFU)
  pbSceneDefaultDisplay(_INTL("It had no effect."),scene)
  next false
end
if pkmn.fainted?
  pbSceneDefaultDisplay(_INTL("This can't be used on the fainted Pokémon."),scene)
end
newForm = (pkmn.form==0) ? 3 : 0
newForm = (pkmn.form==1) ? 2 : 1
pkmn.setForm(newForm) {
  scene&.pbRefresh
  pbSceneDefaultDisplay(_INTL("{1} changed Forme!",pkmn.name),scene)
}
next true
})