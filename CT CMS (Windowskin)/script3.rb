#==============================================================================
# ** Chrono Trigger CMS
#------------------------------------------------------------------------------
# Raziel
# 2006-09-09
# Version 1.20
#------------------------------------------------------------------------------
# Thanks to 
# ~ Squall/Selwyn for his Cursor Script
# ~ RPG Advocate for his Party Members change script
# ~ MeisMe for fixing some bugs and helping me
# ~ Squaresoft for the pictures
#==============================================================================
# ~Instructions
#  Icons of the characters are used in the save menu.
#  Make sure you put them in the icon folder and name them
#  like you name your character file, for example the icon for
#  Arshes would be 001-Fighter01
#  
#  For the chapter function, just use $game_system = "desired filename"
#  in a call script command and then the savefile will have the name 
#  you choose.
#==============================================================================
#==============================================================================
# ** Scene_Menu
#------------------------------------------------------------------------------
#  This class performs menu screen processing.
#==============================================================================
class Scene_Menu
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     menu_index : command cursor's initial position
  #--------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    # Make command window
    @equip_background = Window_Base.new(315, 37, 270, 410)
    @target_background = Window_Base.new(320, 101, 267, 329)
    @accessory_window = Window_Base.new(45, 139, 270, 75)
    @help_background = Window_Base.new(45, 35, 540, 82)
    @accessory_window.z = 999
    @weapon_window = Window_Base.new(45, 214, 270, 233)
    @skill_left = Window_Base.new(45, 36, 270, 340)
    @skill_right = Window_Base.new(315, 36, 274, 340)
    @save_left = Window_Base.new(39,273,241,172)
    @save_right = Window_Base.new(280,273,320,172)
    @weapon_window.z = 999
    @target_background.z = 999
    @back_ground = Sprite.new
    @back_ground.bitmap = RPG::Cache.picture(CT_Pictures::BG_Picture)
    @item_background = Window_Base.new(45, 117, 540, 330)
    @playtime_background = Window_Base.new(0, 384, 160, 96)
    @playtime_background.z = 9999
    @party_change = Window_PartyChange.new
    @command_window = Window_IconCommands.new
    @command_window.index = @menu_index
    @actor_window = Window_Actors.new
    @new_equip = Window_NewEquip.new
    $game_temp.equip_window = @new_equip
    @item_window = Window_Item.new
    @help_window = Window_Help.new
    @playtime_window = Window_PlayTime.new
    @item_window.help_window = @help_window
    @help_window.opacity, @item_window.opacity = 0, 0
    @help_window.x, @help_window.y = 48, 45
    @target_window = Window_Target.new
    @actor_skillwindow = Window_SkillActor.new
    @target_cursor = []
    @target_cursor_skill = []
    @switch_cursor = []
    @equip_item = []
    @actor_background = []
    @switch_window = []
    @save_window = []
    @switch = 0
    @actor_background[0] = Window_Base.new(45, 0 + 37, 270, 102)
    @actor_background[1] = Window_Base.new(45, 102 + 37, 270, 102)
    @actor_background[2] = Window_Base.new(45, 204 + 37, 270, 102)
    @actor_background[3] = Window_Base.new(45, 306 + 37, 270, 102)
    @target_cursor[0] = Sprite_Cursor.new(306, 196)
    @target_cursor[1] = Sprite_Cursor.new(306, 276)
    @target_cursor[2] = Sprite_Cursor.new(306, 356)
    @target_cursor_skill[0] = Sprite_Cursor.new(306, 121)
    @target_cursor_skill[1] = Sprite_Cursor.new(306, 201)
    @target_cursor_skill[2] = Sprite_Cursor.new(306, 281)
    @switch_cursor[0] = Sprite_Cursor.new(182, 15)
    @switch_cursor[1] = Sprite_Cursor.new(182, 125)
    @switch_cursor[2] = Sprite_Cursor.new(182, 235)
    @switch_cursor[3] = Sprite_Cursor.new(182, 345)
    @equip_item[0] = Window_EquipItem2.new(0)
    @equip_item[1] = Window_EquipItem2.new(1)
    @equip_item[2] = Window_EquipItem2.new(2)
    @equip_item[3] = Window_EquipItem2.new(3)
    @equip_item[4] = Window_EquipItem2.new(4)
    @switch_window[0] = Window_Base.new(190,15,270,110)
    @switch_window[1] = Window_Base.new(190,125,270,110)
    @switch_window[2] = Window_Base.new(190,235,270,110)
    @switch_window[3] = Window_Base.new(190,345,270,110)
    @save_window[0] = Window_Base.new(39,32, 560, 70)
    @save_window[1] = Window_Base.new(39,102, 560, 70)
    @save_window[2] = Window_Base.new(39,172, 560, 70)
    @equip_description = Window_EquipDescription.new
    @counter = 0
    @end_window = Window_End.new
    @end_window.x = 320 - @end_window.width / 2
    @end_window.y = 220 - @end_window.height / 2
    @savefile_windows = []
    for i in 0..2
      @savefile_windows.push(Window_SaveFile.new(i, make_filename(i)))
    end
    @file_index = $game_temp.last_file_index
    @savefile_windows[@file_index].selected = true
    @save_status = Window_SaveStatus.new
    @skill_actor_window2 = []
    @skill_window = []
    unless $game_party.actors[0] == nil
      @skill_actor_window2[0] = Window_SkillActor2.new($game_party.actors[0])
      @skill_window[0] = Window_Skill.new($game_party.actors[0])
    end
    unless $game_party.actors[1] == nil
      @skill_actor_window2[1] = Window_SkillActor2.new($game_party.actors[1])
      @skill_window[1] = Window_Skill.new($game_party.actors[1])
    end
    unless $game_party.actors[2] == nil
      @skill_actor_window2[2] = Window_SkillActor2.new($game_party.actors[2])
      @skill_window[2] = Window_Skill.new($game_party.actors[2])
    end
    unless $game_party.actors[3] == nil
      @skill_actor_window2[3] = Window_SkillActor2.new($game_party.actors[3])
      @skill_window[3] = Window_Skill.new($game_party.actors[3])
    end
    @item_window.visible = false
    @help_window.visible = false
    @item_background.visible = false
    @help_background.visible = false
    @target_window.visible = false
    @actor_skillwindow.visible = false
    @save_status.visible = false
    @end_window.visible = false
    @party_change.visible = false
    @equip_description.visible = false
    @target_background.visible = false
    @accessory_window.visible = false
    @weapon_window.visible = false
    @help_background.visible = false
    @skill_left.visible = false
    @skill_right.visible = false
    @save_left.visible = false
    @save_right.visible = false
    for i in 0..2
      @target_cursor[i].visible = false
      @target_cursor_skill[i].visible = false
      @savefile_windows[i].visible = false
      @switch_cursor[i].visible = false
      @switch_window[i].visible = false
      @switch_cursor[3].visible = false
      @switch_window[3].visible = false
      @save_window[i].visible = false
    end
    for i in 0..4
      @equip_item[i].active = false
      @equip_item[i].visible = false
    end
    for i in 0...$game_party.actors.size
      @skill_window[i].visible = false
      @skill_window[i].active = false
      @skill_window[i].width = 300
      @skill_actor_window2[i].visible = false
      @skill_actor_window2[i].active = false
    end
    @item_window.active = false
    @target_window.active = false
    @actor_skillwindow.active = false
    @end_window.active = false
    @party_change.active = false
    for i in 0..2
      @savefile_windows[i].active = false
    end
    #refresh
    equip_refresh
    # Execute transition
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepare for transition
    Graphics.freeze
    # Dispose of windows
    @back_ground.dispose
    @actor_window.dispose
    @command_window.dispose
    @new_equip.dispose
    @item_window.dispose
    @help_window.dispose
    @item_background.dispose
    @target_window.dispose
    @actor_skillwindow.dispose
    @save_status.dispose
    @end_window.dispose
    @party_change.dispose
    @switch_cursor[3].dispose
    @equip_description.dispose
    @playtime_window.dispose
    @playtime_background.dispose
    @equip_background.dispose
    @accessory_window.dispose
    @help_background.dispose
    @skill_left.dispose
    @skill_right.dispose
    @save_left.dispose
    @save_right.dispose
    for i in @skill_actor_window2
      i.dispose
    end
    for i in @skill_window
      i.dispose
    end
    for i in @savefile_windows
      i.dispose
    end
    for i in @target_cursor
      i.dispose
    end
    for i in @target_cursor_skill
      i.dispose
    end
    for i in @switch_cursor
      i.dispose
    end
    for i in @equip_item
      i.dispose
    end
    for i in @save_window
      i.dispose
    end
    for i in @actor_background
      i.dispose
    end
    for i in @switch_window
      i.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # Update windows
    @actor_window.update
    @command_window.update
    @new_equip.update
    @item_window.update
    @help_window.update
    @target_window.update
    @actor_skillwindow.update
    @save_status.update
    @party_change.update
    @end_window.update
    @equip_description.update
    @playtime_window.update
    equip_refresh
    for i in @savefile_windows
      i.update
    end
    for i in @skill_window
      i.update
    end
    for i in @skill_actor_window2
      i.update
    end
    for i in @equip_item
      i.update
    end
    if @command_window.active
      # If command window is active: call update_command
      update_command
    elsif @actor_window.active
      # If actor window is active: call update_actor
      update_actor
    elsif @new_equip.active
      # If new equip window is active: call update_equip
      update_equip
    elsif @equip_item[@new_equip.index].active
      # If item equip window is active: call update_equipitem
      update_equipitem
    elsif @item_window.active
      # If item window is active: call update_item
      update_item
    elsif @target_window.active
      # If target window is active: call update_target
      update_target
    elsif @actor_skillwindow.active
      # If actor skill window is active: call update_actor_skill
      update_actor_skill
    elsif @skill_window[@actor_skillwindow.index].active
      # If skill window is active: call update_skill
      update_skill
    elsif @savefile_windows[@file_index].active
      # If savefile window is active: call update_savefile
      update_savefile
    elsif @party_change.active
      # If party change window is active: call update_change
      update_change
    elsif @end_window.active
      # If end window is active: call update_end
      update_end
    end
    $game_temp.save_index = @file_index
    $game_temp.skill_index = @skill_window[@actor_skillwindow.index].index
    $game_temp.equip_index = @new_equip.index
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when command window is active)
  #--------------------------------------------------------------------------
  def update_command
    case @command_window.index
    when 0
      for i in 0..3
        @actor_background[i].visible = true
      end
      @equip_background.visible = true
      @actor_window.visible = true
      @new_equip.visible = true
      @item_window.visible = false
      @item_background.visible = false
      @help_background.visible = false
      @help_background.visible = false
    when 1
      for i in 0..3
        @actor_background[i].visible = false
      end
      @equip_background.visible = false
      @actor_window.visible = false
      @new_equip.visible = false
      @actor_skillwindow.visible = false
      @item_window.visible = true
      @item_background.visible = true
      @help_background.visible = true
      @help_background.y = 35
      @help_window.y = 45
      @help_background.width = 540
      @skill_left.visible = false
      @skill_right.visible = false
    when 2
      for i in 0..3
        @switch_window[i].visible = false
      end
      @skill_left.visible = true
      @skill_right.visible = true
      @item_window.visible = false
      @item_background.visible = false
      @party_change.visible = false
      @actor_skillwindow.visible = true
      @help_background.y = 375
      @help_background.width = 545
      @help_background.visible = true
      @help_window.y = 385
    when 3
      for i in 0..2
        @savefile_windows[i].visible = false
        @save_window[i].visible = false
      end
      @help_window.visible = false
      @help_background.visible = false
      @actor_skillwindow.visible = false
      @save_status.visible = false
      @party_change.visible = true
      for i in 0..3
        @switch_window[i].visible = true
      end
      @skill_left.visible = false
      @skill_right.visible = false
      @save_left.visible = false
      @save_right.visible = false
    when 4
      for i in 0..3
        @switch_window[i].visible = false
      end
      @end_window.visible = false
      @party_change.visible = false
      @save_left.visible = true
      @save_right.visible = true
    for i in 0..2
      @savefile_windows[i].visible = true
      @save_window[i].visible = true
    end
    @save_status.visible = true
    when 5
    for i in 0..2
      @savefile_windows[i].visible = false
      @save_window[i].visible = false
    end
    @save_left.visible = false
    @save_right.visible = false
    @save_status.visible = false
    @end_window.visible = true
    end
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Switch to map screen
      $scene = Scene_Map.new
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      @playtime_background.visible = false
      @playtime_window.visible = false
      # Branch by command window cursor position
      case @command_window.index
      when 0  # equip/status
        $game_system.se_play($data_system.decision_se)
        @command_window.active = false
        @command_window.visible = false
        @actor_window.active = true
        @actor_window.index = 0
      when 1  # item
        # Make item window active
        $game_system.se_play($data_system.decision_se)
        @command_window.active = false
        @command_window.visible = false
        @item_window.active = true
        @item_window.index = 0
      when 2  # skills
        $game_system.se_play($data_system.decision_se)
        @command_window.visible = false
        @command_window.active = false
        @actor_skillwindow.active = true
        @actor_skillwindow.index = 0
      when 3 #excahnge
        $game_system.se_play($data_system.decision_se)
        @command_window.visible = false
        @command_window.active = false
        @party_change.active = true
        @checker = 0
      when 4 #save
        if $game_system.save_disabled
        $game_system.se_play($data_system.buzzer_se)
        return
      end
        $game_system.se_play($data_system.decision_se)
        @command_window.visible = false
        @command_window.active = false
        @file_index = 0
        for i in 0..2
          @savefile_windows[i].active = true
          @savefile_windows[i].selected = false
        end
        @savefile_windows[0].selected = true
      when 5 #quit
        $game_system.se_play($data_system.decision_se)
        @command_window.active = false
        @command_window.visible = false
        @end_window.active = true
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Make File Name
  #     file_index : save file index (0-2)
  #--------------------------------------------------------------------------
  def make_filename(file_index)
    return "Save#{file_index + 1}.rxdata"
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when end window is active)
  #--------------------------------------------------------------------------
  def update_end
    # If B button was pressed
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @end_window.active = false
      @end_window.index = 0
      @command_window.visible = true
      @command_window.active = true
      @playtime_background.visible = true
      @playtime_window.visible = true
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      case @end_window.index
      when 0
        $scene = Scene_Title.new
      when 1
        $scene = nil
      when 2
        @end_window.active = false
        @command_window.visible = true
        @command_window.active = true
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when change window is active)
  #--------------------------------------------------------------------------
  def update_change
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      @party_change.active = false
      @party_change.index = 0
      @command_window.visible = true
      @command_window.active = true
      @playtime_background.visible = true
      @playtime_window.visible = true
      @checker = 0
      for i in 0..3
        @switch_cursor[i].visible = false
      end
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      if @checker == 0
        @changer = $game_party.actors[@party_change.index]
        @changer_skill = @skill_window[@party_change.index]
        @changer_skill2 = @skill_actor_window2[@party_change.index]
        @where = @party_change.index
        @switch_cursor[@party_change.index].visible = true
        @checker = 1
        else
        $game_party.actors[@where] = $game_party.actors[@party_change.index]
        $game_party.actors[@party_change.index] = @changer
        @skill_actor_window2[@where] = @skill_actor_window2[@party_change.index]
        @skill_actor_window2[@party_change.index] = @changer_skill2
        @skill_window[@where] = @skill_window[@party_change.index]
        @skill_window[@party_change.index] = @changer_skill
        @checker = 0
        @party_change.refresh
        @actor_window.refresh
        @new_equip.refresh
        @target_window.refresh
        @actor_skillwindow.refresh
        @save_status.refresh
        for i in 0..3
          @switch_cursor[i].visible = false
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when save window is active)
  #--------------------------------------------------------------------------
  def update_savefile
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Call method: on_decision (defined by the subclasses)
      on_decision(make_filename(@file_index))
      $game_temp.last_file_index = @file_index
      return
    end
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Call method: on_cancel (defined by the subclasses)
      on_cancel
      return
    end
    # If the down directional button was pressed
    if Input.repeat?(Input::DOWN)
      # If the down directional button pressed down is not a repeat,
      # or cursor position is more in front than 3
      unless @file_index == 2
      if Input.trigger?(Input::DOWN)
        # Play cursor SE
        $game_system.se_play($data_system.cursor_se)
        # Move cursor down
        @savefile_windows[@file_index].selected = false
        @file_index = (@file_index + 1)# % 3
        @savefile_windows[@file_index].selected = true
        return
      end
      end
    # If the up directional button was pressed
    elsif Input.repeat?(Input::UP)
      # If the up directional button pressed down is not a repeat、
      # or cursor position is more in back than 0
      unless @file_index == 0
        if Input.trigger?(Input::UP)
          # Play cursor SE
          $game_system.se_play($data_system.cursor_se)
          # Move cursor up
          @savefile_windows[@file_index].selected = false
          @file_index = (@file_index - 1)# % 3
          @savefile_windows[@file_index].selected = true
          return
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Decision Processing
  #--------------------------------------------------------------------------
  def on_decision(filename)
    # Play save SE
    $game_system.se_play($data_system.save_se)
    # Write save data
    file = File.open(filename, "wb")
    write_save_data(file)
    file.close
    # If called from event
    if $game_temp.save_calling
      # Clear save call flag
      $game_temp.save_calling = false
      # Switch to map screen
      $scene = Scene_Map.new
      return
    end
    for i in 0..2
      @savefile_windows[i].active = false
      @savefile_windows[i].selected = false
    end
    @savefile_windows[0].selected = true
    @playtime_background.visible = true
    @playtime_window.visible = true
    # Switch to map screen
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # * Cancel Processing
  #--------------------------------------------------------------------------
  def on_cancel
    # Play cancel SE
    $game_system.se_play($data_system.cancel_se)
    # If called from event
    if $game_temp.save_calling
      # Clear save call flag
      $game_temp.save_calling = false
      # Switch to map screen
      $scene = Scene_Map.new
      return
    end
    # Switch to menu screen
    for i in 0..2
      @savefile_windows[i].active = false
      @savefile_windows[i].selected = false
    end
    @savefile_windows[0].selected = true
    @save_status.refresh
    @command_window.visible = true
    @command_window.active = true
    @command_window.index = 4
    @playtime_background.visible = true
    @playtime_window.visible = true
  end
  #--------------------------------------------------------------------------
  # * Write Save Data
  #     file : write file object (opened)
  #--------------------------------------------------------------------------
  def write_save_data(file)
    # Make character data for drawing save file
    characters = []
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      characters.push([actor.character_name, actor.character_hue])
    end
    # Write character data for drawing save file
    Marshal.dump(characters, file)
    # Wrire frame count for measuring play time
    Marshal.dump(Graphics.frame_count, file)
    # Increase save count by 1
    $game_system.save_count += 1
    # Save magic number
    # (A random value will be written each time saving with editor)
    $game_system.magic_number = $data_system.magic_number
    # Write each type of game object
    Marshal.dump($game_system, file)
    Marshal.dump($game_switches, file)
    Marshal.dump($game_variables, file)
    Marshal.dump($game_self_switches, file)
    Marshal.dump($game_screen, file)
    Marshal.dump($game_actors, file)
    Marshal.dump($game_party, file)
    Marshal.dump($game_troop, file)
    Marshal.dump($game_map, file)
    Marshal.dump($game_player, file)
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when equip window is active)
  #--------------------------------------------------------------------------
  def update_equip
    for i in 0..4
      @equip_item[i].visible = false
    end
    @equip_item[@new_equip.index].visible = true
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      @new_equip.index = 0
      @new_equip.active = false
      @actor_window.active = true
      @actor_window.visible = true
      @equip_description.visible = false
      @accessory_window.visible = false
      @weapon_window.visible = false
      for i in 0..4
        @equip_item[i].visible = false
      end
      @item_window.refresh
      @target_window.refresh
      @party_change.refresh
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      @actor = $game_party.actors[$game_temp.cms_index]
      if @actor.equip_fix?(@new_equip.index)
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Play decission SE
      $game_system.se_play($data_system.decision_se)
      @new_equip.active = false
      @equip_item[@new_equip.index].active = true
      @equip_item[@new_equip.index].index = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when equip window is refreshed)
  #--------------------------------------------------------------------------
   def equip_refresh
    if @new_equip.active
      # Erase parameters for after equipment change
      @new_equip.set_new_parameters(nil, nil, nil, nil, nil, nil, nil)
    end
    if @equip_item[@new_equip.index].active
      @actor = $game_party.actors[$game_temp.cms_index]
      # Get currently selected item
      item1 = $game_temp.equip_window.item
      item2 = @equip_item[@new_equip.index].item
      # Change equipment
      @actor.equip($game_temp.equip_index, item2 == nil ? 0 : item2.id)
      # Get parameters for after equipment change
      new_str = @actor.str
      new_atk = @actor.atk
      new_int = @actor.int
      new_agi = @actor.agi
      new_pdef = @actor.pdef
      new_mdef = @actor.mdef
      new_dex = @actor.dex
      # Return equipment
      @actor.equip($game_temp.equip_index, item1 == nil ? 0 : item1.id)
      # Draw in left window
      $game_temp.equip_window.set_new_parameters(new_str, new_atk, new_int, new_agi, new_pdef, new_mdef, new_dex)
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when equip item window is active)
  #--------------------------------------------------------------------------
  def update_equipitem
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Activate right window
      @equip_item[@new_equip.index].active = false
      @equip_item[@new_equip.index].index = 0
      @new_equip.active = true
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Play equip SE
      $game_system.se_play($data_system.equip_se)
      # Get currently selected data on the item window
      item = @equip_item[@new_equip.index].item
      # Change equipment
      @actor.equip(@new_equip.index, item == nil ? 0 : item.id)
      # Activate right window
      @new_equip.active = true
      @equip_item[@new_equip.index].active = false
      @equip_item[@new_equip.index].index = 0
      # Remake right window and item window contents
      @new_equip.refresh
      @equip_item[@new_equip.index].refresh
      @equip_description.refresh
      @actor_window.refresh
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when actor window is active)
  #--------------------------------------------------------------------------
  def update_actor
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      @actor_window.active = false
      @actor_window.index = 0
      @command_window.visible = true
      @command_window.active = true
      @playtime_background.visible = true
      @playtime_window.visible = true
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Play decisiion SE
      $game_system.se_play($data_system.decision_se)
      @actor_window.active = false
      @actor_window.visible = false
      @accessory_window.visible = true
      @weapon_window.visible = true
      @equip_item[0].visible = true
      @new_equip.active = true
      @equip_description.visible = true
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when actor skill window is active)
  #--------------------------------------------------------------------------
  def update_actor_skill
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      @actor_skillwindow.active = false
      @actor_skillwindow.index = 0
      @command_window.visible = true
      @command_window.active = true
      @command_window.index = 2
      @playtime_background.visible = true
      @playtime_window.visible = true
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      @actor_skillwindow.active = false
      @skill_window[@actor_skillwindow.index].help_window = @help_window
      @skill_window[@actor_skillwindow.index].visible = true
      @skill_window[@actor_skillwindow.index].active = true
      @skill_window[@actor_skillwindow.index].index = 0
      @actor_skillwindow.visible = false
      @skill_actor_window2[@actor_skillwindow.index].visible = true
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when item window is active)
  #--------------------------------------------------------------------------
  def update_item
    # If B button was pressed
    if @target_window.visible == false
      for i in 0...$game_party.actors.size - 1
        @target_cursor[i].visible = false
      end
    end
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Switch to menu screen
      @item_window.visible = false
      @item_window.active = false
      @command_window.visible = true
      @command_window.active = true
      @help_window.visible = false
      @playtime_background.visible = true
      @playtime_window.visible = true
      @item_window.index = 0
      @command_window.index = 1
      return
    # If C button was pressed
    elsif Input.trigger?(Input::C)
      # Get currently selected data on the item window
      @item = @item_window.item
      # If not a use item
      unless @item.is_a?(RPG::Item)
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # If it can't be used
      unless $game_party.item_can_use?(@item.id)
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # If effect scope is an ally
      if @item.scope >= 3
        # Activate target window
        @item_window.active = false
        @target_window.visible = true
        @target_background.visible = true
        @target_window.active = true
        @target_window.y = 0
        @target_background.y = 118
        # Set cursor position to effect scope (single / all)
        if @item.scope == 4 || @item.scope == 6
          @target_window.index = -1
        else
          @target_window.index = 0
        end
      # If effect scope is other than an ally
      else
        # If command event ID is valid
        if @item.common_event_id > 0
          # Command event call reservation
          $game_temp.common_event_id = @item.common_event_id
          # Play item use SE
          $game_system.se_play(@item.menu_se)
          # If consumable
          if @item.consumable
            # Decrease used items by 1
            $game_party.lose_item(@item.id, 1)
            # Draw item window item
            @item_window.draw_item(@item_window.index)
          end
          # Switch to map screen
          $scene = Scene_Map.new
          return
        end
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when skill window is active)
  #--------------------------------------------------------------------------
  def update_skill
    if @target_window.visible == false
      for i in 0...$game_party.actors.size - 1
        @target_cursor_skill[i].visible = false
      end
    end
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      @skill_window[@actor_skillwindow.index].visible = false
      @skill_window[@actor_skillwindow.index].active = false
      @skill_window[@actor_skillwindow.index].index = 0
      @help_window.visible = false
      @skill_actor_window2[@actor_skillwindow.index].visible = false
      @actor_skillwindow.visible = true
      @actor_skillwindow.active = true
      # If C button was pressed
    elsif Input.trigger?(Input::C)
      @actor = $game_party.actors[@actor_skillwindow.index]
      # Get currently selected data on the skill window
      @skill = @skill_window[@actor_skillwindow.index].skill
      # If unable to use
      if @skill == nil or not @actor.skill_can_use?(@skill.id)
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # If effect scope is ally
      if @skill.scope >= 3
        # Activate target window
        @skill_window[@actor_skillwindow.index].active = false
        @skill_window[@actor_skillwindow.index].visible = false
        @target_window.visible = true
        @target_window.active = true
        @target_window.y = -75
        # Set cursor position to effect scope (single / all)
        if @skill.scope == 4 || @skill.scope == 6
          @target_window.index = -1
        elsif @skill.scope == 7
          @target_window.index = @actor_index - 10
        else
          @target_window.index = 0
        end
      # If effect scope is other than ally
      else
        # If common event ID is valid
        if @skill.common_event_id > 0
          # Common event call reservation
          $game_temp.common_event_id = @skill.common_event_id
          # Play use skill SE
          $game_system.se_play(@skill.menu_se)
          # Use up SP
          @actor.sp -= @skill.sp_cost
          # Remake each window content
          @status_window.refresh
          @skill_window[@actor_skillwindow.index].refresh
          @target_window.refresh
          # Switch to map screen
          $scene = Scene_Map.new
          return
        end
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when target window is active)
  #--------------------------------------------------------------------------
  def update_target
    if @item_window.visible
      if @target_window.index < 0
        for i in 0...$game_party.actors.size - 1
          @target_cursor[i].visible = true
        end
      end
      # If B button was pressed
      if Input.trigger?(Input::B)
        # Play cancel SE
        $game_system.se_play($data_system.cancel_se)
        # If unable to use because items ran out
        unless $game_party.item_can_use?(@item.id)
          # Remake item window contents
          @item_window.refresh
        end
        # Erase target window
        @item_window.active = true
        @target_window.visible = false
        @target_background.visible = false
        @target_window.active = false
        return
      end
      # If C button was pressed
      if Input.trigger?(Input::C)
        # If items are used up
        if $game_party.item_number(@item.id) == 0
          # Play buzzer SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # If target is all
        if @target_window.index == -1
          # Apply item effects to entire party
          used = false
          for i in $game_party.actors
            used |= i.item_effect(@item)
          end
        end
        # If single target
        if @target_window.index >= 0
          # Apply item use effects to target actor
          target = $game_party.actors[@target_window.index]
          used = target.item_effect(@item)
        end
        # If an item was used
        if used
          # Play item use SE
          $game_system.se_play(@item.menu_se)
          # If consumable
          if @item.consumable
            # Decrease used items by 1
            $game_party.lose_item(@item.id, 1)
            # Redraw item window item
            @item_window.draw_item(@item_window.index)
          end
          # Remake target window contents
          @target_window.refresh
          @actor_skillwindow.refresh
          @skill_actor_window2[@actor_skillwindow.index].refresh
          # If all party members are dead
          if $game_party.all_dead?
            # Switch to game over screen
            $scene = Scene_Gameover.new
            return
          end
          # If common event ID is valid
          if @item.common_event_id > 0
            # Common event call reservation
            $game_temp.common_event_id = @item.common_event_id
            # Switch to map screen
            $scene = Scene_Map.new
            return
          end
        end
        # If item wasn't used
        unless used
          # Play buzzer SE
          $game_system.se_play($data_system.buzzer_se)
        end
        return
      end
    else
      if @target_window.index < 0
        for i in 0...$game_party.actors.size - 1
          @target_cursor_skill[i].visible = true
        end
      end
      # If B button was pressed
      if Input.trigger?(Input::B)
        # Play cancel SE
        $game_system.se_play($data_system.cancel_se)
        # Erase target window
        @skill_window[@actor_skillwindow.index].active = true
        @skill_window[@actor_skillwindow.index].visible = true
        @target_window.visible = false
        @target_background.visible = false
        @target_window.active = false
        return
      end
      # If C button was pressed
      if Input.trigger?(Input::C)
        # If unable to use because SP ran out
        unless @actor.skill_can_use?(@skill.id)
          # Play buzzer SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # If target is all
        if @target_window.index == -1
          # Apply skill use effects to entire party
          used = false
          for i in $game_party.actors
            used |= i.skill_effect(@actor, @skill)
          end
        end
        # If target is user
        if @target_window.index <= -2
          # Apply skill use effects to target actor
          target = $game_party.actors[@target_window.index + 10]
          used = target.skill_effect(@actor, @skill)
        end
        # If single target
        if @target_window.index >= 0
          # Apply skill use effects to target actor
          target = $game_party.actors[@target_window.index]
          used = target.skill_effect(@actor, @skill)
        end
        # If skill was used
        if used
          # Play skill use SE
          $game_system.se_play(@skill.menu_se)
          # Use up SP
          @actor.sp -= @skill.sp_cost
          # Remake each window content
          @actor_skillwindow.refresh
          @skill_window[@actor_skillwindow.index].refresh
          @skill_actor_window2[@actor_skillwindow.index].refresh
          @target_window.refresh
          # If entire party is dead
          if $game_party.all_dead?
            # Switch to game over screen
            $scene = Scene_Gameover.new
            return
         end
          # If command event ID is valid
          if @skill.common_event_id > 0
            # Command event call reservation
            $game_temp.common_event_id = @skill.common_event_id
            # Switch to map screen
            $scene = Scene_Map.new
            return
          end
        end
        # If skill wasn't used
        unless used
          # Play buzzer SE
          $game_system.se_play($data_system.buzzer_se)
        end
        return
      end
    end
  end  
