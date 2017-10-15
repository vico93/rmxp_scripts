#==============================================================================
# � Scene_Map
#------------------------------------------------------------------------------
#  � a classe que procede � imagem de title
#==============================================================================
#   Traduzido:
#    By Apidcloud
#    Data: 01/12/08
#==============================================================================
class Scene_Map
  #--------------------------------------------------------------------------
  # ? Consultar a configura��o da cena mapa
  #--------------------------------------------------------------------------
  alias scene_map_main main
  alias scene_map_update update
  #--------------------------------------------------------------------------
  # ? Remete para o principal
  #--------------------------------------------------------------------------
  def main
    @on_map_diplay = Window_Mapstats.new
    $ABS.display = Sprite.new
    $ABS.display.bitmap = Bitmap.new(88, 48)
    scene_map_main
    $ABS.display.dispose
    @on_map_diplay.dispose
  end
  #--------------------------------------------------------------------------
  # ? Remete para a actualiza��o
  #--------------------------------------------------------------------------
  def update
    @on_map_diplay.update
    $ABS.update
    if Input.trigger?(Input::L)
      # Ataque do player
      if $ABS.player_defending == false
        $ABS.player_melee_preconditions
      end
    end
    if Input.press?(Input::R)
      # O escudo do player est� activo
      $ABS.player_defending= true
    else
      # O escudo do player n�o est� activo
      $ABS.player_defending = false
    end
    if Input.trigger?(Input::X)
      # Skill do player tecla 1
      $ABS.player_skill_preconditions(1)
    end
    if Input.trigger?(Input::Y)
      # Skill do player tecla 2
      $ABS.player_skill_preconditions(2)
    end
    if Input.trigger?(Input::Z)
      # Skill do player tecla 3
      $ABS.player_skill_preconditions(3)
    end
    scene_map_update
  end
end


