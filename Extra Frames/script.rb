#==============================================================================
# Extra Frames
# por COGHWELL
# http://members.jcom.home.ne.jp/cogwheel/
#==============================================================================
# O script permite que a imagem do character tenha mais que 4 frames.
#
# Para definir a quantidade de frames basta definir o nome adicione [X]
# ao seu nome, onde X é o numero de frames.
#
# Ex.:
# 001-Fighter01[7].png
#
# Isto significa que o 001-Fighter01 terá 7 frames
#==============================================================================

#==============================================================================
# ¦ Game_Character
#==============================================================================
class Game_Character
  #--------------------------------------------------------------------------
  def update
    if jumping?
      update_jump
    elsif moving?
      update_move
    else
      update_stop
    end
    if @character_name[/\[(\d+)\]/]
      @anime_count = 20 if @anime_count > 0 and @pattern == @original_pattern
      if @anime_count * ($1.to_i - 1) / 4 > 18 - @move_speed * 2
        if not @step_anime and @stop_count > 0
          @pattern = @original_pattern
        else
          @pattern = @pattern % ($1.to_i - 1) + 1
        end
        @anime_count = 0
      end
    else
      if @anime_count > 18 - @move_speed * 2
        if not @step_anime and @stop_count > 0
          @pattern = @original_pattern
        else
          @pattern = (@pattern + 1) % 4
        end
        @anime_count = 0
      end
    end
    if @wait_count > 0
      @wait_count -= 1
      return
    end
    if @move_route_forcing
      move_type_custom
      return
    end
    if @starting or lock?
      return
    end
    if @stop_count > (40 - @move_frequency * 2) * (6 - @move_frequency)
      case @move_type
      when 1
        move_type_random
      when 2
        move_type_toward_player
      when 3
        move_type_custom
      end
    end
  end
end


#================================================= =============================
# ¦ Sprite_Character
#================================================= =============================
class Sprite_Character < RPG::Sprite
  #--------------------------------------------------------------------------
  def update
    super
    if @tile_id != @character.tile_id or
       @character_name != @character.character_name or
       @character_hue != @character.character_hue
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      @character_hue = @character.character_hue
      if @tile_id >= 384
        self.bitmap = RPG::Cache.tile($game_map.tileset_name,
        @tile_id, @character.character_hue)
        self.src_rect.set(0, 0, 32, 32)
        self.ox = 16
        self.oy = 32
      else
        self.bitmap = RPG::Cache.character(@character.character_name,
        @character.character_hue)
        if @character.character_name[/\[(\d+)\]/]
          @cw = bitmap.width / $1.to_i
          @ch = bitmap.height / 4
        else
          @cw = bitmap.width / 4
          @ch = bitmap.height / 4
        end
        self.ox = @cw / 2
        self.oy = @ch
      end
    end
    self.visible = (not @character.transparent)
    if @tile_id == 0
      sx = @character.pattern * @cw
      sy = (@character.direction - 2) / 2 * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z(@ch)
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
  end
end

#================================================= =============================
# ¦ Window_Base
#================================================= =============================
class Window_Base < Window
  #--------------------------------------------------------------------------
  def draw_actor_graphic(actor, x, y)
    bitmap = RPG::Cache.character(actor.character_name, actor.character_hue)
    if actor.character_name[/\[(\d+)\]/]
      cw = bitmap.width / $1.to_i
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 4
      ch = bitmap.height / 4
    end
    src_rect = Rect.new(0, 0, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end
end

#================================================= =============================
# ¦ Window_SaveFile
#================================================= =============================
class Window_SaveFile < Window_Base
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = normal_color
    name = "File #{@file_index + 1}"
    self.contents.draw_text(4, 0, 600, 32, name)
    @name_width = contents.text_size(name).width
    if @file_exist
      for i in 0...@characters.size
        bitmap = RPG::Cache.character(@characters[i][0], @characters[i][1])
        if @characters[i][0][/\[(\d+)\]/]
          cw = bitmap.width / $1.to_i
          ch = bitmap.height / 4
        else
        cw = bitmap.width / 4
        ch = bitmap.height / 4
      end
      src_rect = Rect.new(0, 0, cw, ch)
      x = 300 - @characters.size * 32 + i * 64 - cw / 2
      self.contents.blt(x, 68 - ch, bitmap, src_rect)
    end
    hour = @total_sec / 60 / 60
    min = @total_sec / 60 % 60
    sec = @total_sec % 60
    time_string = sprintf("%02d:%02d:%02d", hour, min, sec)
    self.contents.font.color = normal_color
    self.contents.draw_text(4, 8, 600, 32, time_string, 2)
    self.contents.font.color = normal_color
    time_string = @time_stamp.strftime("%Y/%m/%d %H:%M")
    self.contents.draw_text(4, 40, 600, 32, time_string, 2)
    end
  end
end

#================================================= =============================
# ¦ Game_Player
#================================================= =============================
class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  def anime_update
    if @character_name[/\[(\d+)\]/]
      @anime_count = 20 if @anime_count > 0 and @pattern == @original_pattern
      if @anime_count * ($1.to_i - 1) / 4 > 18 - @move_speed * 2
        if not @step_anime and @stop_count > 0
          @pattern = @original_pattern
        else
          @pattern = @pattern % ($1.to_i - 1) + 1
        end
        @anime_count = 0
      end
    else
      if @anime_count > 18 - @move_speed * 2
        if not @step_anime and @stop_count > 0
          @pattern = @original_pattern
        else
          @pattern = (@pattern + 1) % 4
        end
        @anime_count = 0
      end
    end
  end
end