end
#==============================================================================
# ** Window_IcoonCommands
#------------------------------------------------------------------------------
#  This class performs command processing.
#==============================================================================
class Window_IconCommands < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(210, 190, 220, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.index = 0
    self.z = 200
    @column_max = 6
    @item_max = 6
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.blt(4,5,RPG::Cache.icon(CT_Pictures::Icon_1), Rect.new(0,0,24,24))
    self.contents.blt(36,5,RPG::Cache.icon(CT_Pictures::Icon_2), Rect.new(0,0,24,24))
    self.contents.blt(68,5,RPG::Cache.icon(CT_Pictures::Icon_3), Rect.new(0,0,24,24))
    self.contents.blt(100,5,RPG::Cache.icon(CT_Pictures::Icon_4), Rect.new(0,0,24,24))
    self.contents.blt(132,5,RPG::Cache.icon(CT_Pictures::Icon_5), Rect.new(0,0,24,24))
    self.contents.blt(164,5,RPG::Cache.icon(CT_Pictures::Icon_6), Rect.new(0,0,24,24))
  end
  #--------------------------------------------------------------------------
  # * Cursor Rectangle Update
  #--------------------------------------------------------------------------
  def update_cursor_rect
    self.cursor_rect.set(@index * 32, 1, 32, 32)
  end
end
#==============================================================================
# ** Window_Actors
#------------------------------------------------------------------------------
#  This class is for choosing an actor to be equipped
#==============================================================================
class Window_Actors < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(30, 21, 350, 450)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.index = 0
    self.z += 50
    self.active = false
    self.opacity = 0
    @item_max = $game_party.actors.size
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.size = 18
    self.contents.font.bold = true
    $game_temp.cms_index = @old_index = @index
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      y  = i * 102
      pow = actor.str + actor.atk
      self.contents.draw_text(14, y, 100, 32, actor.name)
      self.contents.draw_text(154, y, 100, 32, "LV #{actor.level}")
      self.contents.draw_text(60, y + 65, 100, 32, "#{pow}")
      self.contents.draw_text(210, y + 65, 100, 32, "#{actor.pdef}")
      draw_actor_hp(actor, 14, y + 20)
      draw_actor_sp(actor, 14, y + 40)
      self.contents.blt(14, y + 70, RPG::Cache.icon($data_weapons[actor.weapon_id] == nil ? CT_Pictures::Weapon_alternative : $data_weapons[actor.weapon_id].icon_name), Rect.new(0,0,24,24))
      self.contents.blt(174, y + 70, RPG::Cache.icon($data_armors[actor.armor1_id] == nil ? CT_Pictures::Shield_alternative : $data_armors[actor.armor1_id].icon_name), Rect.new(0,0,24,24))
    end
  end
  #--------------------------------------------------------------------------
  # * Cursor Rectangle Update
  #--------------------------------------------------------------------------
  def update_cursor_rect
    self.cursor_rect.set(0, @index * 102, 0, 0)
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    super
    if @old_index != @index
      refresh
      @old_index = @index
    end
  end    
end
#==============================================================================
# ** Window_NewEquip
#------------------------------------------------------------------------------
#  This window displays items the actor is currently equipped with on the
#  equipment screen, stats etc.
#==============================================================================
class Window_NewEquip < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(300, 20, 350, 450)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.index = 0
    self.active = false
    self.opacity = 0
    @item_max = 5
    @old_index = $game_temp.cms_index
    refresh
  end
  #--------------------------------------------------------------------------
  # * Item Acquisition
  #--------------------------------------------------------------------------
  def item
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.size = 18
    self.contents.font.bold = true
    @actor = $game_party.actors[$game_temp.cms_index]
    self.contents.draw_text(164, 10, 100, 32, @actor.name)
    draw_actor_state(@actor, 164, 42)
    self.contents.draw_text(164, 74, 100, 32, "LV #{@actor.level}")
    self.contents.blt(20,20,RPG::Cache.picture("Faces/" + @actor.character_name), Rect.new(0,0,100,100))
    @data = []
    @data.push($data_weapons[@actor.weapon_id])
    @data.push($data_armors[@actor.armor1_id])
    @data.push($data_armors[@actor.armor2_id])
    @data.push($data_armors[@actor.armor3_id])
    @data.push($data_armors[@actor.armor4_id])
    @item_max = @data.size
    self.contents.font.color = system_color
    y = 115
    self.contents.draw_text(14, 25 * 0 + y, 92, 32, $data_system.words.weapon)
    self.contents.draw_text(14, 25 * 1 + y, 92, 32, $data_system.words.armor1)
    self.contents.draw_text(14, 25 * 2 + y, 92, 32, $data_system.words.armor2)
    self.contents.draw_text(14, 25 * 3 + y, 92, 32, $data_system.words.armor3)
    self.contents.draw_text(15, 25 * 4 + y, 92, 32, $data_system.words.armor4)
    draw_item_name(@data[0], 110, 25 * 0 + y)
    draw_item_name(@data[1], 110, 25 * 1 + y)
    draw_item_name(@data[2], 110, 25 * 2 + y)
    draw_item_name(@data[3], 110, 25 * 3 + y)
    draw_item_name(@data[4], 110, 25 * 4 + y)
    self.contents.font.color = normal_color
    self.contents.draw_text(14, 250, 500, 32, $data_system.words.str)
    self.contents.draw_text(14, 270, 500, 32, $data_system.words.atk)
    self.contents.draw_text(14, 290, 500, 32, $data_system.words.int)
    self.contents.draw_text(14, 310, 500, 32, $data_system.words.dex)
    self.contents.draw_text(144, 250, 500, 32, $data_system.words.agi)
    self.contents.draw_text(144, 270, 500, 32, $data_system.words.pdef)
    self.contents.draw_text(144, 290, 500, 32, $data_system.words.mdef)
    up_color = Color.new(60, 255, 255)
    str = @actor.str.to_s
    if @new_str != nil
      str = @new_str.to_s
      @actor.str == @new_str ? self.contents.font.color = normal_color : @actor.str < @new_str ? 
      self.contents.font.color = up_color : self.contents.font.color = disabled_color
    end
    self.contents.draw_text(25, 250, 100, 32, str, 2)
    atk = @actor.atk.to_s
    if @new_atk != nil
      atk = @new_atk.to_s
      @actor.atk == @new_atk ? self.contents.font.color = normal_color : @actor.atk < @new_atk ? 
      self.contents.font.color = up_color : self.contents.font.color = disabled_color
    end
    self.contents.draw_text(25, 270, 100, 32, atk, 2)
    int = @actor.int.to_s
    if @new_int != nil
      int = @new_int.to_s
      @actor.int == @new_int ? self.contents.font.color = normal_color : @actor.int < @new_int ? 
      self.contents.font.color = up_color : self.contents.font.color = disabled_color
    end
    self.contents.draw_text(25, 290, 100, 32, int, 2)
    agi = @actor.agi.to_s
    if @new_agi != nil
      agi = @new_agi.to_s
      @actor.agi == @new_agi ? self.contents.font.color = normal_color : @actor.agi < @new_agi ? 
      self.contents.font.color = up_color : self.contents.font.color = disabled_color
    end
    self.contents.draw_text(160, 250, 100, 32, agi, 2)
    pdef = @actor.pdef.to_s
    if @new_pdef != nil
      pdef = @new_pdef.to_s
      @actor.pdef == @new_pdef ? self.contents.font.color = normal_color : @actor.pdef < @new_pdef ? 
      self.contents.font.color = up_color : self.contents.font.color = disabled_color
    end
    self.contents.draw_text(160, 270, 100, 32, pdef, 2)
    mdef = @actor.mdef.to_s
    if @new_mdef != nil
      mdef = @new_mdef.to_s
      @actor.mdef == @new_mdef ? self.contents.font.color = normal_color : @actor.mdef < @new_mdef ? 
      self.contents.font.color = up_color : self.contents.font.color = disabled_color
    end
    self.contents.draw_text(160, 290, 100, 32, mdef, 2)
    dex = @actor.dex.to_s
    if @new_mdef != nil
      dex = @new_dex.to_s
      @actor.dex == @new_dex ? self.contents.font.color = normal_color : @actor.dex < @new_dex ? 
      self.contents.font.color = up_color : self.contents.font.color = disabled_color
    end
    self.contents.draw_text(160, 310, 100, 32, dex, 2)
    self.contents.font.color = normal_color
    self.contents.draw_text(14, 353, 500, 32, "EXP")
    self.contents.draw_text(14, 370, 500, 32, "NEXT")
    self.contents.draw_text(14, 353, 240, 32, "#{@actor.exp}",2)
    self.contents.draw_text(14, 370, 240, 32, "#{@actor.next_exp}",2)
  end
  #--------------------------------------------------------------------------
  # * Set parameters after changing equipment
  #--------------------------------------------------------------------------
  def set_new_parameters(new_str, new_atk, new_int, new_agi, new_pdef, new_mdef, new_dex)
    if @new_atk != new_atk or @new_pdef != new_pdef or @new_mdef != new_mdef or
      @new_str != new_str or @new_int != new_int or @new_agi != new_agi or @new_dex != new_dex
      @new_str = new_str
      @new_atk = new_atk
      @new_int = new_int
      @new_agi = new_agi
      @new_pdef = new_pdef
      @new_mdef = new_mdef
      @new_dex = new_dex
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Cursor Rectangle Update
  #--------------------------------------------------------------------------
  def update_cursor_rect
    self.cursor_rect.set(14, @index * 25 + 115, 0, 0)
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    super
    if @old_index != $game_temp.cms_index
      refresh
      @old_index = $game_temp.cms_index
    end
  end
end
#==============================================================================
# ** Window_Item
#------------------------------------------------------------------------------
#  This window displays items in possession on the item and battle screens.
#==============================================================================
class Window_Item < Window_Selectable
  #--------------------------------------------------------------------------
  # * Draw Item
  #     index : item number
  #--------------------------------------------------------------------------
  def initialize
    super(48, 125, 500, 320)
    self.index = 0
    self.z = 150
    # If in battle, move window to center of screen
    # and make it semi-transparent
    if $game_temp.in_battle
      @column_max = 2
      self.y = 64
      self.x = 0
      self.y = 64
      self.width = 640
      self.height = 256
      self.back_opacity = 160
    end
    refresh
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #     index : item number
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    case item
    when RPG::Item
      number = $game_party.item_number(item.id)
    when RPG::Weapon
      number = $game_party.weapon_number(item.id)
    when RPG::Armor
      number = $game_party.armor_number(item.id)
    end
    if item.is_a?(RPG::Item) and $game_party.item_can_use?(item.id)
      self.contents.font.color = normal_color
    else
      self.contents.font.color = disabled_color
    end
    if $game_temp.in_battle
      x = 4 + index % 2 * (288 + 32)
      y = index / 2 * 32
    else
      self.contents.font.size = 18
      self.contents.font.bold = true
      x = 4
      y = index * 32
    end
    rect = Rect.new(x, y, self.width / @column_max - 32, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    bitmap = RPG::Cache.icon(item.icon_name)
    opacity = self.contents.font.color == normal_color ? 255 : 128
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24), opacity)
    self.contents.draw_text(x + 28, y, 212, 32, item.name, 0)
    if $game_temp.in_battle
      self.contents.draw_text(x + 240, y, 16, 32, ":", 1)
      self.contents.draw_text(x + 256, y, 24, 32, number.to_s, 2)
    else
      self.contents.draw_text(x + 300, y, 16, 32, ":", 1)
      self.contents.draw_text(x + 316, y, 24, 32, number.to_s, 2)
    end
  end
