#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

# ============================================
# CALCULADOR DE EFICIÊNCIA TÉRMICA - INVERTER
# ============================================
# Script:    inverter-efficiency-calc.sh
# Descrição: Calcula a temperatura ideal para operação eficiente
#            de ar-condicionado inverter baseado em engenharia térmica
# Autor:     Assistente de Eficiência Energética
# Versão:    1.0
# ============================================

# Cores para output profissional
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'
UNDERLINE='\033[4m'

# Variáveis padrão (valores típicos para residências)
DEFAULT_MAX_POWER=12000
DEFAULT_ECO_PERCENT=35
DEFAULT_DT_MAX=15

# Forçar separador decimal como ponto para cálculos
export LC_NUMERIC="C"

# ============================================
# FUNÇÃO: Exibe ajuda detalhada e pedagógica
# ============================================
show_help() {
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║   CALCULADOR DE EFICIÊNCIA PARA AR-CONDICIONADO INVERTER  ║${NC}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${NC}\n"
    
    echo -e "${BOLD}${UNDERLINE}CONCEITO CIENTÍFICO:${NC}"
    echo "Um ar-condicionado inverter atinge máxima eficiência quando opera"
    echo "a maior parte do tempo no 'modo econômico' (baixa potência)."
    echo "Este script calcula a diferença de temperatura ideal (ΔT) entre"
    echo "o ambiente externo e interno para que isso aconteça.\n"
    
    echo -e "${BOLD}${UNDERLINE}FÓRMULA MATEMÁTICA APLICADA:${NC}"
    echo -e "${YELLOW}    ΔT_ideal = (ΔT_max × Potência_Econômica) / Potência_Máxima${NC}"
    echo "    Onde:"
    echo "    • ΔT_max = Diferença máxima que o aparelho consegue vencer (tipicamente 14-16°C)"
    echo "    • Potência_Econômica = Potência no modo de manutenção (30-40% da máxima)"
    echo "    • Potência_Máxima = Capacidade total do aparelho em BTU/h\n"
    
    echo -e "${BOLD}${UNDERLINE}SINTAXE DE USO:${NC}"
    echo -e "  ${GREEN}Modo Básico:${NC}"
    echo -e "  ${0##*/} ${BLUE}--temp-externa TEMP [--potencia BTU] [--percent-eco %]${NC}"
    echo -e "  ${GREEN}Modo Avançado:${NC}"
    echo -e "  ${0##*/} ${BLUE}--temp-externa TEMP --potencia BTU --percent-eco % --dt-max ΔT${NC}"
    echo -e "  ${GREEN}Ajuda:${NC}"
    echo -e "  ${0##*/} ${BLUE}--help${NC} ou ${BLUE}-h${NC}\n"
    
    echo -e "${BOLD}${UNDERLINE}PARÂMETROS:${NC}"
    echo -e "  ${BLUE}--temp-externa, -t${NC}  Temperatura externa atual (°C) ${BOLD}[OBRIGATÓRIO]${NC}"
    echo -e "  ${BLUE}--potencia, -p${NC}      Potência máxima do aparelho (BTU/h)"
    echo -e "                  Padrão: ${DEFAULT_MAX_POWER} BTU/h (típico para 20-25m²)"
    echo -e "  ${BLUE}--percent-eco, -e${NC}   Percentual da potência no modo econômico (%)"
    echo -e "                  Padrão: ${DEFAULT_ECO_PERCENT}% (35% da potência máxima)"
    echo -e "  ${BLUE}--dt-max, -d${NC}        ΔT máxima que o aparelho pode vencer (°C)"
    echo -e "                  Padrão: ${DEFAULT_DT_MAX}°C (14-16°C é o comum)\n"
    
    echo -e "${BOLD}${UNDERLINE}EXEMPLOS PRÁTICOS:${NC}"
    echo -e "  1. ${GREEN}Temperatura externa de 35°C com aparelho padrão:${NC}"
    echo -e "     ${0##*/} --temp-externa 35"
    echo -e "  2. ${GREEN}Aparelho de 18.000 BTU com temperatura externa de 40°C:${NC}"
    echo -e "     ${0##*/} -t 40 -p 18000"
    echo -e "  3. ${GREEN}Cálculo personalizado completo:${NC}"
    echo -e "     ${0##*/} --temp-externa 32 --potencia 12000 --percent-eco 30 --dt-max 14\n"
    
    echo -e "${BOLD}${UNDERLINE}SAÍDA DO SCRIPT:${NC}"
    echo "  • Temperatura ideal programada para máxima eficiência"
    echo "  • Faixa de temperatura para conforto eficiente"
    echo "  • Explicação do cálculo e recomendações técnicas"
    
    echo -e "\n${BOLD}${YELLOW}⚠️  IMPORTANTE:${NC} Valores entre 23°C e 25°C são recomendados para"
    echo -e "conforto térmico humano, independente do cálculo. Use este resultado"
    echo -e "como referência técnica, não como prescrição absoluta.\n"
}

