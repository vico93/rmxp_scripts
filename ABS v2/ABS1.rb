#==============================================================================
# ¦ Action Battle System
#------------------------------------------------------------------------------
#  By: Near Fantastica
#   Date: 07/2/05
#   Version 2
# 
#   Traduzido:
#    By Apidcloud
#    Data: 01/12/08
#
#   A key – X input – Skill Hot Key 1
#   S key – Y input – Skill Hot Key 2
#   D key – Z input – Skill Hot Key 3
#   Q key – L input – Attacking
#   W key –R input – Defending
#
#   A Habilidade Hot Keys podem ser mudados no menu de skills por selecionar 
#   durante o skill que quer e apertando a hot key que você quer ter para
#   seleccionar essa skill também !
#
#   Obrigado a Harosata, Akura, Hazarim, Deke, Arcaine e
#   obrigado a todos por testar e por você colocar.
#==============================================================================

class Action_Battle_System
  #--------------------------------------------------------------------------
  # ? Abrir instância variável
  #--------------------------------------------------------------------------
  attr_accessor :active_actor
  attr_accessor :display
  attr_accessor :player_defending
  attr_accessor :skill_hot_key
  attr_accessor :dash_level
  #--------------------------------------------------------------------------
  # ? Inicialização
  #--------------------------------------------------------------------------
  def initialize
    @event_counter = 0
    @display = Sprite.new
    @display.bitmap = Bitmap.new(88, 48)
    @clear_counter = 0
    @active_actor = 0
    @player_defending = false
    @restore = false
    @reduce= false
    @timer = 0
    @dash_level = 5
    @sec = 0
    @skill_hot_key = {}
    @skill_hot_key[1]  = 0
    @skill_hot_key[2]  = 0
    @skill_hot_key[3] = 0
    @enemy_id = {}
    @enemy_name = {}
    @enemy_hp = {}
    @enemy_sp = {}
    @enemy_str = {}
    @enemy_dex = {}
    @enemy_agi  = {}
    @enemy_int = {}
    @enemy_atk = {}
    @enemy_pdef = {}
    @enemy_mdef = {}
    @enemy_eva = {}
    @enemy_animation1_id = {}
    @enemy_animation2_id = {}
    @enemy_exp = {}
    @enemy_gold = {}
    @enemy_item_id = {}
    @enemy_weapon_id = {}
    @enemy_armor_id = {}
    @enemy_treasure_prob = {}
    @enemy_engagement = {}
    @enemy_movment = {}
    @enemy_frequency = {}
    @enemy_speed = {}
    @enemy_defending = {}
    @enemy_dex_loop = {}
  end
  #--------------------------------------------------------------------------
  # ? Configuração do inimigo
  #--------------------------------------------------------------------------
  def enemy_setup
    # Configuração do número máximo de eventos
    @event_counter = 0
    for i in 1..999
      if $game_map.map.events[i].id > @event_counter
        @event_counter = $game_map.map.events[i].id
      end
    end
    # Configuração de evento
    for i in 1..@event_counter #$game_map.map.events.size
      # Define o evento a definição Nill
      @enemy_id[i] = 0
      for x in 1..$data_enemies.size - 1
        if $game_map.map.events[i] == nil
          next i
        end
        if $game_map.map.events[i].name == $data_enemies[x].name
          # Evento é um inimigo/Instalação de inimigos
          @enemy_id[i] = $data_enemies[x].id
          @enemy_name[i] = $data_enemies[x].name
          @enemy_hp[i] = $data_enemies[x].maxhp
          @enemy_sp[i] = $data_enemies[x].maxsp
          @enemy_str[i] = $data_enemies[x].str
          @enemy_dex[i] = $data_enemies[x].dex
          @enemy_agi [i] = $data_enemies[x].agi
          @enemy_int[i] = $data_enemies[x].int
          @enemy_atk[i] = $data_enemies[x].atk
          @enemy_pdef[i] = $data_enemies[x].pdef
          @enemy_mdef[i] = $data_enemies[x].mdef
          @enemy_eva[i] = $data_enemies[x].eva
          @enemy_animation1_id[i] = $data_enemies[x].animation1_id
          @enemy_animation2_id[i] = $data_enemies[x].animation2_id
          @enemy_exp[i] = $data_enemies[x].exp
          @enemy_gold[i] = $data_enemies[x].gold
          @enemy_item_id[i] = $data_enemies[x].item_id
          @enemy_weapon_id[i] = $data_enemies[x].weapon_id
          @enemy_armor_id[i] = $data_enemies[x].armor_id
          @enemy_treasure_prob[i] = $data_enemies[x].treasure_prob
          @enemy_states = []
          @enemy_engagement[i] = false
          @enemy_movment[i] = 0
          @enemy_frequency[i] = 0
          @enemy_speed[i] = 0
          @enemy_defending[i] = false
          @enemy_dex_loop[i] = 0
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ? Update Dash
  #--------------------------------------------------------------------------
  def update_dash
    # verificar se escudo está activo
    if @player_defending == true
      $game_player.move_speed = 3
      return
    end
    # verificar se o Modo Dash está activo
    if Input.press?(Input::A)
      if $game_player.moving?
        # Se a tecla A for pressionada entra em Modo dash
        # reduzir o nível de dash
        $game_player.move_speed=5
        @restore = false
        if @reduce == false
          @timer = 50 # comando de tempo inicial off
          @reduce = true
        else
          @timer-= 1
        end
        @sec = (@timer / Graphics.frame_rate)%60
        if @sec == 0
          if @dash_level != 0
            @dash_level -= 1
            @timer = 50 # contagem de timer
          end
        end
        if @dash_level == 0
          $game_player.move_speed=4
        end
      end
    else
      # restaura nível de dash
      $game_player.move_speed=4
      @reduce = false
      if @restore == false
        @timer = 80 # comando de tempo inicial off
        @restore = true
      else
        @timer-= 1
      end
      @sec = (@timer / Graphics.frame_rate)%60
      if @sec == 0
        if @dash_level != 5
          @dash_level+= 1
          @timer = 60 # contagem de timer
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ? Apagar o display
  #--------------------------------------------------------------------------
  def clear_display
    @clear_counter += 1
    if @clear_counter == 50
      @clear_counter = 0
      @display.bitmap.clear
    end
  end
  #--------------------------------------------------------------------------
  # ? Actualização
  #--------------------------------------------------------------------------
  def update
    update_dash
    clear_display
    for i in 1..@event_counter
      # Verificar se é um evento é inimigo
      if @enemy_id[i] == 0
        next
      else
        # Inimigos ocupados
        if @enemy_engagement[i] == true
          # Verificar alcance
          if in_range?(i,5)
            # Actualização de batalha
            if in_range?(i,1)
              event_melee_attack(i)
            else
              event_skill_attack(i)
            end
            next
          else
            @enemy_engagement[i] = false
            # Modificação de movimento
            $game_map.events[i].move_type = @enemy_movment[i]
            $game_map.events[i].move_frequency = @enemy_frequency[i]
            $game_map.events[i].move_speed = @enemy_speed[i]
            next
          end
        end
        # Verificar alcance
        if in_range?(i,5)
          # Verificar a direcçao do evento
          if facing_player?(i)
            # Definir inimigo ocupado
            @enemy_engagement[i] = true
            # Modificar movimento
            @enemy_movment[i] = $game_map.events[i].move_type
            $game_map.events[i].move_type = 2
            @enemy_frequency[i] = $game_map.events[i].move_frequency
            $game_map.events[i].move_frequency = 5
            @enemy_speed[i] = $game_map.events[i].move_speed
            $game_map.events[i].move_speed = 4
            # Actualização da batalha
            if in_range?(i,1)
              event_melee_attack(i)
            else
              event_skill_attack(i)
            end
          end
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ? Verificar se o evento está ao alcance
  #--------------------------------------------------------------------------
  def in_range?(event_index, range)
    playerx = $game_player.x
    playery = $game_player.y
    eventx = $game_map.events[event_index].x
    eventy = $game_map.events[event_index].y
    # Determine x and y do circulo
    x = (playerx - eventx) * (playerx - eventx)
    y = (playery - eventy) * (playery - eventy)
    # Determine raduis
    r = x +y
    if r <= (range * range)
       return true
    else
      return false
    end
  end
  #--------------------------------------------------------------------------
  # ? Verificar se o evento está frente a frente com o player
  #--------------------------------------------------------------------------
  def facing_player?(event_index)
    playerx = $game_player.x
    playery = $game_player.y
    eventx = $game_map.events[event_index].x
    eventy = $game_map.events[event_index].y
    event_direction = $game_map.events[event_index].direction
    # Verificar abaixo
    if event_direction == 2
      if playery >= eventy
        return true
      end
    end
    # Verificar esquerda
    if event_direction == 4
      if playerx <= eventx
        return true
      end
    end
    # Verificar direita
    if event_direction == 6
      if playerx >= eventx
        return true
      end
    end
    # Verificar acima
    if event_direction == 8
      if playery <= eventy
        return true
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ? Verificar os eventos de condições de ataque
  #    NOTA : Não há turnos no ABS, portanto, não há turnos predefinidos
  #--------------------------------------------------------------------------
  def event_melee_preconditions(event_index)
    if @enemy_dex_loop[event_index] >= @enemy_dex[event_index] * 20
      @enemy_dex_loop[event_index]  = 0
      for i in 0..$data_enemies[@enemy_id[event_index]].actions.size - 1
        if $data_enemies[@enemy_id[event_index]].actions[i].kind == 0
          actions = $data_enemies[@enemy_id[event_index]].actions[i]
          # Verificar a condição do nivel de HP
          if @enemy_hp[event_index] * 100.0 / $data_enemies[@enemy_id[event_index]].maxhp > actions.condition_hp
            next
          end
          # Verificar condição do nível máximo
          if $game_party.max_level < actions.condition_level
            next
          end
          # Verificar condição de switch
          switch_id = actions.condition_switch_id
          if actions.condition_switch_id > 0 and $game_switches[switch_id] == false
            next
          end
          # Verificar Rank para ver se ele é maior, em seguida, os dados roll
          n = rand(10)
          if actions.rating < n
            next
          end
          # Acção de regresso
          case actions.basic
          when 0
            return 0
          when 1
            return 1
          when 2
            return 2
          when 3
            return 3
          end
        end
      end
      # Nenhuma acção tomada
      return 3
    else
      # Adicionar ao dex loop
      @enemy_dex_loop[event_index] += @enemy_dex[event_index]
      return 3
    end
  end
  #--------------------------------------------------------------------------
  # ? Verificar as condições do evento de ataque
  #    NOTA : Não há turnos no ABS, portanto, não há turnos predefinidos
  #--------------------------------------------------------------------------
  def event_skill_preconditions(event_index)
    if @enemy_dex_loop[event_index] >= @enemy_dex[event_index] * 100
      @enemy_dex_loop[event_index]  = 0
      for i in 0..$data_enemies[@enemy_id[event_index]].actions.size - 1
        if $data_enemies[@enemy_id[event_index]].actions[i].kind == 1
          actions = $data_enemies[@enemy_id[event_index]].actions[i]
          # Verificar a condição do nivel de HP
          if @enemy_hp[event_index] * 100.0 / $data_enemies[@enemy_id[event_index]].maxhp > actions.condition_hp
            return 0
          end
          # Verificar condição do nível máximo
          if $game_party.max_level < actions.condition_level
            return 0
          end
          # Verificar condição de switch
          switch_id = action.condition_switch_id
          if actions.condition_switch_id > 0 and $game_switches[switch_id] == false
            return 0
          end
          return actions.skill_id
        end
      end
      return 0
    else
      # Adicionar ao dex loop
      @enemy_dex_loop[event_index] += @enemy_dex[event_index]
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # ? Cálculo da correcção atributo
  #     element_set : Atributos
  #--------------------------------------------------------------------------
  def player_elements_correct(element_set)
    # No caso de não ser atributo
    if element_set == []
      # voltar 100
      return 100
    end
    # O mais fraco é retornado em um atributo que é dada ao método element_rate *
     # É definida no Game_Actor e Game_Enemy a classe que sucedeu a partir desta classe
    weakest = -100
    for i in element_set
      weakest = [weakest, $game_party.actors[@active_actor].element_rate(i)].max
    end
    return weakest
  end
  #--------------------------------------------------------------------------
  # ? Evento de ataque inimigo
  #--------------------------------------------------------------------------
  def event_melee_attack(event_index)
    kind = event_melee_preconditions(event_index)
    case kind
    when 0 # O inimigo a atacar
      @enemy_defending[event_index] = false
      # Decisão de ataque ao primeiro alvo.
      hit_rate = 100
      for i in @enemy_states
          hit_rate *= $data_states[i].hit_rate / 100.0
      end
      hit_result = (rand(100) < hit_rate)
      # Em caso de o alvo ser atingido
      if hit_result == true
        # O cálculo do dano básico
        atk = [@enemy_atk[event_index] - $game_party.actors[@active_actor].pdef / 2, 0].max
        damage = atk * (20 + @enemy_str[event_index] ) / 20
        # Correcção de atributos
        damage *= player_elements_correct([])
        damage /= 100
        # Quando a marca de dano é correcta
        if damage > 0
          # Correcção crítica
          if rand(100) < 4 * @enemy_dex[event_index] / $game_party.actors[@active_actor].agi
            damage *= 2
          end
          # Correcção da defesa
          if  @player_defending == true
            damage /= 2
          end
        end
        # Disperção
        if damage.abs > 0
          amp = [damage.abs * 15 / 100, 1].max
          damage += rand(amp+1) + rand(amp+1) - amp
        end
        # Decisão de ataque ao segundo alvo.
        eva = 8 * $game_party.actors[@active_actor].agi / @enemy_dex[event_index] + $game_party.actors[@active_actor].eva
        hit = damage < 0 ? 100 : 100 - eva
        # Verificar o fugir
        cant_evade = false
        for i in $game_party.actors[@active_actor].states
          if $data_states[i].cant_evade
            cant_evade = true
          end
        end
        hit = cant_evade ? 100 : hit
        hit_result = (rand(100) < hit)
      end
      # Em caso de o alvo desejado ser atingido
      if hit_result == true
        # Cancelamento do membro chocante
        # Nota : Eu ainda não consigo que os efeitos de stats trabalhem correctamente
        # tirar_stat_choque
        # Apartir de danos, subtrair HP
        damage = damage.abs
        $game_party.actors[@active_actor].hp -= damage
        hit_player(damage, @enemy_animation2_id[event_index])
        if $game_party.actors[@active_actor].hp <= 0
          player_dead
        end
        # Mudança de stat
        # Nota : Eu ainda não consigo que os efeitos de stats trabalhem correctamente
        # stat_mais(@enemy_states)
        # stat_menos(@enemy_states)
      end
    when 1 # Inimigo a defender-se
      if @enemy_defending[event_index] != true
        @enemy_defending[event_index] = true
        $game_map.events[event_index].move_speed = $game_map.events[event_index].move_speed - 1
      end
    when 2 # Inimigo a escapar
      # Nota : Podia adicionar um evento de teletransporte para fazer o evento de salto ser maior em relação ao player
    when 3 # Nenhuma medida tomada
    end
  end
  #--------------------------------------------------------------------------
  # ? Evento de ataque por skill
  #--------------------------------------------------------------------------
  def event_skill_attack(event_index)
    # Verificar as condições do inimigo
    skill_id = event_skill_preconditions(event_index)
    # Se as condições não coincidirem
    if skill_id ==  0
      return
    end
    skill = $data_skills[skill_id]
    # Verificar o custo de SP
    if skill.sp_cost > @enemy_sp[event_index]
      return
    end
    @enemy_sp[event_index] -= skill.sp_cost
    # Quando o efeito de competências efectivas amigo da HP com 1 ou mais, a sua própria HP 0,
     # Ou a efectiva distância de habilidade com o amigo da HP 0, o seu próprio HP são 1 ou mais,
    if ((skill.scope == 3 or skill.scope == 4) and @enemy_hp == 0) or
       ((skill.scope == 5 or skill.scope == 6) and @enemy_hp >= 1)
      # ??????
      return
    end
    # Limpar o efeito flag
    effective = false
    # Quando o ID do evento comum é um efeito, ajuste do efeito flag
    effective |= skill.common_event_id > 0
    # Decisão de ataque ao primeiro alvo.
    skill_hit = 100
    for i in @enemy_states
      skill_hit *= $data_states[i].hit_rate / 100.0
    end
    user_hit = 100
    for i in @enemy_states
      user_hit *= $data_states[i].hit_rate / 100.0
    end
    hit = skill_hit
    if skill.atk_f > 0
      hit *= user_hit / 100
    end
    hit_result = (rand(100) < hit)
    # No caso de um skill incerto ajuste do efeito flag
    effective |= hit < 100
    # Em caso de o alvo ser atingido
    if hit_result == true
      # Cálculo de poder
      power = skill.power + @enemy_atk[event_index] * skill.atk_f / 100
      if power > 0
        power -= $game_party.actors[@active_actor].pdef * skill.pdef_f / 200
        power -= $game_party.actors[@active_actor].mdef * skill.mdef_f / 200
        power = [power, 0].max
      end
      # Cálculo de ampliação da categoria
      rate = 20
      rate += (@enemy_str[event_index] * skill.str_f / 100)
      rate += (@enemy_dex[event_index] * skill.dex_f / 100)
      rate += (@enemy_agi[event_index] * skill.agi_f / 100)
      rate += (@enemy_int[event_index] * skill.int_f / 100)
      # Cálcular o dano básico
      damage = power * rate / 20
      # Correcção de atributo
      damage *= player_elements_correct(skill.element_set)
      damage /= 100
      # Quando a marca dos danos está correcta
      if damage > 0
        # Correcção da defesa
        if @player_defending == true
          damage /= 2
        end
      end
      # Dispersão
      if skill.variance > 0 and damage.abs > 0
        amp = [damage.abs * skill.variance / 100, 1].max
        damage += rand(amp+1) + rand(amp+1) - amp
      end
      # Decisão de ataque ao segundo alvo.
      eva = 8 * $game_party.actors[@active_actor].agi / @enemy_dex[event_index] + $game_party.actors[@active_actor].eva
      hit = damage < 0 ? 100 : 100 - eva * skill.eva_f / 100
      cant_evade = false
      for i in $game_party.actors[@active_actor].states
        if $data_states[i].cant_evade
          cant_evade = true
        end
      end
      hit = cant_evade ? 100 : hit
      hit_result = (rand(100) < hit)
      # No caso de um skill incerto ajuste do efeito flag
      effective |= hit < 100
    end
    # Decisão de ataque ao primeiro alvo.
    if hit_result == true
      # Em caso de ataque físico diferente do poder 0
      if skill.power != 0 and skill.atk_f > 0
        # Cancelamento do membro chocante
        # Nota : Eu ainda não consigo que os efeitos de stats trabalhem correctamente
        # tirar_stat_choque
        # Ajuste do efeito flag
        effective = true
      end
      # A partir de danos subtração de HP
      last_hp = $game_party.actors[@active_actor].hp
      $game_party.actors[@active_actor].hp -= damage
      effective |= $game_party.actors[@active_actor].hp != last_hp
      # Mudança de stat
      # Nota : Eu ainda não consigo que os efeitos de stats trabalhem correctamente
      # efeito |= stat_mais(skill.plus_state_set)
      # efeito |= stats_menos(skill.minus_state_set)
      if skill.power == 0 # When power is 0
        # Ajuste de dano para 0
        damage = 0
      end
      hit_player(damage, skill.animation2_id)
      if $game_party.actors[@active_actor].hp <= 0
           player_dead
        end
    end
  end
  #--------------------------------------------------------------------------
  # ? Mostrar animação de dano
  #--------------------------------------------------------------------------
  def player_dead
    if $game_party.all_dead?
      $game_temp.gameover = true
    end
    $scene = Scene_Menu.new
  end
  #--------------------------------------------------------------------------
  # ? Mostrar animação de dano
  #--------------------------------------------------------------------------
  def hit_player(damage, animation_id)
    if damage != 0
      $game_player.jump(0, 0)
      $game_player.animation_id = animation_id
      @display.bitmap.clear
      @clear_counter = 0
      @display.bitmap.font.name = $defaultfonttype  # Unknown At This Time
      @display.bitmap.font.size = 32
      @display.x = ($game_player.real_x - $game_map.display_x) / 4
      @display.y = ($game_player.real_y - $game_map.display_y) / 4
      @display.z = 500
      @display.bitmap.font.color.set(255, 0, 0)
      @display.bitmap.draw_text(@display.bitmap.rect, damage.to_s, 1)
    end
  end
  #--------------------------------------------------------------------------
  # ? Cálculo da correcção de atributo
  #     ajuste de elemento : Atributo
  #--------------------------------------------------------------------------
  def event_elements_correct(element_set, event_index)
    # No caso de não ser atributo
    if element_set == []
      # return 100
      return 100
    end
    # O mais fraco é retornado em um atributo que é dada ao método element_rate *
     # É definida no Game_Actor e Game_Enemy a classe que sucedeu a partir desta classe
    weakest = -100
    for i in element_set
      # Nota : Eu ainda não consigo que os efeitos de stats trabalhem correctamente
      weakest = [weakest, $data_enemies[@enemy_id[event_index]].element_rate(i)].max
    end
    return weakest
  end
  #--------------------------------------------------------------------------
  # ? Precondições de ataque furtivo ao inimigo
  #--------------------------------------------------------------------------
  def player_melee_preconditions
    for i in 1..@event_counter
      # Verificar de o evento é inimigo
      if @enemy_id[i] == 0
        next
      end
      if in_range?(i,1)
        player_melee_attack(i)
        next
      end
    end
  end
  #--------------------------------------------------------------------------
  # ? Evento de ataque furtivo
  #--------------------------------------------------------------------------
  def player_melee_attack(event_index)
      # Decisão de ataque ao primeiro alvo.
      hit_rate = 100
      for i in  $game_party.actors[@active_actor].states
          hit_rate *= $data_states[i].hit_rate / 100.0
      end
      hit_result = (rand(100) < hit_rate)
      # No caso de o alvo ser atingido
      if hit_result == true
        # Cálculo de dano básico
        atk = [$game_party.actors[@active_actor].atk - @enemy_pdef[event_index] / 2, 0].max
        damage = atk * (20 + $game_party.actors[@active_actor].str) / 20
        # Correcção de atributo
        damage *= 100 #evento_elementos_correcção($game_party.actors[@active_actor].element_set, event_index)
        damage /= 100
        # Quando a marca de dano está correcta
        if damage > 0
          # Correcção crítica
          if rand(100) < 4 * $game_party.actors[@active_actor].dex / @enemy_agi[event_index]
            damage *= 2
          end
          # Correcção de defesa
          if @enemy_defending== true
            damage /= 2
          end
        end
        # Dispersão
        if damage.abs > 0
          amp = [damage.abs * 15 / 100, 1].max
          damage += rand(amp+1) + rand(amp+1) - amp
        end
        # Decisão de ataque ao segundo alvo
        eva = 8 * @enemy_agi[event_index] / $game_party.actors[@active_actor].dex + @enemy_eva[event_index]
        hit = damage < 0 ? 100 : 100 - eva
        # Verificar evadir
        cant_evade = false
        for i in @enemy_states
          if $data_states[i].cant_evade
            cant_evade = true
          end
        end
        hit = cant_evade ? 100 : hit
        hit_result = (rand(100) < hit)
      end
      # No caso de o alvo ser atingido
      if hit_result == true
        # Cancelamento de membro chocante
        # Nota : Eu ainda não consigo que os efeitos de stats trabalhem correctamente
        # tirar_stat_choque
        # Apartir de danos, subtrair HP
        damage = damage.abs
        @enemy_hp[event_index] -= damage
        # Mudança de stat
        # Nota : Eu ainda não consigo que os efeitos de stats trabalhem correctamente
        # stat_mais ($game_party.actors[@active_actor].states)
        # stat_menos($game_party.actors[@active_actor].states)
        hit_event(event_index,damage, $game_party.actors[@active_actor].animation2_id)
        if @enemy_hp[event_index] <= 0
           battle_spoils(event_index)
        end
      end
    end
  #--------------------------------------------------------------------------
  # ? Precondições do skill de ataque do player
  #--------------------------------------------------------------------------
  def player_skill_preconditions(index)
    if$game_party.actors[@active_actor].skill_learn?(@skill_hot_key[index])
      # Ajuste de skill
      skill = $data_skills[@skill_hot_key[index]]
      # Verificar o custo de SP
      if skill.sp_cost > $game_party.actors[@active_actor].sp
        return
      end
      # Ajuste SP
      $game_party.actors[@active_actor].sp -= skill.sp_cost
      # Verificar skill Scope
      case skill.scope
      when 1 # Um inimigo
        for i in 1..@event_counter
        # Verificar se o evento é inimigo
          if @enemy_id[i] == 0
            next
          else
            case $data_classes[$game_party.actors[@active_actor].class_id].position
            when 0
              if in_range?(i,1)
                player_skill_attack(skill, i)
                return
              end
            when 1
              if in_range?(i,2)
                player_skill_attack(skill, i)
                return
              end
            when 2
              if in_range?(i,5)
                player_skill_attack(skill, i)
                return
              end
            end
          end
        end
      when 2 # Todos os inimigos
        for i in 1..@event_counter
        # Veificar se o evento é inimigo
          if @enemy_id[i] == 0
            next
          else
            case $data_classes[$game_party.actors[@active_actor].class_id].position
            when 0
              if in_range?(i,1)
                player_skill_attack(skill, i)
                return
              end
            when 1
              if in_range?(i,2)
                player_skill_attack(skill, i)
                return
              end
            when 2
              if in_range?(i,5)
                player_skill_attack(skill, i)
                return
              end
            end
          end
        end
      when 3 # Um aliado
        # Nota : Eu ainda não consigo que os efeitos de stats trabalhem correctamente  e por consequente
        # não se pode introduzir, mas estes skills podem ser activados no Menu principal
      when 4 # Todos os aliados
        # Nota : Eu ainda não consigo que os efeitos de stats trabalhem correctamente  e por consequente
        # não se pode introduzir, mas estes skills podem ser activados no Menu principal
      end
    else
      return
    end
  end
  #--------------------------------------------------------------------------
  # ? Skill de ataque do player
  #--------------------------------------------------------------------------
  def player_skill_attack(skill, event_index)
     # Quando o efeito de competências efectivas amigo da HP com 1 ou mais, a sua própria HP 0,
     # Ou a efectiva distância de habilidade com o amigo da HP 0, o seu próprio HP são 1 ou mais
      if ((skill.scope == 3 or skill.scope == 4) and @enemy_hp == 0) or
        ((skill.scope == 5 or skill.scope == 6) and @enemy_hp >= 1)
        return
      end
    # Apagar o efeito flag
    effective = false
    # Quando o ID doevento comum é efectado, ajuste do efeito flag
    effective |= skill.common_event_id > 0
    # Decisão de ataque ao primeiro alvo
    skill_hit = 100
    for i in $game_party.actors[@active_actor].states
      skill_hit *= $data_states[i].hit_rate / 100.0
    end
    user_hit = 100
    for i in $game_party.actors[@active_actor].states
      user_hit *= $data_states[i].hit_rate / 100.0
    end
    hit = skill_hit
    if skill.atk_f > 0
      hit *= user_hit / 100
    end
    hit_result = (rand(100) < hit)
    # No caso de um skill incerto, ajustar o efeito flag
    effective |= hit < 100
    # No caso do alvo receber ataque
    if hit_result == true
      # Calcular poder
      power = skill.power + $game_party.actors[@active_actor].atk * skill.atk_f / 100
      if power > 0
        power -= @enemy_pdef[event_index] * skill.pdef_f / 200
        power -= @enemy_mdef[event_index] * skill.mdef_f / 200
        power = [power, 0].max
      end
      # Calculo da ampliação de categoria
      rate = 20
      rate += ($game_party.actors[@active_actor].str * skill.str_f / 100)
      rate += ($game_party.actors[@active_actor].dex * skill.dex_f / 100)
      rate += ($game_party.actors[@active_actor].agi * skill.agi_f / 100)
      rate += ($game_party.actors[@active_actor].int * skill.int_f / 100)
      # Cálculo de dano básico
      damage = power * rate / 20
      # Correcção de atributo
      damage *= 100 #Correcção dos elementos do evento(skill.element_set, event_index)
      damage /= 100
      # Quando a marca de dano é correcto
      if damage > 0
        # Correcção de defesa
        if @enemy_defending == true
          damage /= 2
        end
      end
      # Dispersão
      if skill.variance > 0 and damage.abs > 0
        amp = [damage.abs * skill.variance / 100, 1].max
        damage += rand(amp+1) + rand(amp+1) - amp
      end
      # Decisão de ataque ao segundo alvo
      eva = 8 * @enemy_agi[event_index] / $game_party.actors[@active_actor].dex + @enemy_eva[event_index]
      hit = damage < 0 ? 100 : 100 - eva * skill.eva_f / 100
      cant_evade = false
      for i in @enemy_states
        if $data_states[i].cant_evade
          cant_evade = true
        end
      end
      hit = cant_evade ? 100 : hit
      hit_result = (rand(100) < hit)
      # No caso de um skill incerto, ajustar o efeito flag
      effective |= hit < 100
    end
    # No caso do alvo receber ataque
    if hit_result == true
      # No caso do ataque físico ser diferente do poder 0
      if skill.power != 0 and skill.atk_f > 0
        # Cancelamento dos membros de choque
        # Nota : Eu ainda não consigo que os efeitos de stats trabalhem correctamente
        # tirar_stats_choque
        # Ajustar o efeito flag
        effective = true
      end
      # Subtracção do dano através do HP
      last_hp = @enemy_hp[event_index]
      @enemy_hp[event_index] -= damage
      effective |= @enemy_hp[event_index] != last_hp
      # Mudança de stat
      # Nota : Eu ainda não consigo que os efeitos de stats trabalhem correctamente
      # efeito |= stats_mais(skill.plus_state_set)
      # efeito |= stats_menos(skill.minus_state_set)
      if skill.power == 0 # Quando o poder é 0
        # Ajuste de dano para 0
        damage = 0
      end
      hit_event(event_index, damage, skill.animation2_id)
      if @enemy_hp[event_index] <= 0
            battle_spoils(event_index)
        end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ? Mostrar animação no dano
  #--------------------------------------------------------------------------
  def hit_event(event_index, damage, animation_id)
    if damage != 0
      $game_map.events[event_index].jump(0, 0)
      $game_map.events[event_index].animation_id = animation_id
      @display.bitmap.clear
      @clear_counter = 0
      @display.bitmap.font.name = $defaultfonttype  # Unknown At This Time
      @display.bitmap.font.size = 32
      @display.x = ($game_map.events[event_index].real_x - $game_map.display_x) / 4
      @display.y = ($game_map.events[event_index].real_y - $game_map.display_y) / 4
      @display.z = 500
      @display.bitmap.font.color.set(255, 0, 0)
      @display.bitmap.draw_text(@display.bitmap.rect, damage.to_s, 1)
    end
  end
  #--------------------------------------------------------------------------
  # ? Spoils da batalha
  #--------------------------------------------------------------------------
  def battle_spoils(event_index)
    $game_map.map.events[event_index].name = "Dead"
    @enemy_id[event_index] = 0
    $game_map.events[event_index].erase
    treasures = []
    if rand(100) < @enemy_treasure_prob[event_index]
      if @enemy_item_id[event_index] > 0
        treasures.push($data_items[@enemy_item_id[event_index]])
      end
      if @enemy_weapon_id[event_index]> 0
        treasures.push($data_weapons[@enemy_weapon_id[event_index]])
      end
      if @enemy_armor_id[event_index] > 0
        treasures.push($data_armors[@enemy_armor_id[event_index]])
      end
    end
    # ???????? 6 ??????
    treasures = treasures[0..5]
    # EXP ??
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      if actor.cant_get_exp? == false
        last_level = actor.level
        actor.exp += @enemy_exp[event_index]
      end
    end
    # ??????
    $game_party.gain_gold(@enemy_gold[event_index] )
    # ???????
    for item in treasures
      case item
      when RPG::Item
        $game_party.gain_item(item.id, 1)
      when RPG::Weapon
        $game_party.gain_weapon(item.id, 1)
      when RPG::Armor
        $game_party.gain_armor(item.id, 1)
      end
    end
  end
end