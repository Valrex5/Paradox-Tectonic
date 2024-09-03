class PokeBattle_Move_DiamondChange < PokeBattle_Move
  def pbMoveFailed?(user, _targets, show_message)
      if !user.canAddItem?(:DIAMONDSWORD) && !canRemoveItem?(user, user.firstItem)
          @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis} is already holding a Diamond Sword!")) if show_message
          return true
      elsif !user.countsAs?(:DIANCIE)
        @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
        return true
      elsif user.form != 0
        @battle.pbDisplay(_INTL("But {1} can't use it the way it is now!", user.pbThis(true))) if show_message
        return true
    end
    return false
  end

  def pbEffectGeneral(user)
      giveSword = false
      if user.canAddItem?(:DIAMONDSWORD)
          giveSword = true
      else
          removedAny = false
          user.eachItemWithName do |item, itemName|
              next if item == :DIAMONDSWORD
              next unless canRemoveItem?(user, item)
              user.removeItem(item)
              @battle.pbDisplay(_INTL("{1} dropped its {2}!", user.pbThis, itemName))
              removedAny = true
              break
          end

          giveSword = true if removedAny
      end

      if giveSword
          @battle.pbDisplay(_INTL("{1} creates a {2}!", user.pbThis, getItemName(:DIAMONDSWORD)))
          user.giveItem(:DIAMONDSWORD)
      end

      user.pbChangeForm(1, _INTL("{1} transforms!", user.pbThis))
      
  end
end 

MultipleForms.register(:DIANCIE, {
    "getFormOnLeavingBattle" => proc { |pkmn, _battle, _usedInBattle, endBattle|
        next 0 if pkmn.form == 1 && (pkmn.fainted? || endBattle)
    },
})