# ============================================
# FUNÇÃO: Valida entrada numérica
# ============================================
validate_number() {
    local value="$1"
    local name="$2"
    local min="$3"
    local max="$4"
    
    if ! [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo -e "${RED}❌ ERRO: '$name' deve ser um número. Recebido: '$value'${NC}" >&2
        return 1
    fi
    
    if (( $(echo "$value < $min" | bc -l) )); then
        echo -e "${RED}❌ ERRO: $name deve ser maior ou igual a $min. Recebido: $value${NC}" >&2
        return 1
    fi
    
    if [[ -n "$max" ]] && (( $(echo "$value > $max" | bc -l) )); then
        echo -e "${RED}❌ ERRO: $name deve ser menor ou igual a $max. Recebido: $value${NC}" >&2
        return 1
    fi
    
    return 0
}

# ============================================
# FUNÇÃO: Realiza o cálculo de eficiência
# ============================================
calculate_efficiency() {
    local temp_out="$1"
    local max_power="$2"
    local eco_percent="$3"
    local dt_max="$4"
    
    # Cálculo da potência econômica (em BTU/h)
    local eco_power=$(echo "scale=2; $max_power * $eco_percent / 100" | bc -l)
    
    # Aplicação da fórmula: ΔT_ideal = (ΔT_max × Potência_Econômica) / Potência_Máxima
    local dt_ideal=$(echo "scale=2; $dt_max * $eco_power / $max_power" | bc -l)
    
    # Temperatura ideal para programação
    local ideal_temp=$(echo "scale=1; $temp_out - $dt_ideal" | bc -l)
    
    # Temperatura para conforto eficiente (ΔT ~8-10°C)
    local confort_temp_low=$(echo "scale=1; $temp_out - 10" | bc -l)
    local confort_temp_high=$(echo "scale=1; $temp_out - 8" | bc -l)
    
    # Ajuste para não sugerir temperaturas abaixo de 18°C ou acima de 35°C
    if (( $(echo "$ideal_temp < 18" | bc -l) )); then
        ideal_temp=18.0
        dt_ideal=$(echo "scale=2; $temp_out - $ideal_temp" | bc -l)
    fi
    
    if (( $(echo "$confort_temp_low < 18" | bc -l) )); then
        confort_temp_low=18.0
        confort_temp_high=20.0
    fi
    
    # Retorna os resultados
    echo "$dt_ideal:$ideal_temp:$confort_temp_low:$confort_temp_high:$eco_power"
}

# ============================================
# FUNÇÃO: Exibe resultados formatados
# ============================================
display_results() {
    local temp_out="$1"
    local max_power="$2"
    local eco_percent="$3"
    local dt_max="$4"
    local dt_ideal="$5"
    local ideal_temp="$6"
    local confort_low="$7"
    local confort_high="$8"
    local eco_power="$9"
    
    echo -e "\n${BOLD}${PURPLE}══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}   RESULTADO DO CÁLCULO DE EFICIÊNCIA TÉRMICA${NC}"
    echo -e "${BOLD}${PURPLE}══════════════════════════════════════════════════════════════════${NC}\n"
    
    # Seção 1: Dados de Entrada
    echo -e "${BOLD}${UNDERLINE}📊 DADOS DE ENTRADA:${NC}"
    printf "  • Temperatura Externa:        ${GREEN}%.1f°C${NC}\n" "$temp_out"
    printf "  • Potência Máxima do Aparelho: ${BLUE}%.0f BTU/h${NC}\n" "$max_power"
    printf "  • Modo Econômico:             ${YELLOW}%.0f%% da potência máxima${NC}\n" "$eco_percent"
    printf "  • ΔT Máxima Suportada:        %.0f°C\n" "$dt_max"
    printf "  • Potência em Modo Econômico:  %.0f BTU/h\n" "$eco_power"
    
    # Seção 2: Cálculo Realizado
    echo -e "\n${BOLD}${UNDERLINE}🧮 FÓRMULA APLICADA:${NC}"
    echo -e "  ${YELLOW}ΔT_ideal = (ΔT_max × Potência_Econômica) / Potência_Máxima${NC}"
    echo -e "  ${YELLOW}ΔT_ideal = ($dt_max × $eco_power) / $max_power${NC}"
    printf "  ${YELLOW}ΔT_ideal = %.2f°C${NC}\n" "$dt_ideal"
    
    # Seção 3: Resultados
    echo -e "\n${BOLD}${UNDERLINE}🎯 RECOMENDAÇÕES TÉCNICAS:${NC}"
    echo -e "  ${GREEN}1. PARA MÁXIMA EFICIÊNCIA ENERGÉTICA:${NC}"
    printf "     Programe o termostato para: ${BOLD}%.1f°C${NC}\n" "$ideal_temp"
    printf "     (ΔT de %.1f°C em relação aos %.1f°C externos)\n" "$dt_ideal" "$temp_out"
    
    echo -e "\n  ${GREEN}2. PARA CONFORTO COM BOA EFICIÊNCIA:${NC}"
    printf "     Programe entre: ${BOLD}%.1f°C e %.1f°C${NC}\n" "$confort_low" "$confort_high"
    printf "     (ΔT de 8°C a 10°C em relação ao externo)\n"
    
    echo -e "\n  ${GREEN}3. RECOMENDAÇÃO PADRÃO DE CONFORTO:${NC}"
    echo -e "     Mantenha entre: ${BOLD}23°C e 25°C${NC} (recomendação PROcel/Anvisa)"
    
    # Seção 4: Explicação Pedagógica
    echo -e "\n${BOLD}${UNDERLINE}📚 EXPLICAÇÃO TÉCNICA:${NC}"
    echo -e "  O ar-condicionado inverter atinge seu pico de eficiência quando"
    echo -e "  opera no 'modo de manutenção' (baixa potência). A diferença de"
    echo -e "  temperatura calculada (ΔT_ideal = ${dt_ideal}°C) representa o ponto"
    echo -e "  onde a capacidade de resfriamento do aparelho no modo econômico"
    echo -e "  iguala a carga térmica do ambiente."
    echo -e "  \n  Se você programar uma temperatura ${RED}mais baixa${NC} que ${ideal_temp}°C,"
    echo -e "  o aparelho precisará operar em potência ${RED}mais alta${NC} por mais tempo,"
    echo -e "  reduzindo a eficiência da tecnologia inverter."
    
    # Seção 5: Status do Consumo
    echo -e "\n${BOLD}${UNDERLINE}⚡ STATUS PREVISTO DO CONSUMO:${NC}"
    
    local status_color=$GREEN
    local status_text="BAIXO"
    local status_desc="Maior tempo em modo econômico"
    
    if (( $(echo "$dt_ideal >= 8" | bc -l) )); then
        status_color=$YELLOW
        status_text="MODERADO"
        status_desc="Picos de potência mais frequentes"
    fi
    
    if (( $(echo "$ideal_temp < 23" | bc -l) )); then
        status_color=$RED
        status_text="ALTO"
        status_desc="Operação frequente em alta potência"
    fi
    
    echo -e "  Programando a ${ideal_temp}°C: ${status_color}${BOLD}${status_text}${NC}"
    echo -e "  ${status_desc}"
    
    echo -e "\n${BOLD}${PURPLE}══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}💡 Dica: Use ventiladores para melhorar a sensação térmica${NC}"
    echo -e "${CYAN}   sem baixar mais a temperatura do ar-condicionado.${NC}"
    echo -e "${BOLD}${PURPLE}══════════════════════════════════════════════════════════════════${NC}\n"
}

# ============================================
# PROCESSAMENTO DOS ARGUMENTOS
# ============================================

# Verifica se não há argumentos ou pedido de ajuda
if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    show_help
    exit 0
fi

# Variáveis para armazenar parâmetros
TEMP_OUT=""
MAX_POWER=$DEFAULT_MAX_POWER
ECO_PERCENT=$DEFAULT_ECO_PERCENT
DT_MAX=$DEFAULT_DT_MAX

# Parse dos argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        --temp-externa|-t)
            TEMP_OUT="$2"
            shift 2
            ;;
        --potencia|-p)
            MAX_POWER="$2"
            shift 2
            ;;
        --percent-eco|-e)
            ECO_PERCENT="$2"
            shift 2
            ;;
        --dt-max|-d)
            DT_MAX="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}❌ ERRO: Argumento desconhecido: $1${NC}" >&2
            echo -e "Use ${0##*/} --help para ver a sintaxe correta." >&2
            exit 1
            ;;
    esac