#==============================================================================
#  Window_Base
#------------------------------------------------------------------------------
#   Acrescenta fun��o Draw, Draw Hp, Sp Draw, Draw Exp, 
#   Acrescenta chamar actores combatentes, refine chamar texto do n�vel dos actores
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # ? Mostrar HP
  #     actor : actor
  #     x     : desenho da coordenada X 
  #     y     : desenho da coordenada Y
  #     width : largura do desenho 
  #--------------------------------------------------------------------------
  def draw_actor_hp_text(actor, x, y, width = 144)
    # Mostra string de "HP" do character 
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 32, 32, $data_system.words.hp)
    # C�lculos � um espa�o que desenha o HP m�ximo
    if width - 32 >= 108
      hp_x = x + width - 108
      flag = true
    elsif width - 32 >= 48
      hp_x = x + width - 48
      flag = false
    end
    # Mostrar HP
    self.contents.font.color = actor.hp == 0 ? knockout_color :
      actor.hp <= actor.maxhp / 4 ? crisis_color : normal_color
    self.contents.draw_text(hp_x, y, 40, 32, actor.hp.to_s, 2)
    # Mostrar HP m�ximo 
    if flag
      self.contents.font.color = normal_color
      self.contents.draw_text(hp_x + 40, y, 12, 32, "/", 1)
      self.contents.draw_text(hp_x + 52, y, 48, 32, actor.maxhp.to_s)
    end
  end
  #--------------------------------------------------------------------------
  # ? Mostrar SP
  #     actor : actor
  #     x     : desenho da coordenada X 
  #     y     : desenho da coordenada Y
  #     width : largura do desenho
  #--------------------------------------------------------------------------
  def draw_actor_sp_text(actor, x, y, width = 144)
    # Mostra string de "SP" do character
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 32, 32, $data_system.words.sp)
    # C�lculos � um espa�o que desenha o SP m�ximo
    if width - 32 >= 108
      sp_x = x + width - 108
      flag = true
    elsif width - 32 >= 48
      sp_x = x + width - 48
      flag = false
    end
    # Mostrar HP
    self.contents.font.color = actor.sp == 0 ? knockout_color :
      actor.sp <= actor.maxsp / 4 ? crisis_color : normal_color
    self.contents.draw_text(sp_x, y, 40, 32, actor.sp.to_s, 2)
    # Mostrar HP m�ximo 
    if flag
      self.contents.font.color = normal_color
      self.contents.draw_text(sp_x + 40, y, 12, 32, "/", 1)
      self.contents.draw_text(sp_x + 52, y, 48, 32, actor.maxsp.to_s)
    end
  end
  #--------------------------------------------------------------------------
  # ? Desenha o comprimento do HP dos players
  #--------------------------------------------------------------------------
  def draw_actor_hp_bar(actor, x, y, width = 100, height = 10, bar_color = Color.new(255, 0, 0, 255))
    self.contents.fill_rect(x, y, width, height, Color.new(255, 255, 255, 100)) 
    w = width * actor.hp / actor.maxhp
    for i in 0..height
      r = bar_color.red   * (height -i)/height  + 0   * i/height 
      g = bar_color.green * (height -i)/height  + 0 * i/height 
      b = bar_color.blue  * (height -i)/height  + 0 * i/height 
      a = bar_color.alpha * (height -i)/height  + 255 * i/height 
      self.contents.fill_rect(x, y+i, w , 1, Color.new(r, g, b, a)) 
    end
  end
  #--------------------------------------------------------------------------
  # ? Desenha o comprimento do SP dos players
  #--------------------------------------------------------------------------
  def draw_actor_sp_bar(actor, x, y, width = 100, height = 10, bar_color = Color.new(0, 0, 255, 255))
    self.contents.fill_rect(x, y, width, height, Color.new(255, 255, 255, 100)) 
    w = width * actor.sp / actor.maxsp
    for i in 0..height
      r = bar_color.red   * (height -i)/height  + 0   * i/height 
      g = bar_color.green * (height -i)/height  + 0 * i/height 
      b = bar_color.blue  * (height -i)/height  + 0 * i/height 
      a = bar_color.alpha * (height -i)/height  + 255 * i/height 
      self.contents.fill_rect(x, y+i, w , 1, Color.new(r, g, b, a)) 
    end
  end
  #--------------------------------------------------------------------------
  # ? Desenha o comprimento da EXP dos players
  #--------------------------------------------------------------------------
  def draw_actor_exp_bar(actor, x, y, width = 100, height = 10, bar_color = Color.new(255, 255, 0, 255))
    self.contents.fill_rect(x, y, width, height, Color.new(255, 255, 255, 100)) 
    if actor.level == 99
      w = 0
    else
      w = width * actor.exp / actor.next_exp_s.to_f
    end
    for i in 0..height
      r = bar_color.red   * (height -i)/height  + 0   * i/height 
      g = bar_color.green * (height -i)/height  + 0 * i/height 
      b = bar_color.blue  * (height -i)/height  + 0 * i/height 
      a = bar_color.alpha * (height -i)/height  + 255 * i/height 
      self.contents.fill_rect(x, y+i, w , 1, Color.new(r, g, b, a)) 
    end
  end
  #--------------------------------------------------------------------------
  # ? Desenha o comprimento da for�a dos players
  #--------------------------------------------------------------------------
  def draw_actor_str_bar(actor, i, x, y, width = 100, height = 10, bar_color = Color.new(255, 0, 0, 255))
    self.contents.fill_rect(x, y, width, height, Color.new(255, 255, 255, 100)) 
    w = width * actor.str / 999
    for i in 0..height
      r = bar_color.red   * (height -i)/height  + 0   * i/height
      g = bar_color.green * (height -i)/height  + 0 * i/height 
      b = bar_color.blue  * (height -i)/height  + 0 * i/height
      a = bar_color.alpha * (height -i)/height  + 255 * i/height
      self.contents.fill_rect(x, y+i, w , 1, Color.new(r, g, b, a))
    end
  end
  #--------------------------------------------------------------------------
  # ? Desenha o comprimento da destreza dos players
  #--------------------------------------------------------------------------
  def draw_actor_dex_bar(actor, i, x, y, width = 100, height = 10, bar_color = Color.new(0, 255, 0, 255))
    self.contents.fill_rect(x, y, width, height, Color.new(255, 255, 255, 100)) 
    w = width * actor.dex / 999
    for i in 0..height
      r = bar_color.red   * (height -i)/height  + 0   * i/height
      g = bar_color.green * (height -i)/height  + 0 * i/height 
      b = bar_color.blue  * (height -i)/height  + 0 * i/height
      a = bar_color.alpha * (height -i)/height  + 255 * i/height
      self.contents.fill_rect(x, y+i, w , 1, Color.new(r, g, b, a))
    end
  end
  #--------------------------------------------------------------------------
  # ? Desenha o comprimento da agilidade dos players
  #--------------------------------------------------------------------------
  def draw_actor_agi_bar(actor, i, x, y, width = 100, height = 10, bar_color = Color.new(0, 0, 255, 255))
    self.contents.fill_rect(x, y, width, height, Color.new(255, 255, 255, 100)) 
    w = width * actor.agi / 999
    for i in 0..height
      r = bar_color.red   * (height -i)/height  + 0   * i/height
      g = bar_color.green * (height -i)/height  + 0 * i/height 
      b = bar_color.blue  * (height -i)/height  + 0 * i/height
      a = bar_color.alpha * (height -i)/height  + 255 * i/height
      self.contents.fill_rect(x, y+i, w , 1, Color.new(r, g, b, a))
    end
  end
  #--------------------------------------------------------------------------
  # ? Desenha o comprimento da intelig�ncia dos players
  #--------------------------------------------------------------------------
  def draw_actor_int_bar(actor, i, x, y, width = 100, height = 10, bar_color = Color.new(180, 100, 200, 255))
    self.contents.fill_rect(x, y, width, height, Color.new(255, 255, 255, 100)) 
    w = width * actor.int / 999
    for i in 0..height
      r = bar_color.red   * (height -i)/height  + 0   * i/height
      g = bar_color.green * (height -i)/height  + 0 * i/height 
      b = bar_color.blue  * (height -i)/height  + 0 * i/height
      a = bar_color.alpha * (height -i)/height  + 255 * i/height
      self.contents.fill_rect(x, y+i, w , 1, Color.new(r, g, b, a))
    end
  end
  #--------------------------------------------------------------------------
  # ? Desenha a barra do poder da dash
  #--------------------------------------------------------------------------
  def draw_dash_bar(x, y, width = 50, height = 10)
    self.contents.fill_rect(x, y, width, height, Color.new(255, 255, 255, 100)) 
    case $ABS.dash_level
    when 0 .. 1 
      bar_color = Color.new(255, 0, 0, 255)
    when 2 .. 3
      bar_color = Color.new(255, 255, 0, 255) 
    else
      bar_color = Color.new(0, 255, 0, 255) 
    end
    w = width * $ABS.dash_level / 5
    for i in 0..height
      r = bar_color.red   * (height -i)/height  + 0   * i/height 
      g = bar_color.green * (height -i)/height  + 0 * i/height 
      b = bar_color.blue  * (height -i)/height  + 0 * i/height 
      a = bar_color.alpha * (height -i)/height  + 255 * i/height 
      self.contents.fill_rect(x, y+i, w , 1, Color.new(r, g, b, a)) 
    end
  end
  #--------------------------------------------------------------------------
  # ? Desenha o battler dos actores
  #--------------------------------------------------------------------------
  def draw_actor_battler(actor, x, y)
      bitmap = RPG::Cache.battler(actor.character_name, actor.character_hue)
      cw = bitmap.width
      ch = bitmap.height
      src_rect = Rect.new(0, 0, cw, ch)
      self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end
