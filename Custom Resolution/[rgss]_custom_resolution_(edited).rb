#==============================================================================
# Custom Resolution (DLL-less) 
# Authors: ForeverZer0, KK20, LiTTleDRAgo
# Version: 0.97e
# Date: 11.2.2014
#==============================================================================
# LiTTleDRAgo's Notes
#==============================================================================
#
#  Change Resolution in game :
#      $resolution.change_resolution(width, height)
#
#  Enable / Disable the script : 
#      $resolution.enable(true / false)
#
#  Change Tile in game :
#      $game_map.change_tile(x,y,layer,tile_id)
#
#  Note that X in the notes below means that it's no longer true
#
#  If you're using RGSS3, don't use map larger than 20 x 15 or
#  resolution larger than 640 x 480
#
#==============================================================================
# KK20's Notes
#==============================================================================
# Introduction:
#
#   This script is intended to create screen resolutions other than 640 x 480.
#   The script comes with its own Tilemap rewrite in order to combat larger
#   screen resolutions (because anything beyond 640 x 480 is not drawn).
#
# Instructions:
#
#   Place script above 'Main'. Probably best to put it below all your other
#   custom scripts.
#   This version does not require the 'screenshot.dll'.
#
# Things to Consider:
#
#  X Fullscreen will change the resolution back to 640 x 480. A solution is in
#    the works.
#  - Transitions do not work properly on larger resolutions. You can use a
#    Transitions Add-Ons script if you want better transitions (otherwise, all
#    you will get is the default fade in/out). Links listed below.
#  - Custom scripts that draw windows to the screen will probably need edits.
#  - Larger resolutions = more processing power = more lag
#
#
#  ***************************************************************************
#  * THIS IS STILL A WORK IN PROGRESS; IF YOU FIND ANYTHING PLEASE REPORT IT *
#  ***************************************************************************
#
#  Links:
#  - Fantasist's Transitions Pack
#    http://forum.chaos-project.com/index.php/topic,1390.0.html
#  - ForeverZer0's Add-ons
#    http://forum.chaos-project.com/index.php/topic,7862.0.html
#  - ThallionDarkshine's Add-ons
#    http://forum.chaos-project.com/index.php/topic,12655.0.html
#  - Drago Transition Pack
#    http://forum.chaos-project.com/index.php/topic,13488.0.html
#
#==============================================================================
# ForeverZer0's Notes from v0.93                   (outdated information)
#==============================================================================
# Introduction:
#
#   My goal in creating this script was to create a system that allowed the 
#   user to set the screen size to something other than 640 x 480, but not have
#   make huge sacrifices in compatibility and performance. Although the script
#   is not simply Plug-and-Play, it is about as close as one can achieve with a
#   script of this nature.
#
# Instructions:
#
#  X Place the "screenshot.dll" from Fantasist's Transition Pack script, which
#    can be found here: http://sendspace.com/file/yjd54h in your game folder
#  - Place this script above main, below default scripts.
#  - In my experience, unchecking "Reduce Screen Flickering" actually helps 
#    the screen not to flicker. Open menu with F1 while playing and set this 
#    to what you get the best results with.
#
# Features:
#  
#  X Totally re-written Tilemap and Plane class. Both classes were written to
#    display the map across any screen size automatically. The Tilemap class
#    is probably even more efficient than the original, which will help offset
#    any increased lag due to using a larger screen size with more sprites
#    being displayed.
#  - Every possible autotile graphic (48 per autotile) will be cached for the
#    next time that tile is used.
#  - Autotile animation has been made as efficient as possible, with a system
#    that stores their coodinates, but only if they change. This greatly 
#    reduces the number of iterations at each update.
#  X System creates an external file to save pre-cached data priorities and
#    autotiles. This will decrease any loading times even more, and only takes
#    a second, depending on the number of maps you have.
#  - User defined autotile animation speed. Can change with script calls.
#  - Automatic re-sizing of Bitmaps and Viewports that are 640 x 480 to the
#    defined resolution, unless explicitely over-ridden in the method call.
#    The graphics themselves will not be resized, but any existing scripts that
#    use the normal screen size will already be configured to display different
#    sizes of graphics for transitions, battlebacks, pictures, fogs, etc.
#  X Option to have a log file ouput each time the game is ran, which can alert
#    you to possible errors with map sizes, etc.
#
# Issues/Bugs/Possible Bugs:
#
#   - Graphic related scripts and your graphics will need to be customized to
#     fit the new screen size, so this script is not for everyone.
#   X The Z-axis for the Plane class, which is used for Fogs and Panoramas has
#     been altered. It is now multiplied by 1000. This will likely be a minor
#     issue for most, since this class is very rarely used except for Fogs and
#     Panoramas, which are already far above and below respectfully.
#   - Normal transitions using graphics cannot be used. With the exception of
#     a standard fade, like that used when no graphic is defined will be used.
#     Aside from that, only special transitions from Transition Pack can be
#     used.
#==============================================================================
#  Credits/Thanks:
#  - ForeverZer0, for script.
#  - Creators of the Transition Pack and Screenshot.dll
#  - Selwyn, for base resolution script
#  - KK20, for Version 0.94 and above and the Tilemap class
#  - LiTTleDRAgo, for Core Engine script to remove screenshot.dll dependency
#==============================================================================
#                             CONFIGURATION
#==============================================================================
 
  SCREEN = [1024,576]
  # Define the resolution of the game screen. These values can be anything
  # within reason. Centering, viewports, etc. will all be taken care of, but it
  # is recommended that you use values divisible by 32 for best results.
 
  UPDATE_COUNT = 8
  # Define the number of frames between autotile updates. The lower the number,
  # the faster the animations cycle. This can be changed in-game with the
  # following script call: $game_map.autotile_speed = SPEED
 
  USE_CR_SPRITE = true
  # Replace unused sprite in tilemap with a dummy, still in experimental phase.
  
  
#==============================================================================
# ** Resolution
#------------------------------------------------------------------------------
#  
#==============================================================================

