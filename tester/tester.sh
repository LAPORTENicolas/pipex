#!/bin/bash

WHITE="\033[0m"
RED="\033[91m"
GREEN="\033[92m"
ORANGE="\033[93m"
BLUE="\033[94m"
VALGRIND='valgrind --leak-check=full --show-leak-kinds=all '
OUTFILE='outfile.txt'
REAL_OUTFILE='real_outfile.txt'
REAL_RETURN=0
PIPEX_RETURN=0
COMPTEUR=0

INFILE='infile3'
touch memoire.log

reset_file() {
	rm $OUTFILE 2>/dev/null
	rm $REAL_OUTFILE 2>/dev/null
	rm memoire.log 2>/dev/null
	touch memoire.log
}

check_leak() {
	printf "$BLUE Memory leak:"
	if ! grep -sq 'LEAK SUMMARY:' memoire.log; then
		#if grep -sq 'All heap blocks were freed -- no leaks are possible' memoire.log; then
		printf "$GREEN c bon\n"
	else
		printf "$RED ca leak\n"
		((COMPTEUR = COMPTEUR + 1))
	fi
}

check_return() {
	if [ "$REAL_RETURN" -eq "$PIPEX_RETURN" ]; then
		printf "$BLUE Return value: $GREEN OK\n"
	else
		((COMPTEUR = COMPTEUR + 1))
		printf "$BLUE Return value: $RED KO\n"
		printf " $BLUE Orinal return value: $WHITE $REAL_RETURN\n"
		printf " $BLUE Pipex return value: $WHITE $PIPEX_RETURN\n"
	fi
}

check_result() {
	if ! diff $REAL_OUTFILE $OUTFILE >/dev/null; then
		printf "$BLUE diff $REAL_OUTFILE $OUTFILE:$RED c mort\n\n"
		((COMPTEUR = COMPTEUR + 1))
		return
	else
		printf "$BLUE diff $REAL_OUTFILE $OUTFILE:$GREEN c bon\n"
	fi
	if ! cat $OUTFILE 2>/dev/null >/dev/null; then
		printf "$BLUE cat $OUTFILE:$RED c mort\n"
		return
	else
		printf "$BLUE cat $OUTFILE:$GREEN c bon\n"
	fi
	check_leak
	check_return
	printf "${WHITE}\n"
}

reset_file
printf "$BLUE Test 01: $WHITE $INFILE < ls | wc -l > $OUTFILE\n"
touch $REAL_OUTFILE
touch $OUTFILE
<$INFILE /bin/ls | wc -l >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "ls" "wc -l" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "ls" "wc -l" $OUTFILE 2>&1
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 02: $WHITE $INFILE < ls -la | wc -l > $OUTFILE\n"
touch $REAL_OUTFILE
touch $OUTFILE
<$INFILE /bin/ls -la | wc -l >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "ls -la" "wc -l" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "ls -la" "wc -l" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 03: $WHITE $INFILE < ls -tmp | wc -l > $OUTFILE\n"
touch $REAL_OUTFILE
touch $OUTFILE
<$INFILE /bin/ls -tmp | wc -l >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "ls -tmp" "wc -l" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "ls -tmp" "wc -l" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
touch $REAL_OUTFILE
touch $OUTFILE
printf "$BLUE Test 04: $WHITE $INFILE < ls -tmp | grep 0 > $OUTFILE\n"
<$INFILE /bin/ls -tmp | grep 0 >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "ls -tmp" "grep 0" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "ls -tmp" "grep 0" $OUTFILE
PIPEX_RETURN=$?
check_result

## PART 2 BAD FILE BAD FUNCTION
printf "$WHITE\nPART 2: Invalide file and function.\n\n"

