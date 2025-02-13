pi()
{
echo '
# Ways to calculate pi in the terminal
'
echo -e "${shell_color_palette[bcyan]}How do I print pi (3.14159) with PYTHON/PERL/AWK:${shell_color_palette[color_off]}\n"
cat <<'EOF'
See at:  https://unix.stackexchange.com/questions/166220/how-do-i-print-pi-3-14159

python -c "import math; print(str(math.pi)[:7])"
perl -Mbignum=bpi -wle 'print bpi(NUM)'
perl -Mbignum=bpi -wle 'print bpi(6)'
echo "s=5; scale=s+2; pi=4*a(1); scale=s-1; pi/1" |  bc -l
awk '/M_PIl/ {print $4}' /usr/include/math.h | tr -d L
EOF
}