class Resolution
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader :version, :width, :height
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    # Define version.
    @version = 0.975
    # Set instance variables for calling basic Win32 functions.
    ini = Win32API.new('kernel32', 'GetPrivateProfileString','PPPPLP', 'L')
    ini.call('Game', 'Title', '', (title = "\0" * 256), 256, '.\\Game.ini')
    title.delete!("\0")
    @window   = LiTTleDRAgo.hwnd
    @metrics  = Win32API.new('user32', 'GetSystemMetrics', 'I', 'I')
    # Set default size, displaying error if size is larger than the hardware.
    default_size = self.size
    if default_size[0] < SCREEN[0] || default_size[1] < SCREEN[1]
      print("\"#{title}\" requires a minimum screen resolution of "+
            "[#{SCREEN[0]} x #{SCREEN[1]}]\r\n\r\n" +
            "\tYour Resolution: [#{default_size[0]} x #{default_size[1]}]")
      exit
    end
    # Apply resolution change.
    enable(true)   
  end
  #--------------------------------------------------------------------------
  # * Returns the screen size of the machine.
  #--------------------------------------------------------------------------
  def size
    return [@metrics.call(0), @metrics.call(1)]
  end
  #--------------------------------------------------------------------------
  # * Enable / Disable the resolution script
  #--------------------------------------------------------------------------
  def enable(value = true)
    value && !@enable && change_resolution(SCREEN[0], SCREEN[1])
    unless $imported[:drg_custom_resolution]
      !value && @enable && change_resolution(640,480) 
    end
    @enable = value
  end
  #--------------------------------------------------------------------------
  # * Returns true if resolution is enabled
  #--------------------------------------------------------------------------
  def enabled?
    @enable
  end
  #--------------------------------------------------------------------------
  # * Returns the fullscreen state
  #--------------------------------------------------------------------------
  def fullscreen?
    size.at(0) == Graphics.width
  end
  #--------------------------------------------------------------------------
  # * Change the resolution size
  #--------------------------------------------------------------------------
  unless method_defined?(:change_resolution)
    def change_resolution(w = @width, h = @height)
      @set_window_long ||= Win32API.new('user32', 'SetWindowLong', 'lil','L')
      @set_window_pos  ||= Win32API.new('user32', 'SetWindowPos','lliiiii','I')
      w, h = (w / 32.0).ceil * 32, (h / 32.0).ceil * 32
      x, y = (size[0] - w) / 2, (size[1] - h) / 2
      if Graphics.respond_to?(:resize_screen)
        Graphics.resize_screen(w,h)
      else
        @set_window_pos.call(@window, 0, x, y, w + 6, h + 26, 0)
      end
      @set_window_long.call(@window, -16, 0x14CA0000)
      @width, @height = w, h  if @width != w || @height != h
      Graphics.check_center_player
    end
  end
  #--------------------------------------------------------------------------
end
 
#==============================================================================
# ** Drago - Core Engine
# Version : 1.39
# Contact : littledrago.blogspot.com / forum.chaos-project.com
#==============================================================================

module LiTTleDRAgo
  #-------------------------------------------------------------------------
  # * Constant
  #-------------------------------------------------------------------------
  VX           = defined?(Window_ActorCommand)
  VXA          = defined?(Window_BattleActor)
  RGSS1        = defined?(Hangup)
  RGSS2        = RUBY_VERSION == '1.8.1' && !RGSS1
  RGSS3        = RUBY_VERSION == '1.9.2'
  APPPATHDRAGO = "#{ENV['APPDATA']}/Drago/"
end

$imported ||= {}
#==============================================================================
# ** CoreDLL
#------------------------------------------------------------------------------
#  
#==============================================================================
module CoreDLL
  #-------------------------------------------------------------------------
  # * Constant
  #-------------------------------------------------------------------------
  Rtlmemory_pi = Win32API.new('kernel32','RtlMoveMemory','pii','i')
  Rtlmemory_ip = Win32API.new('kernel32','RtlMoveMemory','ipi','i')
  #-------------------------------------------------------------------------
  # * Get the game window handle (specific to game)
  #-------------------------------------------------------------------------
  unless method_defined?(:hwnd)
    def hwnd
      @window_find ||= Win32API.new('user32', 'FindWindowEx', %w(l l p p), 'i')
      @game_window ||= @window_find.call(0,0,"RGSS Player",0)
      return @game_window
    end  
  end
  #-------------------------------------------------------------------------
  # * Get the Game Window's width and height
  #-------------------------------------------------------------------------
  unless method_defined?(:client_size)
    def client_size
      @window_c_rect ||= Win32API.new('user32', 'GetClientRect', %w(l p), 'i')
      @window_c_rect.call(self.hwnd, (rect = [0, 0, 0, 0].pack('l4')))
      right, bottom = rect.unpack('l4')[2..3]
      return right, bottom
    end  
  end
  #--------------------------------------------------------------------------
  # * snap_to_bitmap
  #--------------------------------------------------------------------------
  unless method_defined?(:snap_to_bitmap)
    def snap_to_bitmap
      @getdc       ||= Win32API.new('user32','GetDC','i','i')
      @ccdc        ||= Win32API.new('gdi32','CreateCompatibleDC','i','i')
      @ccbitmap    ||= Win32API.new('gdi32','CreateCompatibleBitmap','iii','i')
      @deleteobject||= Win32API.new('gdi32','DeleteObject','i','i')
      @bitblt      ||= Win32API.new('gdi32','BitBlt','iiiiiiiii','i')
      @setdibits   ||= Win32API.new('gdi32','SetDIBits','iiiiipi','i')
      @getdibits   ||= Win32API.new('gdi32','GetDIBits','iiiiipi','i')
      @selectobject||= Win32API.new('gdi32','SelectObject','ii','i')
      bitmap = Bitmap.new((width = Graphics.width), (height = Graphics.height))
      info   = [40,width,height,1,32,0,0,0,0,0,0].pack('LllSSLLllLL')
      hDC    = @ccdc.call((dc = @getdc.call(hwnd)))
      hBM    = @ccbitmap.call(dc, width, height)
      @deleteobject.call(@selectobject.call(hDC, hBM))
      @setdibits.call(hDC, hBM, 0, height, (address = bitmap.address), info, 0)
      @bitblt.call(hDC, 0, 0, width, height, dc, 0, 0, 0xCC0020)
      @getdibits.call(hDC, hBM, 0, height, address, info, 0)
      @deleteobject.call(hBM)
      @deleteobject.call(hDC)
      bitmap
    end     
  end
end                        
LiTTleDRAgo.extend(CoreDLL)
 
#==============================================================================
# ** Graphics
#------------------------------------------------------------------------------
#  This module handles all Graphics
#==============================================================================
class << Graphics
  #--------------------------------------------------------------------------
  # ● Redefined method: width
  #--------------------------------------------------------------------------
  unless method_defined?(:width)
    def width
      LiTTleDRAgo.client_size.at(0)
    end
  end
  #--------------------------------------------------------------------------
  # ● Redefined method: height
  #--------------------------------------------------------------------------
  unless method_defined?(:height)
    def height
      LiTTleDRAgo.client_size.at(1) 
    end
  end
  #--------------------------------------------------------------------------
  # ● Redefined method: snap_to_bitmap
  #--------------------------------------------------------------------------
  unless method_defined?(:snap_to_bitmap)
    def snap_to_bitmap
      LiTTleDRAgo.snap_to_bitmap 
    end
  end
