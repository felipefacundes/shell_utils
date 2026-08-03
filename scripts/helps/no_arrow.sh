# Função para impedir que se use as setas
no_arrow(){
    while true; do
        # Ler um caractere
        read -rs -n 1 key
        
        # Se for ESC (código 27)
        if [[ $key == $'\x1b' ]]; then
            # Ler próximo caractere com timeout pequeno
            read -rs -n 1 -t 0.1 key2
            
            if [[ $key2 == "[" ]]; then
                read -rs -n 1 -t 0.1 key3
                
                case $key3 in
                    "A") : #printf '\033[1S'  # Sroll up
                        ;;
                    "B") : #printf '\033[1T'  # Scroll down
                        ;;
                esac
            fi
        else
            break
        fi
    done
}