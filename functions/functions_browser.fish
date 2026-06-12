#!/usr/bin/env fish
# License: GPLv3
# Credits: Felipe Facundes

function fzf_functions_browser

    function __cleanup
        printf '\e[?7h\e[?25h\e[2J\e[;r\e[?1049l'
        stty echo icanon </dev/tty >/dev/null 2>/dev/null
        clear
        echo "Goodbye!"
        set RUNNING false
    end

    function __fuzzy_match -a pattern string
        if test -z "$string"
            return 1
        end
        string match -qi "*$pattern*" "$string"
    end

    # Get functions
    set -l all_functions (functions -n)
    set -l total_all (count $all_functions)
    
    if test $total_all -eq 0
        echo "No functions found"
        return 1
    end

    set -l filtered_functions $all_functions
    set -l total_count $total_all
    set -l selected_index 1
    set -l search_term ""
    set -l cursor_pos 1
    set -l previous_search_term ""
    set -l RUNNING true

    # Initial draw
    printf \e'[?25l'
    printf \e'[2J'
    printf \e'[H'

    while test "$RUNNING" = true
        # === DRAW SCREEN ===
        printf \e'[2J'
        printf \e'[H'
        
        # Header
        printf "\e[1m\e[36m╔══════════════════════════════════════════════════════════════╗\e[0m\n"
        printf "\e[1m\e[36m║              Fish Function Browser                           ║\e[0m\n"
        printf "\e[1m\e[36m╚══════════════════════════════════════════════════════════════╝\e[0m\n"
        printf "\e[32m Type to search | ↑↓: Navigate | Enter: Full view | q: Quit\e[0m\n"
        printf "\n"
        
        # Search line
        printf "\e[1m Search: \e[0m"
        
        set -l search_len (string length "$search_term")
        if test $search_len -gt 0
            if test $cursor_pos -le $search_len
                set -l before_cursor (string sub -l (math $cursor_pos - 1) "$search_term")
                set -l at_cursor (string sub -s $cursor_pos -l 1 "$search_term")
                set -l after_cursor (string sub -s (math $cursor_pos + 1) "$search_term")
                printf "%s" "$before_cursor"
                printf "\e[7m%s\e[0m" "$at_cursor"
                printf "%s" "$after_cursor"
            else
                printf "%s" "$search_term"
                printf " "
            end
        else
            printf " "
        end
        
        printf "  \e[32m[%d matches]\e[0m\n" $total_count
        printf "\n"
        
        # Function list header
        printf "\e[1m Functions:\e[0m\n"
        printf "\e[36m────────────────────────────────────────────────────────────────\e[0m\n"
        
        set -l max_display 10
        set -l start_idx 1
        
        if test $selected_index -gt $max_display
            set start_idx (math $selected_index - $max_display + 1)
        end
        
        set -l end_idx (math $start_idx + $max_display - 1)
        if test $end_idx -gt $total_count
            set end_idx $total_count
        end
        
        if test $total_count -gt 0
            for i in (seq $start_idx $end_idx)
                set -l func_name $filtered_functions[$i]
                
                if test -z "$func_name"
                    continue
                end
                
                if test $i -eq $selected_index
                    printf "\e[1m\e[36m> \e[0m"
                    printf "%s\n" "$func_name"
                else
                    printf "  %s\n" "$func_name"
                end
            end
        end
        
        if test $total_count -gt $max_display
            set -l remaining (math $total_count - $max_display)
            if test $remaining -gt 0
                printf "\n\e[32m... and %d more functions\e[0m\n" $remaining
            end
        end
        
        # Preview
        printf "\n\e[1m Preview:\e[0m\n"
        printf "\e[36m────────────────────────────────────────────────────────────────\e[0m\n"
        
        if test $total_count -gt 0 -a $selected_index -le $total_count
            set -l selected_func $filtered_functions[$selected_index]
            if test -n "$selected_func"
                functions $selected_func 2>/dev/null | head -n 20
            end
        end
        
        # === READ KEY ===
        set -l key (bash -c 'read -r -n 1 key 2>/dev/null; printf "%s" "$key"')
        
        if test -z "$key"
            read -n 1 -s key 2>/dev/null
        end
        
        if test -z "$key"
            __cleanup
            break
        end
        
        switch "$key"
            case \e
                set -l key2 (bash -c 'read -r -n 2 -t 0.5 key2 2>/dev/null; printf "%s" "$key2"')
                if test -z "$key2"
                    read -n 2 -s -t 0.5 key2 2>/dev/null
                end
                
                switch "$key2"
                    case '[A'
                        if test $selected_index -gt 1
                            set selected_index (math $selected_index - 1)
                        end
                    case '[B'
                        if test $selected_index -lt $total_count
                            set selected_index (math $selected_index + 1)
                        end
                    case '[C'
                        set -l search_len (string length "$search_term")
                        if test $cursor_pos -le $search_len
                            set cursor_pos (math $cursor_pos + 1)
                        end
                    case '[D'
                        if test $cursor_pos -gt 1
                            set cursor_pos (math $cursor_pos - 1)
                        end
                end
            case \x7f \b
                set -l search_len (string length "$search_term")
                if test $search_len -gt 0 -a $cursor_pos -gt 1
                    set -l before_cursor (string sub -l (math $cursor_pos - 2) "$search_term")
                    set -l after_cursor (string sub -s $cursor_pos "$search_term")
                    set search_term "$before_cursor$after_cursor"
                    set cursor_pos (math $cursor_pos - 1)
                end
            case \n \r
                if test $total_count -gt 0 -a -n "$filtered_functions[$selected_index]"
                    printf \e'[?25h'
                    stty echo icanon
                    clear
                    printf "\e[1m\e[36m Full definition: \e[33m%s\e[0m\n" $filtered_functions[$selected_index]
                    printf "\e[36m════════════════════════════════════════════════════════════════\e[0m\n"
                    functions $filtered_functions[$selected_index]
                    printf "\n"
                    printf "\e[32m Press Enter to continue...\e[0m"
                    read
                    stty -echo -icanon
                    printf \e'[?25l'
                end
            case q Q
                __cleanup
                break
            case '*'
                set -l before_cursor (string sub -l (math $cursor_pos - 1) "$search_term")
                set -l after_cursor (string sub -s $cursor_pos "$search_term")
                set search_term "$before_cursor$key$after_cursor"
                set cursor_pos (math $cursor_pos + 1)
        end
        
        # Filter if search term changed
        if test "$search_term" != "$previous_search_term"
            set filtered_functions
            if test -z "$search_term"
                set filtered_functions $all_functions
            else
                for func in $all_functions
                    if test -n "$func"
                        if __fuzzy_match "$search_term" "$func"
                            set -a filtered_functions "$func"
                        end
                    end
                end
            end
            
            set total_count (count $filtered_functions)
            
            if test $total_count -eq 0
                set total_count 0
            end
            
            if test $selected_index -gt $total_count
                set selected_index $total_count
            end
            if test $selected_index -lt 1
                set selected_index 1
            end
            
            set previous_search_term "$search_term"
        end
    end
    
    __cleanup
end