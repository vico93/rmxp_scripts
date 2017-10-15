# CBS v2

## Introdução
Este com certeza é um dos melhores scripts de batalha para o Rpg Maker XP!
Também conhecido como *Cybersam*, ele proporciona uma batalha animada, ou seja, os personagens fazem uma animação diferente para cada tipo de comando.

Para usá-lo corretamente, é necessário abandonar os battlers do RTP e passar a usar os battlers animados específicos para o CBS.

## Instalação
Bom, este sistema usa dois scripts. Crie uma nova classe acima do `Main` de nome Animated_Sprite e cole o conteúdo do arquivo `Animated_Sprite.rb`.

Em seguida crie uma nova classe abaixo do primeiro script e acima do `Main` (Isto deve ser corretamente feito, pois ao contrário não funciona), de o nome de Battle_animation e cole o conteúdo do arquivo `Battle_animation.rb`.

## Instruções
Este sistema funciona apenas copiando e colando os scripts acima na forma correta no seu projeto. Mas ele pode ser editado de várias maneiras possíveis para funcionar da forma que desejar... 

Se você não entende nada sobre a linguagem de programação Ruby, vai com calma na hora de modificá-lo.

Agora vamos dar umas dicas de como personalizar este sistema:

1. Este script só aceita battler animados de tamanho *256 x 448*. Se colocar uma imagem maior, ele vai cortar o personagem pela metade e vai ficar piscando. Bom, para usar battler animados de tamanho maior, que normalmente são de 512 x 896, mude no script Battle_animation a linha 236 `@frame_width, @frame_height = 64, 64`. Os números 64 e 64, são o tamanho x e y de um frame. 
Mude para `128, 129`. Com estas coordenadas, poderá usar battlers animados com tamanho de *512 x 896*.
Lembre-se, terá que usar agora apenas battlers deste tamanho, não poderá mais usar battlers de *256 x 448*.
 
2. Poderá também criar diferentes tipos de ataques para diferente tipos de armas. Basta ir no script Battle_animation e da linha 509 à 517 poderá mudar o que desejar:
```
--------------------------------------------------------------------------
if @active_battler.is_a?(Game_Actor)
if @active_battler.weapon_id == 1 # <-- weapon ID number1
@weapon_sprite = 4 # <-- battle animation4
elsif @active_battler.weapon_id == 5 # <-- weapon ID number5
@weapon_sprite = 4 # <-- battle animation2
elsif @active_battler.weapon_id == 9 # <-- weapon ID number9
@weapon_sprite = 4 # <-- battle animation0
elsif @active_battler.weapon_id == 13 # <-- weapon ID number13
@weapon_sprite = 4 # <-- battle animation6 
---------------------------------------------------------------------------
```
Observem os números: `1, 5, 9, 13`. Cada número é um ID de um equipamento. Abaixo de cada um tem os números: `4, 4, 4, 4`. Estes números são a pose que o personagem vai fazer.

Poses:
```
-------------------------------
# 0 = Movimentação
# 1 = Esperando
# 2 = Defendendo
# 3 = Levando ataque
# 4 = Atacando
# 5 = Usando habilidade
# 6 = Morto
# 7 = Vitória
-------------------------------
```
Coloque a ID do equipamento que deseja e mude o número da pose para outra de acordo com a tabela acima. Assim mudará a forma de atacar de acordo com o equipamento.
 

3. Da mesmo forma acima que mudou o jeito de atacar de acordo com o equipamento, poderá também mudar a forma de usar uma habilidade de acordo com a habilidade. Para isso mude tudo da linha 638 até a 644. Mas desta vez, mude o nome da habilidade.
 

4. Mude também o jeito de usar habilidades do inimigo. Mude tudo da linha 647 até a 652.

