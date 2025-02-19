class PokeBattle_Move_ChangeTypeDependsOnCategory < PokeBattle_Move
    def pbBaseType(_user)
        ret = :NORMAL
        if physicalMove?
            ret = :FAIRY if GameData::Type.exists?(:FAIRY)
        else
            ret = :STEEL if GameData::Type.exists?(:STEEL)
        end 
        return ret
    end 
end 