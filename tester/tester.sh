#!/bin/bash

if [[ "$#" == 0 ]]; then
    echo program testujący >&2
    echo uruchom: ./tester.sh nazwa_skryptu_do_testowania >&2
    echo skrypt testujący może być uruchamiany tylko z wewnątrz katalogu "tester" >&2
    exit 1
fi

TD="$PWD"
ERR="$PWD"/test_err.log
OUT="$PWD"/test_out.log
final="OK"
SD="./sandbox"
SK="./p.sh"
SKP="$SD/$SK"
DANE1="f1 od 02_2021.csv"
DANE2="fragm2 2021 2022.csv"
BASE="BBB"

#source fun.sh

mkdir -p $SD
chmod 700 $SD
[[ -e $SK ]] && {
    chmod 700 $SK
    rm -f $SK
}
cp "$1" $SKP
chmod 500 $SD
cd $SD

#test 1 - brak argumentów
echo -n "Test 1:  "
"$SK" 2> $ERR > $OUT
res=$?
if [ $res -ne 1 ] || [ $(wc -c <$OUT) -ne 0 ] || [ $(wc -c < $ERR ) -eq 0 ]; then
    echo Fail
    final="Fail"
else
    echo OK.
fi

#test 2 - jeden argument
echo -n "Test 2:  "
"$SK" BBB 2> $ERR > $OUT
res=$?
if [ $res -ne 2 ] || [ $(wc -c <$OUT) -ne 0 ] || [ $(wc -c < $ERR ) -eq 0 ]; then
    echo Fail
    final="Fail"
else
    echo OK.
fi

#test 3 - plik nie istnieje argument
echo -n "Test 3:  "
"$SK" BBB AABB 2> $ERR > $OUT
res=$?
if [ $res -ne 3 ] || [ $(wc -c <$OUT) -ne 0 ] || [ $(wc -c < $ERR ) -eq 0 ]; then
    echo Fail 
    final="Fail"
else
    echo OK.
fi 

# Tutaj pokazuje blad, [res -ne 4 ] z takiego powodu ze w moim systemie da sie 
# utworzyc katalog w katalogu / a w innych systemach jest to niemozliwe!
#test 4- błąd katalogu bazowego
echo -n "Test 4:  "
"$SK" /BBB ../dummy 2> $ERR > $OUT
res=$?
if [ $res -ne 4 ] || [ $(wc -c <$OUT) -ne 0 ] || [ $(wc -c < $ERR ) -eq 0 ]; then
    echo Fail 
    final="Fail"
else
    echo OK.
fi 
# dump_log

#test 5 - poprawne wykonanie skryptu
[[ -e ../"$BASE" ]] && rm -r ../"$BASE"
echo -n "Test 5:  "
"$SK" ../"$BASE" ../"$DANE1" ../"$DANE2" 2> $ERR > $OUT
res=$?
if [ $res -ne 0 ] || [ $(wc -c <$OUT) -ne 0 ] || [ $(wc -c < $ERR ) -ne 0 ]; then
    echo Fail 1
    final="Fail"
else
    echo -n .
    tree ../"$BASE" | tail -n +2 > ../drzewo
    diff ../drzewo ../drzewo_wz 
    res=$?
    if [ $res -ne 0 ];  then
        echo Fail 2 
        final="Fail"
    else
        echo -n .
        if [ ! -e ../"$BASE"/out.log ]; then
            echo Fail 3
            final="Fail"
        else
            echo -n .
            len_wz="222221223311113132111"
            len=$(wc -l < ../"$BASE"/"2021.02.errors" )
            for k in 2021/01 2021/02 2021/03 2022/01 2022/02
            do
                for p in $(ls -1 ../"$BASE"/$k/*.csv)
                do
                    len="$len"$(wc -l < "$p" )
                done
            done
            if [ "$len" != $len_wz ]; then
                echo Fail 4
                final="Fail"
            else
                echo OK.
            fi
        fi
    fi
fi 

echo Final result: $final

#sprzątanie
cd "$TD"
chmod 700 $SD
[[ -e $SK ]] && {
    chmod 700 $SK
}
rm -rf $SD
[[ $final == "OK" ]] && rm -f drzewo; rm -rf "$BASE"; rm -f test_???.log