end
#==============================================================================
# ■ Bitmap
#------------------------------------------------------------------------------
#
#==============================================================================
class Bitmap  
  #----------------------------------------------------------------------------
  # ● Constant
  #----------------------------------------------------------------------------
  RtlMoveMemory_pi = CoreDLL::Rtlmemory_pi
  RtlMoveMemory_ip = CoreDLL::Rtlmemory_ip
  #----------------------------------------------------------------------------
  # ● New method: address
  #----------------------------------------------------------------------------
  unless method_defined?(:address)
    def address
      @address ||= (
        RtlMoveMemory_pi.call(a="\0"*4, __id__*2+16, 4)
        RtlMoveMemory_pi.call(a, a.unpack('L')[0]+8, 4)
        RtlMoveMemory_pi.call(a, a.unpack('L')[0]+16, 4)
        a.unpack('L')[0]
      )
    end
  end
end
#==============================================================================
# **                                               END OF Drago - Core Engine
#==============================================================================
 
#==============================================================================
# ** Graphics
#------------------------------------------------------------------------------
#  This module handles all Graphics
#==============================================================================
class << Graphics
  #---------------------------------------------------------------------------
  # * Method check
  #---------------------------------------------------------------------------
  unless method_defined?(:zer0_graphics_transition)
    #-------------------------------------------------------------------------
    # * Alias Listing
    #-------------------------------------------------------------------------
    alias_method(:zer0_graphics_transition, :transition)     
    #-------------------------------------------------------------------------
    # * Aliased method: transition
    #-------------------------------------------------------------------------
    def transition(duration = 8, *args)
      # Call default transition if no instance of the resolution is defined.
      if $resolution == nil || default_resolution? ||
        !$resolution.enabled? && !$imported[:drg_custom_resolution]
        zer0_graphics_transition(duration, *args)
      else
        # Skip this section and instantly transition graphics if duration is 0.
        if duration > 0
          # Take a snapshot of the the screen, overlaying screen with graphic.
          #$resolution.snapshot
          zer0_graphics_transition(0)
          # Create screen instance
          viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
          sprite = Sprite.new(viewport)
          sprite.bitmap = Graphics.snap_to_bitmap
          # Use a simple fade if transition is not defined.
          fade = 255 / duration
          duration.times { (sprite.opacity -= fade) && update }
          # Dispose sprite and delete snapshot file.
          [sprite, sprite.bitmap, viewport].each {|obj| obj.dispose }
        end
        zer0_graphics_transition(0)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Alias Listing
  #--------------------------------------------------------------------------
  unless method_defined?(:drg_spriteset_viewport_adjust)
    alias_method :drg_spriteset_viewport_adjust, :update
    #--------------------------------------------------------------------------
    # * Aliased method: update
    #--------------------------------------------------------------------------
    def update(*args)
      check_center_player 
      drg_spriteset_viewport_adjust(*args)
    end
    #--------------------------------------------------------------------------
    # * New method: check_center_player
    #--------------------------------------------------------------------------
    def check_center_player
      return unless $resolution
      return unless Game_Player.const_defined?(:CENTER_X)
      $resolution.change_resolution if !$resolution.fullscreen? && 
      viewport_size_change?
      unless Game_Player.const_get(:CENTER_X) == center_x
        Game_Player.const_set(:CENTER_X,  center_x)
        Game_Player.const_set(:CENTER_Y,  center_y)
        $game_player && $game_player.center($game_player.x,$game_player.y)
      end
    end
    #--------------------------------------------------------------------------
    # * X Coordinate of Screen Center
    #--------------------------------------------------------------------------
    def center_x
      zoom_x = $game_map.respond_to?(:zoom_x) ? $game_map.zoom_x : 1
      return ((Graphics.width / 2) / zoom_x - 16).ceil * 4
    end
    #--------------------------------------------------------------------------
    # * Y Coordinate of Screen Center
    #--------------------------------------------------------------------------
    def center_y
      zoom_y = $game_map.respond_to?(:zoom_y) ? $game_map.zoom_y : 1
      return ((Graphics.height / 2) / zoom_y - 16).ceil * 4
    end
    #--------------------------------------------------------------------------
    # * New method: viewport_size_change?
    #--------------------------------------------------------------------------
    def viewport_size_change?
      return false unless $resolution
      return false if $resolution.fullscreen? 
      return true if (Graphics.width  - $resolution.width).abs  > 30
      return true if (Graphics.height - $resolution.height).abs > 30
    end
  end
  #--------------------------------------------------------------------------
  # * New method: default_resolution?
  #--------------------------------------------------------------------------
  def default_resolution?
    width <= 640 && height <= 480
  end
end  
 
#==============================================================================
# ** RPG::Cache
#==============================================================================
ModCache = LiTTleDRAgo::VX ? Cache : RPG::Cache
module ModCache
  #-------------------------------------------------------------------------
  # * Self
  #-------------------------------------------------------------------------
  class << self
    #---------------------------------------------------------------------------
    # * Constant
    #---------------------------------------------------------------------------
    AUTO_INDEX = [
      [27,28,33,34],  [5,28,33,34],  [27,6,33,34],  [5,6,33,34],
      [27,28,33,12],  [5,28,33,12],  [27,6,33,12],  [5,6,33,12],
      [27,28,11,34],  [5,28,11,34],  [27,6,11,34],  [5,6,11,34],
      [27,28,11,12],  [5,28,11,12],  [27,6,11,12],  [5,6,11,12],
      [25,26,31,32],  [25,6,31,32],  [25,26,31,12], [25,6,31,12],
      [15,16,21,22],  [15,16,21,12], [15,16,11,22], [15,16,11,12],
      [29,30,35,36],  [29,30,11,36], [5,30,35,36],  [5,30,11,36],
      [39,40,45,46],  [5,40,45,46],  [39,6,45,46],  [5,6,45,46],
      [25,30,31,36],  [15,16,45,46], [13,14,19,20], [13,14,19,12],
      [17,18,23,24],  [17,18,11,24], [41,42,47,48], [5,42,47,48],
      [37,38,43,44],  [37,6,43,44],  [13,18,19,24], [13,14,43,44],
      [37,42,43,48],  [17,18,47,48], [13,18,43,48], [1,2,7,8]
    ].freeze
    #---------------------------------------------------------------------------
    # * Alias Listing
    #---------------------------------------------------------------------------
    if method_defined?(:autotile)
      $@ || alias_method(:autotile_cr_tilemap, :autotile)
    end
    #---------------------------------------------------------------------------
    # * Aliased method: autotile
    #---------------------------------------------------------------------------
    def autotile(filename)
      if respond_to?(:autotile_cr_tilemap)
        return autotile_cr_tilemap(filename) unless $resolution.enabled?
      end
      key = "Graphics/Autotiles/#{filename}"
      if !@cache.include?(key) || @cache[key].disposed?
        # Cache the autotile graphic.
        @cache[key] = (filename == '') ? Bitmap.new(128, 96) : Bitmap.new(key)
        # Cache each configuration of this autotile.
        new_bm = self.format_autotiles(@cache[key], filename)
        @cache[key].dispose
        @cache[key] = new_bm
      end
      return @cache[key]
    end
    #--------------------------------------------------------------------------
    # * New method: include?
    #--------------------------------------------------------------------------
    unless method_defined?(:include?)
      def include?(key)
        @cache[key] && !@cache[key].disposed?
      end 
    end
    #---------------------------------------------------------------------------
    # * New method: format_autotiles
    #---------------------------------------------------------------------------
    def format_autotiles(bitmap, filename)
      if bitmap.height > 32
        frames = bitmap.width / 96
        template = Bitmap.new(256*frames,192)
        # Create a bitmap to use as a template for creation.
        (0..frames-1).each{|frame|
        (0...6).each {|i| (0...8).each {|j| AUTO_INDEX[8*i+j].each {|number|
          number -= 1
          x, y = 16 * (number % 6), 16 * (number / 6)
          rect = Rect.new(x + (frame * 96), y, 16, 16)
          template.blt((32 * j + x % 32) + 
          (frame * 256), 32 * i + y % 32, bitmap, rect)
        }}}}
        return template
      else
        return bitmap
      end
    end
  end
