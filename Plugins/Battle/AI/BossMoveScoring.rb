class MoveScoringHandlerHash < HandlerHash2
end

class BossBehaviourHash < HandlerHash2
end

class PokeBattle_AI
	def self.AIErrorRecovered(error)
		pbMessage(_INTL("A recoverable AI error has occured. Please report the following to a programmer."))
		pbPrintException(error)
	end
	
	BossSpeciesUseMoveCodeIfAndOnlyIf			= MoveScoringHandlerHash.new
	BossSpeciesUseMoveIDIfAndOnlyIf				= MoveScoringHandlerHash.new
	
	def self.triggerBossSpeciesUseMoveCodeIfAndOnlyIf(speciesAndMoveCode,user,target,move)
		ret = nil
		begin
			ret = BossSpeciesUseMoveCodeIfAndOnlyIf.trigger(speciesAndMoveCode,user,target,move)
		rescue
			AIErrorRecovered($!)
		end
		return ret
	end
	
	def self.triggerBossSpeciesUseMoveIDIfAndOnlyIf(speciesAndMoveID,user,target,move)
		ret = nil
		begin
			ret = BossSpeciesUseMoveIDIfAndOnlyIf.trigger(speciesAndMoveID,user,target,move)
		rescue
			AIErrorRecovered($!)
		end
		return ret
	end
	
	BossDecidedOnMove				 	= BossBehaviourHash.new
	BossBeginTurn						= BossBehaviourHash.new
	
	def self.triggerBossDecidedOnMove(species,move,user,targets)
		ret = nil
		begin
			return BossDecidedOnMove.trigger(species,move,user,targets)
		rescue
			AIErrorRecovered($!)
		end
	end
	
	def self.triggerBossBeginTurn(species,battler)
		ret = nil
		begin
			return BossBeginTurn.trigger(species,battler)
		rescue
			AIErrorRecovered($!)
		end
	end

	def pbGetRealDamageBoss(move,user,target)
		# Calculate how much damage the move will do (roughly)
		baseDmg = pbMoveBaseDamage(move,user,target,0)
		# Account for accuracy of move
		accuracy = pbRoughAccuracy(move,user,target,0)
		realDamage = baseDmg * accuracy/100.0
		# Two-turn attacks waste 2 turns to deal one lot of damage
		if move.chargingTurnMove? || move.function=="0C2"   # Hyper Beam
		  realDamage *= 2/3   # Not halved because semi-invulnerable during use or hits first turn
		end
		return realDamage
	end

	def pbGetMoveScoreBoss(move,user,target)
		score = 100

		# Rejecting moves
		@battle.messagesBlocked = true
		
		score = 0 if PokeBattle_AI.triggerBossRejectMoveCode(move.function,move,user,target)
		score = 0 if PokeBattle_AI.triggerBossRejectMoveID(move.id,move,user,target)
		score = 0 if PokeBattle_AI.triggerBossSpeciesRejectMove(user.species,move,user,target)
		
		useMoveIFF = PokeBattle_AI.triggerBossSpeciesUseMoveCodeIfAndOnlyIf([user.species,move.function],user,target,move)
		if !(useMoveIFF.nil?)
			score = useMoveIFF ? 99999 : 0
		end
		useMoveIFF = PokeBattle_AI.triggerBossSpeciesUseMoveIDIfAndOnlyIf([user.species,move.id],user,target,move)
		if !(useMoveIFF.nil?)
			score = useMoveIFF ? 99999 : 0
		end

		if score > 0
			# Try very hard not to use a move that would fail against the target
			if !target.nil? && move.pbFailsAgainstTarget?(user,target)
				echoln("Scoring #{move.name} a 1 due to being predicted to fail against the target")
				score = 0
			end

			# Never use a move that would fail outright
			if move.pbMoveFailed?(user,[target])
				echoln("Scoring #{move.name} a 0 due to being predicted to fail entirely")
				score = 0
			end
		end
		@battle.messagesBlocked = false
		
		return score
	end
end