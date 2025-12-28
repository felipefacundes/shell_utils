#!/usr/bin/env python3
"""
Jewish Calendar Terminal Display
Exibe o calendário judaico no terminal com suporte multilíngue
Dependencies: pip install convertdate holidays
"""

from convertdate import hebrew
from datetime import date
import holidays
import sys
import os
import locale

# ==================== LANGUAGE DETECTION & TRANSLATIONS ====================
def detect_system_language():
    """Detect system language from environment variables."""
    # Try multiple environment variables in order of priority
    lang_env_vars = ['LANGUAGE', 'LC_ALL', 'LC_MESSAGES', 'LANG']
    
    for env_var in lang_env_vars:
        lang = os.environ.get(env_var)
        if lang:
            # Extract language code (e.g., 'pt_BR.UTF-8' -> 'pt')
            lang_code = lang.split('_')[0].lower()
            if lang_code in ['pt', 'en']:
                return lang_code
    
    # Default to English if no supported language detected
    return 'en'

# Get current system language
CURRENT_LANG = detect_system_language()

# Translation dictionaries
TRANSLATIONS = {
    'en': {
        'title': "Jewish Calendar - Terminal",
        'today_greg': "Today's date (Gregorian)",
        'today_heb': "Today's date (Hebrew)",
        'note': "Note: Jewish days begin at sunset of the previous day.",
        'no_holidays': "This month has no major Jewish holidays.",
        'holidays_title': "Jewish Holidays this month",
        'israel_holidays': "Holidays in Israel (for reference)",
        'legend': "Legend",
        'today_cal': "Today",
        'holiday_cal': "Major holiday in calendar",
        'month_names': {
            1: 'Nissan', 2: 'Iyar', 3: 'Sivan', 4: 'Tamuz',
            5: 'Av', 6: 'Elul', 7: 'Tishrei', 8: 'Cheshvan',
            9: 'Kislev', 10: 'Tevet', 11: 'Shevat', 12: 'Adar',
            13: 'Adar II'
        },
        'holidays': {
            (7, 1): "Rosh Hashaná (Jewish New Year)",
            (7, 2): "Rosh Hashaná (2nd day)",
            (7, 10): "Yom Kippur",
            (7, 15): "Sukkot (1st day)",
            (7, 21): "Hoshana Rabbah",
            (7, 22): "Shemini Atzeret",
            (7, 23): "Simchat Torah",
            (9, 25): "Hanukkah (1st candle)",
            (10, 3): "Hanukkah (8th candle, last day)",
            (12, 14): "Purim",
            (13, 14): "Purim (in leap years, in Adar II)",
            (1, 15): "Passover (1st day)",
            (1, 21): "Passover (7th day)",
            (3, 6): "Shavuot"
        },
        'weekdays': ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    },
    'pt': {
        'title': "Calendário Judaico - Terminal",
        'today_greg': "Data de hoje (gregoriana)",
        'today_heb': "Data de hoje (judaica)",
        'note': "Nota: Dias judaicos começam ao pôr do sol do dia anterior.",
        'no_holidays': "Este mês não possui feriados judaicos principais.",
        'holidays_title': "Feriados Judaicos deste mês",
        'israel_holidays': "Feriados em Israel (para referência)",
        'legend': "Legenda",
        'today_cal': "Dia atual",
        'holiday_cal': "Feriado principal no calendário",
        'month_names': {
            1: 'Nissan', 2: 'Iyar', 3: 'Sivan', 4: 'Tamuz',
            5: 'Av', 6: 'Elul', 7: 'Tishrei', 8: 'Cheshvan',
            9: 'Kislev', 10: 'Tevet', 11: 'Shevat', 12: 'Adar',
            13: 'Adar II'
        },
        'holidays': {
            (7, 1): "Rosh Hashaná (Ano Novo Judaico)",
            (7, 2): "Rosh Hashaná (2º dia)",
            (7, 10): "Yom Kipur",
            (7, 15): "Sucot (1º dia)",
            (7, 21): "Hoshana Raba",
            (7, 22): "Shemini Atzeret",
            (7, 23): "Simchat Torá",
            (9, 25): "Chanucá (1ª vela)",
            (10, 3): "Chanucá (8ª vela, final)",
            (12, 14): "Purim",
            (13, 14): "Purim (em anos embolismais, em Adar II)",
            (1, 15): "Pessach (1º dia)",
            (1, 21): "Pessach (7º dia)",
            (3, 6): "Shavuot"
        },
        'weekdays': ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab"]
    }
}

# Get translations for current language
T = TRANSLATIONS[CURRENT_LANG]

# ==================== TERMINAL COLORS ====================
try:
    if sys.stdout.isatty():
        RED = '\033[91m'
        GREEN = '\033[92m'
        YELLOW = '\033[93m'
        BLUE = '\033[94m'
        BOLD = '\033[1m'
        RESET = '\033[0m'
        HIGHLIGHT_STYLE = BOLD + BLUE
        HOLIDAY_STYLE = BOLD + YELLOW
    else:
        RED = GREEN = YELLOW = BLUE = BOLD = RESET = ''
        HIGHLIGHT_STYLE = '>'
        HOLIDAY_STYLE = '*'
