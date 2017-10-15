#==============================================================================
# Cheats Input Script - v1.2 - by BudsieBuds
#------------------------------------------------------------------------------
#  NOTE: Comece a editar na linha 68 e pare quando ver '# STOP EDITING \\'.
#==============================================================================

#==============================================================================
# ** Scene_Cheats
#------------------------------------------------------------------------------
#  by BudsieBuds
#==============================================================================

class Scene_Cheats
#--------------------------------------------------------------------------
# * Processamento Principal
#--------------------------------------------------------------------------
def main
   # Faz as janelas
   @edit_window = Window_CheatsEdit.new
   @input_window = Window_CheatsInput.new
   # Executa a transição
   Graphics.transition
   # Loop principal
   loop do
     # Atualiza a tela
     Graphics.update
     # Atualiza a informação eviada
     Input.update
     # Atualiza o Frame
     update
     # Sai do Loop se for mudado de tela
     if $scene != self
       break
     end
   end
   # Prepara para transição
   Graphics.freeze
   # Tira as janelas
   @edit_window.dispose
   @input_window.dispose
end
#--------------------------------------------------------------------------
# * Atualização de Frame
#--------------------------------------------------------------------------
def update
   # Atualiza Janelas
   @edit_window.update
   @input_window.update
   # Se o botão B for apertado
   if Input.repeat?(Input::B)
     # Se a posição do cursor está em 0
     if @edit_window.index == 0
       return
     end
     # Inicia SE de cancelar
     $game_system.se_play($data_system.cancel_se)
     # Deleta Texto
     @edit_window.back
     return
   end
   # Se o botão C for apertado
   if Input.trigger?(Input::C)
     # Se a posição do cursor estiver em [OK]
     if @input_window.character == nil
       @cheat_word = @edit_window.cheat.downcase

=begin
# START EDITING //

===============================================================================

  O código que você deverá colocar:
    elsif @cheat_word == "seucheataqui"

-------------------------------------------------------------------------------

  Para itens::
    $game_party.gain_item(Item ID, Quantos)

  Para dinheiro:
    $game_party.gain_gold(Quanto)

  Para armas:
    $game_party.gain_weapon(Weapon ID, Quantos)

  Para armaduras:
    $game_party.gain_armor(Armor ID, Quantos)

  Para habilidades:
    $game_party.actors[Actor ID].learn_skill(Habilidade ID)

  Para adicionar heróis:
    $game_party.add_actor(ID)

-------------------------------------------------------------------------------

  Som de verificação
    $game_system.se_play($data_system.decision_se)

-------------------------------------------------------------------------------

   Seu código pode ter um máximo de 17 letras.
   O primeiro código deve começar com 'if'.
   Os códigos que virão logo após devem começar com 'elsif'.

===============================================================================
=end

if @cheat_word == "estourico"
   $game_party.gain_gold(500)
   $game_system.se_play($data_system.decision_se)

elsif @cheat_word == "souumguerreiro"
   $game_party.gain_weapon(1, 1)
   $game_party.gain_armor(21, 1)
   $game_system.se_play($data_system.decision_se)

elsif @cheat_word == "euamoitens"
   for i in 1...$data_items.size
     $game_party.gain_item(i, 10)
     $game_system.se_play($data_system.decision_se)
   end

elsif @cheat_word == "meenvieoheroi2"
   $game_party.add_actor(2)
   $game_system.se_play($data_system.decision_se)

# STOP EDITING \\

         else
           # Toca SE buzzer
           $game_system.se_play($data_system.buzzer_se)
         end
       # Volta para o mapa
       $scene = Scene_Map.new
       return
     end
     # Se os carácteres de texto forem vazios
     if @input_window.character == ""
       # Toca SE buzzer
       $game_system.se_play($data_system.buzzer_se)
       return
     end
     # Toca SE de seleção
     $game_system.se_play($data_system.decision_se)
     # Adicionar carácteres de texto
     @edit_window.add(@input_window.character)
     return
   end
end
end


#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  by BudsieBuds
#==============================================================================

class Window_Base < Window
#--------------------------------------------------------------------------
# * Draw Graphic
#     icon  : icon
#     x     : draw spot x-coordinate
#     y     : draw spot y-coordinate
#--------------------------------------------------------------------------
def draw_icon_graphic(icon, x, y)
   bitmap = RPG::Cache.icon(icon)
   cw = bitmap.width
   ch = bitmap.height
   src_rect = Rect.new(0, 0, cw, ch)
   self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
end
end


#==============================================================================
# ** Window_CheatsEdit
#------------------------------------------------------------------------------
#  by BudsieBuds
#==============================================================================

class Window_CheatsEdit < Window_Base
#--------------------------------------------------------------------------
# * Public Instance Variables
#--------------------------------------------------------------------------
attr_reader   :cheat                    # cheat
attr_reader   :index                    # cursor position
#--------------------------------------------------------------------------
# * Object Initialization
#--------------------------------------------------------------------------
def initialize
   super(0, 0, 640, 128)
   self.contents = Bitmap.new(width - 32, height - 32)
   @max_char = 17
   @index = 0
   @cheat = ""
   refresh
   update_cursor_rect
end
#--------------------------------------------------------------------------
# * Add Character
#     character : text character to be added
#--------------------------------------------------------------------------
def add(character)
   if @index < @max_char and character != ""
     @cheat += character
     @index += 1
     refresh
     update_cursor_rect
   end