reset_file
printf "$BLUE Test 05: $WHITE $INFILE < ls | wc -l > inexist_file\n"
exec 2>/dev/null
<$INFILE cat main.c | wc -l >$REAL_OUTFILE
REAL_RETURN=$?
exec 2>/dev/tty
$VALGRIND ./pipex $INFILE "cat main.c" "wc -l" $OUTFILE 2>&1 | tee memoire.log >/dev/null
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 06: $WHITE $INFILE < lls | wc -l > $OUTFILE\n"
exec 2>/dev/null
<$INFILE lls | wc -l >$REAL_OUTFILE
REAL_RETURN=$?
exec 2>/dev/tty
$VALGRIND ./pipex $INFILE "lls" "wc -l" $OUTFILE 2>&1 | tee memoire.log >/dev/null
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 07: $WHITE $INFILE < ls | xwc -l > $OUTFILE\n"
exec 2>/dev/null
<$INFILE ls | xwc -l >$REAL_OUTFILE
REAL_RETURN=$?
exec 2>/dev/tty
$VALGRIND ./pipex $INFILE "ls" "xwc -l" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "ls" "xwc -l" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 08: $WHITE $INFILE < lls ls | xwc -l > $OUTFILE\n"
exec 2>/dev/null
<$INFILE lls ls | xwc -l >$REAL_OUTFILE
REAL_RETURN=$?
exec 2>/dev/tty
$VALGRIND ./pipex $INFILE "lls ls" "xwc -l" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "lls ls" "xwc -l" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 9: $WHITE bad_$INFILE < lls | wc -l > $OUTFILE\n"
exec 2>/dev/null
<$INFILE lls | wc -l >$REAL_OUTFILE
REAL_RETURN=$?
exec 2>/dev/tty
$VALGRIND ./pipex $INFILEe "lls" "wc -l" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "lls" "wc -l" $OUTFILE 2>&1
PIPEX_RETURN=$?
check_result

## PART 3
printf "$WHITE\nPART 3: ARG.\n\n"

reset_file
printf "$BLUE Test 10: $WHITE no arg \n"
$VALGRIND ./pipex 2>&1 | tee memoire.log >/dev/null
check_leak
printf "\n"

reset_file
printf "$BLUE Test 11: $WHITE $INFILE \n"
$VALGRIND ./pipex $INFILE 2>&1 | tee memoire.log >/dev/null
check_leak
printf "\n"

reset_file
printf "$BLUE Test 12: $WHITE $INFILE wc -l\n"
$VALGRIND ./pipex $INFILE "wc -l" 2>&1 | tee memoire.log >/dev/null
check_leak
printf "\n"

reset_file
printf "$BLUE Test 13: $WHITE $INFILE wc-l $OUTFILE\n"
$VALGRIND ./pipex $INFILE "wc -l" $OUTFILE 2>&1 | tee memoire.log >/dev/null
if cat $OUTFILE 2>/dev/null >/dev/null; then
	printf "$BLUE cat $OUTFILE:$RED c mort\n"
else
	printf "$BLUE cat $OUTFILE:$GREEN c bon\n"
fi
check_leak
printf "\n"

# PART 4
printf "$WHITE\nPART 4: Random tests\n\n"

reset_file
printf "$BLUE Test 14: $WHITE $INFILE < cat -e | cat -e > $OUTFILE\n"
<$INFILE cat -e | cat -e >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "cat -e" "cat -e" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "cat -e" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_leak
check_return

reset_file
printf "$BLUE Test 15: $WHITE $INFILE < fake_cmd | cat -e > $OUTFILE\n"
exec 2>/dev/null
<$INFILE fake_cmd | cat -e >$REAL_OUTFILE
REAL_RETURN=$?
exec 2>/dev/tty
$VALGRIND ./pipex $INFILE "fake_cmd" "cat -e" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "fake_cmd" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 16: $WHITE $INFILE < "" | cat -e > $OUTFILE\n"
exec 2>/dev/null
<$INFILE "" | cat -e >$REAL_OUTFILE
REAL_RETURN=$?
exec 2>/dev/tty
$VALGRIND ./pipex $INFILE "" "cat -e" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 17: $WHITE $INFILE < sleep 1 | cat -e > $OUTFILE\n"
exec 2>/dev/null
<$INFILE sleep 1 | cat -e >$REAL_OUTFILE
REAL_RETURN=$?
exec 2>/dev/tty
$VALGRIND ./pipex $INFILE "sleep 1" "cat -e" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "sleep 1" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 18: $WHITE $INFILE < cat -e | fake_cmd > $OUTFILE\n"
exec 2>/dev/null
<$INFILE cat -e | sdfadlknca >$REAL_OUTFILE
REAL_RETURN=$?
exec 2>/dev/tty
$VALGRIND ./pipex $INFILE "cat -e" "fdsalkjncuiodas" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "cat -e" "cklasdf" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 19: ${WHITE} cat -e | wc -l > no_perm\n"
touch $REAL_OUTFILE
touch $OUTFILE
chmod 000 $REAL_OUTFILE
chmod 000 $OUTFILE
exec 2>/dev/null
<$INFILE cat -e | wc -l >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "cat -e" "wc -l" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "cat -e" "wc -l" $OUTFILE
PIPEX_RETURN=$?
exec 2>/dev/tty
chmod 777 $REAL_OUTFILE
chmod 777 $OUTFILE
check_result

