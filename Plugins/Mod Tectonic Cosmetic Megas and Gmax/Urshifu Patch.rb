module GameData
	class Species
			attr_reader :id
			attr_reader :id_number
			attr_reader :species
			attr_reader :form
			attr_reader :real_name
			attr_reader :real_form_name
			attr_reader :real_category
			attr_reader :real_pokedex_entry
			attr_reader :pokedex_form
			attr_reader :type1
			attr_reader :type2
			attr_reader :base_stats
			attr_reader :evs
			attr_reader :base_exp
			attr_reader :growth_rate
			attr_reader :gender_ratio
			attr_reader :catch_rate
			attr_reader :happiness
			attr_reader :moves
			attr_reader :tutor_moves
			attr_reader :egg_moves
			attr_reader :abilities
			attr_reader :hidden_abilities
			attr_reader :wild_item_common
			attr_reader :wild_item_uncommon
			attr_reader :wild_item_rare
			attr_reader :egg_groups
			attr_reader :hatch_steps
			attr_reader :incense
			attr_reader :evolutions
			attr_reader :height
			attr_reader :weight
			attr_reader :color
			attr_reader :shape
			attr_reader :habitat
			attr_reader :generation
			attr_reader :mega_stone
			attr_reader :mega_move
			attr_reader :unmega_form
			attr_reader :mega_message
			attr_reader :notes
			attr_accessor :earliest_available
			attr_reader :flags

			DATA = {}
			DATA_FILENAME = "species.dat"

			BASE_DATA = {} # Data that hasn't been extended

			extend ClassMethods
			include InstanceMethods
			def form_specific_moves
					if @species == :ROTOM
							return [
									nil,
									:OVERHEAT,    # Heat, Microwave
									:HYDROPUMP,   # Wash, Washing Machine
									:BLIZZARD,    # Frost, Refrigerator
									:AIRSLASH,    # Fan
									:LEAFSTORM, # Mow, Lawnmower
							]
					elsif @species == :URSHIFU
							return %i[
									WICKEDBLOW
									SURGINGSTRIKES
									SURGINGSTRIKES
									WICKEDBLOW
							]
					elsif @species == :NECROZMA
							return [
									nil,
									:SUNSTEELSTRIKE, # Dusk Mane (with Solgaleo) (form 1)
									:MOONGEISTBEAM, # Dawn Wings (with Lunala) (form 2)
							]
					end
					return []
			end
		end 
	end 