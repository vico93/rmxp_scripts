#==============================================================================
# ■ Cursor Script
#------------------------------------------------------------------------------
# 　Script to display a cursor instead of a highlight box
#   by squall
#   squall@rmxp.ch
#==============================================================================

#==============================================================================
# ■ Cursor_Sprite
#==============================================================================

class Sprite_Cursor < Sprite
  #--------------------------------------------------------------------------
  # ● instances
  #--------------------------------------------------------------------------
  attr_accessor :true_x
  attr_accessor :true_y
  #--------------------------------------------------------------------------
  # ● initialize
  #--------------------------------------------------------------------------
  def initialize(x = 0, y = 0)
    super()
    self.x = @true_x = x
    self.y = @true_y = y
    self.z += 1000
    self.bitmap = RPG::Cache.picture(CT_Pictures::Cursor) rescue Bitmap.new(32, 32)
  end
  #--------------------------------------------------------------------------
  # ● update
  #--------------------------------------------------------------------------
  def update
    super
    
    if self.y < @true_y
      n = (@true_y - self.y) / 3
      n = 1 if n == 0
      self.y += n
    elsif self.y > @true_y
      n = (self.y - @true_y) / 3
      n = 1 if n == 0
      self.y -= n
    end

    if self.x < @true_x
      n = (@true_x - self.x) / 3
      n = 1 if n == 0
      self.x += n
    elsif self.x > @true_x
      n = (self.x - @true_x) / 3
      n = 1 if n == 0
      self.x -= n
    end
  end
end

#==============================================================================
# ■ Window_Selectable
#==============================================================================

class Window_Selectable < Window_Base
  #--------------------------------------------------------------------------
  # ● instances
  #--------------------------------------------------------------------------
  attr_reader   :index
  attr_reader   :help_window
  attr_accessor :cursor
  alias update_cursor_moves update
  #--------------------------------------------------------------------------
  # ● initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item_max = 1
    @column_max = 1
    @index = 0
    @cursor = Sprite_Cursor.new(x, y)
    unless $scene.is_a?(Scene_Menu)
      @cursor.opacity = 0
    end
    update_cursor
  end
  #--------------------------------------------------------------------------
  # ● x=
  #--------------------------------------------------------------------------
  def x=(x)
    super
    @cursor.x = x if !@cursor.nil?
  end
  #--------------------------------------------------------------------------
  # ● y=
  #--------------------------------------------------------------------------
  def y=(y)
    super
    @cursor.y = y if !@cursor.nil?
  end
  #--------------------------------------------------------------------------
  # ● visible=
  #--------------------------------------------------------------------------
  def visible=(visible)
    super
    if !@cursor.nil? and visible == false
      @cursor.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # ● dispose
  #--------------------------------------------------------------------------
  def dispose
    @cursor.dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● update_cursor_rect
  #--------------------------------------------------------------------------
  def update_cursor_rect
    row = @index / @column_max
    if row < self.top_row
      self.top_row = row
    end
    if row > self.top_row + (self.page_row_max - 1)
      self.top_row = row - (self.page_row_max - 1)
    end
    cursor_width = self.width / @column_max - 32
    x = @index % @column_max * (cursor_width + 32)
    y = @index / @column_max * 32 - self.oy
    if $scene.is_a?(Scene_Menu)
      self.cursor_rect.set(x, y, 0, 0)
    else
      self.cursor_rect.set(x, y, cursor_width, 32)
    end
  end
  #--------------------------------------------------------------------------
  # ● update_cursor
  #--------------------------------------------------------------------------
  def update_cursor
    @cursor.true_x = self.cursor_rect.x + self.x - 8
    @cursor.true_y = self.cursor_rect.y + self.y + 16
    @cursor.update
    @cursor.visible = self.visible
  end
  #--------------------------------------------------------------------------
  # ● update
  #--------------------------------------------------------------------------
  def update
    update_cursor_moves
    update_cursor
  end
end