end
#==============================================================================
# ** Window_Help
#------------------------------------------------------------------------------
#  This window shows skill and item explanations along with actor status.
#==============================================================================
class Window_Help < Window_Base
  #--------------------------------------------------------------------------
  # * Set Text
  #  text  : text string displayed in window
  #  align : alignment (0..flush left, 1..center, 2..flush right)
  #--------------------------------------------------------------------------
  def set_text(text, align = 0)
    # If at least one part of text and alignment differ from last time
    if text != @text or align != @align
      # Redraw text
      self.contents.clear
      unless $game_temp.in_battle
        self.contents.font.size = 18
        self.contents.font.bold = true
      end
      self.contents.font.color = normal_color
      self.contents.draw_text(4, 0, self.width - 40, 32, text, align)
      @text = text
      @align = align
      @actor = nil
    end
    self.visible = true
  end
end
#==============================================================================
# ** Window_Target
#------------------------------------------------------------------------------
#  This window selects a use target for the actor on item and skill screens.
#==============================================================================
class Window_Target < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(305, 0, 336, 480)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.z += 999
    self.opacity = 0
    @item_max = $game_party.actors.size
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.size = 18
    self.contents.font.bold = true
    for i in 0...$game_party.actors.size
      x = 4
      y = i * 79 + 100
      actor = $game_party.actors[i]
      pow = actor.str + actor.atk
      draw_actor_graphic(actor, 235, y + 85)
      self.contents.font.size = 17
      self.contents.draw_text(14, y, 100, 32, actor.name)
      self.contents.draw_text(154, y, 100, 32, "LV #{actor.level}")
      self.contents.draw_text(50, y + 55, 100, 32, "#{pow}")
      self.contents.draw_text(190, y + 55, 100, 32, "#{actor.pdef}")
      draw_actor_hp(actor, 14, y + 15)
      draw_actor_sp(actor, 14, y + 30)
      self.contents.blt(14, y + 60, RPG::Cache.icon($data_weapons[actor.weapon_id] == nil ? CT_Pictures::Weapon_alternative : $data_weapons[actor.weapon_id].icon_name), Rect.new(0,0,24,24))
      self.contents.blt(154, y + 60, RPG::Cache.icon($data_armors[actor.armor1_id] == nil ? CT_Pictures::Shield_alternative : $data_armors[actor.armor1_id].icon_name), Rect.new(0,0,24,24))
    end
  end
  #--------------------------------------------------------------------------
  # * Cursor Rectangle Update
  #--------------------------------------------------------------------------
  def update_cursor_rect
    # Cursor position -1 = all choices, -2 or lower = independent choice
    # (meaning the user's own choice)
    if @index >= 0
      self.cursor_rect.set(10, @index * 82 + 100, 0, 0)
    else
      self.cursor_rect.set(10, 100, 0, 0)
    end
  end