reset_file
printf "$BLUE Test 20: ${WHITE} >no_perm cat -e | wc -l > ${OUTFILE}\n"
chmod 000 $INFILE
exec 2>/dev/null
<$INFILE cat -e | wc -l >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "cat -e" "wc -l" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "cat -e" "wc -l" $OUTFILE
PIPEX_RETURN=$?
exec 2>/dev/tty
chmod 777 $INFILE
check_result

reset_file
printf "$BLUE Test 21: $WHITE $INFILE < cat -e | empty_str > $OUTFILE\n"
exec 2>/dev/null
<$INFILE cat -e | "" >$REAL_OUTFILE
REAL_RETURN=$?
exec 2>/dev/tty
$VALGRIND ./pipex $INFILE "cat -e" "" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "cat -e" "" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 22: $WHITE $INFILE < ./pipex infile "ls" "wc" outfile2.txt | wc -l > $OUTFILE\n"
exec 2>/dev/null
touch real_outfile2.txt
touch outfile2.txt
<$INFILE ./pipex infile "ls" "wc" real_outfile2.txt | wc -l >$REAL_OUTFILE
REAL_RETURN=$?
exec 2>/dev/tty
$VALGRIND ./pipex $INFILE "./pipex infile "ls" "wc" outfile2.txt" "wc -l" $OUTFILE 2>&1 | tee memoire.log >/dev/null
PIPEX_RETURN=$?
REAL_OUTFILE='real_outfile2.txt'
OUTFILE='outfile2.txt'
check_result
rm $REAL_OUTFILE
rm $OUTFILE
OUTFILE='outfile.txt'
REAL_OUTFILE='real_outfile.txt'
check_result

reset_file
printf "$BLUE Test 23: $WHITE $INFILE < yes | head -n 10 > $OUTFILE\n"
<$INFILE yes | head -n 10 >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "yes" "head -n 10" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "yes" "head -n 10" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 24: $WHITE $INFILE < cat | grep foo | head -n 1 > $OUTFILE\n"
<$INFILE cat | grep foo | head -n 1 >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "cat" "grep foo" "head -n 1" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "cat" "grep foo" "head -n 1" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 25: $WHITE $INFILE < seq 1 10000 | sort -R | wc -l > $OUTFILE\n"
<$INFILE seq 1 10000 | sort -R | wc -l >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "seq 1 10000" "sort -R" "wc -l" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "seq 1 10000" "sort -R" "wc -l" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 26: $WHITE $INFILE < cat | sh -c 'sleep 5 & exit' | echo done > $OUTFILE\n"
<$INFILE cat | sh -c 'sleep 5 & exit' | echo done >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "cat" "sh -c 'sleep 5 & exit'" "echo done" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "cat" "sh -c 'sleep 5 & exit'" "echo done" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 27: $WHITE <$INFILE exec 1>&- | cat > $OUTFILE\n"
<$INFILE exec 1>&- | cat >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "exec 1>&-" "cat" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "exec 1>&-" "cat" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 28: $WHITE <$INFILE cat | sort > $OUTFILE\n"
<$INFILE cat | sort >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "cat" "sort" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "cat" "sort" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 29: $WHITE <$INFILE cat | read var > $OUTFILE\n"
<$INFILE cat | read var >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "cat" "read var" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "cat" "read var" $OUTFILE
PIPEX_RETURN=$?
check_result

#PART 5
printf "$WHITE\nPART 5: Bad files\n\n"

