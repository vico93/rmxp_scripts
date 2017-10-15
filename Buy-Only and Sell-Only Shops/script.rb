# Buy-Only and Sell-Only Shops
# by RPG Advocate
#==============================================================================
# ** Game_Temp
#------------------------------------------------------------------------------
#  This class handles temporary data that is not included with save data.
#  Refer to "$game_temp" for the instance of this class.
#==============================================================================
class Game_Temp
 #--------------------------------------------------------------------------
 # * Public Instance Variables
 #--------------------------------------------------------------------------
 attr_accessor :shop_type                # map music (for battle memory)
 #--------------------------------------------------------------------------
 # * Object Initialization
 #--------------------------------------------------------------------------
 alias boasos_init initialize
 def initialize
   boasos_init
   @shop_type = 0
 end
end
#==============================================================================
# ** Window_ShopCommand
#------------------------------------------------------------------------------
#  This window is used to choose your business on the shop screen.
#==============================================================================
class Window_ShopCommand < Window_Selectable
 #--------------------------------------------------------------------------
 # * Object Initialization
 #--------------------------------------------------------------------------
 def initialize
   super(0, 64, 480, 64)
   self.contents = Bitmap.new(width - 32, height - 32)
   @item_max = 3
   @column_max = 3
   @commands = ["Buy", "Sell", "Exit"]
   self.contents.font.name = "Arial"
   self.contents.font.size = 24
   refresh
   self.index = 0
 end
 #--------------------------------------------------------------------------
 # * Refresh
 #--------------------------------------------------------------------------
 def refresh
   self.contents.clear
   if $game_temp.shop_type == 0
     for i in 0...@item_max
     draw_item(i)
     end
   end
   if $game_temp.shop_type == 1
     self.contents.draw_text(4, 0, 324, 32, "You can only buy at this shop.")
     self.index = -1
     update_cursor_rect
   end
   if $game_temp.shop_type == 2
     self.contents.draw_text(4, 0, 324, 32, "You can only sell at this shop.")
     self.index = -1
     update_cursor_rect
   end
 end
 #--------------------------------------------------------------------------
 # * Draw Item
 #     index : item number
 #--------------------------------------------------------------------------
 def draw_item(index)
   x = 4 + index * 160
   self.contents.draw_text(x, 0, 128, 32, @commands[index])
 end
 #--------------------------------------------------------------------------
 # * Cursor Rectangle Update
 #--------------------------------------------------------------------------
 def update_cursor_rect
   if $game_temp.shop_type == 0
     super
   end
   if $game_temp.shop_type == 1 || $game_temp.shop_type == 2
     self.cursor_rect.empty
   end
 end