end
#==============================================================================
# ** Window_Skill
#------------------------------------------------------------------------------
#  This window displays usable skills on the skill and battle screens.
#==============================================================================
class Window_Skill < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     actor : actor
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(310, 32, 300, 352)
    self.contents = Bitmap.new (width - 32, height - 32)
    self.index = 0
    self.opacity = 0
    @actor = actor
    # If in battle, move window to center of screen
    # and make it semi-transparent
    if $game_temp.in_battle
      @column_max = 2
      self.opacity = 255
      self.x = 0
      self.y = 64
      self.height = 256
      self.width = 640
      self.back_opacity = 160
    end
    refresh
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #     index : item number
  #--------------------------------------------------------------------------
  def draw_item(index)
    skill = @data[index]
    if @actor.skill_can_use?(skill.id)
      self.contents.font.color = normal_color
    else
      self.contents.font.color = disabled_color
    end
    if $game_temp.in_battle
      x = 4 + index % 2 * (288 + 32)
      y = index / 2 * 32
    else
      self.contents.font.size = 18
      self.contents.font.bold = true
      x = 4
      y = index * 32
    end
    rect = Rect.new(x, y, self.width / @column_max - 32, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    bitmap = RPG::Cache.icon(skill.icon_name)
    opacity = self.contents.font.color == normal_color ? 255 : 128
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24), opacity)
    self.contents.draw_text(x + 28, y, 150, 32, skill.name, 0)
    if $game_temp.in_battle
      self.contents.draw_text(x + 200, y, 48, 32, skill.sp_cost.to_s, 2)
    end
  end