reset_file
printf "$BLUE Test 30: $WHITE </dev/null cat | grep foo > $OUTFILE\n"
</dev/null cat | grep foo >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex /dev/null "cat" "grep foo" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex /dev/null "cat" "grep foo" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 31: $WHITE <no_rights cat | cat -e > $OUTFILE\n"
<no_rights cat | cat -e >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex no_rights "cat" "cat -e" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex no_rights "cat" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 32: $WHITE <$INFILE cat | cat -e > no_rights\n"
<$INFILE cat | cat -e >no_rights
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "cat" "cat -e" no_rights 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "cat" "cat -e" no_rights
PIPEX_RETURN=$?
check_leak
check_return
printf "\n"

reset_file
printf "$BLUE Test 33: $WHITE <no_rights cat | cat -e > no_rights\n"
<no_rights cat | cat -e >no_rights
REAL_RETURN=$?
$VALGRIND ./pipex no_rights "cat" "cat -e" no_rights 2>&1 | tee memoire.log >/dev/null
./pipex no_rights "cat" "cat -e" no_rights
PIPEX_RETURN=$?
check_leak
check_return
printf "\n"

reset_file
printf "$BLUE Test 34: $WHITE <no_rights_read cat | cat -e > $OUTFILE\n"
<no_rights_read cat | cat -e >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex no_rights_read "cat" "cat -e" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex no_rights_read "cat" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 35: $WHITE <no_rights_write cat | cat -e > $OUTFILE\n"
<no_rights_write cat | cat -e >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex no_rights_write "cat" "cat -e" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex no_rights_write "cat" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 36: $WHITE <$INFILE cat | cat -e > no_rights_read\n"
<$INFILE cat | cat -e >no_rights_read2
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "cat" "cat -e" no_rights_read 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "cat" "cat -e" no_rights_read
PIPEX_RETURN=$?
chmod +r no_rights_read
chmod +r no_rights_read2
OUTFILE='no_rights_read'
REAL_OUTFILE='no_rights_read2'
check_result
OUTFILE='outfile.txt'
REAL_OUTFILE='real_outfile.txt'
chmod -r no_rights_read
chmod -r no_rights_read2

reset_file
printf "$BLUE Test 37: $WHITE <$INFILE cat | cat -e > no_rights_write\n"
<$INFILE cat | cat -e >no_rights_write
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "cat" "cat -e" no_rights_write 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "cat" "cat -e" no_rights_write
PIPEX_RETURN=$?
check_leak
check_return
printf "\n"

reset_file
printf "$BLUE Test 38: $WHITE <no_rights_read cat | cat -e > no_rights_write\n"
<no_rights_read cat | cat -e >no_rights_write
REAL_RETURN=$?
$VALGRIND ./pipex no_rights_read "cat" "cat -e" no_rights_write 2>&1 | tee memoire.log >/dev/null
./pipex no_rights_read "cat" "cat -e" no_rights_write
PIPEX_RETURN=$?
check_leak
check_return
printf "\n"

reset_file
rm no_rights_read
rm no_rights_read2
touch no_rights_read
touch no_rights_read2
chmod -r no_rights_read
chmod -r no_rights_read2
printf "$BLUE Test 39: $WHITE <no_rights_write cat | cat -e > no_rights_read\n"
<no_rights_write cat | cat -e >no_rights_read
REAL_RETURN=$?
$VALGRIND ./pipex no_rights_write "cat" "cat -e" no_rights_read 2>&1 | tee memoire.log >/dev/null
./pipex no_rights_write "cat" "cat -e" no_rights_read
PIPEX_RETURN=$?
chmod +r no_rights_read
chmod +r no_rights_read2
OUTFILE='no_rights_read'
REAL_OUTFILE='no_rights_read2'
check_result
OUTFILE='outfile.txt'
REAL_OUTFILE='real_outfile.txt'
chmod -r no_rights_read
chmod -r no_rights_read2

reset_file
printf "$BLUE Test 40: $WHITE <$INFILE cat | grep foo /dev/full \n"
<$INFILE cat | grep foo >/dev/full
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "cat" "grep foo" /dev/full 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "cat" "grep foo" /dev/full
PIPEX_RETURN=$?
check_return
check_leak

