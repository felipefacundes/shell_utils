#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This is a standard template for a bash script with multiple arguments, covering as many situations as possible. 
And avoiding infinite loop for argument with no input, with many example regular expressions.
DOCUMENTATION

help() {
    echo 'menu help:' && grep -ri '-' "$0" | head -n12 | tail -n9
}

if [[ -z $1 ]] || [[ $1 == "-h" || $1 == "--help" ]] || [[ -z $2 ]]; then
    help
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -a|-alpha)
            a=$2
            shift 2
            continue
            ;;
        -an|-alphanum)
            an=$2
            shift 2
            continue
            ;;
        -aan|-alpha_and_num|-naa|-num_and_alpha)
            a_and_n=$2
            shift 2
            continue
            ;;
        -n|-number)
            n=$2
            shift 2
            continue
            ;;
        -e|-extension)
            e=$2
            shift 2
            continue
            ;;
        -email)
            email=$2
            shift 2
            continue
            ;;
        -url)
            url=$2
            shift 2
            continue
            ;;
        -ip)
            ip=$2
            shift 2
            continue
            ;;
        -ipv6)
            ipv6=$2
            shift 2
            continue
            ;;
        *)
            # Clear all variables and functions
            for VAR in $(grep -E '[a-zA-Z0-9"'\''\[\]]*=' "${0}" | grep -v '^#' | cut -d'=' -f1 | awk '{print $1}'); do
                eval unset "\${VAR}"
            done
            break
            ;;
    esac
done

if [[ "$a" =~ ^[[:alpha:]]+$ ]]; then
    echo "alpha: $a"
elif [[ "$a" ]]; then
    echo 'Only letters are accepted in this argument!'
fi
if [[ "$an" =~ ^[[:alnum:]]+$ ]]; then
    echo "alphanum: $an"
elif [[ "$an" ]]; then 
    echo 'Only letters or numbers are accepted!'
fi
if [[ "$a_and_n" =~ [[:alpha:]].*[[:digit:]] || "$a_and_n" =~ [[:digit:]].*[[:alpha:]] ]]; then
    echo "alpha and num: $a_and_n"
elif  [[ "$a_and_n" ]]; then
    echo 'Only letters with numbers or numbers with letters are accepted!'
fi
if [[ "$e" =~ [[:alnum:]]\..[[:alnum:]] ]]; then
    echo "extension: $e"
elif [[ "$e" ]]; then
    echo 'An extension must have a dot "." and text: "file.ext"' 
fi
if [[ "$n" =~ ^[0-9]+$ ]]; then
    echo "number: $n"
elif [[ "$n" ]]; then
    echo 'Only numbers are accepted in this argument!'
fi
if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo "Email: $email"
elif [[ "$email" ]]; then
    echo 'Invalid email address!'
fi
if [[ "$url" =~ ^(ftp|http|https)://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$ ]]; then
    echo "URL: $url"
elif [[ "$url" ]]; then
    echo 'Invalid URL!'
fi
if [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "IP Address: $ip"
elif [[ "$ip" ]]; then
    echo 'Invalid IP address!'
fi
if [[ "$ipv6" =~ ^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$ ]]; then
    echo "IPv6 Address: $ipv6"
elif [[ "$ipv6" ]]; then
    echo 'Invalid IPv6 address!'
fi