end

#==============================================================================
#  �  Ao mostrar o mapa
#------------------------------------------------------------------------------
#     Mostrar os stats player corrente na janela
#=============================================================================

class Window_Mapstats < Window_Base
  #--------------------------------------------------------------------------
  # ? Inicializa��o
  #--------------------------------------------------------------------------
  def initialize
    super(0, 400, 640, 80)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.contents.font.name = $defaultfonttype
    self.contents.font.size = $defaultfontsize
    self.back_opacity = 125 
    # self.opacity = 0
    update
  end
  #--------------------------------------------------------------------------
  # ? Actualiza��o
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    actor = $game_party.actors[$ABS.active_actor]
    draw_actor_graphic(actor, 10, 45) # draws the actor graphic
    draw_actor_name(actor, 30, -5) #draws the actors name
    draw_actor_level(actor, 30, 15) #draws the actor level
    draw_actor_hp_text(actor, 110, -5) #draws the actors hp
    draw_actor_hp_bar(actor, 260, 5)  #draws the actors hp bar
    draw_actor_sp_text(actor,110, 15) #draws the actors sp
    draw_actor_sp_bar(actor, 260, 27) #draws the actors sp bar
    draw_dash_bar(375, 27) #draws the dash level bar
    self.contents.draw_text(377, -5, 120, 32, "Dash") 
   end
   #--------------------------------------------------------------------------
   # ? Actualiza��o
   #--------------------------------------------------------------------------
   def update
     if Graphics.frame_count / Graphics.frame_rate != @total_sec
       refresh
     end
   end