INFILE='big'
head -c 500MB </dev/urandom >big
reset_file
printf "$BLUE Test 41: $WHITE $INFILE < cat | wc -l > $OUTFILE\n"
touch $REAL_OUTFILE
touch $OUTFILE
<$INFILE /bin/cat | wc -l >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "cat" "wc -l" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "cat" "wc -l" $OUTFILE 2>&1
PIPEX_RETURN=$?
check_result
rm big
INFILE='infile'

reset_file
printf "$BLUE Test 42: $WHITE </dev/null yes | head -n 100 > $OUTFILE\n"
</dev/null yes | head -n 100 >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex /dev/null "yes" "head -n 100" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex /dev/null "yes" "head -n 100" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$BLUE Test 43: $WHITE </dev/zero yes | head -n 100 > $OUTFILE\n"
</dev/zero yes | head -n 100 >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex /dev/zero "yes" "head -n 100" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex /dev/zero "yes" "head -n 100" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
head -c 500MB </dev/urandom >big
cp big infile_rm
cp big infile_rm2
printf "$BLUE Test 44: $WHITE $INFILE < cat | wc -l > $OUTFILE\n"
touch $REAL_OUTFILE
touch $OUTFILE
<infile_rm /bin/cat | wc -l >$REAL_OUTFILE
rm infile_rm
REAL_RETURN=$?
$VALGRIND ./pipex infile_rm2 "cat" "wc -l" $OUTFILE 2>&1 | tee memoire.log >/dev/null
rm infile_rm2
./pipex big "cat" "wc -l" $OUTFILE 2>&1
PIPEX_RETURN=$?
rm big
check_result

reset_file
head -c 500MB </dev/urandom >big
cp big infile_rm
cp big infile_rm2
printf "$BLUE Test 45: $WHITE $INFILE < cat | grep 0 > $OUTFILE\n"
touch $REAL_OUTFILE
touch $OUTFILE
exec 2>/dev/null
<infile_rm /bin/cat | grep 0 >$REAL_OUTFILE
REAL_RETURN=$?
rm infile_rm
$VALGRIND ./pipex infile_rm2 "cat" "grep 0" $OUTFILE 2>&1 | tee memoire.log >/dev/null
rm infile_rm2
./pipex big "cat" "grep 0" $OUTFILE 2>&1
PIPEX_RETURN=$?
rm big
exec 2>/dev/tty
check_result

#PART BONUS
printf "\n$ORANGE[BONUS]$WHITE Test pipex multiple pipe\n\n"

reset_file
printf "$BLUE Test 1: $WHITE $INFILE < free  | grep Mem | grep -Eo '[0-9]{0,2200}' > $OUTFILE\n"
<$INFILE grep "Mem" | grep -Eo '[0-9]{0,2200}' >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "grep Mem" "grep -Eo [0-9]{0,2200}" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "grep Mem" "grep -Eo [0-9]{0,2200}" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$ORANGE Test 2: $WHITE $INFILE < grep Mem | grep -Eo '[0-9]{0,2200} | sed -n '2p' > $OUTFILE\n"
<$INFILE grep "Mem" | grep -Eo '[0-9]{0,2200}' | sed -n '2p' >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "grep Mem" "grep -Eo [0-9]{0,2200}" "sed -n 2p" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "grep Mem" "grep -Eo [0-9]{0,2200}" "sed -n 2p" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$ORANGE Test 3: $WHITE $INFILE < grep Mem | greeeep -Eo '[0-9]{0,2200} | echo 4 > $OUTFILE\n"
exec 2>/dev/null
<$INFILE grep "Mem" | greeeep -Eo '[0-9]{0,2200}' | echo 4 >$REAL_OUTFILE
REAL_RETURN=$?
exec 2>/dev/tty
$VALGRIND ./pipex $INFILE "grep Mem" "greeeeep -Eo [0-9]{0,2200}" "echo 4" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "grep Mem" "greeeeep -Eo [0-9]{0,2200}" "echo 4" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$ORANGE Test 4 $WHITE $INFILE < grep Mem | greeeep -Eo '[0-9]{0,2200} | echo 4 > very_long_name\n"
exec 2>/dev/null
<$INFILE grep "Mem" | greeeep -Eo '[0-9]{0,2200}' | echo 4 >saflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkf
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "grep Mem" "greeeeep -Eo [0-9]{0,2200}" "echo 4" saflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkf 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "grep Mem" "greeeeep -Eo [0-9]{0,2200}" "echo 4" saflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkfsaflsdalkfanklajsdfhasjklfkf
PIPEX_RETURN=$?
exec 2>/dev/tty
check_leak
check_return
printf "\n"

