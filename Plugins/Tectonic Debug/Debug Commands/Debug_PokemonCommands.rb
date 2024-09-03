#===============================================================================
#
#===============================================================================
module PokemonDebugMenuCommands
    @@commands = HandlerHashBasic.new
  
    def self.register(option, hash)
      @@commands.add(option, hash)
    end
  
    def self.registerIf(condition, hash)
      @@commands.addIf(condition, hash)
    end
  
    def self.copy(option, *new_options)
      @@commands.copy(option, *new_options)
    end
  
    def self.each
      @@commands.each { |key, hash| yield key, hash }
    end
  
    def self.hasFunction?(option, function)
      option_hash = @@commands[option]
      return option_hash && option_hash.keys.include?(function)
    end
  
    def self.getFunction(option, function)
      option_hash = @@commands[option]
      return (option_hash && option_hash[function]) ? option_hash[function] : nil
    end
  
    def self.call(function, option, *args)
      option_hash = @@commands[option]
      return nil if !option_hash || !option_hash[function]
      return (option_hash[function].call(*args) == true)
    end
  end
  
  #===============================================================================
  # HP/Status options
  #===============================================================================
  PokemonDebugMenuCommands.register("hpstatusmenu", {
    "parent"      => "main",
    "name"        => _INTL("HP/Status..."),
    "always_show" => true
  })
  
  PokemonDebugMenuCommands.register("sethp", {
    "parent"      => "hpstatusmenu",
    "name"        => _INTL("Set HP"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      if pkmn.egg?
        screen.pbDisplay(_INTL("{1} is an egg.", pkmn.name))
      else
        params = ChooseNumberParams.new
        params.setRange(0, pkmn.totalhp)
        params.setDefaultValue(pkmn.hp)
        newhp = pbMessageChooseNumber(
           _INTL("Set {1}'s HP (max. {2}).", pkmn.name, pkmn.totalhp), params) { screen.pbUpdate }
        if newhp != pkmn.hp
          pkmn.hp = newhp
          screen.pbRefreshSingle(pkmnid)
        end
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("setstatus", {
    "parent"      => "hpstatusmenu",
    "name"        => _INTL("Set status"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      if pkmn.egg?
        screen.pbDisplay(_INTL("{1} is an egg.", pkmn.name))
      elsif pkmn.hp <= 0
        screen.pbDisplay(_INTL("{1} is fainted, can't change status.", pkmn.name))
      else
        cmd = 0
        commands = [_INTL("[Cure]")]
        ids = [:NONE]
        GameData::Status.each do |s|
          next if s.id == :NONE
          commands.push(s.name)
          ids.push(s.id)
        end
        loop do
          cmd = screen.pbShowCommands(_INTL("Set {1}'s status.", pkmn.name), commands, cmd)
          break if cmd < 0
          case cmd
          when 0   # Cure
            pkmn.heal_status
            screen.pbDisplay(_INTL("{1}'s status was cured.", pkmn.name))
            screen.pbRefreshSingle(pkmnid)
          else   # Give status problem
            count = 0
            cancel = false
            if ids[cmd] == :SLEEP
              params = ChooseNumberParams.new
              params.setRange(0, 9)
              params.setDefaultValue(3)
              count = pbMessageChooseNumber(
                 _INTL("Set the Pokémon's sleep count."), params) { screen.pbUpdate }
              cancel = true if count <= 0
            end
            if !cancel
              pkmn.status      = ids[cmd]
              pkmn.statusCount = count
              screen.pbRefreshSingle(pkmnid)
            end
          end
        end
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("fullheal", {
    "parent"      => "hpstatusmenu",
    "name"        => _INTL("Fully heal"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      if pkmn.egg?
        screen.pbDisplay(_INTL("{1} is an egg.", pkmn.name))
      else
        pkmn.heal
        screen.pbDisplay(_INTL("{1} was fully healed.", pkmn.name))
        screen.pbRefreshSingle(pkmnid)
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("makefainted", {
    "parent"      => "hpstatusmenu",
    "name"        => _INTL("Make fainted"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      if pkmn.egg?
        screen.pbDisplay(_INTL("{1} is an egg.", pkmn.name))
      else
        pkmn.hp = 0
        screen.pbRefreshSingle(pkmnid)
      end
      next false
    }
  })
  
  #===============================================================================
  # Level/stats options
  #===============================================================================
  PokemonDebugMenuCommands.register("levelstats", {
    "parent"      => "main",
    "name"        => _INTL("Level/stats..."),
    "always_show" => true
  })
  
  PokemonDebugMenuCommands.register("setlevel", {
    "parent"      => "levelstats",
    "name"        => _INTL("Set level"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      if pkmn.egg?
        screen.pbDisplay(_INTL("{1} is an egg.", pkmn.name))
      else
        params = ChooseNumberParams.new
        params.setRange(1, GameData::GrowthRate.max_level)
        params.setDefaultValue(pkmn.level)
        level = pbMessageChooseNumber(
           _INTL("Set the Pokémon's level (max. {1}).", params.maxNumber), params) { screen.pbUpdate }
        if level != pkmn.level
          pkmn.level = level
          pkmn.calc_stats
          screen.pbRefreshSingle(pkmnid)
        end
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("setexp", {
    "parent"      => "levelstats",
    "name"        => _INTL("Set Exp"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      if pkmn.egg?
        screen.pbDisplay(_INTL("{1} is an egg.", pkmn.name))
      else
        minxp = pkmn.growth_rate.minimum_exp_for_level(pkmn.level)
        maxxp = pkmn.growth_rate.minimum_exp_for_level(pkmn.level + 1)
        if minxp == maxxp
          screen.pbDisplay(_INTL("{1} is at the maximum level.", pkmn.name))
        else
          params = ChooseNumberParams.new
          params.setRange(minxp, maxxp - 1)
          params.setDefaultValue(pkmn.exp)
          newexp = pbMessageChooseNumber(
             _INTL("Set the Pokémon's Exp (range {1}-{2}).", minxp, maxxp - 1), params) { screen.pbUpdate }
          if newexp != pkmn.exp
            pkmn.exp = newexp
            pkmn.calc_stats
            screen.pbRefreshSingle(pkmnid)
          end
        end
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("randomizePID", {
    "parent"      => "levelstats",
    "name"        => _INTL("Randomize PID"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      cmd = 0
      loop do
        persid = sprintf("0x%08X", pkmn.personalID)
        cmd = screen.pbShowCommands(_INTL("Personal ID is {1}.", persid), [_INTL("Randomise pID")], cmd)
        break if cmd < 0
        pkmn.personalID = rand(2 ** 16) | rand(2 ** 16) << 16
        pkmn.calc_stats
        screen.pbRefreshSingle(pkmnid)
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("sethappiness", {
    "parent"      => "levelstats",
    "name"        => _INTL("Set happiness"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      params = ChooseNumberParams.new
      params.setRange(0, 255)
      params.setDefaultValue(pkmn.happiness)
      h = pbMessageChooseNumber(
         _INTL("Set the Pokémon's happiness (max. 255)."), params) { screen.pbUpdate }
      if h != pkmn.happiness
        pkmn.happiness = h
        screen.pbRefreshSingle(pkmnid)
      end
      next false
    }
  })

  PokemonDebugMenuCommands.register("resetpersonality", {
    "parent"      => "levelstats",
    "name"        => _INTL("Reset Personality"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      pkmn.resetPersonality
      screen.pbDisplay(_INTL("Reset {1}'s personality.", pkmn.name))
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("conteststats", {
    "parent"      => "levelstats",
    "name"        => _INTL("Contest stats..."),
    "always_show" => true
  })
  
  PokemonDebugMenuCommands.register("setbeauty", {
    "parent"      => "conteststats",
    "name"        => _INTL("Set Beauty"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      params = ChooseNumberParams.new
      params.setRange(0, 255)
      params.setDefaultValue(pkmn.beauty)
      newval = pbMessageChooseNumber(
         _INTL("Set the Pokémon's Beauty (max. 255)."), params) { screen.pbUpdate }
      if newval != pkmn.beauty
        pkmn.beauty = newval
        screen.pbRefreshSingle(pkmnid)
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("setcool", {
    "parent"      => "conteststats",
    "name"        => _INTL("Set Cool"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      params = ChooseNumberParams.new
      params.setRange(0, 255)
      params.setDefaultValue(pkmn.cool)
      newval = pbMessageChooseNumber(
         _INTL("Set the Pokémon's Cool (max. 255)."), params) { screen.pbUpdate }
      if newval != pkmn.cool
        pkmn.cool = newval
        screen.pbRefreshSingle(pkmnid)
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("setcute", {
    "parent"      => "conteststats",
    "name"        => _INTL("Set Cute"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      params = ChooseNumberParams.new
      params.setRange(0, 255)
      params.setDefaultValue(pkmn.cute)
      newval = pbMessageChooseNumber(
         _INTL("Set the Pokémon's Cute (max. 255)."), params) { screen.pbUpdate }
      if newval != pkmn.cute
        pkmn.cute = newval
        screen.pbRefreshSingle(pkmnid)
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("setsmart", {
    "parent"      => "conteststats",
    "name"        => _INTL("Set Smart"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      params = ChooseNumberParams.new
      params.setRange(0, 255)
      params.setDefaultValue(pkmn.smart)
      newval = pbMessageChooseNumber(
         _INTL("Set the Pokémon's Smart (max. 255)."), params) { screen.pbUpdate }
      if newval != pkmn.smart
        pkmn.smart = newval
        screen.pbRefreshSingle(pkmnid)
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("settough", {
    "parent"      => "conteststats",
    "name"        => _INTL("Set Tough"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      params = ChooseNumberParams.new
      params.setRange(0, 255)
      params.setDefaultValue(pkmn.tough)
      newval = pbMessageChooseNumber(
         _INTL("Set the Pokémon's Tough (max. 255)."), params) { screen.pbUpdate }
      if newval != pkmn.tough
        pkmn.tough = newval
        screen.pbRefreshSingle(pkmnid)
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("setsheen", {
    "parent"      => "conteststats",
    "name"        => _INTL("Set Sheen"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      params = ChooseNumberParams.new
      params.setRange(0, 255)
      params.setDefaultValue(pkmn.sheen)
      newval = pbMessageChooseNumber(
         _INTL("Set the Pokémon's Sheen (max. 255)."), params) { screen.pbUpdate }
      if newval != pkmn.sheen
        pkmn.sheen = newval
        screen.pbRefreshSingle(pkmnid)
      end
      next false
    }
  })
  
  #===============================================================================
  # Moves options
  #===============================================================================
  PokemonDebugMenuCommands.register("moves", {
    "parent"      => "main",
    "name"        => _INTL("Moves..."),
    "always_show" => true
  })
  
  PokemonDebugMenuCommands.register("teachmove", {
    "parent"      => "moves",
    "name"        => _INTL("Teach move"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      move = pbChooseMoveList
      if move
        pbLearnMove(pkmn, move)
        screen.pbRefreshSingle(pkmnid)
      end
      next false
    }
  })

  PokemonDebugMenuCommands.register("teachlegalmove", {
    "parent"      => "moves",
    "name"        => _INTL("Teach legal move"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      move = pbChooseMoveListForSpecies(pkmn.species, nil, true)
      if move
        pbLearnMove(pkmn, move)
        screen.pbRefreshSingle(pkmnid)
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("forgetmove", {
    "parent"      => "moves",
    "name"        => _INTL("Forget move"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      pbChooseMove(pkmn, 2, 4)
      moveindex = getGlobalVariable(2)
      if moveindex >= 0
        movename = pkmn.moves[moveindex].name
        pkmn.forget_move_at_index(moveindex)
        screen.pbDisplay(_INTL("{1} forgot {2}.", pkmn.name, movename))
        screen.pbRefreshSingle(pkmnid)
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("resetmoves", {
    "parent"      => "moves",
    "name"        => _INTL("Reset moves"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      pkmn.reset_moves
      screen.pbDisplay(_INTL("{1}'s moves were reset.", pkmn.name))
      screen.pbRefreshSingle(pkmnid)
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("setmovepp", {
    "parent"      => "moves",
    "name"        => _INTL("Set move PP"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      cmd = 0
      loop do
        commands = []
        for i in pkmn.moves
          break if !i.id
          if i.total_pp <= 0
            commands.push(_INTL("{1} (PP: ---)", i.name))
          else
            commands.push(_INTL("{1} (PP: {2}/{3})", i.name, i.pp, i.total_pp))
          end
        end
        commands.push(_INTL("Restore all PP"))
        cmd = screen.pbShowCommands(_INTL("Alter PP of which move?"), commands, cmd)
        break if cmd < 0
        if cmd >= 0 && cmd < commands.length - 1   # Move
          move = pkmn.moves[cmd]
          movename = move.name
          if move.total_pp <= 0
            screen.pbDisplay(_INTL("{1} has infinite PP.", movename))
          else
            cmd2 = 0
            loop do
              msg = _INTL("{1}: PP {2}/{3} (PP Up {4}/3)", movename, move.pp, move.total_pp, move.ppup)
              cmd2 = screen.pbShowCommands(msg, [
                 _INTL("Set PP"),
                 _INTL("Full PP"),
                 _INTL("Set PP Up")], cmd2)
              break if cmd2 < 0
              case cmd2
              when 0   # Change PP
                params = ChooseNumberParams.new
                params.setRange(0, move.total_pp)
                params.setDefaultValue(move.pp)
                h = pbMessageChooseNumber(
                   _INTL("Set PP of {1} (max. {2}).", movename, move.total_pp), params) { screen.pbUpdate }
                move.pp = h
              when 1   # Full PP
                move.pp = move.total_pp
              when 2   # Change PP Up
                params = ChooseNumberParams.new
                params.setRange(0, 3)
                params.setDefaultValue(move.ppup)
                h = pbMessageChooseNumber(
                   _INTL("Set PP Up of {1} (max. 3).", movename), params) { screen.pbUpdate }
                move.ppup = h
                move.pp = move.total_pp if move.pp > move.total_pp
              end
            end
          end
        elsif cmd == commands.length - 1   # Restore all PP
          pkmn.heal_PP
        end
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("setinitialmoves", {
    "parent"      => "moves",
    "name"        => _INTL("Reset initial moves"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      pkmn.record_first_moves
      screen.pbDisplay(_INTL("{1}'s moves were set as its first-known moves.", pkmn.name))
      screen.pbRefreshSingle(pkmnid)
      next false
    }
  })
  
  #===============================================================================
  # Other options
  #===============================================================================
  PokemonDebugMenuCommands.register("setitem", {
    "parent"      => "main",
    "name"        => _INTL("Set item"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      cmd = 0
      commands = [
        _INTL("Replace items"),
        _INTL("Remove items"),
        _INTL("Add item"),
      ]
      loop do
        msg = (pkmn.hasItem?) ? _INTL("{1}: {2}.", pkmn.itemCountD(true), pkmn.itemsName) : _INTL("No item.")
        cmd = screen.pbShowCommands(msg, commands, cmd)
        break if cmd < 0
        case cmd
        when 0   # Replace items
          item = pbChooseItemList
          if item && !pkmn.hasItem?(item)
            pkmn.removeItems
            pkmn.giveItem(item)
            screen.pbRefreshSingle(pkmnid)
          end
        when 1   # Remove items
          if pkmn.hasItem?
            pkmn.removeItems
            screen.pbRefreshSingle(pkmnid)
          end
        when 2  # Add item
          item = pbChooseItemList
          if item && !pkmn.hasItem?(item)
            pkmn.giveItem(item)
            screen.pbRefreshSingle(pkmnid)
          end
        else
          break
        end
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("setability", {
    "parent"      => "main",
    "name"        => _INTL("Set ability"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      cmd = 0
      commands = [
        _INTL("Set possible ability"),
        _INTL("Set any ability"),
        _INTL("Reset")
      ]
      loop do
        if pkmn.ability
          msg = _INTL("Ability is {1} (index {2}).", pkmn.ability.name, pkmn.ability_index)
        else
          msg = _INTL("No ability (index {1}).", pkmn.ability_index)
        end
        cmd = screen.pbShowCommands(msg, commands, cmd)
        break if cmd < 0
        case cmd
        when 0   # Set possible ability
          abils = pkmn.getAbilityList
          ability_commands = []
          abil_cmd = 0
          for i in abils
            ability_commands.push(((i[1] < 2) ? "" : "(H) ") + GameData::Ability.get(i[0]).name)
            abil_cmd = ability_commands.length - 1 if pkmn.ability_id == i[0]
          end
          abil_cmd = screen.pbShowCommands(_INTL("Choose an ability."), ability_commands, abil_cmd)
          next if abil_cmd < 0
          pkmn.ability_index = abils[abil_cmd][1]
          pkmn.ability = nil
          screen.pbRefreshSingle(pkmnid)
        when 1   # Set any ability
          new_ability = pbChooseAbilityList(pkmn.ability_id)
          if new_ability && new_ability != pkmn.ability_id
            pkmn.ability = new_ability
            screen.pbRefreshSingle(pkmnid)
          end
        when 2   # Reset
          pkmn.ability_index = nil
          pkmn.ability = nil
          screen.pbRefreshSingle(pkmnid)
        end
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("setgender", {
    "parent"      => "main",
    "name"        => _INTL("Set gender"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      if pkmn.singleGendered?
        screen.pbDisplay(_INTL("{1} is single-gendered or genderless.", pkmn.speciesName))
      else
        cmd = 0
        loop do
          msg = [_INTL("Gender is male."), _INTL("Gender is female.")][pkmn.male? ? 0 : 1]
          cmd = screen.pbShowCommands(msg, [
             _INTL("Make male"),
             _INTL("Make female"),
             _INTL("Reset")], cmd)
          break if cmd < 0
          case cmd
          when 0   # Make male
            pkmn.makeMale
            if !pkmn.male?
              screen.pbDisplay(_INTL("{1}'s gender couldn't be changed.", pkmn.name))
            end
          when 1   # Make female
            pkmn.makeFemale
            if !pkmn.female?
              screen.pbDisplay(_INTL("{1}'s gender couldn't be changed.", pkmn.name))
            end
          when 2   # Reset
            pkmn.gender = nil
          end
          $Trainer.pokedex.register(pkmn) if !settingUpBattle
          screen.pbRefreshSingle(pkmnid)
        end
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("speciesform", {
    "parent"      => "main",
    "name"        => _INTL("Species/form..."),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      cmd = 0
      loop do
        msg = [_INTL("Species {1}, form {2}.", pkmn.speciesName, pkmn.form),
               _INTL("Species {1}, form {2} (forced).", pkmn.speciesName, pkmn.form)][(pkmn.forced_form.nil?) ? 0 : 1]
        cmd = screen.pbShowCommands(msg, [
           _INTL("Set species"),
           _INTL("Set form"),
           _INTL("Remove form override")], cmd)
        break if cmd < 0
        case cmd
        when 0   # Set species
          species = pbChooseSpeciesList(pkmn.species)
          if species && species != pkmn.species
            pkmn.species = species
            pkmn.calc_stats
            $Trainer.pokedex.register(pkmn) if !settingUpBattle
            screen.pbRefreshSingle(pkmnid)
          end
        when 1   # Set form
          cmd2 = 0
          formcmds = [[], []]
          GameData::Species.each do |sp|
            next if sp.species != pkmn.species
            form_name = sp.form_name
            form_name = _INTL("Unnamed form") if !form_name || form_name.empty?
            form_name = sprintf("%d: %s", sp.form, form_name)
            formcmds[0].push(sp.form)
            formcmds[1].push(form_name)
            cmd2 = sp.form if pkmn.form == sp.form
          end
          if formcmds[0].length <= 1
            screen.pbDisplay(_INTL("Species {1} only has one form.", pkmn.speciesName))
          else
            cmd2 = screen.pbShowCommands(_INTL("Set the Pokémon's form."), formcmds[1], cmd2)
            next if cmd2 < 0
            f = formcmds[0][cmd2]
            if f != pkmn.form
              if MultipleForms.hasFunction?(pkmn, "getForm")
                next if !screen.pbConfirm(_INTL("This species decides its own form. Override?"))
                pkmn.forced_form = f
              end
              pkmn.form = f
              $Trainer.pokedex.register(pkmn) if !settingUpBattle
              screen.pbRefreshSingle(pkmnid)
            end
          end
        when 2   # Remove form override
          pkmn.forced_form = nil
          screen.pbRefreshSingle(pkmnid)
        end
      end
      next false
    }
  })
  
  #===============================================================================
  # Cosmetic options
  #===============================================================================
  PokemonDebugMenuCommands.register("cosmetic", {
    "parent"      => "main",
    "name"        => _INTL("Cosmetic info..."),
    "always_show" => true
  })
  
  PokemonDebugMenuCommands.register("setshininess", {
    "parent"      => "cosmetic",
    "name"        => _INTL("Set shininess"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      cmd = 0
      loop do
        msg = [_INTL("Is shiny."), _INTL("Is normal (not shiny).")][pkmn.shiny? ? 0 : 1]
        cmd = screen.pbShowCommands(msg, [
             _INTL("Make shiny"),
             _INTL("Make normal"),
             _INTL("Reset")], cmd)
        break if cmd < 0
        case cmd
        when 0   # Make shiny
          pkmn.shiny = true
        when 1   # Make normal
          pkmn.shiny = false
        when 2   # Reset
          pkmn.shiny = nil
        end
        screen.pbRefreshSingle(pkmnid)
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("setpokeball", {
    "parent"      => "cosmetic",
    "name"        => _INTL("Set Poké Ball"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      commands = []
      balls = []
      for key in $BallTypes.keys
        item = GameData::Item.try_get($BallTypes[key])
        balls.push([item.id, item.name]) if item
      end
      balls.sort! { |a, b| a[1] <=> b[1] }
      cmd = 0
      for i in 0...balls.length
        next if balls[i][0] != pkmn.poke_ball
        cmd = i
        break
      end
      balls.each { |ball| commands.push(ball[1]) }
      loop do
        oldball = GameData::Item.get(pkmn.poke_ball).name
        cmd = screen.pbShowCommands(_INTL("{1} used.", oldball), commands, cmd)
        break if cmd < 0
        pkmn.poke_ball = balls[cmd][0]
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("setribbons", {
    "parent"      => "cosmetic",
    "name"        => _INTL("Set ribbons"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      cmd = 0
      loop do
        commands = []
        ids = []
        GameData::Ribbon.each do |ribbon_data|
          commands.push(_INTL("{1} {2}",
             (pkmn.hasRibbon?(ribbon_data.id)) ? "[Y]" : "[  ]", ribbon_data.name))
          ids.push(ribbon_data.id)
        end
        commands.push(_INTL("Give all"))
        commands.push(_INTL("Clear all"))
        cmd = screen.pbShowCommands(_INTL("{1} ribbons.", pkmn.numRibbons), commands, cmd)
        break if cmd < 0
        if cmd >= 0 && cmd < ids.length   # Toggle ribbon
          if pkmn.hasRibbon?(ids[cmd])
            pkmn.takeRibbon(ids[cmd])
          else
            pkmn.giveRibbon(ids[cmd])
          end
        elsif cmd == commands.length - 2   # Give all
          GameData::Ribbon.each do |ribbon_data|
            pkmn.giveRibbon(ribbon_data.id)
          end
        elsif cmd == commands.length - 1   # Clear all
          pkmn.clearAllRibbons
        end
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("sethueshift", {
    "parent"      => "cosmetic",
    "name"        => _INTL("Set hue shift"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      if pkmn.egg?
        screen.pbDisplay(_INTL("{1} is an egg.", pkmn.name))
      else
        params = ChooseNumberParams.new
        params.setNegativesAllowed(true)
        params.setRange(-90, 90)
        params.setDefaultValue(0)
        newhueshift = pbMessageChooseNumber(
          _INTL("Set {1}'s Hue Shift (Gameplay range is {2} to {3}).", pkmn.name, -(Pokemon::HUE_SHIFT_RANGE/2), Pokemon::HUE_SHIFT_RANGE/2), params) { screen.pbUpdate }
        pkmn.manual_hue_shift = newhueshift
        screen.pbRefreshSingle(pkmnid)
      end
      next false
    }
  })

  PokemonDebugMenuCommands.register("setshadeshift", {
    "parent"      => "cosmetic",
    "name"        => _INTL("Set shade shift"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      if pkmn.egg?
        screen.pbDisplay(_INTL("{1} is an egg.", pkmn.name))
      else
        params = ChooseNumberParams.new
        params.setNegativesAllowed(true)
        params.setRange(-160, 160)
        params.setDefaultValue(0)
        newshadeshift = pbMessageChooseNumber(
          _INTL("Set {1}'s Shade Shift (Gameplay range is {2} to {3}).", pkmn.name, -(Pokemon::SHADE_SHIFT_RANGE/2), Pokemon::SHADE_SHIFT_RANGE/2), params) { screen.pbUpdate }
        pkmn.manual_shade_shift = newshadeshift
        screen.pbRefreshSingle(pkmnid)
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("ownership", {
    "parent"      => "cosmetic",
    "name"        => _INTL("Ownership..."),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      cmd = 0
      loop do
        gender = [_INTL("Male"), _INTL("Female"), _INTL("Unknown")][pkmn.owner.gender]
        msg = [_INTL("Player's Pokémon\n{1}\n{2}\n{3} ({4})", pkmn.owner.name, gender, pkmn.owner.public_id, pkmn.owner.id),
               _INTL("Foreign Pokémon\n{1}\n{2}\n{3} ({4})", pkmn.owner.name, gender, pkmn.owner.public_id, pkmn.owner.id)
              ][pkmn.foreign?($Trainer) ? 1 : 0]
        cmd = screen.pbShowCommands(msg, [
             _INTL("Make player's"),
             _INTL("Set OT's name"),
             _INTL("Set OT's gender"),
             _INTL("Random foreign ID"),
             _INTL("Set foreign ID")], cmd)
        break if cmd < 0
        case cmd
        when 0   # Make player's
          pkmn.owner = Pokemon::Owner.new_from_trainer($Trainer)
        when 1   # Set OT's name
          pkmn.owner.name = pbEnterPlayerName(_INTL("{1}'s OT's name?", pkmn.name), 1, Settings::MAX_PLAYER_NAME_SIZE)
        when 2   # Set OT's gender
          cmd2 = screen.pbShowCommands(_INTL("Set OT's gender."),
             [_INTL("Male"), _INTL("Female"), _INTL("Unknown")], pkmn.owner.gender)
          pkmn.owner.gender = cmd2 if cmd2 >= 0
        when 3   # Random foreign ID
          pkmn.owner.id = $Trainer.make_foreign_ID
        when 4   # Set foreign ID
          params = ChooseNumberParams.new
          params.setRange(0, 65535)
          params.setDefaultValue(pkmn.owner.public_id)
          val = pbMessageChooseNumber(
             _INTL("Set the new ID (max. 65535)."), params) { screen.pbUpdate }
          pkmn.owner.id = val | val << 16
        end
      end
      next false
    }
  })
  
  #===============================================================================
  # Other options
  #===============================================================================
  PokemonDebugMenuCommands.register("setegg", {
    "parent"      => "main",
    "name"        => _INTL("Set egg"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      cmd = 0
      loop do
        msg = [_INTL("Not an egg"),
               _INTL("Egg (hatches in {1} steps).", pkmn.steps_to_hatch)][pkmn.egg? ? 1 : 0]
        cmd = screen.pbShowCommands(msg, [
             _INTL("Make egg"),
             _INTL("Make Pokémon"),
             _INTL("Set steps left to 1")], cmd)
        break if cmd < 0
        case cmd
        when 0   # Make egg
          if !pkmn.egg? && (pbHasEgg?(pkmn.species) ||
             screen.pbConfirm(_INTL("{1} cannot legally be an egg. Make egg anyway?", pkmn.speciesName)))
            pkmn.level          = Settings::EGG_LEVEL
            pkmn.calc_stats
            pkmn.name           = _INTL("Egg")
            pkmn.steps_to_hatch = pkmn.species_data.hatch_steps
            pkmn.hatched_map    = 0
            pkmn.obtain_method  = 1
            screen.pbRefreshSingle(pkmnid)
          end
        when 1   # Make Pokémon
          if pkmn.egg?
            pkmn.name           = nil
            pkmn.steps_to_hatch = 0
            pkmn.hatched_map    = 0
            pkmn.obtain_method  = 0
            screen.pbRefreshSingle(pkmnid)
          end
        when 2   # Set steps left to 1
          pkmn.steps_to_hatch = 1 if pkmn.egg?
        end
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("mysterygift", {
    "parent"      => "main",
    "name"        => _INTL("Mystery Gift"),
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      pbCreateMysteryGift(0, pkmn)
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("duplicate", {
    "parent"      => "main",
    "name"        => _INTL("Duplicate"),
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      if screen.pbConfirm(_INTL("Are you sure you want to copy this Pokémon?"))
        clonedpkmn = pkmn.clone
        if screen.is_a?(PokemonPartyScreen) || screen.is_a?(TilingCardsPokemonMenu_Scene)
          pbStorePokemon(clonedpkmn)
          screen.pbHardRefresh
          screen.pbDisplay(_INTL("The Pokémon was duplicated."))
        elsif screen.is_a?(PokemonStorageScreen)
          if screen.storage.pbMoveCaughtToParty(clonedpkmn)
            if pkmnid[0] != -1
              screen.pbDisplay(_INTL("The duplicated Pokémon was moved to your party."))
            end
          else
            oldbox = screen.storage.currentBox
            newbox = screen.storage.pbStoreCaught(clonedpkmn)
            if newbox < 0
              screen.pbDisplay(_INTL("All boxes are full."))
            elsif newbox != oldbox
              screen.pbDisplay(_INTL("The duplicated Pokémon was moved to box \"{1}.\"", screen.storage[newbox].name))
              screen.storage.currentBox = oldbox
            end
          end
          screen.pbHardRefresh
        end
        next true
      end
      next false
    }
  })
  
  PokemonDebugMenuCommands.register("delete", {
    "parent"      => "main",
    "name"        => _INTL("Delete"),
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      if screen.pbConfirm(_INTL("Are you sure you want to delete this Pokémon?"))
        if screen.is_a?(PokemonPartyScreen) || screen.is_a?(TilingCardsPokemonMenu_Scene)
          screen.party[pkmnid] = nil
          screen.party.compact!
          screen.pbHardRefresh
        elsif screen.is_a?(PokemonStorageScreen)
          screen.scene.pbRelease(pkmnid, heldpoke)
          (heldpoke) ? screen.heldpkmn = nil : screen.storage.pbDelete(pkmnid[0], pkmnid[1])
          screen.scene.pbRefresh
        end
        next true
      end
      next false
    }
  })
  