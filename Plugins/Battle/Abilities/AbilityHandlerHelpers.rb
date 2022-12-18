# For abilities that grant immunity to moves of a particular type, and heals the
# ability's bearer by 1/4 of its total HP instead.
def pbBattleMoveImmunityHealAbility(user,target,move,moveType,immuneType,battle,showMessages)
	return false if user.index==target.index
	return false if moveType != immuneType
	if target.applyFractionalHealing(1.0/4.0, showAbilitySplash: true) <= 0
	  battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!", target.pbThis,target.abilityName,move.name)) if showMessages
	end
	return true
end

# For abilities that grant immunity to moves of a particular type, and raises
# one of the ability's bearer's stats instead.
def pbBattleMoveImmunityStatAbility(user,target,move,moveType,immuneType,stat,increment,battle,showMessages)
	return false if user.index==target.index
	return false if moveType != immuneType
	battle.pbShowAbilitySplash(target) if showMessages
	if target.tryRaiseStat(stat,target,increment: increment)
	  battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true))) if showMessages
	end
	battle.pbHideAbilitySplash(target)
	return true
end

def pbBattleWeatherAbility(weather,battler,battle,ignorePrimal=false,ignoreFainted=false)
    return if !ignorePrimal && [:HarshSun, :HeavyRain, :StrongWinds].include?(battle.field.weather)
    battle.pbShowAbilitySplash(battler)
    battle.pbStartWeather(battler,weather,4,true,ignoreFainted)
    # NOTE: The ability splash is hidden again in def pbStartWeather.
end

def terrainSetAbility(terrain,battler,battle,ignorePrimal=false)
	return if battle.field.terrain == terrain
	battle.pbShowAbilitySplash(battler)
	battle.pbStartTerrain(battler, terrain)
	# NOTE: The ability splash is hidden again in def pbStartTerrain.
end

def randomStatusProcAbility(status,chance,user,target,move,battle)
	return if battle.pbRandom(100) >= chance
	return if user.pbHasStatus?(status)
	return if !move.canApplyAdditionalEffects?(user,target)
    battle.pbShowAbilitySplash(user)
    if target.pbCanInflictStatus?(status, user, true, move)
      target.pbInflictStatus(status,0,nil,user)
    end
    battle.pbHideAbilitySplash(user)
end