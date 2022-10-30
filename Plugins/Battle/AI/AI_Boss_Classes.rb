class PokeBattle_AI_Keldeo < PokeBattle_AI_Boss
	rejectPoisonMovesIfBelched
end

class PokeBattle_AI_Donster < PokeBattle_AI_Boss
	rejectPoisonMovesIfBelched
end

class PokeBattle_AI_Combee < PokeBattle_AI_Boss
	@@firstTurnOnly.push(:HELPINGHAND)

	def initialize(user,battle)
		case user.level
		when 1..24
			@@nonFirstTurnOnly.push(:SMUSH)
		when 25..39
			@useMoveIFF.add(:CREEPOUT, proc { |move, user, target, battle|
				next user.nthTurnThisRound?(1)
			})
			@@fallback.push(:STEAMROLLER)
		when 40..70
			@useMoveIFF.add(:CREEPOUT, proc { |move, user, target, battle|
				next user.nthTurnThisRound?(1)
			})
			@@fallback.push(:BUGBUZZ)
		end
	end
end

class PokeBattle_AI_Gourgeist < PokeBattle_AI_Boss
	@@useMoveIFF.add(:TRICKORTREAT, proc { |move, user, target, battle|
		next user.lastTurnThisRound?
	})
end

class PokeBattle_AI_Electrode < PokeBattle_AI_Boss
	TURNS_TO_EXPLODE = 3

	@@warnedIFFMove.add(:EXPLOSION, {
		:condition => proc { |move, user, target, battle|
			next user.turnCount == ELECTRODE_TURNS_TO_EXPLODE
		},
		:warning => proc { |move, user, targets, battle|
			_INTL("#{user.pbThis} notices one of your Pokémon's flammable item!")
		}
	})

	@@decidedOnMove.add(:EXPLOSION, proc { |move, user, targets, battle|
		_INTL("#{user.pbThis} is fully charged. Its about to explode!")
	})

	@@beginTurn.push( proc { |move, user, target, battle|
		turnsRemaining = ELECTRODE_TURNS_TO_EXPLODE - user.turnCount
		if turnsRemaining > 0
			battle.pbDisplayBossNarration(_INTL("#{user.pbThis} is charging up."))
			battle.pbDisplayBossNarration(_INTL("#{turnsRemaining} turns remain!"))
		end
	})
end

class PokeBattle_AI_Entei < PokeBattle_AI_Boss
	@@warnedIFFMove.add(:INCINERATE, {
		:condition => proc { |move, user, target, battle|
			next target.item && (target.item.is_berry? || target.item.is_gem?)
		},
		:warning => proc { |move, user, targets, battle|
			_INTL("#{user.pbThis} notices a flammable item amongst your Pokémon!")
		}
	})
end

class PokeBattle_AI_Incineroar < PokeBattle_AI_Boss
	@@lastTurnOnly.concat([:SWAGGER,:TAUNT])
end

class PokeBattle_AI_Linoone < PokeBattle_AI_Boss
	@@warnedIFFMove.add(:COVET, {
		:condition => proc { |move, user, target, battle|
			next user.item.nil? && !target.item.nil?
		},
		:warning => proc { |move, user, targets, battle|
			target = targets[0]
			_INTL("#{user.pbThis} eyes #{target.pbThis(true)}'s #{GameData::Item.get(target.item).real_name} with jealousy!")
		}
	})
end

class PokeBattle_AI_Parasect < PokeBattle_AI_Boss
	@@warnedIFFMove.add(:SPORE, {
		:condition => proc { |move, user, target, battle|
			anyAsleep = false
			user.battle.battlers.each do |b|
				next if !b || !user.opposes?(b)
				anyAsleep = true if b.asleep?
			end
			next !anyAsleep
		},
		:warning => proc { |move, user, targets, battle|
			_INTL("#{user.pbThis}'s shroom stalks perked up!")
		}
	})
end

class PokeBattle_AI_Xerneas < PokeBattle_AI_Boss
	@@useMoveIFF.add(:GEOMANCY, proc { |move, user, target, battle|
		next user.turnCount == 0 && user.lastTurnThisRound?
	})
end

class PokeBattle_AI_Jirachi < PokeBattle_AI_Boss
	@@useMoveIFF.add(:DOOMDESIRE, proc { |move, user, target, battle|
		next user.battle.turnCount % 3 == 0 && user.lastTurnThisRound?
	})

	@@warnedIFFMove.add(:LIFEDEW, {
		:condition => proc { |move, user, target, battle|
			next user.battle.turnCount % 3 == 1 && user.hp < user.totalhp/2
		},
		:warning => proc { |move, user, targets, battle|
			_INTL("#{user.pbThis} takes a passive stance, inspecting its wounds.")
		}
	})
end

class PokeBattle_AI_Magnezone < PokeBattle_AI_Boss
	@@useMoveIFF.add(:ZAPCANNON, proc { |move, user, target, battle|
		next user.battle.commandPhasesThisRound == 0 && user.pointsAt?(:LockOnPos,target)
	})

	@@lastTurnOnly.push(:LOCKON)
end

class PokeBattle_AI_Ninetales < PokeBattle_AI_Boss
	@@firstTurnOnly.push(:WILLOWISP)
end

class PokeBattle_AI_PorygonZ < PokeBattle_AI_Boss
	@@firstTurnOnly.concat([:CONVERSION,:CONVERSION2])
end

class PokeBattle_AI_Cresselia < PokeBattle_AI_Boss
	@@beginTurn.push( proc { |move, user, target, battle|
		if battle.turnCount == 4
			battle.pbDisplayBossNarration(_INTL("A Shadow creeps into the dream..."))
			battle.addAvatarBattler(:DARKRAI,user.level)
		end
	})
end

class PokeBattle_AI_Groudon < PokeBattle_AI_Boss
	@@wholeRound.concat([:ERUPTION,:PRECIPICEBLADES])

	@@warnedIFFMove.add(:ERUPTION, {
		:condition => proc { |move, user, target, battle|
			next user.battle.turnCount == 0
		},
		:warning => proc { |move, user, targets, battle|
			_INTL("#{user.pbThis} is clearly preparing a massive opening attack!")
		}
	})

	@@warnedIFFMove.add(:PRECIPICEBLADES, {
		:condition => proc { |move, user, target, battle|
			next turnCount > 0 && turnCount % 3 == 0
		},
		:warning => proc { |move, user, targets, battle|
			_INTL("#{user.pbThis} is gathering energy for a big attack!")
		}
	})
end

class PokeBattle_AI_Kyogre < PokeBattle_AI_Boss
	@@wholeRound.concat([:WATERSPOUT,:ORIGINPULSE])

	@@warnedIFFMove.add(:WATERSPOUT, {
		:condition => proc { |move, user, target, battle|
			next user.battle.turnCount == 0
		},
		:warning => proc { |move, user, targets, battle|
			_INTL("#{user.pbThis} is clearly preparing a massive opening attack!")
		}
	})

	@@warnedIFFMove.add(:ORIGINPULSE, {
		:condition => proc { |move, user, target, battle|
			next turnCount > 0 && turnCount % 3 == 0
		},
		:warning => proc { |move, user, targets, battle|
			_INTL("#{user.pbThis} is gathering energy for a big attack!")
		}
	})
end