end
#--------------------------------------------------------------------------
# * Delete Character
#--------------------------------------------------------------------------
def back
   if @index > 0
     # Delete 1 text character
     name_array = @cheat.split(//)
     @cheat = ""
     for i in 0...name_array.size-1
       @cheat += name_array[i]
     end
     @index -= 1
     refresh
     update_cursor_rect
   end
end
#--------------------------------------------------------------------------
# * Refresh
#--------------------------------------------------------------------------
def refresh
   self.contents.clear
   # Draw cheat
   name_array = @cheat.split(//)
   for i in 0...@max_char
     c = name_array[i]
     if c == nil
       c = "_"
     end
     x = (i + 1) * 32
     self.contents.draw_text(x, 32, 28, 32, c, 1)
   end
   # Draw graphic
   draw_icon_graphic("cheat", 16, 60)
end
#--------------------------------------------------------------------------
# * Cursor Rectangle Update
#--------------------------------------------------------------------------
def update_cursor_rect
   x = (@index + 1) * 32
   self.cursor_rect.set(x, 32, 28, 32)
end
#--------------------------------------------------------------------------
# * Frame Update
#--------------------------------------------------------------------------
def update
   super
   update_cursor_rect
end
end


#==============================================================================
# ** Window_CheatsInput
#------------------------------------------------------------------------------
#  by BudsieBuds
#==============================================================================

class Window_CheatsInput < Window_Base
CHARACTER_TABLE =
[
   "A","B","C","D","E",
   "F","G","H","I","J",
   "K","L","M","N","O",
   "P","Q","R","S","T",
   "U","V","W","X","Y",
   "Z"," "," "," "," ",
   "+","-","*","/","!",
   "1","2","3","4","5",
   "" ,"" ,"" ,"" ,"" ,
   "a","b","c","d","e",
   "f","g","h","i","j",
   "k","l","m","n","o",
   "p","q","r","s","t",
   "u","v","w","x","y",
   "z"," "," "," "," ",
   "#","$","%","&","@",
   "6","7","8","9","0",
   "" ,"" ,"" ,"" ,"" ,
]
#--------------------------------------------------------------------------
# * Object Initialization
#--------------------------------------------------------------------------
def initialize
   super(0, 128, 640, 352)
   self.contents = Bitmap.new(width - 32, height - 32)
   @index = 0
   refresh
   update_cursor_rect
end
#--------------------------------------------------------------------------
# * Text Character Acquisition
#--------------------------------------------------------------------------
def character
   return CHARACTER_TABLE[@index]
end
#--------------------------------------------------------------------------
# * Refresh
#--------------------------------------------------------------------------
def refresh
   self.contents.clear
   for i in 0...90
     x = 140 + i / 5 / 9 * 180 + i % 5 * 32
     y = i / 5 % 9 * 32
     self.contents.draw_text(x, y, 32, 32, CHARACTER_TABLE[i], 1)
   end
   self.contents.draw_text(428, 9 * 32, 48, 32, "OK", 1)
end
#--------------------------------------------------------------------------
# * Cursor Rectangle Update
#--------------------------------------------------------------------------
def update_cursor_rect
   # If cursor is positioned on [OK]
   if @index >= 90
     self.cursor_rect.set(428, 9 * 32, 48, 32)
   # If cursor is positioned on anything other than [OK]
   else
     x = 140 + @index / 5 / 9 * 180 + @index % 5 * 32
     y = @index / 5 % 9 * 32
     self.cursor_rect.set(x, y, 32, 32)
   end
end
#--------------------------------------------------------------------------
# * Frame Update
#--------------------------------------------------------------------------
def update
   super
   # If cursor is positioned on [OK]
   if @index >= 90
     # Cursor down
     if Input.trigger?(Input::DOWN)
       $game_system.se_play($data_system.cursor_se)
       @index -= 90
     end
     # Cursor up
     if Input.repeat?(Input::UP)
       $game_system.se_play($data_system.cursor_se)
       @index -= 90 - 40
     end
   # If cursor is positioned on anything other than [OK]
   else
     # If right directional button is pushed
     if Input.repeat?(Input::RIGHT)
       # If directional button pressed down is not a repeat, or
       # cursor is not positioned on the right edge
       if Input.trigger?(Input::RIGHT) or
          @index / 45 < 3 or @index % 5 < 4
         # Move cursor to right
         $game_system.se_play($data_system.cursor_se)
         if @index % 5 < 4
           @index += 1
         else
           @index += 45 - 4
         end
         if @index >= 90
           @index -= 90
         end
       end
     end
     # If left directional button is pushed
     if Input.repeat?(Input::LEFT)
       # If directional button pressed down is not a repeat, or
       # cursor is not positioned on the left edge
       if Input.trigger?(Input::LEFT) or
          @index / 45 > 0 or @index % 5 > 0
         # Move cursor to left
         $game_system.se_play($data_system.cursor_se)
         if @index % 5 > 0
           @index -= 1
         else
           @index -= 45 - 4
         end
         if @index < 0
           @index += 90
         end
       end
     end
     # If down directional button is pushed
     if Input.repeat?(Input::DOWN)
       # Move cursor down
       $game_system.se_play($data_system.cursor_se)
       if @index % 45 < 40
         @index += 5
       else
         @index += 90 - 40
       end
     end
     # If up directional button is pushed
     if Input.repeat?(Input::UP)
       # If directional button pressed down is not a repeat, or
       # cursor is not positioned on the upper edge
       if Input.trigger?(Input::UP) or @index % 45 >= 5
         # Move cursor up
         $game_system.se_play($data_system.cursor_se)
         if @index % 45 >= 5
           @index -= 5
         else
           @index += 90
         end
       end
     end
     # If L or R button was pressed
     if Input.repeat?(Input::L) or Input.repeat?(Input::R)
       # Move capital / small
       $game_system.se_play($data_system.cursor_se)
       if @index < 45
         @index += 45
       else
         @index -= 45
       end
     end
   end
   update_cursor_rect
end
end