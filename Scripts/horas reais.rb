=begin
Esse script aqui que eu criei faz com que as horas do seu jogo fique igual as horas do seu computador.

Primeiramente crie um novo script acima do Scene_Title e coloque esse module abaixo:

C�digo
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
Esse � o script que processa todas as condi��es e mudan�a de tons de tela. Para modificar as horas que voc� quer que mude o tom de tela, veja os varios ifs que tem dentro do def update. Todos que possuem o def entre?(n1, n2) � a condi��o que est� sendo criada para as horas para que a tela mude de cor.
E ent�o dentro dessas condi��es ter� Tone.new(n1, n2, n3, n4), sendo que n1 � vermelho, n2 verde, n3 azul e n4 cinza, ai � so mudar esse n�meros para a tonalidade ficar do jeito que voc� quer.

Para atualizar as horas o tempo todo voc� deve ir at� o Scene_Map e procurar pela linha: @spriteset.update, adicione acima dessa linha:

C�digo:
Horas.update
Pronto! � somente isso para voc� configurar e colocar esse script para funcionar.
Mas se voc� quer criar condi��es para se seja determinada hora, voc� pode fazer isso a eventos mesmo sem problemas! S� ir na op��o "Condi��es" e na 4� aba voc� ir� encontrar a op��o "Scripts", dentro dela voc� coloca Horas.entre?(n1, n2). Sendo n1 a hora m�nima e n2 a m�xima. Por exemplo se estiver entre as horas 10 e 12, voc� cria Horas.entre?(10, 12), e dentro da condi��o acontece o que voc� quer. Mas se voc� quer somente um hora, voc� coloca ela em n1 e n2 (se for 10 por exemplo, voc� colocar Horas.entre?(10, 10)).

Previs�o apra a vers�o 2:
- Mudar tom de tela somente em mapas desejados;
- Uma janela para mostrar que horas, minutos e segundos s�o atualmente;
- O que voc� sugerir.
=end