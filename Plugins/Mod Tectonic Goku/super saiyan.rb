class PokeBattle_Move_ChangeUserGokuForm < PokeBattle_TwoTurnMove
  def pbMoveFailed?(user, _targets, show_message)
      if !user.countsAs?(:GOKU)
          @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
          return true
      elsif not (user.form == 0 || user.form == 8)
          @battle.pbDisplay(_INTL("But {1} can't use it the way it is now!", user.pbThis(true))) if show_message
          return true
      end
      return false
  end


  def pbEffectGeneral(user)
    if user.form == 8
      user.pbChangeForm(9, _INTL("{1} transformed!", user.pbThis))
    end 
  end

  def getEffectScore(user, _target)
      score = super
      score += 100
      score += 50 if user.firstTurn?
      return score
  end
end 