end
#==============================================================================
# ** Window_SkillActor
#------------------------------------------------------------------------------
#  This window displays selectable characters for the skill window
#==============================================================================
class Window_SkillActor < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(32,20,320,350)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.opacity = 0
    self.index = 0
    @column_max = 1
    @item_max = $game_party.actors.size
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.size = 18
    self.contents.font.bold = true
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      x = 60
      y = i * 80
      draw_actor_graphic(actor, 30, y + 65)
      self.contents.draw_text(x, y, 150, 32, "#{actor.name}")
      self.contents.draw_text(x + 80, y, 150, 32, "LV #{actor.level}")
      draw_actor_hp(actor, x, y + 15)
      draw_actor_sp(actor, x, y + 30)
      draw_actor_state(actor, x, y + 45)
    end
  end
  #--------------------------------------------------------------------------
  # * Cursor Rectangle Update
  #-------------------------------------------------------------------------
  def update_cursor_rect
    self.cursor_rect.set(10, @index * 80 + 10, 0, 0)
  end
end
#==============================================================================
# ** Window_SkillActor2
#------------------------------------------------------------------------------
#  This window displays selected character for the skill window
#==============================================================================
class Window_SkillActor2 < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #   actor : actor
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(32,20,320,350)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.opacity = 0
    @old_index = $game_temp.skill_index
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = normal_color
    self.contents.font.size = 18
    self.contents.font.bold = true
    x = 60
    y = 0
    draw_actor_graphic(@actor, 30, y + 65)
    self.contents.draw_text(x, y, 150, 32, "#{@actor.name}")
    self.contents.draw_text(x + 80, y, 150, 32, "LV #{@actor.level}")
    draw_actor_hp(@actor, x, y + 15)
    draw_actor_sp(@actor, x, y + 30)
    draw_actor_state(@actor, x, y + 45)
    self.contents.draw_text(x + 70, y + 45, 150, 32,$data_system.words.sp + " uses ")
    unless @actor.skills[$game_temp.skill_index] == nil
      if @actor.sp < $data_skills[@actor.skills[$game_temp.skill_index]].sp_cost
        self.contents.font.color = knockout_color
      else
        self.contents.font.color = normal_color
      end
    end
    @sp_uses = @actor.skills[$game_temp.skill_index] == nil ? "" : $data_skills[@actor.skills[$game_temp.skill_index]].sp_cost.to_s
    self.contents.draw_text(x + 135, y + 45, 150, 32, @sp_uses)
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    super
    if $game_temp.skill_index != @old_index
      refresh
      @old_index = $game_temp.skill_index
    end
  end