reset_file
printf "$ORANGE Test 5: $WHITE $INFILE < empty_str | empty_str | empty_str > $OUTFILE\n"
exec 2>/dev/null
<$INFILE "" | "" | "" >$REAL_OUTFILE
REAL_RETURN=$?
exec 2>/dev/tty
$VALGRIND ./pipex $INFILE "" "" "" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "" "" "" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$ORANGE Test 6: $WHITE $INFILE < empty_str | cat -e | cat -e > $OUTFILE\n"
exec 2>/dev/null
<$INFILE "" | cat -e | cat -e >$REAL_OUTFILE
REAL_RETURN=$?
exec 2>/dev/tty
$VALGRIND ./pipex $INFILE "" "cat -e" "cat -e" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "" "cat -e" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$ORANGE Test 7: $WHITE $INFILE < cat -e | empty_str | cat -e > $OUTFILE\n"
exec 2>/dev/null
<$INFILE cat -e | "" | cat -e >$REAL_OUTFILE
REAL_RETURN=$?
exec 2>/dev/tty
$VALGRIND ./pipex $INFILE "cat -e" "" "cat -e" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "cat -e" "" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$ORANGE Test 8: $WHITE $INFILE < cat -e | cat -e | cat -e > $OUTFILE\n"
<$INFILE cat -e | cat -e | cat -e >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "cat -e" "cat -e" "cat -e" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "cat -e" "cat -e" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$ORANGE Test 9: $WHITE $INFILE < cat -e | sleep 2 | cat -e > $OUTFILE\n"
<$INFILE cat -e | sleep 2 | cat -e >$REAL_OUTFILE
REAL_RETURN=$?
$VALGRIND ./pipex $INFILE "cat -e" "sleep 2" "cat -e" $OUTFILE 2>&1 | tee memoire.log >/dev/null
./pipex $INFILE "cat -e" "sleep 2" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
head -c 500MB </dev/urandom >big
cp big infile_rm
cp big infile_rm2
printf "$ORANGE Test 10: $WHITE $INFILE < cat | grep 0 | cat -e | wc -l > $OUTFILE\n"
touch $REAL_OUTFILE
touch $OUTFILE
exec 2>/dev/null
<infile_rm /bin/cat | grep 0 | /bin/cat -e | wc -l >$REAL_OUTFILE
rm infile_rm
REAL_RETURN=$?
$VALGRIND ./pipex infile_rm2 "cat" "grep 0" "cat -e" "wc -l" $OUTFILE 2>&1 | tee memoire.log >/dev/null
rm infile_rm2
./pipex big "cat" "grep 0" "cat -e" "wc -l" $OUTFILE 2>&1
PIPEX_RETURN=$?
rm big
exec 2>/dev/tty
check_result

printf "\n$ORANGE[BONUS]$WHITE Test pipex here_doc\n\n"

