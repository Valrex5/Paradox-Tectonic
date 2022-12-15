DOWNSIDE_ABILITIES = [:SLOWSTART,:PRIMEVALSLOWSTART,:DEFEATIST,:TRUANT]

STATUS_UPSIDE_ABILITIES = [:GUTS,:AUDACITY,:MARVELSCALE,:MARVELSKIN,:QUICKFEET]

ALL_STATUS_SCORE_BONUS = 0
STATUS_UPSIDE_MALUS = 60

def getStatusSettingEffectScore(statusApplying,user,target,policies=[])
	case statusApplying
	when :SLEEP
		return getSleepEffectScore(user,target,policies)
	when :POISON
		return getPoisonEffectScore(user,target,policies)
	when :BURN
		return getBurnEffectScore(user,target,policies)
	when :FROSTBITE
		return getFrostbiteEffectScore(user,target,policies)
	when :NUMB
		return getNumbEffectScore(user,target,policies)
	when :DIZZY
		return getDizzyEffectScore(user,target,policies)
	end

	return score
end

def getNumbEffectScore(user,target,policies=[])
	if target && target.canNumb?(user,false)
		score = 0
		if target.hasDamagingAttack?
			score += 60
		end
		if target.pbSpeed(true) > user.pbSpeed(true)
			score += 60
		end
		score -= STATUS_UPSIDE_MALUS if target.hasActiveAbilityAI?(STATUS_UPSIDE_ABILITIES)
		score += STATUS_PUNISHMENT_BONUS if user.hasStatusPunishMove? || user.pbHasMoveFunction?('07C') # Smelling Salts
		score += 60 if user.hasActiveAbilityAI?(:TENDERIZE)
	else
		return 0
	end
	return score
end

def getPoisonEffectScore(user,target,policies=[])
	if target && target.canPoison?(user,false)
		return 9999 if policies.include?(:PRIORITIZEDOTS)
		score = 40
		score += 20 if target.hp == target.totalhp
		score += 20 if target.hp >= target.totalhp / 2 || target.hp <= target.totalhp / 8
		score += 60 if @battle.pbIsTrapped?(target.index)
		score += NON_ATTACKER_BONUS unless user.hasDamagingAttack?
		score -= STATUS_UPSIDE_MALUS if target.hasActiveAbilityAI?([:TOXICBOOST,:POISONHEAL].concat(STATUS_UPSIDE_ABILITIES))
		score += STATUS_PUNISHMENT_BONUS if user.hasStatusPunishMove? || user.pbHasMoveFunction?('07B') # Venoshock
		score *= 2 if user.hasActiveAbilityAI?(:AGGRAVATE)
	else
		return 0
	end
	return score
end

def getBurnEffectScore(user,target,policies=[])
	if target && target.canBurn?(user,false)
		return 9999 if policies.include?(:PRIORITIZEDOTS)
		score = 40
		if target.hasPhysicalAttack?
			score += 30
			score += 30 unless target.hasSpecialAttack?
		end
		score += 20 if target.hp >= target.totalhp / 2 || target.hp <= target.totalhp / 8
		score += NON_ATTACKER_BONUS unless user.hasDamagingAttack?
		score -= STATUS_UPSIDE_MALUS if target.hasActiveAbilityAI?([:FLAREBOOST,:BURNHEAL].concat(STATUS_UPSIDE_ABILITIES))
		score += STATUS_PUNISHMENT_BONUS if user.hasStatusPunishMove? || user.pbHasMoveFunction?('50E') # Flare Up
		score *= 2 if user.hasActiveAbilityAI?(:AGGRAVATE)
	else
		return 0
	end
	return score
end