end

#==============================================================================
# � Scene_Title
#------------------------------------------------------------------------------
#  � a classe que procede a tela de inicio
#==============================================================================

class Scene_Title
  #--------------------------------------------------------------------------
  # ? Consulta a configura��o da Cena de t�tulo
  #--------------------------------------------------------------------------
  alias scene_title_update update
  #--------------------------------------------------------------------------
  # ? carrega os nomes dos eventos 
  #--------------------------------------------------------------------------
  def update
    $ABS = Action_Battle_System.new
    scene_title_update
  end
end

#==============================================================================
# � Game_Map
#------------------------------------------------------------------------------
#  Acrescenta defini��es dos nomes � classe Game Map
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # ? Consultar a configura��o do Game Map
  #--------------------------------------------------------------------------
  attr_accessor :map
  alias game_map_setup setup
  #--------------------------------------------------------------------------
  # ? Consultar a configura��o do mapa
  #--------------------------------------------------------------------------
  def setup(map_id)
    game_map_setup(map_id)
    $ABS.enemy_setup
  end
end

#==============================================================================
# � Game_Character
#------------------------------------------------------------------------------
#  Acrescenta tipos de movimento ao acessador 
#==============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # ? Abrir vari�vel de inst�ncia
  #--------------------------------------------------------------------------
  attr_accessor :move_type
  attr_accessor :move_speed
  attr_accessor :move_frequency
  attr_accessor :character_name
end

#==============================================================================
# � Scene_Skill
#------------------------------------------------------------------------------
#  � a classe que procede � imagem de skill
#==============================================================================

