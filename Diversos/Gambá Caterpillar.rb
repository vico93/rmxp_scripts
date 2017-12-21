#=====================================================
#                   Gambá Caterpillar
#======================================================
#
# Com esse sistema os outros membros do grupo seguem
# o primeiro, que você controla, mas diferente dos
# outros Caterpillares, os membros do grupo são eventos,
# que ficam em um certo mapa, e são movidos para o mapa
# onde você está, assim como no sistema de ferramentas
# do XAS ABS, permitindo que você customize melhor cada
# herói que te segue. Se estiver utilizando um ABS, você
# pode até programar para ele lutar ao seu lado.
# No mapa designado, devem estar os eventos com o ID dos
# heróis no database. Por exemplo, a party padrão do Maker
# são os heróis 1, 2, 7 e 8, então eu preciso ter 8 eventos
# no mapa, no mínimo, sendo o evento 1 o herói 1 (se ele
# for o lider da party não precisa), o 2 o herói 2, e assim
# sucessivamente. Eles não precisam necessariamente te
# seguir, você pode programá-los para fazer o que quiser
#
# ID do mapa onde estão os eventos dos heróis
  MAPID = 2
#
# Com essa opção ativa, os heróis serão teletransportados
# automaticamente para perto do herói se o herói estivar
# longe. Útil caso algum membro fique preso em alguma
# parte do mapa
  RELOCAR = true
# Distância para relocar os membros da party
  RELDIST = 10
#
#
#======================================================


module Gamba_Map
  map_id = MAPID
  map = load_data(sprintf("Data/Map%03d.rxdata", map_id))
  @@events = map.events
end

class Game_Temp
 
  attr_accessor :criou
  attr_accessor :partyids
  alias gamba_caterpillar_initialize initialize
  def initialize
    @criou = false
    @partyids = []
    gamba_caterpillar_initialize
  end
 
end

class Game_Actor < Game_Battler
  attr_accessor :actor_id
end

class Caterpillar_Event < Game_Event
  include Gamba_Map
end


class Caterpillar_Token < Caterpillar_Event
 
  attr_accessor :token
  def initialize(i)
   
   
     
      actor = $game_party.actors[i]
      id = actor.id
     
      original_event = @@events[id]
      return if original_event == nil
      user = $game_player
     
      event = original_event.dup
      event.x = user.x
      event.y = user.y
     
      for p in 1..$game_map.events.size
        if $game_map.events[p] == nil
          $game_temp.partyids[id] = p
        else
          $game_temp.partyids[id] = $game_map.events.size + 1
        end
      end
      @token = true
      super($game_map.map_id, event)
   
  end
end 
 
class Scene_Map
  alias gamba_caterpillar_update update
  alias gamba_caterpillar_transfer transfer_player
  def update
       
   
   
    if $game_temp.criou == false
      for i in 1..($game_party.actors.size-1)
     
        bullet_token = Caterpillar_Token.new(i)
        $game_map.add_token_cater(bullet_token)
       
      end
      $game_temp.criou = true
   
    elsif RELOCAR == true
      for i in 1..($game_party.actors.size-1)
        actor = $game_party.actors[i]
        id = actor.id
        ex = $game_map.events[$game_temp.partyids[id]].x
        ey = $game_map.events[$game_temp.partyids[id]].y
        hx = $game_player.x
        hy = $game_player.y
       
        radius =((hx-ex) ** 2) + ((hy-ey) ** 2)
        $game_map.events[$game_temp.partyids[id]].moveto(hx,hy) if radius > (RELDIST ** 2)

      end
    end
   
    gamba_caterpillar_update
  end
 
  def transfer_player
   
    gamba_caterpillar_transfer
    $game_temp.criou = false
   
  end
 
end


#========================================================#
# Créditos para Xiderowg por essa parte do script,
# baseado no sistema de ferramentas do XMS ABS
#========================================================#

module Gamba_RefreshToken
  def refresh_token
    for event in $game_map.need_add_tokens
      @character_sprites.push(Sprite_Character.new(@viewport1, event))
    end
    $game_map.need_add_tokens.clear
    for sprite in @character_sprites.dup
      if $game_map.need_remove_tokens.empty?
        break
      end
      if $game_map.need_remove_tokens.delete(sprite.character)
        @character_sprites.delete(sprite)
        sprite.dispose
      end
    end
    $game_map.need_refresh_token = false
  end
end



class Spriteset_Map
  include Gamba_RefreshToken
  alias xrxs_lib15_update update
  def update
    xrxs_lib15_update
    refresh_token if $game_map.need_refresh_token
  end
end

class Game_Map
  attr_accessor :need_refresh_token
  attr_accessor :events
  alias gamba_caterpillar_map_update update
  def update
    gamba_caterpillar_map_update

  end
  def need_add_tokens
    @need_add_tokens = [] if @need_add_tokens == nil
    return @need_add_tokens
  end
  def need_remove_tokens
    @need_remove_tokens = [] if @need_remove_tokens == nil
    return @need_remove_tokens
  end

  def add_token_cater(token_event)
    @events[$game_temp.partyids[token_event.id]] = token_event
   
    self.need_add_tokens.push(token_event)
    self.need_refresh_token = true
  end

  #def remove_token_cater(token_event)
  #  @events.delete($game_temp.partyids[token_event.id])
  #  self.need_remove_tokens.push(token_event)
  #  self.need_refresh_token = true
  #end

end

class Game_Event < Game_Character
  attr_accessor :token
  def initialize(map_id, event)
    super()
    @map_id = map_id
    @event = event
    @id = @event.id
    @erased = false
    @starting = false
    @through = true
    #@token = false
    moveto(@event.x, @event.y)
    refresh
  end
end 

class Interpreter

  def setup_starting_event
    if $game_map.need_refresh
      $game_map.refresh
    end
    if $game_temp.common_event_id > 0
      setup($data_common_events[$game_temp.common_event_id].list, 0)
      $game_temp.common_event_id = 0
      return
    end
    for event in $game_map.events.values
      if event.starting
        if event.trigger < 3
          event.clear_starting
          event.lock
        end
      #"                                                     "#
        if event.token != nil and event.token == true
            setup(event.list, $game_temp.partyids[event.id])
        else
            setup(event.list, event.id)
        end   
      #"                                                     "#
        return
      end
    end
    for common_event in $data_common_events.compact
      if common_event.trigger == 1 and
         $game_switches[common_event.switch_id] == true
        setup(common_event.list, 0)
        return
      end
    end
  end

 
end