def getFrostbiteEffectScore(user,target,policies=[])
	if target && target.canFrostbite?(user,false)
		return 9999 if policies.include?(:PRIORITIZEDOTS)
		score = 40
		if target.hasSpecialAttack?
			score += 30
			score += 30 unless target.hasPhysicalAttack?
		end
		score += 20 if target.hp >= target.totalhp / 2 || target.hp <= target.totalhp / 8
		score += NON_ATTACKER_BONUS unless user.hasDamagingAttack?
		score -= STATUS_UPSIDE_MALUS if target.hasActiveAbilityAI?([:FROSTHEAL].concat(STATUS_UPSIDE_ABILITIES))
		score += STATUS_PUNISHMENT_BONUS if user.hasStatusPunishMove? || user.pbHasMoveFunction?('50C') # Ice Impact
		score *= 2 if user.hasActiveAbilityAI?(:AGGRAVATE)
	else
		return 0
	end
	return score
end

def getSleepEffectScore(user,target,policies=[])
	score = 200
	score -= 100 if target.hasSleepAttack?
	score += STATUS_PUNISHMENT_BONUS if user.hasStatusPunishMove?
	return score
end

def getDizzyEffectScore(user,target,policies=[])
	canDizzy = target.canDizzy?(user,false) && !target.hasActiveAbility?(:MENTALBLOCK)
	if canDizzy
		score = 60 # TODO: Some sort of basic AI for rating abilities?
		score += 20 if target.hp >= target.totalhp / 2
		score += 20 if user.hasDamagingAttack?
		score -= STATUS_UPSIDE_MALUS if target.hasActiveAbilityAI?([:FLUSTERFLOCK,:HEADACHE].concat(STATUS_UPSIDE_ABILITIES))
		score += STATUS_PUNISHMENT_BONUS if user.hasStatusPunishMove?
	else
		return 0
	end
	return score
end

def getLeechEffectScore(user,target,policies=[])
	canLeech = target.canLeech?(user,false)
	if canLeech
		return 9999 if policies.include?(:PRIORITIZEDOTS)
		score = 40
		score += NON_ATTACKER_BONUS * 2 unless user.hasDamagingAttack?
		score += 20 if target.hp >= target.totalhp / 2
		score += 30 if target.totalhp > user.totalhp * 2
		score -= 30 if target.totalhp < user.totalhp / 2
		score -= STATUS_UPSIDE_MALUS if target.hasActiveAbilityAI?(STATUS_UPSIDE_ABILITIES)
		score += STATUS_PUNISHMENT_BONUS if user.hasStatusPunishMove?
		score *= 4 if user.hasActiveAbilityAI?(:AGGRAVATE)
		score *= 1.5 if user.hasActiveAbilityAI?(:ROOTED)
		score *= 1.3 if user.hasActiveItem?(:BIGROOT)
		score *= 2 if user.hasAlly?
	else
		return 0
	end
	return score
end

def getFlinchingEffectScore(baseScore,user,target,policies)
	userSpeed = user.pbSpeed(true)
    targetSpeed = target.pbSpeed(true)
    
    if target.hasActiveAbilityAI?(:INNERFOCUS) || target.substituted? ||
          target.effectActive?(:FlinchedAlready) || targetSpeed > userSpeed
      return 0
    end

	score = baseScore
	score *= 2 if user.hasAlly?

	return score
end

def getWantsToBeFasterScore(user,other,magnitude=1)
	return getWantsToBeSlowerScore(user,other,-magnitude)
end

def getWantsToBeSlowerScore(user,other,magnitude=1)
	userSpeed = user.pbSpeed(true)
	otherSpeed = other.pbSpeed(true)
	if userSpeed < otherSpeed
		score += 10 * magnitude
	else
		score -= 10 * magnitude
	end
	return score
end

def getHazardSettingEffectScore(user,target)
	score -= 40
	canChoose = false
	user.eachOpposing do |b|
		next if !user.battle.pbCanChooseNonActive?(b.index)
		canChoose = true
		break
	end
	return 0 if !canChoose # Opponent can't switch in any Pokemon
		
	score += 15 * user.enemiesInReserveCount
	score += 15 * user.alliesInReserveCount
	return score
end