reset_file
printf "$ORANGE Test 0: $WHITE cat -e <<EOF | cat -e >> $OUTFILE\n"
cat -e <<EOF | cat -e >>$REAL_OUTFILE
$(cat infile2)
EOF
REAL_RETURN=$?
printf "$(cat infile2)\nEOF" | $VALGRIND ./pipex here_doc "EOF" "cat -e" "cat -e" /dev/null 2>&1 | tee memoire.log >/dev/null
printf "$(cat infile2)\nEOF" | ./pipex here_doc EOF "cat -e" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$ORANGE Test 1: $WHITE cat -e <<EOF | cat -e > $OUTFILE\n"
cat -e <<EOF | cat -e >$REAL_OUTFILE
$(cat infile)
EOF
REAL_RETURN=$?
printf "$(cat infile)\nEOF" | $VALGRIND ./pipex here_doc "EOF" "cat -e" "cat -e" /dev/null 2>&1 | tee memoire.log >/dev/null
printf "$(cat infile)\nEOF" | ./pipex here_doc EOF "cat -e" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$ORANGE Test 2: $WHITE cat -e <<EOF | cat -e >> $OUTFILE\n"
cat -e <<EOF | cat -e >>$REAL_OUTFILE
Bonjour
comment
?
EOF
REAL_RETURN=$?
exec 2>/dev/null
$VALGRIND printf "Bonjour
comment
?
EOF" | ./pipex here_doc "EOF" "cat -e" "cat -e" /dev/null 2>&1 | tee memoire.log >/dev/null
exec 2>/dev/tty
printf "Bonjour
comment
?
EOF" | ./pipex here_doc EOF "cat -e" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$ORANGE Test 3: $WHITE cat -e <<EOF | cat -e >> $OUTFILE\n"
cat -e <<EOF | cat -e >>$REAL_OUTFILE
$(printf "$(cat infile)")EOF
EOF
REAL_RETURN=$?
printf "$(cat infile)EOF\nEOF" | $VALGRIND ./pipex here_doc "EOF" "cat -e" "cat -e" /dev/null 2>&1 | tee memoire.log >/dev/null
printf "$(cat infile)EOF\nEOF" | ./pipex here_doc EOF "cat -e" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$ORANGE Test 4: $WHITE cat -e <<EOF | cat -e >> $OUTFILE\n"
exec 2>/dev/null
cat -e <<EOF | cat -e >>$REAL_OUTFILE
$(printf "$(cat infile)")EOF
EOF
REAL_RETURN=$?
EOF
EOF
printf "$(cat infile)EOF\nEOF\nEOF\nEOF" | $VALGRIND ./pipex here_doc "EOF" "cat -e" "cat -e" /dev/null 2>&1 | tee memoire.log >/dev/null
printf "$(cat infile)EOF\nEOF\nEOF\nEOF" | ./pipex here_doc EOF "cat -e" "cat -e" $OUTFILE
PIPEX_RETURN=$?
exec 2>/dev/tty
check_result

reset_file
printf "$ORANGE Test 5: $WHITE cat -e <<EOF | cat -e >> $OUTFILE\n"
exec 2>/dev/null
cat -e <<EOF | cat -e >>$REAL_OUTFILE
$(printf "$(cat infile)")EOF
EOF
REAL_RETURN=$?
EOF
EOF
printf "$(cat infile)EOF\nEOF\nEOF\nEOF" | $VALGRIND ./pipex here_doc "EOF" "cat -e" "cat -e" /dev/null 2>&1 | tee memoire.log >/dev/null
printf "$(cat infile)EOF\nEOF\nEOF\nEOF" | ./pipex here_doc EOF "cat -e" "cat -e" $OUTFILE
PIPEX_RETURN=$?
exec 2>/dev/tty
check_result

reset_file
printf "$ORANGE Test 6: $WHITE cat -e <<EOF | cat -e >> $OUTFILE\n"
exec 2>/dev/null
cat -e <<EOF | cat -e >>$REAL_OUTFILE
EOF
REAL_RETURN=$?
$(printf "$(cat infile)")EOF
EOF
EOF
EOF
printf "EOF\n$(cat infile)EOF\nEOF\nEOF\nEOF" | $VALGRIND ./pipex here_doc "EOF" "cat -e" "cat -e" /dev/null 2>&1 | tee memoire.log >/dev/null
printf "EOF\n$(cat infile)EOF\nEOF\nEOF\nEOF" | ./pipex here_doc EOF "cat -e" "cat -e" $OUTFILE
PIPEX_RETURN=$?
exec 2>/dev/tty
check_result

