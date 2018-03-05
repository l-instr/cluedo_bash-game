#!/bin/bash
. ${0/\.sh/.conf}
grep -q "ПОБЕДА" /tmp/Cluedo_round.log \
	&& { for i in /tmp/Cluedo /tmp/Cluedo_Bass /tmp/Cluedo_igrok-0* /tmp/Cluedo_round.log; do echo "__ $i"; cat $i;done > "/tmp/Cluedo_round-$(date -d "@$(stat -c %Z /tmp/Cluedo_round.log)" +%y%m%d_%H%M).log"; rm /tmp/Cluedo /tmp/Cluedo_round.log /tmp/Cluedo_igrok-0*; }

INIT(){
	echo "******** Генерим игру ******"
	## echo "NN:Выбор:K:P:T:КтоОтветил:Что:Кубик" >> /tmp/Cluedo_round.log
	echo -e "00:Очутился в:K_$(echo "$Ks"|shuf -n1|X_)::: Cluedo:Начало:" > /tmp/Cluedo_round.log

	# Выбор случайных вариантов - задание игры
	rKs=$(echo "$Ks"|shuf -n1)
	rPs=$(echo "$Ps"|shuf -n1)
	rTs=$(echo "$Ts"|shuf -n1)
	echo -e "$rKs\n$rPs\n$rTs" > /tmp/Cluedo	# /tmp/Cluedo   	- Задание
	{
		echo "$Ks" | grep -v "$(sed -n 1p /tmp/Cluedo)"
		echo "$Ps" | grep -v "$(sed -n 2p /tmp/Cluedo)"
		echo "$Ts" | grep -v "$(sed -n 3p /tmp/Cluedo)"
	} > /tmp/Cluedo_other 				# /tmp/Cluedo_other	- колода без задания

	# /tmp/Cluedo_Bass		- Бассейн: остаток колоды + количество игроков
	nB=$[$(cat /tmp/Cluedo_other| wc -l)%$Ni]
	[ $nB -le 1 ] && nB=$[$nB+$Ni]; shuf -n $nB /tmp/Cluedo_other| sort > /tmp/Cluedo_Bass; > /tmp/Cluedo_Bass_known
	# /tmp/Cluedo_Bass_known	- какие уже известны мне из бассейна

	# /tmp/Cluedo_igrok-0№		- карточки № игрока
	split -l $[($(cat /tmp/Cluedo_other| wc -l)-$nB)/$Ni] -d <(SpisokBez /tmp/Cluedo_other /tmp/Cluedo_Bass | shuf) /tmp/Cluedo_igrok-
}
[ -f /tmp/Cluedo ] || INIT

