=begin
Esse script aqui que eu criei faz com que as horas do seu jogo fique igual as horas do seu computador.

Primeiramente crie um novo script acima do Scene_Title e coloque esse module abaixo:

Código
=end:
# Module Script de Horas 
#   Criado por Firewords
#-----------------------------------
# v-1

module Horas
  
  attr :HORAS
  
  def update
    @HORAS = Time.new.hour
    
      if self.entre?(0, 3)
        $game_screen.start_tone_change(Tone.new(-155, -155, -155, 0), 1)
      end
      
      if self.entre?(4, 6)
        $game_screen.start_tone_change(Tone.new(-85, -85, -85, 0), 1)
      end
      
      if self.entre?(7, 9)
        $game_screen.start_tone_change(Tone.new(-35, -35, -35, 0), 1)
      end
      
      if self.entre?(10, 15)
        $game_screen.start_tone_change(Tone.new(0, 0, 0, 0), 1)
      end
      
      if self.entre?(16, 17)
        $game_screen.start_tone_change(Tone.new(-25, -25, -25, 0), 1)
      end
      
      if self.entre?(18, 19)
        $game_screen.start_tone_change(Tone.new(-70, -70, -70, 0), 1)
      end
      
      if self.entre?(20, 21)
        $game_screen.start_tone_change(Tone.new(-110, -110, -110, 0), 1)
      end
      
      if self.entre?(22, 23)
        $game_screen.start_tone_change(Tone.new(-155, -155, -155, 0), 1)
      end
      
  end
      
  def entre?(h1, h2)
    return true if @HORAS >= h1 && @HORAS <= h2
    return false
  end
  
  module_function :update
  module_function :entre?
end
=begin
Esse é o script que processa todas as condições e mudança de tons de tela. Para modificar as horas que você quer que mude o tom de tela, veja os varios ifs que tem dentro do def update. Todos que possuem o def entre?(n1, n2) é a condição que está sendo criada para as horas para que a tela mude de cor.
E então dentro dessas condições terá Tone.new(n1, n2, n3, n4), sendo que n1 é vermelho, n2 verde, n3 azul e n4 cinza, ai é so mudar esse números para a tonalidade ficar do jeito que você quer.

Para atualizar as horas o tempo todo você deve ir até o Scene_Map e procurar pela linha: @spriteset.update, adicione acima dessa linha:

Código:
Horas.update
Pronto! É somente isso para você configurar e colocar esse script para funcionar.
Mas se você quer criar condições para se seja determinada hora, você pode fazer isso a eventos mesmo sem problemas! Só ir na opção "Condições" e na 4ª aba você irá encontrar a opção "Scripts", dentro dela você coloca Horas.entre?(n1, n2). Sendo n1 a hora mínima e n2 a máxima. Por exemplo se estiver entre as horas 10 e 12, você cria Horas.entre?(10, 12), e dentro da condição acontece o que você quer. Mas se você quer somente um hora, você coloca ela em n1 e n2 (se for 10 por exemplo, você colocar Horas.entre?(10, 10)).

Previsão apra a versão 2:
- Mudar tom de tela somente em mapas desejados;
- Uma janela para mostrar que horas, minutos e segundos são atualmente;
- O que você sugerir.
=end