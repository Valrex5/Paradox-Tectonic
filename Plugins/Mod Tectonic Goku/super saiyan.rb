class PokeBattle_Move_ChangeUserGokuForm < PokeBattle_Move
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