reset_file
printf "$ORANGE Test 7: $WHITE cat -e <<END | cat -e >> $OUTFILE\n"
cat -e <<END | cat -e >>$REAL_OUTFILE
$(printf "$(cat infile)")END
END
REAL_RETURN=$?
printf "$(cat infile)END\nEND" | $VALGRIND ./pipex here_doc "END" "cat -e" "cat -e" /dev/null 2>&1 | tee memoire.log >/dev/null
printf "$(cat infile)END\nEND" | ./pipex here_doc END "cat -e" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$ORANGE Test 8: $WHITE cat -e <<LIMITER | cat -e >> $OUTFILE\n"
cat -e <<LIMITER | cat -e >>$REAL_OUTFILE
$(printf "$(cat infile)")LIMITER
LIMITER
REAL_RETURN=$?
printf "$(cat infile)LIMITER\nLIMITER" | $VALGRIND ./pipex here_doc "LIMITER" "cat -e" "cat -e" /dev/null 2>&1 | tee memoire.log >/dev/null
printf "$(cat infile)LIMITER\nLIMITER" | ./pipex here_doc LIMITER "cat -e" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$ORANGE Test 9: $WHITE cat -e <<LIMITER | cat -e >> $OUTFILE\n"
cat -e <<LIMITER | cat -e >>$REAL_OUTFILE
bjrLIMITER
bjr
LIMITER
REAL_RETURN=$?
printf "bjrLIMITER\nbjr\nLIMITER" | $VALGRIND ./pipex here_doc "LIMITER" "cat -e" "cat -e" /dev/null 2>&1 | tee memoire.log >/dev/null
printf "bjrLIMITER\nbjr\nLIMITER" | ./pipex here_doc LIMITER "cat -e" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

printf "$ORANGE Test 10: $WHITE cat -e <<LIMITER | cat -e >> $OUTFILE\n"
cat -e <<LIMITER | cat -e >>$REAL_OUTFILE
$(printf "$(cat infile2)")LIMITER
LIMITER
REAL_RETURN=$?
printf "$(cat infile2)LIMITER\nLIMITER" | $VALGRIND ./pipex here_doc "LIMITER" "cat -e" "cat -e" /dev/null 2>&1 | tee memoire.log >/dev/null
printf "$(cat infile2)LIMITER\nLIMITER" | ./pipex here_doc LIMITER "cat -e" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

reset_file
printf "$ORANGE Test 11: $WHITE cat -e <<LIMITER | cat -e >> $OUTFILE\n"
cat -e <<LIMITER | cat -e >>$REAL_OUTFILE
$(printf "$(cat infile4)")LIMITER
LIMITER
REAL_RETURN=$?
printf "$(cat infile4)LIMITER\nLIMITER" | $VALGRIND ./pipex here_doc "LIMITER" "cat -e" "cat -e" /dev/null 2>&1 | tee memoire.log >/dev/null
printf "$(cat infile4)LIMITER\nLIMITER" | ./pipex here_doc LIMITER "cat -e" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

printf "$ORANGE Test 12: $WHITE cat -e <<LIMITER | cat -e >> $OUTFILE\n"
cat -e <<LIMITER | cat -e >>$REAL_OUTFILE
$(printf "$(cat infile4)")LIMITER
LIMITER
REAL_RETURN=$?
printf "$(cat infile4)LIMITER\nLIMITER" | $VALGRIND ./pipex here_doc "LIMITER" "cat -e" "cat -e" /dev/null 2>&1 | tee memoire.log >/dev/null
printf "$(cat infile4)LIMITER\nLIMITER" | ./pipex here_doc LIMITER "cat -e" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

printf "$ORANGE Test 13: $WHITE cat -e <<LIMITER | cat -e >> $OUTFILE\n"
cat -e <<LIMITER | cat -e >>$REAL_OUTFILE
$(printf "$(cat infile4)")LIMITER
LIMITER
REAL_RETURN=$?
printf "$(cat infile4)LIMITER\nLIMITER" | $VALGRIND ./pipex here_doc "LIMITER" "cat -e" "cat -e" /dev/null 2>&1 | tee memoire.log >/dev/null
printf "$(cat infile4)LIMITER\nLIMITER" | ./pipex here_doc LIMITER "cat -e" "cat -e" $OUTFILE
PIPEX_RETURN=$?
check_result

if [ $COMPTEUR -gt 0 ]; then
	printf "$RED Error total: $COMPTEUR"
	exit
fi

printf "$GREEN"
cat .success