def getSelfKOMoveScore(user,target)
	reserves = user.battle.pbAbleNonActiveCount(user.idxOwnSide)
	return 0 if reserves == 0 # don't want to lose or draw
	return 0 if user.hp > user.totalhp / 2
	score -= 50
	score -= 30 if user.hp > user.totalhp / 8
	return score
end

def statusSpikesWeightOnSide(side,excludeEffects=[])
	hazardWeight = 0
	hazardWeight += 20 * side.countEffect(:PoisonSpikes) if !excludeEffects.include?(:PoisonSpikes)
	hazardWeight += 20 * side.countEffect(:FlameSpikes) if !excludeEffects.include?(:FlameSpikes)
	hazardWeight += 20 * side.countEffect(:FrostSpikes) if !excludeEffects.include?(:FrostSpikes)
	return 0
end

def hazardWeightOnSide(side,excludeEffects=[])
	hazardWeight = 0
	hazardWeight += 20 * side.countEffect(:Spikes) if !excludeEffects.include?(:Spikes)
	hazardWeight += 50 if side.effectActive?(:StealthRock) && !excludeEffects.include?(:StealthRock)
	hazardWeight += 20 if side.effectActive?(:StickyWeb) && !excludeEffects.include?(:StickyWeb)
	hazardWeight += statusSpikesWeightOnSide(side,excludeEffects)
	return hazardWeight
end

def getSwitchOutEffectScore(user,target)
	score -= 10
	score -= hazardWeightOnSide(user.pbOwnSide)
	return score
end

def getForceOutEffectScore(user,target)
	return 0 if target.substituted?
	count = 0
	@battle.pbParty(target.index).each_with_index do |pkmn,i|
		count += 1 if @battle.pbCanSwitchLax?(target.index,i)
	end
	return 0 if count
	score += hazardWeightOnSide(target.pbOwnSide)
	return score
end

def getHealingEffectScore(user,target,magnitude=5)
	return 0 if user.opposes?(target) && !target.effectActive?(:NerveBreak)
    return 0 if !user.opposes?(target) && target.effectActive?(:NerveBreak)
    if target.hp <= target.totalhp / 2
      	score += magnitude * 10
	  	score *= 1.5 if target.hasActiveAbilityAI?(:ROOTED)
    	score *= 1.3 if target.hasActiveItem?(:BIGROOT)
    end
	if !user.opposes?(target)
		score += target.stages[:DEFENSE] * 2 * magnitude
		score += target.stages[:SPECIAL_DEFENSE] * 2 * magnitude
	end
	return score
end

def getMultiStatUpEffectScore(statUpArray,user,target)
	score = 0

	for i in 0...statUpArray.length/2
		statSymbol = statUpArray[i*2]
		statIncreaseAmount = statUpArray[i*2 + 1]

		# Give no extra points for attacking stats you can't use
		next if statSymbol == :ATTACK && !target.hasPhysicalAttack?
		next if statSymbol == :SPECIAL_ATTACK && !target.hasSpecialAttack?

		# Increase the score more for boosting attacking stats
		if statSymbol == :ATTACK || statSymbol == :SPECIAL_ATTACK
			increase = 40
		else
			increase = 30
		end

		increase *= statIncreaseAmount
		increase -= target.stages[statSymbol] * 10 # Reduce the score for each existing stage

		increase *= -1 if target.hasActiveAbilityAI?(:CONTRARY)

		score += increase
	end

	# Stat up moves tend to be strong on the first turn
    score *= 1.2 if target.firstTurn?

	# Stat up moves tend to be strong when you have HP to use
    score *= 1.2 if target.hp > target.totalhp / 2
	
	# Stat up moves tend to be strong when you are protected by a substitute
	score *= 1.2 if target.substituted?

    # Feel more free to use the move the fewer pokemon that can attack the buff receiver this turn
    target.eachPotentialAttacker do |b|
      score *= 0.8
    end
	
	return score
end