end
#==============================================================================
# ** Window_SaveFile
#------------------------------------------------------------------------------
#  This window displays save files on the save and load screens.
#==============================================================================
class Window_SaveFile < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     file_index : save file index (0-2)
  #     filename   : file name
  #--------------------------------------------------------------------------
  def initialize(file_index, filename)
    super(42, 35 + file_index % 4 * 70, 640, 90)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.opacity = 0
    @file_index = file_index
    @filename = "Save#{@file_index + 1}.rxdata"
    @time_stamp = Time.at(0)
    @file_exist = FileTest.exist?(@filename)
    if @file_exist
      file = File.open(@filename, "r")
      @time_stamp = file.mtime
      @characters = Marshal.load(file)
      @frame_count = Marshal.load(file)
      @game_system = Marshal.load(file)
      @game_switches = Marshal.load(file)
      @game_variables = Marshal.load(file)
      @total_sec = @frame_count / Graphics.frame_rate
      file.close
    end
    refresh
    @selected = false
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.size = 18
    self.contents.font.bold = true
    # Draw file number
    self.contents.font.color = normal_color
    name = "File#{@file_index + 1}"
    self.contents.draw_text(4, 0, 600, 32, name)
    @name_width = contents.text_size(name).width
    # If save file exists
    if @file_exist
      self.contents.draw_text(0, 0, 600, 32, @game_system.chapter.to_s,1)
    end
  end