except AttributeError:
    RED = GREEN = YELLOW = BLUE = BOLD = RESET = ''
    HIGHLIGHT_STYLE = '>'
    HOLIDAY_STYLE = '*'

# ==================== MAIN FUNCTIONS ====================
def get_current_dates():
    """Get current Gregorian date and convert to Hebrew date."""
    today_greg = date.today()
    heb_year, heb_month, heb_day = hebrew.from_gregorian(today_greg.year,
                                                         today_greg.month,
                                                         today_greg.day)
    return today_greg, heb_year, heb_month, heb_day

def generate_month_calendar(heb_year, heb_month, current_heb_day):
    """
    Generate Hebrew month calendar matrix and highlight current day.
    Returns the matrix and list of holidays for the month.
    """
    month_matrix = hebrew.monthcalendar(heb_year, heb_month)
    month_holidays = []
    
    for week in month_matrix:
        for i, day in enumerate(week):
            if day is not None:
                holiday_key = (heb_month, day)
                
                if holiday_key in T['holidays']:
                    holiday_name = T['holidays'][holiday_key]
                    month_holidays.append((day, holiday_name))
                    
                    # Mark major holidays with asterisk
                    if any(keyword in holiday_name for keyword in 
                           ["Rosh Hashaná", "Yom Kippur", "Yom Kipur", 
                            "Hanukkah", "Chanucá", "Passover", "Pessach", "Purim"]):
                        week[i] = f"{day}*"
                    else:
                        week[i] = f"{day}"
                else:
                    week[i] = f"{day}"
                
                # Highlight current day
                if day == current_heb_day:
                    week[i] = f"{HIGHLIGHT_STYLE}{week[i]}{RESET}"
    
    return month_matrix, month_holidays

def get_israeli_holidays(greg_year, heb_month):
    """
    Get Israeli holidays (which follow the Jewish calendar)
    for the Gregorian year, using the 'holidays' library.
    Useful for cross-reference.
    """
    try:
        # 'IL' is the country code for Israel in the holidays package
        holiday_obj = holidays.IL(years=greg_year)
        holiday_list = []
        for holiday_date, name in sorted(holiday_obj.items()):
            # Convert holiday Gregorian date to Hebrew
            heb_y, heb_m, heb_d = hebrew.from_gregorian(holiday_date.year,
                                                         holiday_date.month,
                                                         holiday_date.day)
            holiday_list.append((holiday_date, name, (heb_y, heb_m, heb_d)))
        return holiday_list
    except Exception as e:
        # Silent fallback if library is not installed or fails
        return []

def display_calendar(heb_year, heb_month, month_matrix, month_holidays):
    """Format and print the calendar in terminal."""
    month_name = T['month_names'].get(heb_month, f"Month {heb_month}")
    header = f"{BOLD}{month_name} {heb_year}{RESET}"
    
    print(f"\n{header:^27}")
    print("-" * 27)
    
    # Print weekdays in detected language
    print(" " + "  ".join(f"{day:3}" for day in T['weekdays']))
    
    for week in month_matrix:
        formatted_week = []
        for day in week:
            if day is None:
                formatted_week.append(" " * 5)
            else:
                formatted_week.append(f"{day:^5}")
        print("".join(formatted_week))

def main():
    """Main script function."""
    print(f"{BOLD}{T['title']}{RESET}")
    print(f"{GREEN}{T['today_greg']}: {date.today():%d/%m/%Y}{RESET}")
    
    # Get current dates
    today_greg, heb_year, heb_month, heb_day = get_current_dates()
    heb_date_formatted = f"{heb_day}/{heb_month}/{heb_year}"
    print(f"{GREEN}{T['today_heb']}:   {heb_date_formatted}{RESET}")
    print(f"{YELLOW}{T['note']}{RESET}\n")
    
    # Generate calendar and holidays
    calendar, month_holidays = generate_month_calendar(heb_year, heb_month, heb_day)
    
    # Display calendar
    display_calendar(heb_year, heb_month, calendar, month_holidays)
    print()
    
    # Display holidays list
    if month_holidays:
        print(f"{BOLD}{T['holidays_title']}:{RESET}")
        for day, name in sorted(month_holidays):
            style = HOLIDAY_STYLE if day == heb_day else ""
            month_name = T['month_names'][heb_month]
            print(f"  {style}{day:>2} of {month_name}: {name}{RESET if style else ''}")
    else:
        print(f"{YELLOW}{T['no_holidays']}{RESET}")
    
    # Get and display Israeli holidays for reference (original feature)
    israel_holidays = get_israeli_holidays(today_greg.year, heb_month)
    if israel_holidays:
        print(f"\n{BOLD}{T['israel_holidays']} {today_greg.year}:{RESET}")
        for h_date, h_name, (h_y, h_m, h_d) in israel_holidays:
            if h_m == heb_month:  # Only show if in current Hebrew month
                print(f"  {h_date:%d/%m}: {h_name} ({h_d}/{h_m}/{h_y})")
    
    # Print legend
    print(f"\n{BOLD}{T['legend']}:{RESET} {HIGHLIGHT_STYLE}{T['today_cal']}{RESET},  *{T['holiday_cal']}")
    
    # Display detected language (optional - can be removed)
    #print(f"\n{'(Language detected: ' + CURRENT_LANG + ')'}")

if __name__ == "__main__":
    main()