class Scene_Skill
 #--------------------------------------------------------------------------
 # ? Inicializa��o de objectos
 #     actor_index: Indice de actor
 #--------------------------------------------------------------------------
 def initialize(actor_index = 0, equip_index = 0)
   @actor_index = actor_index
 end
 #--------------------------------------------------------------------------
 # ? Principais transforma��es
 #--------------------------------------------------------------------------
 def main
   # Adquirir o actor
   @actor = $game_party.actors[@actor_index]
   # Ajudar a elaborar a janela, a janela do status e da habilidade da janela
   @help_window = Window_Help.new
   @status_window = Window_SkillStatus.new(@actor)
   @skill_window = Window_Skill.new(@actor)
   # Ajuda na associa��o da janela
   @skill_window.help_window = @help_window
   # Alvo janela compila��o (invisibilidade n�o activamente ajuste)
   @target_window = Window_Target.new
   @target_window.visible = false
   @target_window.active = false
   # Janela das teclas de skill
   @shk_window = Window_Command.new(250, ["Skill Assigned to Hot Key"])
   @shk_window.visible = false
   @shk_window.active = false
   @shk_window.x = 200
   @shk_window.y = 250
   @shk_window.z = 1500
   # Execu��o de transi��o
   Graphics.transition
   # Loop principal
   loop do
     # Renova as imagens do jogo
     Graphics.update
     # Atualizar as informa��es de entrada
     Input.update
     # Renova��o de frames
     update
     # Quando a imagem muda, interrompe-se o ciclo
     if $scene != self
       break
     end
   end
   # Prepara��o para transi��o
   Graphics.freeze
   # Deixar a janela
   @help_window.dispose
   @status_window.dispose
   @skill_window.dispose
   @target_window.dispose
   @shk_window.dispose
 end
 #--------------------------------------------------------------------------
 # ? Renova��o de frames
 #--------------------------------------------------------------------------
 def update
   # Renovar as janelas
   @help_window.update
   @status_window.update
   @skill_window.update
   @target_window.update
   @shk_window.update
   # ^Quando a janela de skills est� activa: � chamado a actualiza��o de skills
   if @skill_window.active
     update_skill
     return
   end
   # Quando a janela alvo est� activa: � chamado a actualiza��o de alvos
   if @target_window.active
     update_target
     return
   end
   # Quando a janela das teclas de skills est� activa: � chamada a actualiza��o de shk 
   if @shk_window.active
     update_shk
     return
   end
 end
 #--------------------------------------------------------------------------
 # ? Quando os frames s�o renovados (a janela de skill est� activa)
 #--------------------------------------------------------------------------
 def update_skill
   # Quando o bot�o B � apertado
   if Input.trigger?(Input::B)
     # Perfoma o cancelamento de SE
     $game_system.se_play($data_system.cancel_se)
     # Mudar a screen do menu
     $scene = Scene_Menu.new(1)
     return
   end
   # Quando o bot�o C � apertado
   if Input.trigger?(Input::C)
     # Adquirir os dados, que actualmente estao selecionados na janela de skills
     @skill = @skill_window.skill
     # Quando n�o podes usar
     if @skill == nil or not @actor.skill_can_use?(@skill.id)
       # Performa a buzzer de SE
       $game_system.se_play($data_system.buzzer_se)
       return
     end
     # Performa a decis�o de SE
     $game_system.se_play($data_system.decision_se)
     # Quando o alcance do efeito participa
     if @skill.scope >= 3
       # Convers�o alvo activa a janela
       @skill_window.active = false
       @target_window.x = (@skill_window.index + 1) % 2 * 304
       @target_window.visible = true
       @target_window.active = true
       # Definindo posi��o do cursor efetivo alcance (a �nica unidade / todo ) de acordo com
       if @skill.scope == 4 || @skill.scope == 6
         @target_window.index = -1
       elsif @skill.scope == 7
         @target_window.index = @actor_index - 10
       else
         @target_window.index = 0
       end
     # Quando o alcance do efeito � diferente de participa
     else
       # Quando o ID do evento comum � efectivo
       if @skill.common_event_id > 0
         # Rserva-se a chamada do evento comum
         $game_temp.common_event_id = @skill.common_event_id
         # Quando se utiliza a habilidade realizando SE
         $game_system.se_play(@skill.menu_se)
         # Consumo de SP
         @actor.sp -= @skill.sp_cost
         # Re-escrever o que cada janela cont�m
         @status_window.refresh
         @skill_window.refresh
         @target_window.refresh
         # Modificar para a imagem do mapa
         $scene = Scene_Map.new
         return
       end
     end
     return
   end
   # Quando o bot�o X � apertado
   if Input.trigger?(Input::X)
     # Performa a decis�o de SE
     $game_system.se_play($data_system.decision_se)
     @skill_window.active = false
     @shk_window.active = true
     @shk_window.visible = true
     $ABS.skill_hot_key[1] = @skill_window.skill.id
   end
   # Quando o bot�o Y � apertado
   if Input.trigger?(Input::Y)
     # Performa a decis�o de SE
     $game_system.se_play($data_system.decision_se)
     @skill_window.active = false
     @shk_window.active = true
     @shk_window.visible = true
     $ABS.skill_hot_key[2] = @skill_window.skill.id
   end
   # Quando o bot�o Z � apertado
   if Input.trigger?(Input::Z)
     # Performa a decis�o de SE
     $game_system.se_play($data_system.decision_se)
     @skill_window.active = false
     @shk_window.active = true
     @shk_window.visible = true
     $ABS.skill_hot_key[3] = @skill_window.skill.id
   end
   # Quando o bot�o R � apertado
   if Input.trigger?(Input::R)
     # Performa o cursor SE
     $game_system.se_play($data_system.cursor_se)
     # Para o seguinte actor
     @actor_index += 1
     @actor_index %= $game_party.actors.size
     # Modificar para outra imagem de skill
     $scene = Scene_Skill.new(@actor_index)
     return
   end
   # Quando o bot�o L � apertado,
   if Input.trigger?(Input::L)
     # Performa o cursor de SE
     $game_system.se_play($data_system.cursor_se)
     # Para o actor anterior
     @actor_index += $game_party.actors.size - 1
     @actor_index %= $game_party.actors.size
     # Modificar para outra imagem de skill
     $scene = Scene_Skill.new(@actor_index)
     return
   end
 end
 #--------------------------------------------------------------------------
 # ? Quando os frames s�o renovados (a janela shk � activada)
 #--------------------------------------------------------------------------
 def update_shk
   # O bot�o C � apertado
   if Input.trigger?(Input::C)
     # Performa a decis�o de SE
     $game_system.se_play($data_system.decision_se)
     # Reseta a janela das teclas de skill
     @shk_window.active = false
     @shk_window.visible = false
     @skill_window.active = true
     #Modificar para a screen do menu
     $scene = Scene_Skill.new(@actor_index)
     return
   end
 end
end