end

#==============================================================================
# ** Tilemap_DataTable
#------------------------------------------------------------------------------
#  
#==============================================================================
class Tilemap_DataTable
  #---------------------------------------------------------------------------
  # * Public Instance Variables
  #---------------------------------------------------------------------------
  attr_accessor :table
  #---------------------------------------------------------------------------
  # * Get tilemap table
  #---------------------------------------------------------------------------
  define_method(:initialize)  {|table| @table = table }
  define_method(:"[]")        {|*args| @table[*args]  }
  define_method(:"[]=")       {|*args| @table[*args[0..-2]] = args.last }
  def method_missing(sym, *a, &blk)  table.send(sym, *a, &blk) end
end
  
#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles the map. It includes scrolling and passable determining
#  functions. Refer to "$game_map" for the instance of this class.
#==============================================================================
 
class Game_Map
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_writer :autotile_speed
  #--------------------------------------------------------------------------
  # * Alias Listing
  #--------------------------------------------------------------------------
  $@ || alias_method(:drg_scroll_up_adjust,    :scroll_up)
  $@ || alias_method(:drg_scroll_left_adjust,  :scroll_left)
  $@ || alias_method(:drg_scroll_down_adjust,  :scroll_down)
  $@ || alias_method(:drg_scroll_right_adjust, :scroll_right)
  #--------------------------------------------------------------------------
  # * Scroll Down
  #--------------------------------------------------------------------------
  def scroll_down(distance)
    times = vxa_map_multiplier
    if loop_vertical?
      @display_y += distance
      @display_y %= height * times
      @parallax_y += distance if @parallax_y && @parallax_loop_y
    else
      last_y = @display_y
      result = [@display_y + distance, map_edge.at(1) / zoom_y].min
      drg_scroll_down_adjust(distance)
      @display_y = result
      @parallax_y += @display_y - last_y if @parallax_y
    end
  end
  #--------------------------------------------------------------------------
  # * Scroll Right
  #--------------------------------------------------------------------------
  def scroll_right(distance)
    times = vxa_map_multiplier
    if loop_horizontal?
      @display_x += distance
      @display_x %= width * times 
      @parallax_x += distance if @parallax_x && @parallax_loop_x
    else
      last_x = @display_x
      result = [@display_x + distance, map_edge.at(0) / zoom_x].min
      drg_scroll_right_adjust(distance)
      @display_x = result
      @parallax_x += @display_x - last_x if @parallax_x
    end
  end
  #--------------------------------------------------------------------------
  # * New method: map_edge
  #--------------------------------------------------------------------------
  def map_edge
    times = vxa_map_multiplier
    [_w = [(width  * zoom_x - screen_tile_x).ceil * times, 0].max,
     _h = [(height * zoom_y - screen_tile_y).ceil * times, 0].max]
  end
  #--------------------------------------------------------------------------
  # * New method: vxa_map_multiplier
  #--------------------------------------------------------------------------
  def vxa_map_multiplier
    LiTTleDRAgo::VXA ? 1 : 128
  end
  #--------------------------------------------------------------------------
  # * New method: change_tile
  #--------------------------------------------------------------------------
  def change_tile(x, y, z, tile_id = 0)
    data[x,y,z] = tile_id    
    spriteset.tilemap.map_data = data if spriteset.is_a?(Spriteset_Map)
  end
  #--------------------------------------------------------------------------
  # * New method: spriteset
  #--------------------------------------------------------------------------
  unless method_defined?(:spriteset)
    define_method(:spriteset) { $scene.instance_variable_get(:@spriteset) }
  end
  #--------------------------------------------------------------------------
  # * New method: screen_tile_x
  #--------------------------------------------------------------------------
  unless method_defined?(:screen_tile_x)
    define_method(:screen_tile_x) {(Graphics.width  / 32.0).ceil}
  end
  #--------------------------------------------------------------------------
  # * New method: screen_tile_y
  #--------------------------------------------------------------------------
  unless method_defined?(:screen_tile_y)
    define_method(:screen_tile_y) {(Graphics.height / 32.0).ceil}
  end
  #--------------------------------------------------------------------------
  # * New method: autotile_speed, zoom_x, zoom_y
  #--------------------------------------------------------------------------
  define_method(:autotile_speed) { [@autotile_speed ||= UPDATE_COUNT, 1].max }
  define_method(:zoom_x) { resolution_enabled? ? (@zoom_x ||= 1) : 1 }
  define_method(:zoom_y) { resolution_enabled? ? (@zoom_y ||= 1) : 1 }
  define_method(:resolution_enabled?) { $resolution && $resolution.enabled? }
  method_defined?(:loop_horizontal?) || define_method(:loop_horizontal?) {}
  method_defined?(:loop_vertical?)   || define_method(:loop_vertical?)   {}
end
 
#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles the player. Its functions include event starting
#  determinants and map scrolling. Refer to "$game_player" for the one
#  instance of this class.
#==============================================================================
 
