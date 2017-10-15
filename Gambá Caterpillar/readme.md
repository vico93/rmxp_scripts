# Gambá Caterpillar

## Introdução
Com esse sistema os outros membros do grupo seguem o primeiro, que você controla, mas diferente dos outros Caterpillares, os membros do grupo são eventos, que ficam em um certo mapa, e são movidos para o mapa onde você está, assim como no sistema de ferramentas do XAS ABS, permitindo que você customize melhor cada herói que te segue. Se estiver utilizando um ABS, você pode até programar para ele lutar ao seu lado.
No mapa designado, devem estar os eventos com o ID dos heróis no database. Por exemplo, a party padrão do Maker são os heróis 1, 2, 7 e 8, então eu preciso ter 8 eventos no mapa, no mínimo, sendo o evento 1 o herói 1 (se ele for o lider da party não precisa), o 2 o herói 2, e assim sucessivamente. Eles não precisam necessariamente te seguir, você pode programá-los para fazer o que quiser.

## Parâmetros
* ID do mapa onde estão os eventos dos heróis: `MAPID = 2`
* Com essa opção ativa, os heróis serão teletransportados automaticamente para perto do herói se o herói estivar longe. Útil caso algum membro fique preso em alguma parte do mapa: `RELOCAR = true`
* Distância para relocar os membros da party: `RELDIST = 10`