end
#==============================================================================
# ** Window_SaveStatus
#------------------------------------------------------------------------------
#  This window displays stats on the save files.
#==============================================================================
class Window_SaveStatus < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0,0,640,480)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.opacity = 0
    @index = $game_temp.save_index
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    filename = "Save#{$game_temp.save_index + 1}.rxdata"
    return unless FileTest.exist?(filename)
    file = File.open(filename, "r")
    @characters = Marshal.load(file)
    @frame_count = Marshal.load(file)
    @game_system = Marshal.load(file)
    @game_switches = Marshal.load(file)
    @game_variables = Marshal.load(file)
    Marshal.load(file)
    Marshal.load(file)
    Marshal.load(file)
    party = Marshal.load(file)
    Marshal.load(file)
    map = Marshal.load(file)
    self.contents.font.size = 20
    self.contents.font.bold = true
    for i in 0...party.actors.size
      actor = party.actors[i]
      x = 284
      y = i * 36 + 265
      draw_actor_name(actor, x + 40, y - 2)
      draw_actor_level(actor, x + 170, y - 2)
      self.contents.blt(x + 5, y + 10, RPG::Cache.icon(actor.character_name), Rect.new(0,0,24,24))
      self.contents.draw_text(x + 40, y + 16, 150, 32, "#{$data_system.words.hp} #{actor.hp} / #{actor.maxhp}")
      self.contents.draw_text(x + 170, y + 16, 150, 32, "#{$data_system.words.sp} #{actor.sp} / #{actor.maxsp}")
    end
    total_sec = @frame_count / Graphics.frame_rate
    hour = total_sec / 60 / 60
    min = total_sec / 60 % 60
    sec = total_sec % 60
    text = sprintf("%02d:%02d:%02d", hour, min, sec)
    map_name = load_data("Data/MapInfos.rxdata")[map.map_id].name
    self.contents.font.size = 20
    self.contents.draw_text(45, 272, 144, 32, map_name)
    self.contents.draw_text(45, 304, 144, 32, "TIME:")
    self.contents.draw_text(100, 304, 144, 32, text,2)
    self.contents.draw_text(45, 336, 144, 32, $data_system.words.gold + ":")
    self.contents.draw_text(100, 336, 144, 32, party.gold.to_s,2)
    self.contents.draw_text(45, 368, 144, 32, "Save #:")
    self.contents.draw_text(100, 368, 144, 32, @game_system.save_count.to_s, 2)
  end 
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    super
    if @index != $game_temp.save_index
      refresh
    @index = $game_temp.save_index
    end
  end
end
#==============================================================================
# ** Window_PartyChange
#------------------------------------------------------------------------------
#  This window displays changable characters.
#==============================================================================
class Window_PartyChange < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0,0,640,480)
    self.index = 0
    self.opacity = 0
    @item_max = $game_party.actors.size
    self.contents = Bitmap.new(width - 32, height - 32)
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.size = 18
    self.contents.font.bold = true
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      x = 140
      y = i * 110
      draw_actor_graphic(actor, x + 260, y + 80)
      draw_actor_name(actor,x + 80, y)
      draw_actor_level(actor, x + 160, y)
      draw_actor_hp(actor, x + 80, y + 20)
      draw_actor_sp(actor, x + 80, y + 40)
      self.contents.draw_text(x + 104, y + 72, 150, 32, (actor.str + actor.atk).to_s)
      self.contents.draw_text(x + 204, y + 72, 150, 32, actor.pdef.to_s)
      self.contents.blt(x + 80, y + 72, RPG::Cache.icon($data_weapons[actor.weapon_id] == nil ? CT_Pictures::Weapon_alternative : $data_weapons[actor.weapon_id].icon_name), Rect.new(0,0,24,24))
      self.contents.blt(x + 180, y + 72, RPG::Cache.icon($data_armors[actor.armor1_id] == nil ? CT_Pictures::Shield_alternative : $data_armors[actor.armor1_id].icon_name), Rect.new(0,0,24,24))
    end
  end
  #--------------------------------------------------------------------------
  # * Cursor Rectangle Update
  #-------------------------------------------------------------------------
  def update_cursor_rect
    self.cursor_rect.set(190, @index * 110, 0, 0)
  end