class Game_Player
  #--------------------------------------------------------------------------
  # * Alias Listing
  #--------------------------------------------------------------------------
  $@ || alias_method(:drg_adjust_viewport_center, :center)
  #--------------------------------------------------------------------------
  # * Aliased method: center
  #--------------------------------------------------------------------------
  def center(x, y)
    drg_adjust_viewport_center(x, y)
    # Recalculate the screen center based on the new resolution.   
    max_x = $game_map.map_edge.at(0) / $game_map.zoom_x
    max_y = $game_map.map_edge.at(1) / $game_map.zoom_y
    $game_map.display_x = [0, [(x * 32*4) - center_x, max_x.ceil].min].max
    $game_map.display_y = [0, [(y * 32*4) - center_y, max_y.ceil].min].max
    if $game_map.spriteset.is_a?(Spriteset_Map) && 
      $game_map.spriteset.tilemap.is_a?(CRTilemap)
      $game_map.spriteset.tilemap.refresh
    end
  end  
  #--------------------------------------------------------------------------
  # * X Coordinate of Screen Center
  #--------------------------------------------------------------------------
  def center_x
    Graphics.center_x
  end
  #--------------------------------------------------------------------------
  # * Y Coordinate of Screen Center
  #--------------------------------------------------------------------------
  def center_y
    Graphics.center_y
  end
end
 
#==============================================================================
# ** Viewport
#------------------------------------------------------------------------------
#  
#==============================================================================
class Viewport
  #--------------------------------------------------------------------------
  # * Alias Listing
  #--------------------------------------------------------------------------
  $@ || alias_method(:zer0_viewport_resize_init, :initialize)
  #--------------------------------------------------------------------------
  # * Aliased method: initialize
  #--------------------------------------------------------------------------
  def initialize(*args)
    default = Rect.new(0, 0, Graphics.width, Graphics.height)
    if args.size == 0 || args == [0, 0, 640, 480]
      # If argument is nil, use default resolution.
      zer0_viewport_resize_init(default)
    else
      # Call method normally.
      zer0_viewport_resize_init(*args)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: resize
  #--------------------------------------------------------------------------
  unless method_defined?(:resize)
    def resize(*args)
      # Resize the viewport. Can call with (X, Y, WIDTH, HEIGHT) or (RECT).
      self.rect = args[0].is_a?(Rect) ? args[0] : Rect.new(*args)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_viewport_sizes
  #--------------------------------------------------------------------------
  def update_viewport_sizes
    map = $game_map
    w, h = Graphics.width, Graphics.height
    hor = $game_map.loop_horizontal?
    ver = $game_map.loop_vertical?
    _w = $game_map.width * 32 * $game_map.zoom_x
    _h = $game_map.height * 32 * $game_map.zoom_y
    _w, _h = 640, 480 unless $game_map.resolution_enabled?
    dx = w > _w && !hor ? (w - _w) / 2 : 0
    dw = hor ? w : [w, $game_map.width  * 32 * $game_map.zoom_x].min  
    dy = h > _h && !ver ? (h - _h) / 2 : 0
    dh = ver ? h : [h, $game_map.height * 32 * $game_map.zoom_y].min 
    resize(Rect.new(dx, dy, dw, dh))
  end
end
 
#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
#  This class brings together map screen sprites, tilemaps, etc.
#  It's used within the Scene_Map class.
#==============================================================================
class Spriteset_Map
  #--------------------------------------------------------------------------
  # * Public Instance Variable
  #--------------------------------------------------------------------------
  attr_reader :tilemap
  #--------------------------------------------------------------------------
  # * Alias Listing 
  #--------------------------------------------------------------------------
  # Checked whether :drg_spriteset_viewport_adjust is already exist
  # Drago - Core Engine already has this method
  unless method_defined?(:drg_spriteset_viewport_adjust)
    # Method Aliasing
    alias_method :drg_spriteset_viewport_adjust, :update
  end
  #--------------------------------------------------------------------------
  # * Aliased method: update
  #--------------------------------------------------------------------------
  def update(*args)
    # If resolution is changing
    if viewport_size_change?
      @viewport_map_width     = $game_map.width * $game_map.zoom_x
      @viewport_map_height    = $game_map.height * $game_map.zoom_y
      @viewport_screen_width  = Graphics.width
      @viewport_screen_height = Graphics.height
      # Change all viewport resolution 
      [@viewport1,@viewport2,@viewport3].each { |v| v.update_viewport_sizes }
    end
    weather_fix_custom_resolution 
    update_tilemap_zoom 
    drg_spriteset_viewport_adjust(*args)
  end
  #--------------------------------------------------------------------------
  # * New method: viewport_size_change?
  #--------------------------------------------------------------------------
  def viewport_size_change?
    return true if @viewport_map_width   != $game_map.width  * $game_map.zoom_x
    return true if @viewport_map_height  != $game_map.height * $game_map.zoom_y
    return true if @viewport_screen_width  != Graphics.width
    return true if @viewport_screen_height != Graphics.height
  end
  #--------------------------------------------------------------------------
  # * New method: reload_tilemap
  #--------------------------------------------------------------------------
  def reload_tilemap
    @tilemap.respond_to?(:dispose) && @tilemap.dispose
    for i in 0..6
      @tilemap.autotiles[i].respond_to?(:dispose) && 
      @tilemap.autotiles[i].dispose
    end
    res = resolution_enabled?
    @tilemap = res ? CRTilemap.new(@viewport1) : Tilemap.new(@viewport1)
    @tilemap.tileset = ModCache.tileset($game_map.tileset_name)
    for i in 0..6
      autotile_name = $game_map.autotile_names[i]
      @tilemap.autotiles[i] = ModCache.autotile(autotile_name)
    end
    @tilemap.map_data = $game_map.data
    @tilemap.priorities = $game_map.priorities
    @tilemap.update
    @viewport_screen_width = 0
  end    
  #--------------------------------------------------------------------------
  # * New method: reload_plane
  #--------------------------------------------------------------------------
  def reload_plane
    z1  = @panorama.respond_to?(:z) ? @panorama.z : -1000
    z2  = @fog.respond_to?(:z)      ? @fog.z      :  5000
    z1 /= 1000 if @panorama.is_a?(CRPlane)
    z2 /= 1000 if @fog.is_a?(CRPlane)
    res = resolution_enabled? && !Graphics.default_resolution?
    bitmap1 = @panorama.respond_to?(:bitmap) ? @panorama.bitmap : nil
    bitmap2 = @fog.respond_to?(:bitmap) ? @fog.bitmap : nil
    @panorama.respond_to?(:dispose) && @panorama.dispose 
    @fog.respond_to?(:dispose) && @fog.dispose      
    p = @panorama = res ? CRPlane.new(@viewport1) : Plane.new(@viewport1)
    f = @fog      = res ? CRPlane.new(@viewport1) : Plane.new(@viewport1)
    p.bitmap = bitmap1 if bitmap1.is_a?(Bitmap)
    f.bitmap = bitmap2 if bitmap2.is_a?(Bitmap)
    p.z, f.z = z1, z2
    @viewport_screen_width = 0
  end
  #--------------------------------------------------------------------------
  # * New method: update_tilemap_zoom
  #--------------------------------------------------------------------------
  def update_tilemap_zoom
    return unless @tilemap.respond_to?(:zoom_x=)
    @tilemap.zoom_x = $game_map.zoom_x
    @tilemap.zoom_y = $game_map.zoom_y
    @weather.zoom_x = $game_map.zoom_x
    @weather.zoom_y = $game_map.zoom_y
  end
  #--------------------------------------------------------------------------
  # * New method: weather_fix_custom_resolution
  #--------------------------------------------------------------------------
  def weather_fix_custom_resolution
    if resolution_enabled? 
      reload_tilemap if @tilemap.is_a?(Tilemap)
    else
      reload_tilemap if @tilemap.is_a?(CRTilemap)
    end
    if resolution_enabled? && !Graphics.default_resolution?
      reload_plane   if @panorama.is_a?(Plane)   || @fog.is_a?(Plane)
    else
      reload_plane   if @panorama.is_a?(CRPlane) || @fog.is_a?(CRPlane)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: resolution_enabled?
  #--------------------------------------------------------------------------
  def resolution_enabled?
    $game_map.resolution_enabled? 
  end