end
#==============================================================================
# ** Scene_Shop
#------------------------------------------------------------------------------
#  This class performs shop screen processing.
#==============================================================================
class Scene_Shop
 #--------------------------------------------------------------------------
 # * Main Processing
 #--------------------------------------------------------------------------
 def main
   @help_window = Window_Help.new
   @command_window = Window_ShopCommand.new
   @gold_window = Window_Gold.new
   @gold_window.x = 480
   @gold_window.y = 64
   @dummy_window = Window_Base.new(0, 128, 640, 352)
   @buy_window = Window_ShopBuy.new($game_temp.shop_goods)
   @buy_window.active = false
   @buy_window.visible = false
   @buy_window.help_window = @help_window
   @sell_window = Window_ShopSell.new
   @sell_window.active = false
   @sell_window.visible = false
   @sell_window.help_window = @help_window
   @number_window = Window_ShopNumber.new
   @number_window.active = false
   @number_window.visible = false
   @status_window = Window_ShopStatus.new
   @status_window.visible = false
   if $game_temp.shop_type == 1
     @command_window.index = 0
     @command_window.active = false
     @dummy_window.visible = false
     @buy_window.active = true
     @buy_window.visible = true
     @buy_window.refresh
     @status_window.visible = true
   end
   if $game_temp.shop_type == 2
     @command_window.index = 1
     @command_window.active = false
     @dummy_window.visible = false
     @sell_window.active = true
     @sell_window.visible = true
     @sell_window.refresh
   end
   Graphics.transition
   loop do
     Graphics.update
     Input.update
     update
     if $scene != self
       break
     end
   end
   Graphics.freeze
   @status_window.item = nil
   @status_window.refresh
   @help_window.dispose
   @command_window.dispose
   @gold_window.dispose
   @dummy_window.dispose
   @buy_window.dispose
   @sell_window.dispose
   @number_window.dispose
   @status_window.dispose
   $game_temp.shop_type = 0
 end
 #--------------------------------------------------------------------------
 # * Frame Update
 #--------------------------------------------------------------------------
 def update
   @help_window.update
   @command_window.update
   @gold_window.update
   @dummy_window.update
   @buy_window.update
   @sell_window.update
   @number_window.update
   @status_window.update
   if @command_window.active
     update_command
     return
   end
   if @buy_window.active
     update_buy
     return
   end
   if @sell_window.active
     update_sell
     return
   end
   if @number_window.active
     update_number
     return
   end
 end
 #--------------------------------------------------------------------------
 # * Frame Update (when command window is active)
 #--------------------------------------------------------------------------
 def update_command
   if Input.trigger?(Input::B)
     $game_system.se_play($data_system.cancel_se)
     $scene = Scene_Map.new
     return
   end
   if Input.trigger?(Input::C)
     case @command_window.index
     when 0
       $game_system.se_play($data_system.decision_se)
       @command_window.active = false
       @dummy_window.visible = false
       @buy_window.active = true
       @buy_window.visible = true
       @buy_window.refresh
       @status_window.visible = true
     when 1
       $game_system.se_play($data_system.decision_se)
       @command_window.active = false
       @dummy_window.visible = false
       @sell_window.active = true
       @sell_window.visible = true
       @sell_window.refresh
     when 2
       $game_system.se_play($data_system.decision_se)
       $scene = Scene_Map.new
     end
     return
   end
 end
 #--------------------------------------------------------------------------
 # * Frame Update (when buy window is active)
 #--------------------------------------------------------------------------
 def update_buy
   @status_window.item = @buy_window.item
   if Input.trigger?(Input::B)
     if $game_temp.shop_type == 1
        $game_system.se_play($data_system.cancel_se)
        $scene = Scene_Map.new
     else
     $game_system.se_play($data_system.cancel_se)
     @command_window.active = true
     @dummy_window.visible = true
     @buy_window.active = false
     @buy_window.visible = false
     @status_window.visible = false
     @status_window.item = nil
     @help_window.set_text("")
     end
     return
   end
   if Input.trigger?(Input::C)
     @item = @buy_window.item
     if @item == nil or @item.price > $game_party.gold
       $game_system.se_play($data_system.buzzer_se)
       return
     end
     case @item
     when RPG::Item
       number = $game_party.item_number(@item.id)
     when RPG::Weapon
       number = $game_party.weapon_number(@item.id)
     when RPG::Armor
       number = $game_party.armor_number(@item.id)
     end
     if number == 99
       $game_system.se_play($data_system.buzzer_se)
       return
     end
     $game_system.se_play($data_system.decision_se)
     max = @item.price == 0 ? 99 : $game_party.gold / @item.price
     max = [max, 99 - number].min
     @buy_window.active = false
     @buy_window.visible = false
     @number_window.set(@item, max, @item.price)
     @number_window.active = true
     @number_window.visible = true
   end
 end
 #--------------------------------------------------------------------------
 # * Frame Update (when sell window is active)
 #--------------------------------------------------------------------------
 def update_sell
   if Input.trigger?(Input::B)
     if $game_temp.shop_type == 2
        $game_system.se_play($data_system.cancel_se)
        $scene = Scene_Map.new
     else
     $game_system.se_play($data_system.cancel_se)
     @command_window.active = true
     @dummy_window.visible = true
     @sell_window.active = false
     @sell_window.visible = false
     @status_window.item = nil
     @help_window.set_text("")
     return
     end
   end
   if Input.trigger?(Input::C)
     @item = @sell_window.item
     @status_window.item = @item
     if @item == nil or @item.price == 0
       $game_system.se_play($data_system.buzzer_se)
       return
     end
     $game_system.se_play($data_system.decision_se)
     case @item
     when RPG::Item
       number = $game_party.item_number(@item.id)
     when RPG::Weapon
       number = $game_party.weapon_number(@item.id)
     when RPG::Armor
       number = $game_party.armor_number(@item.id)
     end
     max = number
     @sell_window.active = false
     @sell_window.visible = false
     @number_window.set(@item, max, @item.price / 2)
     @number_window.active = true
     @number_window.visible = true
     @status_window.visible = true
   end
 end
 #--------------------------------------------------------------------------
 # * Frame Update (when quantity input window is active)
 #--------------------------------------------------------------------------
 def update_number
   if Input.trigger?(Input::B)
     $game_system.se_play($data_system.cancel_se)
     @number_window.active = false
     @number_window.visible = false
     case @command_window.index
     when 0
       @buy_window.active = true
       @buy_window.visible = true
     when 1
       @sell_window.active = true
       @sell_window.visible = true
       @status_window.visible = false
     end
     return
   end
   if Input.trigger?(Input::C)
     $game_system.se_play($data_system.shop_se)
     @number_window.active = false
     @number_window.visible = false
     case @command_window.index
     when 0
       $game_party.lose_gold(@number_window.number * @item.price)
       case @item
       when RPG::Item
         $game_party.gain_item(@item.id, @number_window.number)
       when RPG::Weapon
         $game_party.gain_weapon(@item.id, @number_window.number)
       when RPG::Armor
         $game_party.gain_armor(@item.id, @number_window.number)
       end
       @gold_window.refresh
       @buy_window.refresh
       @status_window.refresh
       @buy_window.active = true
       @buy_window.visible = true
     when 1
       $game_party.gain_gold(@number_window.number * (@item.price / 2))
       case @item
       when RPG::Item
         $game_party.lose_item(@item.id, @number_window.number)
       when RPG::Weapon
         $game_party.lose_weapon(@item.id, @number_window.number)
       when RPG::Armor
         $game_party.lose_armor(@item.id, @number_window.number)
       end
       @gold_window.refresh
       @sell_window.refresh
       @status_window.refresh
       @sell_window.active = true
       @sell_window.visible = true
       @status_window.visible = false
     end
     return
   end
 end
end