end
#==============================================================================
# ** Window_EquipItem
#------------------------------------------------------------------------------
#  This window displays choices when opting to change equipment on the
#  equipment screen.
#==============================================================================
class Window_EquipItem2 < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     equip_type : equip region (0-3)
  #--------------------------------------------------------------------------
  def initialize(equip_type)
    super(50, 210, 275, 240)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = $game_party.actors[$game_temp.cms_index]
    @equip_type = equip_type
    @old_actor = $game_temp.cms_index
    self.active = false
    @old_index = @index
    self.z = 1000
    self.opacity = 0
    self.index = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # * Item Acquisition
  #--------------------------------------------------------------------------
  def item
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
    # Add equippable weapons
    if @equip_type == 0
      weapon_set = $data_classes[@actor.class_id].weapon_set
      for i in 1...$data_weapons.size
        if $game_party.weapon_number(i) > 0 and weapon_set.include?(i)
          @data.push($data_weapons[i])
        end
      end
    end
    # Add equippable armor
    if @equip_type != 0
      armor_set = $data_classes[@actor.class_id].armor_set
      for i in 1...$data_armors.size
        if $game_party.armor_number(i) > 0 and armor_set.include?(i)
          if $data_armors[i].kind == @equip_type-1
            @data.push($data_armors[i])
          end
        end
      end
    end
    # Add blank page
    @data.push(nil)
    # Make a bit map and draw all items
    @item_max = @data.size
    self.contents = Bitmap.new(width - 32, row_max * 32)
    for i in 0...@item_max-1
      draw_item(i)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #     index : item number
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    x = 4
    y = index * 32
    case item
    when RPG::Weapon
      number = $game_party.weapon_number(item.id)
    when RPG::Armor
      number = $game_party.armor_number(item.id)
    end
    bitmap = RPG::Cache.icon(item.icon_name)
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24))
    self.contents.font.color = normal_color
    self.contents.font.size = 18
    self.contents.font.bold = true
    self.contents.draw_text(x + 28, y, 212, 32, item.name, 0)
    self.contents.draw_text(x + 185, y, 16, 32, ":", 1)
    self.contents.draw_text(x + 201, y, 24, 32, number.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # * Update
  #-------------------------------------------------------------------------
  def update
    super
    if $game_temp.cms_index != @old_actor
      @actor = $game_party.actors[$game_temp.cms_index]
      refresh
      @old_actor = $game_temp.cms_index
    end
  end
end
#==============================================================================
# ** Window_EquipDescription
#------------------------------------------------------------------------------
#  This window displays the kind of equipment
#==============================================================================
class Window_EquipDescription < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(30, 21, 320, 480)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.opacity = 0
    self.z = 1000
    @cms_index = $game_temp.cms_index
    @equip_index = $game_temp.equip_index
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.size = 18
    self.contents.font.bold = true
    actor = $game_party.actors[$game_temp.cms_index]
    y  = 0
    pow = actor.str + actor.atk
    self.contents.draw_text(14, y, 100, 32, actor.name)
    self.contents.draw_text(154, y, 100, 32, "LV #{actor.level}")
    self.contents.draw_text(60, y + 65, 100, 32, "#{pow}")
    self.contents.draw_text(210, y + 65, 100, 32, "#{actor.pdef}")
    draw_actor_hp(actor, 14, y + 20)
    draw_actor_sp(actor, 14, y + 40)
    self.contents.blt(14, y + 70, RPG::Cache.icon($data_weapons[actor.weapon_id] == nil ? CT_Pictures::Weapon_alternative : $data_weapons[actor.weapon_id].icon_name), Rect.new(0,0,24,24))
    self.contents.blt(174, y + 70, RPG::Cache.icon($data_armors[actor.armor1_id] == nil ? CT_Pictures::Shield_alternative : $data_armors[actor.armor1_id].icon_name), Rect.new(0,0,24,24))
    if $game_temp.equip_index == 0
      text = $data_system.words.weapon
    else
      text = eval("$data_system.words.armor#{$game_temp.equip_index}")
    end
    self.contents.draw_text(14,122,250,32, "#{text}", 1)
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    super
    if @cms_index != $game_temp.cms_index or @equip_index != $game_temp.equip_index
      refresh
      @cms_index = $game_temp.cms_index
      @equip_index = $game_temp.equip_index
    end
  end
end
#==============================================================================
# ** Window_PlayTime
#------------------------------------------------------------------------------
#  This window displays play time on the menu screen.
#==============================================================================
class Window_PlayTime < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 384, 160, 96)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.opacity = 0
    self.z = 9999
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = system_color
    self.contents.font.size = 18
    self.contents.font.bold = true
    self.contents.draw_text(4, 0, 120, 32, "TIME:")
    self.contents.draw_text(4, 32, 120, 32, $data_system.words.gold + ":")
    @total_sec = Graphics.frame_count / Graphics.frame_rate
    hour = @total_sec / 60 / 60
    min = @total_sec / 60 % 60
    sec = @total_sec % 60
    text = sprintf("%02d:%02d:%02d", hour, min, sec)
    self.contents.font.color = normal_color
    self.contents.draw_text(4, 0, 120, 32, text, 2)
    self.contents.draw_text(4, 32, 120, 32, $game_party.gold.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if Graphics.frame_count / Graphics.frame_rate != @total_sec
      refresh
    end
  end
end
#==============================================================================
# ** Window_End
#------------------------------------------------------------------------------
#  This window displays the end window.
#==============================================================================
class Window_End < Window_Selectable
  def initialize
    super(0,0,192,128)
    self.contents = Bitmap.new(width - 32, height - 32)
    @item_max = 3
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.draw_text(4, 0, 150, 32, "To Title")
    self.contents.draw_text(4, 32, 150, 32, "Shutdown")
    self.contents.draw_text(4, 64, 150, 32, "Cancel")
  end
  #--------------------------------------------------------------------------
  # * Cursor Rectangle Update
  #--------------------------------------------------------------------------
  def update_cursor_rect
    self.cursor_rect.set(4, @index * 32, 0, 0)
  end
end
#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This class is for all in-game windows.
#==============================================================================
class Window_Base < Window
  def draw_item_name(item, x, y)
    if item == nil
      return
    end
    bitmap = RPG::Cache.icon(item.icon_name)
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24))
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 28, y, 110, 32, item.name)
  end
end
#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles the actor. It's used within the Game_Actors class
#  ($game_actors) and refers to the Game_Party class ($game_party).
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Get the current EXP
  #--------------------------------------------------------------------------
  def now_exp
    return @exp - @exp_list[@level]
  end
  #--------------------------------------------------------------------------
  # * Get the next level's EXP
  #--------------------------------------------------------------------------
  def next_exp
    return @exp_list[@level+1] > 0 ? @exp_list[@level+1] - @exp_list[@level] : 0
  end
end
#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles data surrounding the system. Backround music, etc.
#  is managed here as well. Refer to "$game_system" for the instance of 
#  this class.
#==============================================================================
class Game_System
  attr_accessor :chapter
  alias raz_cms_system_initialize initialize
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @chapter = ""
    raz_cms_system_initialize
  end
end
#==============================================================================
# ** Game_Temp
#------------------------------------------------------------------------------
#  This class handles temporary data that is not included with save data.
#  Refer to "$game_temp" for the instance of this class.
#==============================================================================
class Game_Temp
  attr_accessor :cms_index
  attr_accessor :skill_index
  attr_accessor :save_index
  attr_accessor :equip_index
  attr_accessor :equip_window
  alias raz_cms_initialize initialize
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @cms_index = 0
    @skill_index = 0
    @save_index = 0
    @equip_index = 0
    raz_cms_initialize
  end
end
#==============================================================================
# ** Scene_File
#------------------------------------------------------------------------------
#  This is a superclass for the save screen and load screen.
#==============================================================================
class Scene_File
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     help_text : text string shown in the help window
  #--------------------------------------------------------------------------
  def initialize(help_text)
    @help_text = help_text
  end
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    # Make save file window
    @back_ground = Sprite.new
    @back_ground.bitmap = RPG::Cache.picture(CT_Pictures::BG_Picture)
    @save_window = []
    @save_window[0] = Window_Base.new(39,32, 560, 70)
    @save_window[1] = Window_Base.new(39,102, 560, 70)
    @save_window[2] = Window_Base.new(39,172, 560, 70)
    @save_left = Window_Base.new(39,273,241,172)
    @save_right = Window_Base.new(280,273,320,172)
    @savefile_windows = []
    @save_status = Window_SaveStatus.new
    for i in 0..2
      @savefile_windows.push(Window_SaveFile.new(i, make_filename(i)))
    end
    # Select last file to be operated
    @file_index = $game_temp.last_file_index
    @savefile_windows[@file_index].selected = true
    # Execute transition
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepare for transition
    Graphics.freeze
    # Dispose of windows
    @save_status.dispose
    @back_ground.dispose
    @save_left.dispose
    @save_right.dispose
    for i in 0..2
      @save_window[i].dispose
    end
    for i in @savefile_windows
      i.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    @save_status.update
    $game_temp.save_index = @file_index
    if Input.trigger?(Input::C)
      # Call method: on_decision (defined by the subclasses)
      on_decision(make_filename(@file_index))
      $game_temp.last_file_index = @file_index
      return
    end
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Call method: on_cancel (defined by the subclasses)
      on_cancel
      return
    end
    # If the down directional button was pressed
    if Input.repeat?(Input::DOWN)
      # If the down directional button pressed down is not a repeat,
      # or cursor position is more in front than 3
      unless @file_index == 2
        if Input.trigger?(Input::DOWN)
          # Play cursor SE
          $game_system.se_play($data_system.cursor_se)
          # Move cursor down
          @savefile_windows[@file_index].selected = false
          @file_index = (@file_index + 1)
          @savefile_windows[@file_index].selected = true
          return
        end
      end
      # If the up directional button was pressed
      elsif Input.repeat?(Input::UP)
        # If the up directional button pressed down is not a repeat、
        # or cursor position is more in back than 0
        unless @file_index == 0
        if Input.trigger?(Input::UP)
          # Play cursor SE
          $game_system.se_play($data_system.cursor_se)
          # Move cursor up
          @savefile_windows[@file_index].selected = false
          @file_index = (@file_index - 1)
          @savefile_windows[@file_index].selected = true
          return
        end
      end
    end
  end
end