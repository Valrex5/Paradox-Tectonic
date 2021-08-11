def healPartyWithDelay()
	$Trainer.heal_party
	pbMEPlay('Pkmn healing')
	pbWait(68)
end

def earnBadge(badgeNum)
	badgeNames = [
		"Loyalty",
		"Perseverance",
		"Reverence",
		"Patience",
		"Solidarity",
		"Clarity",
		"Generosity",
		"Mercy"
	]
	name = badgeNames[badgeNum-1]
	pbMessage(_INTL("\\me[Badge get]You've earned the {1} Badge.",name))
	$Trainer.badges[badgeNum-1]=true
	$game_switches[3+badgeNum]=true # "Defeated Gym X" switch
	pbWait(120)
	
	# Increase the level cap
	case badgeNum
	when 1
		pbSetLevelCap(20)
	when 2..4
		pbIncreaseLevelCap(5)
	when 5
		pbSetLevelCap(45)
	when 6,7
		pbIncreaseLevelCap(5)
	when 8
		pbSetLevelCap(70)
	else
		echo("Gym badge #{index} not yet defined!\n")
	end
end

def receivedGymRewardYet?(index)
	if $game_variables[78] == 0
		$game_variables[78] = [false] * 8
	end
	
	return $game_variables[78][index]
end

def receiveGymReward(index)
	case index
	when 0
		pbReceiveItem(:FULLRESTORE)
		pbReceiveItem(:MAXREPEL)
		pbReceiveItem(:ULTRABALL)
		pbReceiveItem(:MAXREVIVE)
	else
		echo("Gym item #{index} not yet defined!\n")
	end
	
	$game_variables[78][index] = true # Mark the item as having been received
end

def gymLeaderDialogueHash()
	return @leaderDialogueHash if @leaderDialogueHash
	@leaderDialogueHash = {
		0 => ["I’ll heal up your Pokémon, give your other rewards, and get out of your way.",
		"I’ll heal up your Pokémon and get out of your way."]
	}
	return @leaderDialogueHash
end

def healAndGiveRewardIfNotYetGiven(index)
	dialogue = gymLeaderDialogueHash[index]
	if receivedGymRewardYet?(index)
		pbMessage(dialogue[1])
		healPartyWithDelay()
	else
		pbMessage(dialogue[0])
		healPartyWithDelay()
		receiveGymReward(index)
	end
end

def perfectTrainer()
	blackFadeOutIn() {
		setMySwitch('D',true)
		setFollowerGone()
	}
	pbTrainerDropsItem()
end

def defeatTrainer()
	setMySwitch('A',true)
	setFollowerInactive()
end

def phoneCallSE()
	msgwindow = pbCreateMessageWindow()
	3.times do
		pbMessageDisplay(msgwindow,"\\se[Voltorb Flip level up]Ring ring...")
		pbWait(20)
	end
	pbDisposeMessageWindow(msgwindow)
	Input.update
end

def phoneCall(caller="Unknown",eventSwitch=nil)
	phoneCallSE()
	setMySwitch(eventSwitch,true) if eventSwitch
	if !pbConfirmMessage(_INTL("...It's {1}. Pick up the phone?", caller))
		phoneCallEnd()
		command_end
		return
	end	
end

def phoneCallEnd()
	pbMessage(_INTL("\\se[Voltorb Flip mark]Click."))
	pbWait(40)
end

def showQuestion(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(4,event.x,event.y)
end

def showExclamation(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(3,event.x,event.y)
end

def showHappy(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Happy,event.x,event.y)
end

def showNormal(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Normal,event.x,event.y)
end

def showHate(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Hate,event.x,event.y)
end

def showPoison(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Poison,event.x,event.y)
end

def showSing(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Sing,event.x,event.y)
end

def showLove(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Love,event.x,event.y)
end

def showPokeballEnter(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(FollowerSettings::Animation_Come_In,event.x,event.y)
end

def showPokeballExit(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(FollowerSettings::Animation_Come_Out,event.x,event.y)
end

def blackFadeOutIn(&block)
	$game_screen.start_tone_change(Tone.new(-255,-255,-255,0), 6 * Graphics.frame_rate / 20)
	pbWait(8)
	block.call
	$game_screen.start_tone_change(Tone.new(0,0,0,0), 6 * Graphics.frame_rate / 20)
end

def setMySwitch(switch,value)
	pbSetSelfSwitch(get_self.id,switch,value)
end