done

# ============================================
# VALIDAÇÃO DAS ENTRADAS
# ============================================

# Verifica se temperatura externa foi fornecida
if [[ -z "$TEMP_OUT" ]]; then
    echo -e "${RED}❌ ERRO: Temperatura externa é obrigatória.${NC}" >&2
    echo -e "Use: ${0##*/} --temp-externa TEMP" >&2
    exit 1
fi

# Validações numéricas
if ! validate_number "$TEMP_OUT" "Temperatura externa" -20 60; then exit 1; fi
if ! validate_number "$MAX_POWER" "Potência máxima" 5000 50000; then exit 1; fi
if ! validate_number "$ECO_PERCENT" "Percentual econômico" 20 50; then exit 1; fi
if ! validate_number "$DT_MAX" "ΔT máxima" 10 25; then exit 1; fi

# ============================================
# EXECUÇÃO DO CÁLCULO
# ============================================

echo -e "${BOLD}${GREEN}🔧 Executando cálculo de eficiência térmica...${NC}"

# Chama a função de cálculo
result=$(calculate_efficiency "$TEMP_OUT" "$MAX_POWER" "$ECO_PERCENT" "$DT_MAX")

# Separa os resultados
IFS=":" read -r dt_ideal ideal_temp confort_low confort_high eco_power <<< "$result"

# Exibe os resultados
display_results "$TEMP_OUT" "$MAX_POWER" "$ECO_PERCENT" "$DT_MAX" \
                "$dt_ideal" "$ideal_temp" "$confort_low" "$confort_high" "$eco_power"

exit 0