ROUND(){
	clear; 
	#Бросаем кубик
	d6=$(~/bin/Function/d6 2>/dev/null)

	# Твои: ...
	#ECHOn "Твои   "; 
	#	sort /tmp/Cluedo_igrok-00 | ColorList
	#ECHO "($(cat /tmp/Cluedo_igrok-00 | wc -l))"
	
	# Бассейн
	#ECHOn "Бассейн"
	#	cat /tmp/Cluedo_Bass_known| sed "s/\([^ ]*\)/\\\\\\${cB}[\1\\\\\\${cB}]_/g" | ColorList | tr -d " " | tr "_" " "; echo -ne "${cB}"
	#	SpisokBez /tmp/Cluedo_Bass <(sort /tmp/Cluedo_Bass_known) | sed "s/.*/[X]\\\\\\t/" | xargs echo -ne  | tr -d " "
	#ECHO "\t($[$(cat /tmp/Cluedo_other| wc -l)%$Ni+$Ni])"
	
	for i in P T; do grep -h "^$i" /tmp/Cluedo /tmp/Cluedo_other | sort |sed -f <(Known.sed)| sed "/^.[^:]/s/^/  /"| ColorList ; echo;done
	echoHR - 
	if   [ $1 -le 10 ]; then
		viewLOG
	elif [ $1 -le 15 ]; then  
		viewLOG | head -n $[$1-1] | tail -n +2 | egrep -v "Кубик:"; viewLOG| tail -1 
	else 
		viewLOG | head -n $[$1-1] | tail -n +2 | egrep -v "(Кубик|Бассейн):"; viewLOG| tail -1 
	fi
	echoHR - 
		Map | sed -f <(~/bin/Function/d6.sed.sh $d6) 
	#Комнаты
	echo -e "${cK}> Перейдем в:" 
	#1) echo "$1:Пропуск хода:$(KomnataSey4as):::  Кубик:-:1" >> /tmp/Cluedo_round.log ; continue ;;
	case $d6 in
	1) echo -ne "${cK}"; vKs=$(KomnataSey4as|X_); echo "Остался: $vKs" ;;
	[23]) echo -ne "${cK}"; select vKs in $(KomnataSey4as|sed -f <(Known.sed)|X_) $(echo -e "$Ks\n$Ks" | grep -C1 "$(KomnataSey4as)" | grep -v -- "--"| sort -u|grep -v "$(KomnataSey4as)"|sed -f <(Known.sed)|X_| shuf -n1); do [ -z "$vKs" ] || break; done ;;
	[56]) echo -ne "${cK}"; select vKs in $(diff /tmp/Cluedo_Bass <(sort /tmp/Cluedo_Bass_known) >/dev/null || echo Бассейн) $(echo $(KomnataSey4as|sed -f <(Known.sed)|X_) $(echo -e "$Ks" | grep -v "$(KomnataSey4as)" | shuf -n $[$d6-2] |sort|sed -f <(Known.sed)|X_) |tr " " "\n"|sort|xargs echo); do [ -z "$vKs" ] || break; done ;;
	*) echo -ne "${cK}"; select vKs in $(echo -e "$Ks\n$Ks" | grep -C1 "$(KomnataSey4as)" | grep -v -- "--"| sort -u|sed -f <(Known.sed)|X_); do [ -z "$vKs" ] || break; done ;;
	esac
	if [ "$vKs" = "Бассейн" ];then
		Bs="$(SpisokBez /tmp/Cluedo_Bass <(sort /tmp/Cluedo_Bass_known)|shuf -n1)"
		echo $Bs >> /tmp/Cluedo_Bass_known
		Otv="$(echo $Bs|X_)"	
		## echo "NN:Выбор:K:P:T:КтоОтветил:Что:Кубик" >> /tmp/Cluedo_round.log
		echo "$1:Вернулся в:$(KomnataSey4as):::Бассейн:$Bs:$d6" >> /tmp/Cluedo_round.log
		
	else
		vKs=${vKs/?:}
	#Персонажи
		echo -ne "${cP}"; select vPs in $(echo "$Ps" |sed -f <(Known.sed)|X_); do [ -z "$vPs" ] || break; done
		vPs=${vPs/?:}
	#Предметы
		echo -ne "${cT}"; select vTs in $(echo "$Ts" |sed -f <(Known.sed)|X_); do [ -z "$vTs" ] || break; done
		vTs=${vTs/?:}

		#Ответ игрока $1
		Otvet() { {
		  grep -q "K_$vKs" /tmp/Cluedo_igrok-0$1 && echo -e "Игрок_$1:K_$vKs"; 
		  grep -q "P_$vPs" /tmp/Cluedo_igrok-0$1 && echo -e "Игрок_$1:P_$vPs"; 
		  grep -q "T_$vTs" /tmp/Cluedo_igrok-0$1 && echo -e "Игрок_$1:T_$vTs";  
		} | shuf -n1; }

		Otv="$(Otvet 1 | grep ":" || Otvet 2 | grep ":" || Otvet 3 | grep ":"  || { echo -e "Игроки_:Нету"; })"
		## echo "NN:Выбор:K:P:T:КтоОтветил:Что:Кубик" >> /tmp/Cluedo_round.log
		diff /tmp/Cluedo <(echo -e "K_$vKs\nP_$vPs\nT_$vTs")  | grep -q "." || Otv=" Cluedo:ПОБЕДА"
		echo "$1:Выбор:K_$vKs:P_$vPs:T_$vTs:$Otv:$d6" >> /tmp/Cluedo_round.log
		echo -e "${cY}$1) >>> $Otv ${cY}>>> K_$vKs P_$vPs T_$vTs" | ColorList | grep --color "ПОБЕДА" && {
			#grep -H ПОБЕДА /tmp/Cluedo_round*.log | cut -d: -f1,2  | sort -t: -k2 -n | sed "s|/tmp/Cluedo_round-||;s|/tmp/Cluedo_round.log|Сейчас     |;s|\.log||;s|:|\t|"
			echoHR - 
			viewLOG | sed -f <(otvet.sed) | egrep --color "(<[^<]*>|ПОБЕДА|)"
			echoHR - 
			Map | sed -f <(~/bin/Function/d6.sed.sh $d6); 
			SpisokBez /tmp/Cluedo_Bass <(sort /tmp/Cluedo_Bass_known) |ColorList | sed "s/\([^ ]*\)/$__${cB}[\1$__${cB}]/g" | xargs echo -e; echo -e "$c0"
			grep -H ПОБЕДА /tmp/Cluedo_round*.log | cut -d: -f2 | sort -n |uniq -c|sed "s/^ *\([0-9]*\) \([0-9]*\)/\2 \1/" | tr " " ":"| tr "\n" " "| egrep --color "\<($(grep -H ПОБЕДА /tmp/Cluedo_round.log | cut -d: -f2)|):" 
			exit
		}
	fi
}

A=1$(tail -1 /tmp/Cluedo_round.log | cut -d: -f1); while let A++;do ROUND ${A:1}; done


	
