# cluedo_bash-game
Game "Cluedo" (bash-script based)
Boardgame "Cluedo". 

По настольной игре "Клюэдо". 
Пока версия без ИИ (без "предположений" соперников).
Все настройки в "файле.conf" - можно изменить список "подозреваемых" и "орудий убийств".

** Правила **
Вы детектив и ваша цель разгадать за минимум ходов "кто, где и чем совершил убийство", каждый ход делая соответсвующие предположение. Если у соперника №1 есть на руках карточка с опровержение - он его сообщают, если нет опровергать будет "Игрок №2", и т.д. Если опровержений нет, то это либо победа, либо эти опровержения есть у вас, либо карты с этими опровержениями в "бассейне".
При этом можно делать предположения о месте преступления только находясь на этом месте.
Перемещение между местами предпологаемого преступление происходит в начале хода - в зависимости от выпавшего на кубике числа (чем больше, тем больше возможностей).

*Интерфейс:*
 - В первой строке(желтым) перечислены список "подозреваемых".
 - Во второй (фиолетовым) - список "орудий убийств".
 - Блок "перечень ходов" - начинается с указания с какой комнаты начинаете игру.
 - Выпавшие на кубике число
 - Перечень известных опровержений на начало игры твоиму игроку
 - Перечень опровержений, находычцщихся бассейне. Не известные твоему игроку опровержения не отображаются.
 - Карта местности: бассейн с расположенными(по мере отдаленности) вокруг местами предпологаемого преступления. Помечено текущие расположение вашего игрока.
 