end

#==============================================================================
# ** RPG::Weather
#------------------------------------------------------------------------------
#  A class for weather effects (rain, storm, and snow). It is used within the
# Spriteset_Map class.
#==============================================================================
CRWeather = LiTTleDRAgo::VX ? Spriteset_Weather : RPG::Weather
class CRWeather
  #--------------------------------------------------------------------------
  # * Public Instance Variable
  #--------------------------------------------------------------------------
  attr_reader :viewport
  attr_accessor :zoom_x, :zoom_y
  #--------------------------------------------------------------------------
  # * Alias Listing
  #--------------------------------------------------------------------------
  $@ || alias_method(:init_custom_resolution, :initialize)
  #--------------------------------------------------------------------------
  # * Aliased method: initialize
  #--------------------------------------------------------------------------
  def initialize(viewport)
    @viewport = viewport
    init_custom_resolution(@viewport)
  end
  #--------------------------------------------------------------------------
  # * Overwriten method: update
  #--------------------------------------------------------------------------
  def update
    return if @type == 0
    update_screen if respond_to?(:update_screen)
    @sprites.each {|sprite| update_sprite(sprite) }
  end
  #--------------------------------------------------------------------------
  # * Update Sprite
  #--------------------------------------------------------------------------
  def update_sprite(sprite)
    sprite.ox = @ox
    sprite.oy = @oy
    case @type
    when 1, :rain  then update_sprite_rain(sprite)
    when 2, :storm then update_sprite_storm(sprite)
    when 3, :snow  then update_sprite_snow(sprite)
    end
    create_new_particle(sprite) if sprite.opacity < 64
  end
  #--------------------------------------------------------------------------
  # * Update Sprite [Rain]
  #--------------------------------------------------------------------------
  def update_sprite_rain(sprite)
    sprite.bitmap = @rain_bitmap
    sprite.x -= 2 * sprite.zoom_x
    sprite.y += 16 * sprite.zoom_y
    sprite.opacity -= 8
  end
  #--------------------------------------------------------------------------
  # * Update Sprite [Storm]
  #--------------------------------------------------------------------------
  def update_sprite_storm(sprite)
    sprite.bitmap = @storm_bitmap
    sprite.x -= 8 * sprite.zoom_x
    sprite.y += 16 * sprite.zoom_y
    sprite.opacity -= 12
  end
  #--------------------------------------------------------------------------
  # * Update Sprite [Snow]
  #--------------------------------------------------------------------------
  def update_sprite_snow(sprite)
    sprite.bitmap = @snow_bitmap
    sprite.x -= 2 * sprite.zoom_x
    sprite.y += 8 * sprite.zoom_y
    sprite.opacity -= 8
  end
  #--------------------------------------------------------------------------
  # * Create New Particle
  #--------------------------------------------------------------------------
  def create_new_particle(sprite)
    sprite.x = rand(Graphics.width + 100) - 100 + @ox
    sprite.y = rand(Graphics.height + 200) - 200 + @oy
    sprite.zoom_x = @zoom_x || 1
    sprite.zoom_y = @zoom_y || 1
    sprite.x *= sprite.zoom_x
    sprite.y *= sprite.zoom_y
    sprite.opacity = 160 + rand(96)
  end
  #---------------------------------------------------------------------------
  # * New method: method_missing
  #---------------------------------------------------------------------------
  def method_missing(val,*a,&b)
    en = @sprites.flatten.find_all {|s|s.respond_to?(val.to_sym)}
    if en.empty? 
      text = "Undefined method #{val} at #{self.inspect}"
      raise(NoMethodError,text,caller(1)) 
    end
    return en.map {|s| s.send(val.to_sym,*a,&b)}
  end  
end
  
#==============================================================================
# ** Plane
#------------------------------------------------------------------------------
#  This class is the rewrite of the default plane class
#==============================================================================
 
class CRPlane < Sprite
  #---------------------------------------------------------------------------
  # * Public Instance Variable
  #---------------------------------------------------------------------------
  attr_reader :bitmap
  #---------------------------------------------------------------------------
  # * New method: z=
  #---------------------------------------------------------------------------
  def z=(z)
    # Change the Z value of the viewport, not the sprite.
    super(z * 1000)
  end
  #---------------------------------------------------------------------------
  # * New method: ox=
  #---------------------------------------------------------------------------
  def ox=(ox)
    # Have viewport stay in loop on X-axis.
    super(ox % bitmap.width)  if bitmap.is_a?(Bitmap)
  end
  #---------------------------------------------------------------------------
  # * New method: oy=
  #---------------------------------------------------------------------------
  def oy=(oy)
    # Have viewport stay in loop on Y-axis.
    super(oy % bitmap.height) if bitmap.is_a?(Bitmap)
  end
  #---------------------------------------------------------------------------
  # * New method: bitmap=
  #---------------------------------------------------------------------------
  def bitmap=(tile)
    return if @bitmap == tile
    @bitmap = tile
    if bitmap.is_a?(Bitmap)
      # Calculate the number of tiles to span screen in both directions.
      xx = 1 + (Graphics.width.to_f  / tile.width).ceil
      yy = 1 + (Graphics.height.to_f / tile.height).ceil
      # Create appropriately sized bitmap, then tile with source image.
      plane = Bitmap.new(@bitmap.width * xx, @bitmap.height * yy)
      (0..xx).each {|x| (0..yy).each {|y|
        plane.blt(x * @bitmap.width, y * @bitmap.height, @bitmap, @bitmap.rect)
      }}
      # Set the bitmap to the sprite through its super class (Sprite).
      super(plane)
    end
  end
  #---------------------------------------------------------------------------
  # * Undefine methods dealing with coordinates to do nothing.
  #---------------------------------------------------------------------------
  undef :x, :x=, :y, :y=   if method_defined?(:x)
