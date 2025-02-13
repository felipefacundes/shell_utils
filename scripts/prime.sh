#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Identify the Prime Numbers.
DOCUMENTATION

# Prime Number
echo -e "Learn more at:\nhttps://escolakids.uol.com.br/matematica/numeros-primos.htm\n"
echo -e "Enter Number : \c"
read -r n
for((i=2; i<=$n/2; i++))
do
  ans=$(( n%i ))
  if [ "$ans" -eq 0 ]
  then
    echo "$n is not a prime number."
    exit 0
  fi
done
echo "$n is a prime number."