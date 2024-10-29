#===============================================================================
# ** Interpreter
#-------------------------------------------------------------------------------
#  This interpreter runs event commands. This class is used within the
#  Game_System class and the Game_Event class.
#===============================================================================
class Interpreter
    #-----------------------------------------------------------------------------
    # * Object Initialization
    #     depth : nest depth
    #     main  : main flag
    #-----------------------------------------------------------------------------
    def initialize(depth = 0, main = false)
        @depth = depth
        @main = main
        if depth > 100
            print("Common event call has exceeded maximum limit.")
            exit
        end
        clear
    end

    def inspect
        str = super.chop
        str << format(" @event_id: %d>", @event_id)
        return str
    end

    def clear
        @map_id             = 0 # map ID when starting up
        @event_id           = 0       # event ID
        @message_waiting    = false   # waiting for message to end
        @move_route_waiting = false   # waiting for move completion
        @wait_count         = 0       # wait count
        @child_interpreter  = nil     # child interpreter
        @branch             = {}      # branch data
        @buttonInput        = false
    end

    #-----------------------------------------------------------------------------
    # * Event Setup
    #     list     : list of event commands
    #     event_id : event ID
    #-----------------------------------------------------------------------------
    def setup(list, event_id, map_id = nil)
        clear
        @map_id = map_id || $game_map.map_id
        @event_id = event_id
        @list = list
        @index = 0
        @branch.clear
    end

    def setup_starting_event
        $game_map.refresh if $game_map.need_refresh
        # Set up common event if one wants to start
        if $game_temp.common_event_id > 0
            setup($data_common_events[$game_temp.common_event_id].list, 0)
            $game_temp.common_event_id = 0
            return
        end
        # Check all map events for one that wants to start, and set it up
        for event in $game_map.events.values
            next unless event.starting
            if event.trigger < 3 # Isn't autorun or parallel processing
                event.lock
                event.clear_starting
            end
            setup(event.list, event.id, event.map.map_id)
            return
        end
        # Check all common events for one that is autorun, and set it up
        for common_event in $data_common_events.compact
            next if common_event.trigger != 1 || !$game_switches[common_event.switch_id]
            setup(common_event.list, 0)
            return
        end
    end

    def running?
        return !@list.nil?
    end

    #-----------------------------------------------------------------------------
    # * Frame Update
    #-----------------------------------------------------------------------------
    def update
        @loop_count = 0
        loop do
            @loop_count += 1
            if @loop_count > 100 # Call Graphics.update for freeze prevention
                Graphics.update
                @loop_count = 0
            end
            # If this interpreter's map isn't the current map or connected to it,
            # forget this interpreter's event ID
            @event_id = 0 if $game_map.map_id != @map_id && !$MapFactory.areConnected?($game_map.map_id, @map_id)
            # Update child interpreter if one exists
            if @child_interpreter
                @child_interpreter.update
                @child_interpreter = nil unless @child_interpreter.running?
                return if @child_interpreter
            end
            # Do nothing if a message is being shown
            return if @message_waiting
            # Do nothing if any event or the player is in the middle of a move route
            if @move_route_waiting
                return if $game_player.move_route_forcing
                for event in $game_map.events.values
                    return if event.move_route_forcing
                end
                @move_route_waiting = false
            end
            # Do nothing while waiting
            if @wait_count > 0
                @wait_count -= 1
                return
            end
            # Do nothing if the pause menu is going to open
            return if $game_temp.menu_calling
            # If there are no commands in the list, try to find something that wants to run
            if @list.nil?
                setup_starting_event if @main
                return if @list.nil? # Couldn't find anything that wants to run
            end
            # Execute the next command
            return if execute_command == false
            # Move to the next @index
            @index += 1
        end
    end

    #-----------------------------------------------------------------------------
    # * Execute script
    #-----------------------------------------------------------------------------
    def execute_script(script)
        result = eval(script)
        return result
    	rescue Exception
        e = $!
        raise if e.is_a?(SystemExit) || "#{e.class}" == "Reset"
        event = get_self
        s = "Backtrace:\r\n"
        message = pbGetExceptionMessage(e)
        if e.is_a?(SyntaxError)
            script.each_line do |line|
                line.gsub!(/\s+$/, "")
                if line[/^\s*\(/]
                    message += "\r\n***Line '#{line}' shouldn't begin with '('. Try\r\n"
                    message += "putting the '(' at the end of the previous line instead,\r\n"
                    message += "or using 'extendtext.exe'."
                end
                if line[/::\s*$/]
                    message += "\r\n***Line '#{line}' can't end with '::'. Try putting\r\n"
                    message += "the next word on the same line, e.g. 'PBSpecies:" + ":MEW'"
                end
            end
        else
            for bt in e.backtrace[0, 10]
                s += bt + "\r\n"
            end
            s.gsub!(/Section(\d+)/) { $RGSS_SCRIPTS[::Regexp.last_match(1).to_i][1] }
        end
        message = "Exception: #{e.class}\r\nMessage: " + message + "\r\n"
        message += "\r\n***Full script:\r\n#{script}\r\n"
        if event && $game_map
            map_name = begin
                $game_map.name
            rescue StandardError
                nil
            end || "???"
            err  = "Script error in event #{event.id} (coords #{event.x},#{event.y}), map #{$game_map.map_id} (#{map_name}):\r\n"
            err += "#{message}\r\n#{s}"
            if e.is_a?(Hangup)
                $EVENTHANGUPMSG = err
                raise
            end
        elsif $game_map
            map_name = begin
                $game_map.name
            rescue StandardError
                nil
            end || "???"
            err = "Script error in map #{$game_map.map_id} (#{map_name}):\r\n"
            err += "#{message}\r\n#{s}"
            if e.is_a?(Hangup)
                $EVENTHANGUPMSG = err
                raise
            end
        else
            err = "Script error in interpreter:\r\n#{message}\r\n#{s}"
            if e.is_a?(Hangup)
                $EVENTHANGUPMSG = err
                raise
            end
        end
        raise err
    end

    #-----------------------------------------------------------------------------
    # * Get Character
    #     parameter : parameter
    #-----------------------------------------------------------------------------
    def get_character(parameter = 0)
        case parameter
        when -1   # player
            return $game_player
        when 0    # this event
            events = $game_map.events
            return events ? events[@event_id] : nil
        else      # specific event
            events = $game_map.events
            return events ? events[parameter] : nil
        end
    end

    def get_player
        return get_character(-1)
    end

    def get_self
        return get_character(0)
    end

    def get_event(parameter)
        return get_character(parameter)
    end

    #-----------------------------------------------------------------------------
    # * Freezes all events on the map (for use at the beginning of common events)
    #-----------------------------------------------------------------------------
    def pbGlobalLock
        $game_map.events.values.each { |event| event.minilock }
    end

    #-----------------------------------------------------------------------------
    # * Unfreezes all events on the map (for use at the end of common events)
    #-----------------------------------------------------------------------------
    def pbGlobalUnlock
        $game_map.events.values.each { |event| event.unlock }
    end

    #-----------------------------------------------------------------------------
    # * Gets the next index in the interpreter, ignoring certain commands between messages
    #-----------------------------------------------------------------------------
    def pbNextIndex(index)
        return -1 if !@list || @list.length == 0
        i = index + 1
        loop do
            return i if i >= @list.length - 1
            case @list[i].code
            when 118, 108, 408   # Label, Comment
                i += 1
            when 413             # Repeat Above
                i = pbRepeatAbove(i)
            when 113             # Break Loop
                i = pbBreakLoop(i)
            when 119             # Jump to Label
                newI = pbJumpToLabel(i, @list[i].parameters[0])
                i = (newI > i) ? newI : i + 1
            else
                return i
            end
        end
    end

    def pbRepeatAbove(index)
        index = @list[index].indent
        loop do
            index -= 1
            return index + 1 if @list[index].indent == indent
        end
    end

    def pbBreakLoop(index)
        indent = @list[index].indent
        temp_index = index
        loop do
            temp_index += 1
            return index + 1 if temp_index >= @list.size - 1
            return temp_index + 1 if @list[temp_index].code == 413 &&
                                     @list[temp_index].indent < indent
        end
    end

    def pbJumpToLabel(index, label_name)
        temp_index = 0
        loop do
            return index + 1 if temp_index >= @list.size - 1
            return temp_index + 1 if @list[temp_index].code == 118 &&
                                     @list[temp_index].parameters[0] == label_name
            temp_index += 1
        end
    end

    #-----------------------------------------------------------------------------
    # * Various methods to be used in a script event command.
    #-----------------------------------------------------------------------------
    # Helper function that shows a picture in a script.
    def pbShowPicture(number, name, origin, x, y, zoomX = 100, zoomY = 100, opacity = 255, blendType = 0)
        number += ($game_temp.in_battle ? 50 : 0)
        $game_screen.pictures[number].show(name, origin, x, y, zoomX, zoomY, opacity, blendType)
    end

    # Erases an event and adds it to the list of erased events so that
    # it can stay erased when the game is saved then loaded again.
    def pbEraseThisEvent
        if $game_map.events[@event_id]
            $game_map.events[@event_id].erase
            $PokemonMap.addErasedEvent(@event_id) if $PokemonMap
        end
        @index += 1
        return true
    end

    # Runs a common event.
    def pbCommonEvent(id)
        common_event = $data_common_events[id]
        return unless common_event
        if $game_temp.in_battle
            $game_system.battle_interpreter.setup(common_event.list, 0)
        else
            interp = Interpreter.new
            interp.setup(common_event.list, 0)
            loop do
                Graphics.update
                Input.update
                interp.update
                pbUpdateSceneMap
                break unless interp.running?
            end
        end
    end

    # Sets another event's self switch (eg. pbSetSelfSwitch(20, "A", true) ).
    def pbSetSelfSwitch(eventid, switch_name, value = true, mapid = -1)
        mapid = @map_id if mapid < 0
        old_value = $game_self_switches[[mapid, eventid, switch_name]]
        $game_self_switches[[mapid, eventid, switch_name]] = value
        $MapFactory.getMap(mapid, false).need_refresh = true if value != old_value && $MapFactory.hasMap?(mapid)
    end

    def tsOff?(c)
        return get_self.tsOff?(c)
    end
    alias isTempSwitchOff? tsOff?

    def tsOn?(c)
        return get_self.tsOn?(c)
    end
    alias isTempSwitchOn? tsOn?

    def setTempSwitchOn(c)
        get_self.setTempSwitchOn(c)
    end

    def setTempSwitchOff(c)
        get_self.setTempSwitchOff(c)
    end

    def getVariable(*arg)
        if arg.length == 0
            return nil unless $PokemonGlobal.eventvars
            return $PokemonGlobal.eventvars[[@map_id, @event_id]]
        else
            return $game_variables[arg[0]]
        end
    end

    def setVariable(*arg)
        if arg.length == 1
            $PokemonGlobal.eventvars = {} unless $PokemonGlobal.eventvars
            $PokemonGlobal.eventvars[[@map_id, @event_id]] = arg[0]
        else
            $game_variables[arg[0]] = arg[1]
            $game_map.need_refresh = true
        end
    end

    def setGlobalSwitch(switchID,value = true)
        $game_switches[switchID] = value
        $game_map.need_refresh = true
    end

    def pbGetPokemon(id)
        return $Trainer.party[pbGet(id)]
    end

    def pbSetEventTime(*arg)
        $PokemonGlobal.eventvars = {} unless $PokemonGlobal.eventvars
        time = pbGetTimeNow
        time = time.to_i
        pbSetSelfSwitch(@event_id, "A", true)
        $PokemonGlobal.eventvars[[@map_id, @event_id]] = time
        for otherevt in arg
            pbSetSelfSwitch(otherevt, "A", true)
            $PokemonGlobal.eventvars[[@map_id, otherevt]] = time
        end
    end

    # Used in boulder events. Allows an event to be pushed.
    def pbPushThisEvent(checkForHoles = false)
        event = get_self
        old_x  = event.x
        old_y  = event.y
        holeEvent = nil

        # check for pluggable holes in that direction
        if checkForHoles
            new_x = old_x + xOffsetFromDir($game_player.direction)
            new_y = old_y + yOffsetFromDir($game_player.direction)

            $game_map.events.values.each do |otherEvent|
                next if event == otherEvent
                next unless otherEvent.at_coordinate?(new_x, new_y)
                next unless otherEvent.name[/boulderhole/]
                next if pbGetSelfSwitch(otherEvent.id, "A")

                holeEvent = otherEvent
                holeEvent.through = true
                event.always_on_top = true
                break
            end
        end

        # Apply strict version of passable, which treats tiles that are passable
        # only from certain directions as fully impassible
        if !holeEvent && !event.can_move_in_direction?($game_player.direction)
            $game_player.bump_into_object
            return
        end

        case $game_player.direction
        when 2 then event.move_down
        when 4 then event.move_left
        when 6 then event.move_right
        when 8 then event.move_up
        end

        $PokemonMap.addMovedEvent(@event_id) if $PokemonMap

        if old_x != event.x || old_y != event.y
            $game_player.lock
            loop do
                Graphics.update
                Input.update
                pbUpdateSceneMap
                break unless event.moving?
            end
            $game_player.unlock
        end

        if holeEvent
            pbSEPlay("Anim/Earth3", 80, 80)
            pbWait(10)
            pbSetSelfSwitch(event.id, "A")
            pbSetSelfSwitch(holeEvent.id, "A")

            registerPastModified(holeEvent) if holeEvent.name[/timelinked/]

            registerFutureFilledHole(event,holeEvent) unless holeEvent.name[/timelinked/]
        else
            pbSEPlay("Anim/Earth3", 40, rand(110, 140))
        end

        registerPastModified(event) if event.name[/timelinked/]
    end

    def pbPushThisBoulder
        pbPushThisEvent if $PokemonMap.strengthUsed
        return true
    end

    def pbSmashThisEvent
        event = get_self
        pbSmashEvent(event) if event
        @index += 1
        return true
    end

    def pbTrainerIntro(symbol)
        return true unless GameData::TrainerType.exists?(symbol)
        tr_type = GameData::TrainerType.get(symbol).id
        pbGlobalLock
        pbPlayTrainerIntroME(tr_type)
        return true
    end

    def pbTrainerEnd
        pbGlobalUnlock
        event = get_self
        event.erase_route if event
    end

    def setPrice(item, buy_price = -1, sell_price = -1)
        item = GameData::Item.get(item).id
        $game_temp.mart_prices[item] = [-1, -1] unless $game_temp.mart_prices[item]
        $game_temp.mart_prices[item][0] = buy_price if buy_price > 0
        if sell_price >= 0   # 0=can't sell
            $game_temp.mart_prices[item][1] = sell_price * 2
        elsif buy_price > 0
            $game_temp.mart_prices[item][1] = buy_price
        end
    end

    def setSellPrice(item, sell_price)
        setPrice(item, -1, sell_price)
    end

    SCROLL_SPEED_DEFAULT = 4


  #-----------------------------------------------------------------------------
  # * Map Autoscroll to Coordinates
  #     x     : x coordinate to scroll to and center on
  #     y     : y coordinate to scroll to and center on
  #     speed : (optional) scroll speed (from 1-6, default being 4)
  #-----------------------------------------------------------------------------
  def autoscroll(x,y,speed=SCROLL_SPEED_DEFAULT)
    if $game_map.scrolling?
      return false
    elsif !$game_map.valid?(x,y)
      print 'Map Autoscroll: given x,y is invalid'
      return command_skip
    elsif !(1..6).include?(speed)
      print 'Map Autoscroll: invalid speed (1-6 only)'
      return command_skip
    end
    center_x = (Graphics.width/2 - Game_Map::TILE_WIDTH/2) * 4    # X coordinate in the center of the screen
    center_y = (Graphics.height/2 - Game_Map::TILE_HEIGHT/2) * 4   # Y coordinate in the center of the screen
    max_x = ($game_map.width - Graphics.width*1.0/Game_Map::TILE_WIDTH) * 4 * Game_Map::TILE_WIDTH
    max_y = ($game_map.height - Graphics.height*1.0/Game_Map::TILE_HEIGHT) * 4 * Game_Map::TILE_HEIGHT
    count_x = ($game_map.display_x - [0,[x*Game_Map::REAL_RES_X-center_x,max_x].min].max)/Game_Map::REAL_RES_X
    count_y = ($game_map.display_y - [0,[y*Game_Map::REAL_RES_Y-center_y,max_y].min].max)/Game_Map::REAL_RES_Y
    if !@diag
      @diag = true
      dir = nil
      if count_x > 0
        if count_y > 0
          dir = 7
        elsif count_y < 0
          dir = 1
        end
      elsif count_x < 0
        if count_y > 0
          dir = 9
        elsif count_y < 0
          dir = 3
        end
      end
      count = [count_x.abs,count_y.abs].min
    else
      @diag = false
      dir = nil
      if count_x != 0 && count_y != 0
        return false
      elsif count_x > 0
        dir = 4
      elsif count_x < 0
        dir = 6
      elsif count_y > 0
        dir = 8
      elsif count_y < 0
        dir = 2
      end
      count = count_x != 0 ? count_x.abs : count_y.abs
    end
    $game_map.start_scroll(dir, count, speed) if dir != nil
    if @diag
      return false
    else
      return true
    end
  end

  #-----------------------------------------------------------------------------
  # * Map Autoscroll (to Player)
  #     speed : (optional) scroll speed (from 1-6, default being 4)
  #-----------------------------------------------------------------------------
  def autoscroll_player(speed=SCROLL_SPEED_DEFAULT)
    autoscroll($game_player.x,$game_player.y,speed)
  end
end