end

#==============================================================================
# ** Tilemap
#------------------------------------------------------------------------------
#  
#==============================================================================
class Tilemap
  #---------------------------------------------------------------------------
  # * Public Instance Variables
  #---------------------------------------------------------------------------
  method_defined?(:tileset)   || attr_accessor(:tileset)
  method_defined?(:priorities)|| attr_accessor(:priorities)
  method_defined?(:autotiles) || define_method(:autotiles){ @autotiles ||= [] }
end


#==============================================================================
# ** CRTilemap
#------------------------------------------------------------------------------
#  This class is the rewrite of the default tilemap class
#==============================================================================

class CRTilemap
  #---------------------------------------------------------------------------
  # * Constant
  #---------------------------------------------------------------------------
  CRSprite = Struct.new(:x,:y,:z,:tsprite_id,:tone,:bitmap,:update,:dispose)
  #---------------------------------------------------------------------------
  # * Public Instance Variables
  #---------------------------------------------------------------------------
  attr_reader   :map_data, :ox, :oy, :viewport, :tile_sprites, :zoom_x, :zoom_y
  attr_accessor :tileset, :autotiles, :priorities, :tone
  #---------------------------------------------------------------------------
  # * Tilemap width and height
  #---------------------------------------------------------------------------
  define_method(:width)  { $game_map.screen_tile_x + 2 }
  define_method(:height) { $game_map.screen_tile_y + 2 }
  #---------------------------------------------------------------------------
  # Object Initialization
  #---------------------------------------------------------------------------
  def initialize(viewport)
    # Initialize instance variables to store required data.
    @viewport, @autotiles, @tile_sprites = viewport, [], []
    @current_frame, @total_frames = [], []
    # Get priority data for this tileset from instance of Game_Map.
    @priorities = $game_map.priorities
    # Holds all the Sprite instances of animating tiles 
    # (keys based on tile's ID)
    @animating_tiles = {} 
    # Game map's x/y location of the top left corner tile
    @zoom_x = @zoom_y = @ox = @oy = 1
  end
  #---------------------------------------------------------------------------
  # Makes update to ox and oy. Sprites out of range will be moved based on 
  # these two values.
  #---------------------------------------------------------------------------
  def ox=(ox)
    return if @ox == ox && !@ox_refresh
    @ox_refresh = false
    shift   = (@ox - ox) * @zoom_x
    width   = self.width
    height  = self.height
    count   = (@ox = ox) * 0
    sign    = (shift < 0 ? 1 : -1)
    c_index = @corner_index
    @tile_sprites.flatten.each {|tile| tile.x += shift }
    while (sprite = @tile_sprites.at(c_index)) && 
      !(@range_x === sprite.first.x/@zoom_x) && count < 100
      count += 1
      unless sign == 1
        row_index = c_index / width
        row_index *= width
        c_index = (@corner_index - 1) % width + row_index
      end
      (0...height).each do |n|
        j = (width * n + c_index) % @modtile
        next unless @tile_sprites.at(j)
        (0...@tile_sprites.at(j).size).each do |i|
          tile = @tile_sprites.at(j).at(i)
          tile.x += @incr_x * sign
          tile_update(tile,i)
        end
      end
      c_index /= width
      c_index *= width
      @corner_index = (@corner_index + sign) % width + c_index
      c_index = @corner_index
    end #end of while
  end
  #---------------------------------------------------------------------------
  # Makes update to ox and oy. Sprites out of range will be moved based on 
  # these two values.
  #---------------------------------------------------------------------------
  def oy=(oy)
    return if @oy == oy && !@oy_refresh
    @oy_refresh = false
    shift   = (@oy - oy) * @zoom_y
    width   = self.width
    height  = self.height
    count   = (@oy = oy) * 0
    sign    = (shift < 0 ? 1 : -1)
    r_index = @corner_index
    @tile_sprites.flatten.each do |tile|
      tile.y += shift
      priority = tile.instance_variable_get(:@priorities)
      next unless priority.is_a?(Integer) && priority > 0
      tile.z = 32 + (tile.y.to_i / 32) * 32 + priority * 32 * @zoom_y 
    end
    while (sprite = @tile_sprites.at(r_index)) &&  
      !(@range_y === sprite.first.y/@zoom_y) && count < 100
      count += 1
      r_index = (@corner_index - width) % @modtile unless sign == 1
      r_index /= width
      r_index *= width
      (0...width).each do |n|
        j = n + r_index
        next unless @tile_sprites.at(j)
        (0...@tile_sprites.at(j).size).each do |i|
          tile = @tile_sprites.at(j).at(i)
          tile.y += @incr_y * sign
          tile_update(tile,i)
        end
      end
      @corner_index = (@corner_index + width * sign) % @modtile
      r_index = @corner_index
    end # end of while
  end
  #---------------------------------------------------------------------------
  # * tile_update
  #---------------------------------------------------------------------------
  def tile_update(tile,i)
    if tile.is_a?(Sprite)
      tsprite_id = tile.instance_variable_get(:@tsprite_id)
    else
      tsprite_id = tile.tsprite_id
    end
    @animating_tiles.delete(tsprite_id)
    # Determine what map coordinate this tile now resides at...
    # Assign tile's respective ID value
    map_x = (tile.x / @zoom_x + @ox).round / 32 
    map_y = (tile.y / @zoom_y + @oy).round / 32
    # ...and get its tile_id
    tile_id = @map_data[map_x,map_y,i]
    # If no tile exists here (effectively out of array bounds)
    if tile_id.nil? || (priority = tile.
      instance_variable_set(:@priorities, @priorities[tile_id]) || 0) == 0 
      tile.z = 0
    else
      tile.z = 32  + (tile.y.to_i / 32) * 32 + priority * 32 * @zoom_y 
    end
    # If empty tile    
    if tile_id.nil? || tile_id == 0 
      tile.bitmap = nil
      if USE_CR_SPRITE && tile.is_a?(Sprite)
        temp = [tile.x, tile.y, tile.z, tsprite_id]
        (i = tsprite_id) && tile.dispose
        @tile_sprites[i/3][i%3] = CRSprite.new(*temp)
      end
    else
      if tile.is_a?(CRSprite)
        temp = [tile.x, tile.y, tile.z, tile.tsprite_id]
        tsprite_id = i = temp.at(3)
        tile = (@tile_sprites[i/3][i%3] = Sprite.new(@viewport))
        tile.x, tile.y, tile.z = temp[0..2]
        tile.zoom_x, tile.zoom_y = @zoom_x, @zoom_y
        tile.instance_variable_set(:@priorities, priority)
        tile.instance_variable_set(:@tsprite_id,i)
      end
      tile.tone = @tone if @tone.is_a?(Tone)
      if tile_id >= 384
        tile.bitmap = @tileset unless tile.bitmap == @tileset
        tile_div = (tile_id - 384)
        tile.src_rect.set((tile_div % 8) * 32,(tile_div / 8) * 32, 32, 32)
      else # Autotile
        auto_id = tile_id / 48 - 1
        autotile = @autotiles.at(auto_id)
        tile.bitmap = autotile unless tile.bitmap == autotile
        tile_div = (tile_id % 48)
        tile.src_rect.set((tile_div % 8)*32 + 
        @current_frame.at(auto_id) * 256,(tile_div / 8) * 32, 32, 32)
        @animating_tiles[tsprite_id] = tile if @total_frames.at(auto_id) > 1
      end
    end
  end
  #---------------------------------------------------------------------------
  # * Refresh the tilemap
  #---------------------------------------------------------------------------
  def refresh
    sprite = Sprite.new
    sprite.bitmap = Graphics.snap_to_bitmap
    1.times { Graphics.update }
    # Determine how many frames of animation this autotile has
    for i in 0..6
      bm = @autotiles[i]
      bm.nil? && @total_frames[i] = 1
      bm.nil? || @total_frames[i] = bm.width / (bm.height > 32 ? 256 : 32)
      @current_frame[i] = @ox_refresh = @oy_refresh =  0
    end
    _width  = (width - 2) * 32 + 64
    _height = (height - 2) * 32 + 64
    _ox,_oy = @ox, @oy
    @modtile = _width * _height / 1024
    @range_x = (-49*@zoom_x)..(-17*@zoom_x)
    @range_y = (-49*@zoom_y)..(-17*@zoom_y)
    @incr_x  = _width * @zoom_x
    @incr_y  = _height * @zoom_y
    @animating_tiles.clear
    # Create a sprite and viewport to use for each priority level.
    (0...(width * height)*3).each do |i|
      @tile_sprites[i/3] ||= [] 
      @tile_sprites[i/3][i%3] ||= CRSprite.new if USE_CR_SPRITE
      unless sprite_exist?(@tile_sprites[i/3][i%3])
        @tile_sprites[i/3][i%3] = Sprite.new(@viewport) 
      end
      # Rename to something shorter and easier to work with for below
      tile = @tile_sprites[i/3][i%3]
      # Draw sprite at index location 
      # (ex. ID 0 should always be the top-left sprite)
      org_x = (((i % (width*3) / 3 * 32) - 32) + ((@ox *= 0) % 32))
      org_y = (((i / (width*3) * 32) - 32) + ((@oy *= 0)  % 32)) 
      tile.x = org_x * @zoom_x 
      tile.y = org_y * @zoom_y 
      # Assign tile's respective ID value
      if tile.is_a?(Sprite)
        tile.zoom_x, tile.zoom_y = @zoom_x, @zoom_y 
        tile.instance_variable_set(:@tsprite_id, i)
      else
        tile.tsprite_id = i
      end
      tile_update(tile,i%3)
    end
    # Sprite ID located at top left corner
    @corner_index = 0
    self.ox = _ox
    self.oy = _oy
    sprite.bitmap.dispose
    sprite.dispose
  end
  #---------------------------------------------------------------------------
  # Set map data
  #---------------------------------------------------------------------------
  def map_data=(data)
    # Set the map data to new class
    @map_data = data.is_a?(Tilemap_DataTable) ? 
                data : Tilemap_DataTable.new(data)
    @map_data.table = @map_data.table.clone
    @animating_tiles.clear
    refresh
  end
  #---------------------------------------------------------------------------
  # * Check whether sprite is exist
  #---------------------------------------------------------------------------
  def sprite_exist?(sprite)
    sprite.is_a?(CRSprite) || (sprite.is_a?(Sprite) && !sprite.disposed?)
  end
  #---------------------------------------------------------------------------
  # * New method: method_missing
  #---------------------------------------------------------------------------
  def method_missing(val,*a,&b)
    en = tile_sprites.flatten.find_all {|s|s.respond_to?(val.to_sym)}
    if en.empty? 
      text = "Undefined method #{val} at #{self.inspect}"
      raise(NoMethodError,text,caller(1)) 
    end
    return en.map {|s| s.send(val.to_sym,*a,&b)}
  end  
  #---------------------------------------------------------------------------
  # * New method: zoom_x=
  #---------------------------------------------------------------------------
  def zoom_x=(value)
    return if @zoom_x == value
    (@zoom_x = (value == value.to_i) ? value.to_i : value) && refresh
  end
  #---------------------------------------------------------------------------
  # * New method: zoom_y=
  #---------------------------------------------------------------------------
  def zoom_y=(value)
    return if @zoom_y == value
    (@zoom_y = (value == value.to_i) ? value.to_i : value) && refresh
  end
  #---------------------------------------------------------------------------
  # * Frame Update
  #---------------------------------------------------------------------------
  def update
    update_autotile
    update_check_resolution
  end
  #---------------------------------------------------------------------------
  # * Update the autotile
  #---------------------------------------------------------------------------
  def update_autotile
    # Update the sprites.
    if Graphics.frame_count % $game_map.autotile_speed == 0
      # Increase current frame of tile by one, looping by width.
      for i in 0..6
        next if @total_frames.at(i) == 0
        @current_frame[i] = (@current_frame.at(i) + 1) % @total_frames.at(i)
      end
      @animating_tiles.each_value do |tile|
        frames = tile.bitmap.width
        tile.src_rect.set((tile.src_rect.x+256)%frames,tile.src_rect.y,32,32)
      end
    end
  end
  #---------------------------------------------------------------------------
  # * Refresh if Resolution is changed
  #---------------------------------------------------------------------------
  def update_check_resolution
    if @old_width != width || @old_height != height
      (@old_width = width) && (@old_height = height)
      refresh
    end
  end
  #---------------------------------------------------------------------------
  # Dispose all the tile sprites
  #---------------------------------------------------------------------------
  def dispose
    # Dispose all of the sprites
    @tile_sprites.flatten.each {|tile| tile.dispose }
    @tile_sprites.clear
    @animating_tiles.clear
  end
end

# Call the resolution, setting it to a global variable for plug-ins.
$resolution = Resolution.new