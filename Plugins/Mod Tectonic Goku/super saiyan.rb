class PokeBattle_Move_UseChoiceOfForms < PokeBattle_Move
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @validMoves = %i[
            REVERTTOBASE
            SUPERSAIYAN
            GODFORM
            ULTRAINSTINCT
        ]
    end

    def resolutionChoice(user)
        validMoveNames = []
        @validMoves.each do |move|
            validMoveNames.push(getMoveName(move))
        end

        if @battle.autoTesting
            @chosenMove = @validMoves.sample
        elsif !user.pbOwnedByPlayer? # Trainer AI
            @chosenMove = @validMoves[0]
        else
            chosenIndex = @battle.scene.pbShowCommands(_INTL("Which form should {1} take?", user.pbThis(true)),validMoveNames,0)
            @chosenMove = @validMoves[chosenIndex]
        end
    end

    def pbEffectGeneral(user)
        user.pbUseMoveSimple(@chosenMove)
    end 

    def resetMoveUsageState
        @chosenMove = nil
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        return # No animation
    end
end




class PokeBattle_Move_GokuSuperSaiyan < PokeBattle_Move
  def pbMoveFailed?(user, _targets, show_message)
      if !user.countsAs?(:GOKU)
          @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
          return true
      elsif user.form == 3 || user.form == 5 || user.form == 6 || user.form == 7 || user.form == 9 || user.form == 10
          @battle.pbDisplay(_INTL("But {1} can't use it the way it is now!", user.pbThis(true))) if show_message
          return true
      elsif user.form == 0 && user.level <= 19 || user.form == 1 && user.level <= 30
          @battle.pbDisplay(_INTL("But {1} can't use it at this level!", user.pbThis(true))) if show_message
          return true
      end
      return false
  end


  def pbEffectGeneral(user)
    if user.form == 0
      user.pbChangeForm(1, _INTL("{1} transformed!", user.pbThis))
    elsif user.form == 1
      user.pbChangeForm(2, _INTL("{1} transformed!", user.pbThis))
    elsif user.form == 2
      user.pbChangeForm(3, _INTL("{1} transformed!", user.pbThis))
    elsif user.form == 4
        user.pbChangeForm(5, _INTL("{1} transformed!", user.pbThis))
    elsif user.form == 8
      user.pbChangeForm(9, _INTL("{1} transformed!", user.pbThis))
    end 
  end

  def getEffectScore(user, _target)
      score = super
      score += 100
      score += 50 if user.firstTurn?
      return score
  end

  def resetMoveUsageState
    @chosenForm = nil
  end
end 

class PokeBattle_Move_GokuBase < PokeBattle_Move
  def pbMoveFailed?(user, _targets, show_message)
      if !user.countsAs?(:GOKU)
          @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
          return true
      elsif user.form == 8 || user.form == 9 || user.form == 0 
          @battle.pbDisplay(_INTL("But {1} can't use it the way it is now!", user.pbThis(true))) if show_message
          return true
      end
      return false
  end


  def pbEffectGeneral(user)
    user.pbChangeForm(0, _INTL("{1} transformed!", user.pbThis)) 
  end

  def getEffectScore(user, _target)
      score = super
      score += 100
      score += 50 if user.firstTurn?
      return score
  end

  def resetMoveUsageState
    @chosenForm = nil
  end
end 

class PokeBattle_Move_GokuGod < PokeBattle_Move
  def pbMoveFailed?(user, _targets, show_message)
      if !user.countsAs?(:GOKU)
          @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
          return true
      elsif user.form == 4 || user.form == 5 || user.form == 6 || user.form == 7 || user.form == 8 || user.form == 9 || user.form == 10
          @battle.pbDisplay(_INTL("But {1} can't use it the way it is now!", user.pbThis(true))) if show_message
          return true
      elsif user.level <= 49
          @battle.pbDisplay(_INTL("But {1} can't use it at this level!", user.pbThis(true))) if show_message
          return true
      end
      return false
  end


  def pbEffectGeneral(user)
    user.pbChangeForm(4, _INTL("{1} transformed!", user.pbThis))
  end

  def getEffectScore(user, _target)
      score = super
      score += 100
      score += 50 if user.firstTurn?
      return score
  end

  def resetMoveUsageState
    @chosenForm = nil
  end
end 

class PokeBattle_Move_GokuUltraInstinct < PokeBattle_Move
  def pbMoveFailed?(user, _targets, show_message)
      if !user.countsAs?(:GOKU)
          @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
          return true
      elsif !(user.form == 0)
          @battle.pbDisplay(_INTL("But {1} can't use it the way it is now!", user.pbThis(true))) if show_message
          return true
      elsif user.level <= 69
          @battle.pbDisplay(_INTL("But {1} can't use it at this level!", user.pbThis(true))) if show_message
          return true
      elsif !tournamentWon?
          @battle.pbDisplay(_INTL("But {1} isn't strong enough!", user.pbThis(true))) if show_message
          return true
      end
      return false
  end


  def pbEffectGeneral(user)
    user.pbChangeForm(6, _INTL("{1} transformed!", user.pbThis))
  end

  def getEffectScore(user, _target)
      score = super
      score += 100
      score += 50 if user.firstTurn?
      return score
  end

  def resetMoveUsageState
    @chosenForm = nil
  end
end 