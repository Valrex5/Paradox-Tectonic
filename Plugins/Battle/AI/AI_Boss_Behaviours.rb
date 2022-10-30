class PokeBattle_AI_Boss
    def self.rejectPoisonMovesIfBelched
        @@rejectMovesIf.push(proc { |move, user, battle|
            next true if user.belched? && move.type == :POISON && move.id != :BELCH
        })
    end

    def self.prioritizeFling
        @@requiredMoves.push(:FLING)
    end

    def self.spaceOutProtecting
        @@useMovesIFF.push(proc { |move, user, battle|
            next move.is_a?(PokeBattle_ProtectMove) && @battle.turnCount % 3 && user.firstTurnThisRound?
        })
    end
end