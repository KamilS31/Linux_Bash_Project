#!/bin/bash

#0 START

startT=$(echo "scale=3; $(date +"%s%N")"/1000000 | bc -l) # Wyliczenie czasu poczatkowego w milisek

function Time ()
{
	endT=$(echo "scale=3; $(date +"%s%N")"/1000000 | bc -l)	
	time=$(echo "$endT - $startT" | bc -l)	
	echo -e "$$,$PPID,$time,$(ps ax | grep "$$" | grep -v grep | awk '{ print $5 }')" >> ../out.log
}

# Sprawdzenie poprawnosci uruchomienia:

if [ "$#" == 0 ]
then
	echo -e "Brak argumentow! Poprawny sposob uruchomienia: \n./projekt2022.sh<KAT_BAZOWY><nazwa_plikudanych1><nazwa_pliku_danych2> ... <nazwa_pliku_danychN>" >&2 
	exit 1 												# Brak Time bo nie ma gdzie zapisac wyniku
elif [ "$#" == 1 ]
then
	echo "Podano tylko jeden argument!" >&2	
	exit 2
fi

for i in "${@:2}"				 #*** Interowanie od 2 bo idziemy tylko po plikach danych ***#
do 
	if [[ ! -e "$i" || ! -r "$i" ]]
	then
		echo -e "Brak dostepu do pliku danych lub plik $i nie istnieje!" >&2
		exit 3
	fi
done

mkdir -m 750 "$1"
if [[ $? -ne 0 ]]  # Nie jestem pewien drugiego warunku
then
	echo "Brak mozliwosci utworzenia katalogu bazowego" >&2
	exit 4
fi

#1 START
for i in "${@:2}"    						 #*** Iterowanie od drugiego (2) argumentu ***#
do
	#*** Wyciecie z kazdego pliku danych Rok, Miesiac, ich obrobka i zapisanie do zmiennej ***#
	YM=$(cut -d, -f 3,4 "$i" | tr -d '",' | sort -u | uniq)  

	for line in $YM
	do
		echo "$line" >> "$1"/temp.txt #*** Zapisanie do pliku temp.txt danych wiersz pod wierszem ***#
	done                          

done

# KAT ProjektAC

temp=$(cut -f 1 "$1"/temp.txt | sort -u | uniq) #*** Zapisa zawartosci pliku temp.txt do zmiennej ***#
rm "$1"/temp.txt* 		#*** Usuniecie plikow tymczasowych ***#

#cd $1 # KAT bazowy

for line in $temp  #*** Iterowanie po liniach pliku temp.txt (ROKMIESIAC) ***#
do
	# Tutaj moglem uzyc wycinania stringu tak jak robie to pozniej!!!!!!!!!!!!!!
	rok="$(cut -c 1-4 <<< "$line")" 	#*** Zapis do zmiennej "rok" Roku z danej lini ***#
	miesiac="$(cut -c 5-6 <<< "$line")"	 
	mkdir -m 750 "$1"/"$rok" 2> /dev/null 			#*** "Usuniecie" bledow i uprawnienia ***#
	#cd $rok
	mkdir -m 750 "$1"/"$rok"/"$miesiac" 2> /dev/null
	#cd .. # KAT bazowy	
done
#1 STOP

#2,3 START
for i in "${@:2}"
do	
	if [ "$i" != "$2" ]
	then
		T=()
		Tsmdb=()
	fi
	# Na poczatku dany byly zle posortowane, sort ma byc na poczatku a pozniej obrobka
	Rsort="$(sort "$i" | tr ' ' '_')"
	Dsort="$(sort "$i" | cut -d, -f 3,4,5 | tr -d '",')"
	SMDB="$(sort "$i" | cut -d, -f 7)"

	for line in $Rsort
	do	
		T+=("$line") # Zapisanie do tablicy wszystkich lini z $R
	done

	for line in $SMDB
	do
		Tsmdb+=("$line")
	done

	#cd "$1"
	j=0
	for lineD in $Dsort
	do 
		rok="$(cut -c 1-4 <<< "$lineD")"
		miesiac="$(cut -c 5-6 <<< "$lineD")"	
		dzien="$(cut -c 7-8 <<< "$lineD")"
		#cd $rok
		#cd $miesiac
		if [ "${Tsmdb["$j"]}" != '"8"' ]
		then
			echo "${T["$j"]}" >> "$1"/"$rok"/"$miesiac"/"$dzien".csv
			#cd ..
			#cd ..
		else
			#cd ..
			#cd ..
			echo "${T["$j"]}" >> "$1"/"$rok"."$miesiac".errors
		fi
		j=$((j+1))
	done
done
#2,3 STOP

#4 START
for i in "${@:2}"
do	
	RMDO=$(cut -d, -f 3-6 "$i" | sort -t ',' -k 4 -n 2> /dev/null)
	
	for lines in $RMDO
	do
		echo "$lines" >> "$1"/plik.txt
	done
done

all=$(cat "$1"/plik.txt | sort -t ',' -k 1 -k 2 -k 3 -n | tr -d '"')
rm "$1"/plik.txt*

dateuniq=$(echo "$all" | cut -d, -f 1,2,3 | sort -u)

suma=0
for lineDU in $dateuniq
do
	for lineA in $all # jest posortowane
	do
		# ${var:P:L} P-indeks startowy L-dlugosc
		P="${lineA:0:10}" # sama data
		VAL="${lineA:11:11}" # tylko wartosc

		if [[ $lineDU == "$P" ]]
		then
			suma=$(echo "$suma+$VAL" | bc -l)			
		else
			continue
		fi	
	done

	echo "$lineDU,$suma" >> "$1"/temp.txt

	suma=0
	VAL=0
done

max="$(sort -t ',' -k 4 -n "$1"/temp.txt | tail -n 1)"
min="$(sort -t ',' -k 4 -n "$1"/temp.txt | head -n 1)"
rm "$1"/temp.txt*

mkdir -m 777 "$1/LINKS"
cd "$1"/LINKS/ || exit

ln -s ../"${min:0:4}"/"${min:5:2}"/"${min:8:2}".csv MIN_OPAD
ln -s ../"${max:0:4}"/"${max:5:2}"/"${max:8:2}".csv MAX_OPAD

#4 STOP

Time "$@"       # 14.11.2022 9:48 - 3.12.2022 17:27
