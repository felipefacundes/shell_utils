#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

# Script Name: Alarm Daemon Multilingual

: <<'DOCUMENTATION'
# Bash Alarm Script Analysis

This versatile alarm script serves as a powerful alternative to traditional 
scheduling tools like 'at', 'cron', and 'fcron', offering several advantages:

# Key Features and Strengths

1. User-Friendly Interface
   - Utilizes Zenity for graphical interface interactions
   - Provides intuitive dialog boxes for all user inputs
   - Supports multiple languages (English, Portuguese, French, German, Romanian, Chinese, Korean, Russian, Hebrew, Arab and Spanish)

2. Flexible Scheduling Options
   - Supports one-time alarms
   - Allows daily repetition
   - Enables specific weekday scheduling
   - Offers 10-minute snooze functionality
   - Provides immediate scheduling without root access

3. Rich Notification System
   - Visual alerts through screen gamma manipulation
   - Audio alerts using system sounds
   - Customizable alert messages
   - Screen flashing for visibility
   - Volume-controlled sound notifications

4. Advanced Functionality
   - Can execute custom scripts/commands when alarm triggers
   - Supports opening specific files via xdg-open
   - Maintains persistent alarm storage in ~/.alarms
   - Runs as a user-level daemon without root privileges
   - Automatically handles timezone and locale settings

5. Robust Implementation
   - Error handling for missing inputs
   - Automatic screen detection using xrandr
   - Safe concurrent execution of multiple alarms
   - Clean process management for alert systems
   - Proper cleanup of completed one-time alarms

6. System Integration
   - Works with standard Linux sound system (PulseAudio)
   - Integrates with X11 display server
   - Uses standard filesystem operations
   - Compatible with desktop environments
   - Follows FreeDesktop.org standards

7. User Privacy and Security
   - All data stored in user's home directory
   - No system-wide installation required
   - No root privileges needed
   - Self-contained execution environment
   - Personal alarm configuration per user

This script provides a comprehensive alternative to traditional scheduling tools, 
offering a more user-friendly approach with enhanced features while maintaining 
security and privacy through user-level execution.
DOCUMENTATION

# Supply error prints!
exec 2>/dev/null

# Declare an associative array for multilingual messages
declare -A MESSAGES
if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        [alarm_year]="Ano do alarme"
        [enter_alarm_year]="Digite o ano do alarme (4 dígitos)"
        [alarm_month]="Mês do alarme"
        [enter_alarm_month]="Digite o mês do alarme (01-12)"
        [alarm_day]="Dia do alarme"
        [enter_alarm_day]="Digite o dia do alarme (01-31)"
        [alarm_hour]="Hora do alarme"
        [enter_alarm_hour]="Digite a hora do alarme (00-23)"
        [alarm_minute]="Minuto do alarme"
        [enter_alarm_minute]="Digite o minuto do alarme (00-59)"
        [year_invalid]="Ano inválido! Insira o ano vigente ou posterior."
        [month_invalid]="Mês inválido! Use um valor entre 01 e 12."
        [day_invalid]="Dia inválido! Use um valor entre 01 e 31."
        [hour_invalid]="Hora inválida! Use um valor entre 00 e 23."
        [minute_invalid]="Minuto inválido! Use um valor entre 00 e 59."
        [error_data]="Erro nos dados"
        ["year_empty"]="O campo do ano está vazio."
        ["month_empty"]="O campo do mês está vazio."
        ["day_empty"]="O campo do dia está vazio."
        ["hour_empty"]="O campo da hora está vazio."
        ["minute_empty"]="O campo do minuto está vazio."
        ["alarm_message"]="Mensagem do Alarme"
        ["enter_alarm_message"]="Digite a mensagem a ser exibida quando o alarme tocar:"
        ["execute_script"]="Execute script/comando?"
        ["execute_script_question"]="Você deseja executar um script ou comando?"
        ["select_the_script"]="Selecione o script/comando a ser executado:"
        ["open_file"]="Abrir arquivo?"
        ["open_file_question"]="Você deseja abrir um arquivo com xdg-open?"
        ["open_file_select"]="Selecione o arquivo a ser aberto:"
        ["repeat_alarm"]="Repetir Alarme?"
        ["repeat_alarm_question"]="Você gostaria que o alarme se repetisse?"
        ["select"]="Selecione"
        ["option"]="Opção"
        ["specific_days"]="Dias específicos"
        ["only_this_day"]="Somente este dia"
        ["every_day"]="Todos os dias"
        ["days_of_week"]="Dias da semana"
        ["enter_days_of_week"]="Digite os dias da semana para repetir (ex: Seg, Ter, Qua):"
        ["alarm_created"]="Alarme criado com sucesso!"
        ["repeat_alarm_title"]="Repetir Alarme"
        ["repeat_alarm_10_question"]="Você deseja repetir este alarme nos próximos 10 minutos?"
        ["unable_to_detect_screen"]="Não foi possível detectar o nome da tela. Verifique com 'xrandr --listmonitors'."
        ["help_usage"]="Uso: ${0##*/} [opções]"
        ["help_options"]="Opções:"
        ["help_create"]="  -c    Criar um novo alarme"
        ["help_run"]="  -r    Executar alarmes existentes como daemon"
        ["help_help"]="  -h    Exibir esta ajuda"
    )
elif [[ "${LANG,,}" =~ fr_ ]]; then
    MESSAGES=(
        ["alarm_year"]="Année de l'alarme"
        ["enter_alarm_year"]="Entrez l'année de l'alarme (4 chiffres)"
        ["alarm_month"]="Mois de l'alarme"
        ["enter_alarm_month"]="Entrez le mois de l'alarme (01-12)"
        ["alarm_day"]="Jour de l'alarme"
        ["enter_alarm_day"]="Entrez le jour de l'alarme (01-31)"
        ["alarm_hour"]="Heure de l'alarme"
        ["enter_alarm_hour"]="Entrez l'heure de l'alarme (00-23)"
        ["alarm_minute"]="Minute de l'alarme"
        ["enter_alarm_minute"]="Entrez la minute de l'alarme (00-59)"
        ["year_invalid"]="Année invalide ! Entrez l'année actuelle ou une année plus tard."
        ["month_invalid"]="Mois invalide ! Utilisez une valeur entre 01 et 12."
        ["day_invalid"]="Jour invalide ! Utilisez une valeur entre 01 et 31."
        ["hour_invalid"]="Heure invalide ! Utilisez une valeur entre 00 et 23."
        ["minute_invalid"]="Minute invalide ! Utilisez une valeur entre 00 et 59."
        ["error_data"]="Erreur de données"
        ["year_empty"]="Le champ de l'année est vide."
        ["month_empty"]="Le champ du mois est vide."
        ["day_empty"]="Le champ du jour est vide."
        ["hour_empty"]="Le champ de l'heure est vide."
        ["minute_empty"]="Le champ des minutes est vide."
        ["alarm_message"]="Message de l'alarme"
        ["enter_alarm_message"]="Entrez le message à afficher lorsque l'alarme sonne :"
        ["execute_script"]="Exécuter un script/commande ?"
        ["execute_script_question"]="Voulez-vous exécuter un script ou une commande ?"
        ["select_the_script"]="Sélectionnez le script/la commande à exécuter :"
        ["open_file"]="Ouvrir un fichier ?"
        ["open_file_question"]="Voulez-vous ouvrir un fichier avec xdg-open ?"
        ["open_file_select"]="Sélectionnez le fichier à ouvrir :"
        ["repeat_alarm"]="Répéter l'alarme ?"
        ["repeat_alarm_question"]="Souhaitez-vous répéter l'alarme ?"
        ["select"]="Sélectionner"
        ["option"]="Option"
        ["specific_days"]="Jours spécifiques"
        ["only_this_day"]="Seulement ce jour"
        ["every_day"]="Chaque jour"
        ["days_of_week"]="Jours de la semaine"
        ["enter_days_of_week"]="Entrez les jours de la semaine pour répéter (par ex., Lun, Mar, Mer) :"
        ["alarm_created"]="Alarme créée avec succès !"
        ["repeat_alarm_title"]="Répéter l'alarme"
        ["repeat_alarm_10_question"]="Voulez-vous répéter cette alarme dans les 10 prochaines minutes ?"
        ["unable_to_detect_screen"]="Impossible de détecter le nom de l'écran. Vérifiez avec 'xrandr --listmonitors'."
        ["help_usage"]="Utilisation : ${0##*/} [options]"
        ["help_options"]="Options :"
        ["help_create"]="  -c    Créer une nouvelle alarme"
        ["help_run"]="  -r    Exécuter les alarmes existantes en tant que démon"
        ["help_help"]="  -h    Afficher cette aide"
    )
elif [[ "${LANG,,}" =~ de_ ]]; then
    MESSAGES=(
        ["alarm_year"]="Alarmjahr"
        ["enter_alarm_year"]="Geben Sie das Alarmjahr ein (4 Stellen)"
        ["alarm_month"]="Alarmmonat"
        ["enter_alarm_month"]="Geben Sie den Alarmmonat ein (01-12)"
        ["alarm_day"]="Alarmtag"
        ["enter_alarm_day"]="Geben Sie den Alarmtag ein (01-31)"
        ["alarm_hour"]="Alarmstunde"
        ["enter_alarm_hour"]="Geben Sie die Alarmstunde ein (00-23)"
        ["alarm_minute"]="Alarmminute"
        ["enter_alarm_minute"]="Geben Sie die Alarmminute ein (00-59)"
        ["year_invalid"]="Ungültiges Jahr! Geben Sie das aktuelle Jahr oder ein späteres ein."
        ["month_invalid"]="Ungültiger Monat! Verwenden Sie einen Wert zwischen 01 und 12."
        ["day_invalid"]="Ungültiger Tag! Verwenden Sie einen Wert zwischen 01 und 31."
        ["hour_invalid"]="Ungültige Stunde! Verwenden Sie einen Wert zwischen 00 und 23."
        ["minute_invalid"]="Ungültige Minute! Verwenden Sie einen Wert zwischen 00 und 59."
        ["error_data"]="Datenfehler"
        ["year_empty"]="Das Jahr-Feld ist leer."
        ["month_empty"]="Das Monat-Feld ist leer."
        ["day_empty"]="Das Tag-Feld ist leer."
        ["hour_empty"]="Das Stunden-Feld ist leer."
        ["minute_empty"]="Das Minuten-Feld ist leer."
        ["alarm_message"]="Alarmnachricht"
        ["enter_alarm_message"]="Geben Sie die Nachricht ein, die angezeigt werden soll, wenn der Alarm ausgelöst wird:"
        ["execute_script"]="Skript/Befehl ausführen?"
        ["execute_script_question"]="Möchten Sie ein Skript oder einen Befehl ausführen?"
        ["select_the_script"]="Wählen Sie das Skript/den Befehl aus, das/der ausgeführt werden soll:"
        ["open_file"]="Datei öffnen?"
        ["open_file_question"]="Möchten Sie eine Datei mit xdg-open öffnen?"
        ["open_file_select"]="Wählen Sie die zu öffnende Datei aus:"
        ["repeat_alarm"]="Alarm wiederholen?"
        ["repeat_alarm_question"]="Möchten Sie den Alarm wiederholen?"
        ["select"]="Auswählen"
        ["option"]="Option"
        ["specific_days"]="Spezifische Tage"
        ["only_this_day"]="Nur an diesem Tag"
        ["every_day"]="Jeden Tag"
        ["days_of_week"]="Wochentage"
        ["enter_days_of_week"]="Geben Sie die Wochentage für die Wiederholung ein (z. B. Mo, Di, Mi):"
        ["alarm_created"]="Alarm erfolgreich erstellt!"
        ["repeat_alarm_title"]="Alarm wiederholen"
        ["repeat_alarm_10_question"]="Möchten Sie diesen Alarm in den nächsten 10 Minuten wiederholen?"
        ["unable_to_detect_screen"]="Bildschirmname konnte nicht erkannt werden. Überprüfen Sie mit 'xrandr --listmonitors'."
        ["help_usage"]="Verwendung: ${0##*/} [Optionen]"
        ["help_options"]="Optionen:"
        ["help_create"]="  -c    Einen neuen Alarm erstellen"
        ["help_run"]="  -r    Bestehende Alarme als Daemon ausführen"
        ["help_help"]="  -h    Diese Hilfe anzeigen"
    )
elif [[ "${LANG,,}" =~ ro_ ]]; then
    MESSAGES=(
        ["alarm_year"]="Anul alarmei"
        ["enter_alarm_year"]="Introduceți anul alarmei (4 cifre)"
        ["alarm_month"]="Luna alarmei"
        ["enter_alarm_month"]="Introduceți luna alarmei (01-12)"
        ["alarm_day"]="Ziua alarmei"
        ["enter_alarm_day"]="Introduceți ziua alarmei (01-31)"
        ["alarm_hour"]="Ora alarmei"
        ["enter_alarm_hour"]="Introduceți ora alarmei (00-23)"
        ["alarm_minute"]="Minutul alarmei"
        ["enter_alarm_minute"]="Introduceți minutul alarmei (00-59)"
        ["year_invalid"]="An invalid! Introduceți anul curent sau unul ulterior."
        ["month_invalid"]="Lună invalidă! Utilizați o valoare între 01 și 12."
        ["day_invalid"]="Zi invalidă! Utilizați o valoare între 01 și 31."
        ["hour_invalid"]="Oră invalidă! Utilizați o valoare între 00 și 23."
        ["minute_invalid"]="Minut invalid! Utilizați o valoare între 00 și 59."
        ["error_data"]="Eroare de date"
        ["year_empty"]="Câmpul pentru anul este gol."
        ["month_empty"]="Câmpul pentru lună este gol."
        ["day_empty"]="Câmpul pentru zi este gol."
        ["hour_empty"]="Câmpul pentru oră este gol."
        ["minute_empty"]="Câmpul pentru minut este gol."
        ["alarm_message"]="Mesajul alarmei"
        ["enter_alarm_message"]="Introduceți mesajul care va fi afișat când alarma se declanșează:"
        ["execute_script"]="Executați script/comandă?"
        ["execute_script_question"]="Doriți să executați un script sau o comandă?"
        ["select_the_script"]="Selectați scriptul/comanda de executat:"
        ["open_file"]="Deschideți fișierul?"
        ["open_file_question"]="Doriți să deschideți un fișier cu xdg-open?"
        ["open_file_select"]="Selectați fișierul de deschis:"
        ["repeat_alarm"]="Repetați alarma?"
        ["repeat_alarm_question"]="Doriți să repetați alarma?"
        ["select"]="Selectați"
        ["option"]="Opțiune"
        ["specific_days"]="Zile specifice"
        ["only_this_day"]="Doar această zi"
        ["every_day"]="În fiecare zi"
        ["days_of_week"]="Zilele săptămânii"
        ["enter_days_of_week"]="Introduceți zilele săptămânii pentru repetare (de ex., Lun, Mar, Mie):"
        ["alarm_created"]="Alarma a fost creată cu succes!"
        ["repeat_alarm_title"]="Repetați alarma"
        ["repeat_alarm_10_question"]="Doriți să repetați această alarmă în următoarele 10 minute?"
        ["unable_to_detect_screen"]="Numele ecranului nu a putut fi detectat. Verificați cu 'xrandr --listmonitors'."
        ["help_usage"]="Utilizare: ${0##*/} [opțiuni]"
        ["help_options"]="Opțiuni:"
        ["help_create"]="  -c    Creează o alarmă nouă"
        ["help_run"]="  -r    Rulează alarmele existente ca daemon"
        ["help_help"]="  -h    Afișează acest ajutor"
    )
elif [[ "${LANG,,}" =~ ru_ ]]; then
    MESSAGES=(
        ["alarm_year"]="Год будильника"
        ["enter_alarm_year"]="Введите год будильника (4 цифры)"
        ["alarm_month"]="Месяц будильника"
        ["enter_alarm_month"]="Введите месяц будильника (01-12)"
        ["alarm_day"]="День будильника"
        ["enter_alarm_day"]="Введите день будильника (01-31)"
        ["alarm_hour"]="Час будильника"
        ["enter_alarm_hour"]="Введите час будильника (00-23)"
        ["alarm_minute"]="Минута будильника"
        ["enter_alarm_minute"]="Введите минуту будильника (00-59)"
        ["year_invalid"]="Недопустимый год! Введите текущий год или более поздний."
        ["month_invalid"]="Недопустимый месяц! Используйте значение от 01 до 12."
        ["day_invalid"]="Недопустимый день! Используйте значение от 01 до 31."
        ["hour_invalid"]="Недопустимый час! Используйте значение от 00 до 23."
        ["minute_invalid"]="Недопустимая минута! Используйте значение от 00 до 59."
        ["error_data"]="Ошибка данных"
        ["year_empty"]="Поле года пустое."
        ["month_empty"]="Поле месяца пустое."
        ["day_empty"]="Поле дня пустое."
        ["hour_empty"]="Поле часа пустое."
        ["minute_empty"]="Поле минуты пустое."
        ["alarm_message"]="Сообщение будильника"
        ["enter_alarm_message"]="Введите сообщение, которое будет отображаться при срабатывании будильника:"
        ["execute_script"]="Выполнить скрипт/команду?"
        ["execute_script_question"]="Хотите выполнить скрипт или команду?"
        ["select_the_script"]="Выберите скрипт/команду для выполнения:"
        ["open_file"]="Открыть файл?"
        ["open_file_question"]="Хотите открыть файл с помощью xdg-open?"
        ["open_file_select"]="Выберите файл для открытия:"
        ["repeat_alarm"]="Повторить будильник?"
        ["repeat_alarm_question"]="Хотите повторить будильник?"
        ["select"]="Выбрать"
        ["option"]="Опция"
        ["specific_days"]="Определенные дни"
        ["only_this_day"]="Только этот день"
        ["every_day"]="Каждый день"
        ["days_of_week"]="Дни недели"
        ["enter_days_of_week"]="Введите дни недели для повтора (например, Пн, Вт, Ср):"
        ["alarm_created"]="Будильник успешно создан!"
        ["repeat_alarm_title"]="Повторить будильник"
        ["repeat_alarm_10_question"]="Хотите повторить этот будильник через 10 минут?"
        ["unable_to_detect_screen"]="Не удалось обнаружить имя экрана. Проверьте с помощью 'xrandr --listmonitors'."
        ["help_usage"]="Использование: ${0##*/} [опции]"
        ["help_options"]="Опции:"
        ["help_create"]="  -c    Создать новый будильник"
        ["help_run"]="  -r    Запустить существующие будильники в виде демона"
        ["help_help"]="  -h    Показать эту справку"
    )
elif [[ "${LANG,,}" =~ zh_ ]]; then
    MESSAGES=(
        ["alarm_year"]="闹钟年份"
        ["enter_alarm_year"]="请输入闹钟年份（4位数字）"
        ["alarm_month"]="闹钟月份"
        ["enter_alarm_month"]="请输入闹钟月份（01-12）"
        ["alarm_day"]="闹钟日期"
        ["enter_alarm_day"]="请输入闹钟日期（01-31）"
        ["alarm_hour"]="闹钟小时"
        ["enter_alarm_hour"]="请输入闹钟小时（00-23）"
        ["alarm_minute"]="闹钟分钟"
        ["enter_alarm_minute"]="请输入闹钟分钟（00-59）"
        ["year_invalid"]="无效的年份！请输入当前年份或更晚的年份。"
        ["month_invalid"]="无效的月份！请输入01到12之间的值。"
        ["day_invalid"]="无效的日期！请输入01到31之间的值。"
        ["hour_invalid"]="无效的小时！请输入00到23之间的值。"
        ["minute_invalid"]="无效的分钟！请输入00到59之间的值。"
        ["error_data"]="数据错误"
        ["year_empty"]="年份字段为空。"
        ["month_empty"]="月份字段为空。"
        ["day_empty"]="日期字段为空。"
        ["hour_empty"]="小时字段为空。"
        ["minute_empty"]="分钟字段为空。"
        ["alarm_message"]="闹钟消息"
        ["enter_alarm_message"]="请输入闹钟响起时显示的消息："
        ["execute_script"]="执行脚本/命令？"
        ["execute_script_question"]="您想要执行脚本或命令吗？"
        ["select_the_script"]="选择要执行的脚本/命令："
        ["open_file"]="打开文件？"
        ["open_file_question"]="您想用 xdg-open 打开文件吗？"
        ["open_file_select"]="选择要打开的文件："
        ["repeat_alarm"]="重复闹钟？"
        ["repeat_alarm_question"]="您想重复这个闹钟吗？"
        ["select"]="选择"
        ["option"]="选项"
        ["specific_days"]="特定日期"
        ["only_this_day"]="仅此一天"
        ["every_day"]="每天"
        ["days_of_week"]="一周的天数"
        ["enter_days_of_week"]="输入重复的星期几（例如：周一、周二、周三）："
        ["alarm_created"]="闹钟创建成功！"
        ["repeat_alarm_title"]="重复闹钟"
        ["repeat_alarm_10_question"]="您想在接下来的10分钟内重复这个闹钟吗？"
        ["unable_to_detect_screen"]="无法检测屏幕名称。请使用 'xrandr --listmonitors' 检查。"
        ["help_usage"]="用法：${0##*/} [选项]"
        ["help_options"]="选项："
        ["help_create"]="  -c    创建一个新的闹钟"
        ["help_run"]="  -r    作为守护进程运行现有的闹钟"
        ["help_help"]="  -h    显示此帮助"
    )
elif [[ "${LANG,,}" =~ ko_ ]]; then
    MESSAGES=(
        ["alarm_year"]="알람 연도"
        ["enter_alarm_year"]="알람 연도를 입력하세요 (4자리 숫자)"
        ["alarm_month"]="알람 월"
        ["enter_alarm_month"]="알람 월을 입력하세요 (01-12)"
        ["alarm_day"]="알람 일"
        ["enter_alarm_day"]="알람 일을 입력하세요 (01-31)"
        ["alarm_hour"]="알람 시간"
        ["enter_alarm_hour"]="알람 시간을 입력하세요 (00-23)"
        ["alarm_minute"]="알람 분"
        ["enter_alarm_minute"]="알람 분을 입력하세요 (00-59)"
        ["year_invalid"]="잘못된 연도입니다! 현재 연도 또는 이후 연도를 입력하세요."
        ["month_invalid"]="잘못된 월입니다! 01부터 12 사이의 값을 사용하세요."
        ["day_invalid"]="잘못된 일입니다! 01부터 31 사이의 값을 사용하세요."
        ["hour_invalid"]="잘못된 시간입니다! 00부터 23 사이의 값을 사용하세요."
        ["minute_invalid"]="잘못된 분입니다! 00부터 59 사이의 값을 사용하세요."
        ["error_data"]="데이터 오류"
        ["year_empty"]="연도 필드가 비어 있습니다."
        ["month_empty"]="월 필드가 비어 있습니다."
        ["day_empty"]="날짜 필드가 비어 있습니다."
        ["hour_empty"]="시간 필드가 비어 있습니다."
        ["minute_empty"]="분 필드가 비어 있습니다."
        ["alarm_message"]="알람 메시지"
        ["enter_alarm_message"]="알람이 울릴 때 표시할 메시지를 입력하세요:"
        ["execute_script"]="스크립트/명령 실행?"
        ["execute_script_question"]="스크립트나 명령을 실행하시겠습니까?"
        ["select_the_script"]="실행할 스크립트/명령을 선택하세요:"
        ["open_file"]="파일 열기?"
        ["open_file_question"]="xdg-open으로 파일을 열겠습니까?"
        ["open_file_select"]="열 파일을 선택하세요:"
        ["repeat_alarm"]="알람 반복?"
        ["repeat_alarm_question"]="이 알람을 반복하시겠습니까?"
        ["select"]="선택"
        ["option"]="옵션"
        ["specific_days"]="특정 날짜"
        ["only_this_day"]="이 날만"
        ["every_day"]="매일"
        ["days_of_week"]="요일"
        ["enter_days_of_week"]="반복할 요일을 입력하세요 (예: 월, 화, 수):"
        ["alarm_created"]="알람이 성공적으로 생성되었습니다!"
        ["repeat_alarm_title"]="알람 반복"
        ["repeat_alarm_10_question"]="10분 후에 이 알람을 반복하시겠습니까?"
        ["unable_to_detect_screen"]="화면 이름을 감지할 수 없습니다. 'xrandr --listmonitors'로 확인하세요."
        ["help_usage"]="사용법: ${0##*/} [옵션]"
        ["help_options"]="옵션:"
        ["help_create"]="  -c    새 알람 생성"
        ["help_run"]="  -r    기존 알람을 데몬으로 실행"
        ["help_help"]="  -h    도움말 표시"
    )
elif [[ "${LANG,,}" =~ he_ ]]; then
    MESSAGES=(
        ["alarm_year"]="שנת התרעה"
        ["enter_alarm_year"]="הזן את שנת ההתרעה (4 ספרות)"
        ["alarm_month"]="חודש התרעה"
        ["enter_alarm_month"]="הזן את חודש ההתרעה (01-12)"
        ["alarm_day"]="יום התרעה"
        ["enter_alarm_day"]="הזן את יום ההתרעה (01-31)"
        ["alarm_hour"]="שעת התרעה"
        ["enter_alarm_hour"]="הזן את שעת ההתרעה (00-23)"
        ["alarm_minute"]="דקת התרעה"
        ["enter_alarm_minute"]="הזן את דקת ההתרעה (00-59)"
        ["year_invalid"]="!שנה לא חוקית הזן את השנה הנוכחית או מאוחרת יותר."
        ["month_invalid"]="!חודש לא חוקי השתמש בערך בין 01 ל-12."
        ["day_invalid"]="!יום לא חוקי השתמש בערך בין 01 ל-31."
        ["hour_invalid"]="!שעה לא חוקית השתמש בערך בין 00 ל-23."
        ["minute_invalid"]="!דקה לא חוקית השתמש בערך בין 00 ל-59."
        ["error_data"]="שגיאת נתונים"
        ["year_empty"]="שדה השנה ריק."
        ["month_empty"]="שדה החודש ריק."
        ["day_empty"]="שדה היום ריק."
        ["hour_empty"]="שדה השעה ריק."
        ["minute_empty"]="שדה הדקות ריק."
        ["alarm_message"]="הודעת ההתראה"
        ["enter_alarm_message"]="הזן את ההודעה שתוצג כאשר ההתראה תופעל:"
        ["execute_script"]="להריץ סקריפט/פקודה?"
        ["execute_script_question"]="האם ברצונך להריץ סקריפט או פקודה?"
        ["select_the_script"]="בחר את הסקריפט/פקודה להרצה:"
        ["open_file"]="לפתוח קובץ?"
        ["open_file_question"]="האם ברצונך לפתוח קובץ עם xdg-open?"
        ["open_file_select"]="בחר את הקובץ לפתיחה:"
        ["repeat_alarm"]="לחזור על ההתראה?"
        ["repeat_alarm_question"]="האם ברצונך לחזור על ההתראה?"
        ["select"]="בחר"
        ["option"]="אפשרות"
        ["specific_days"]="ימים מסוימים"
        ["only_this_day"]="רק ביום זה"
        ["every_day"]="כל יום"
        ["days_of_week"]="ימי השבוע"
        ["enter_days_of_week"]="הזן את ימי השבוע לחזרה (לדוגמה: שני, שלישי, רביעי):"
        ["alarm_created"]="ההתראה נוצרה בהצלחה!"
        ["repeat_alarm_title"]="חזור על ההתראה"
        ["repeat_alarm_10_question"]="האם ברצונך לחזור על ההתראה בעוד 10 דקות?"
        ["unable_to_detect_screen"]="לא ניתן לזהות את שם המסך. בדוק עם 'xrandr --listmonitors'."
        ["help_usage"]="שימוש: ${0##*/} [אפשרויות]"
        ["help_options"]="אפשרויות:"
        ["help_create"]="  -c    צור התראה חדשה"
        ["help_run"]="  -r    הרץ התראות קיימות כשירות רקע"
        ["help_help"]="  -h    הצג עזרה זו"
    )
elif [[ "${LANG,,}" =~ ar_ ]]; then
    MESSAGES=(
        ["alarm_year"]="سنة المنبه"
        ["enter_alarm_year"]="أدخل سنة المنبه (4 أرقام)"
        ["alarm_month"]="شهر المنبه"
        ["enter_alarm_month"]="أدخل شهر المنبه (01-12)"
        ["alarm_day"]="يوم المنبه"
        ["enter_alarm_day"]="أدخل يوم المنبه (01-31)"
        ["alarm_hour"]="ساعة المنبه"
        ["enter_alarm_hour"]="أدخل ساعة المنبه (00-23)"
        ["alarm_minute"]="دقيقة المنبه"
        ["enter_alarm_minute"]="أدخل دقيقة المنبه (00-59)"
        ["year_invalid"]="!سنة غير صالحة أدخل السنة الحالية أو لاحقًا."
        ["month_invalid"]="!شهر غير صالح استخدم قيمة بين 01 و 12."
        ["day_invalid"]="!يوم غير صالح استخدم قيمة بين 01 و 31."
        ["hour_invalid"]="!ساعة غير صالحة استخدم قيمة بين 00 و 23."
        ["minute_invalid"]="!دقيقة غير صالحة استخدم قيمة بين 00 و 59."
        ["error_data"]="خطأ في البيانات"
        ["year_empty"]="حقل السنة فارغ."
        ["month_empty"]="حقل الشهر فارغ."
        ["day_empty"]="حقل اليوم فارغ."
        ["hour_empty"]="حقل الساعة فارغ."
        ["minute_empty"]="حقل الدقيقة فارغ."
        ["alarm_message"]="رسالة التنبيه"
        ["enter_alarm_message"]="أدخل الرسالة التي ستظهر عند تشغيل التنبيه:"
        ["execute_script"]="تشغيل سكربت/أمر؟"
        ["execute_script_question"]="هل ترغب في تشغيل سكربت أو أمر؟"
        ["select_the_script"]="اختر السكربت/الأمر للتشغيل:"
        ["open_file"]="فتح ملف؟"
        ["open_file_question"]="هل ترغب في فتح ملف باستخدام xdg-open؟"
        ["open_file_select"]="اختر الملف لفتحه:"
        ["repeat_alarm"]="تكرار التنبيه؟"
        ["repeat_alarm_question"]="هل ترغب في تكرار التنبيه؟"
        ["select"]="اختر"
        ["option"]="خيار"
        ["specific_days"]="أيام محددة"
        ["only_this_day"]="فقط هذا اليوم"
        ["every_day"]="كل يوم"
        ["days_of_week"]="أيام الأسبوع"
        ["enter_days_of_week"]="أدخل أيام الأسبوع للتكرار (مثل: اثنين، ثلاثاء، أربعاء):"
        ["alarm_created"]="تم إنشاء التنبيه بنجاح!"
        ["repeat_alarm_title"]="تكرار التنبيه"
        ["repeat_alarm_10_question"]="هل ترغب في تكرار هذا التنبيه خلال 10 دقائق؟"
        ["unable_to_detect_screen"]="تعذر اكتشاف اسم الشاشة. تحقق باستخدام 'xrandr --listmonitors'."
        ["help_usage"]="الاستخدام: ${0##*/} [خيارات]"
        ["help_options"]="خيارات:"
        ["help_create"]="  -c    إنشاء تنبيه جديد"
        ["help_run"]="  -r    تشغيل التنبيهات الموجودة كخدمة"
        ["help_help"]="  -h    عرض هذه المساعدة"
    )
elif [[ "${LANG,,}" =~ ja_ ]]; then
    MESSAGES=(
        ["alarm_year"]="アラームの年"
        ["enter_alarm_year"]="アラームの年を入力してください（4桁）"
        ["alarm_month"]="アラームの月"
        ["enter_alarm_month"]="アラームの月を入力してください（01-12）"
        ["alarm_day"]="アラームの日"
        ["enter_alarm_day"]="アラームの日を入力してください（01-31）"
        ["alarm_hour"]="アラームの時間"
        ["enter_alarm_hour"]="アラームの時間を入力してください（00-23）"
        ["alarm_minute"]="アラームの分"
        ["enter_alarm_minute"]="アラームの分を入力してください（00-59）"
        ["year_invalid"]="無効な年です！ 現在の年またはそれ以降を入力してください。"
        ["month_invalid"]="無効な月です！ 01から12の値を使用してください。"
        ["day_invalid"]="無効な日です！ 01から31の値を使用してください。"
        ["hour_invalid"]="無効な時間です！ 00から23の値を使用してください。"
        ["minute_invalid"]="無効な分です！ 00から59の値を使用してください。"
        ["error_data"]="データエラー"
        ["year_empty"]="年のフィールドが空です。"
        ["month_empty"]="月のフィールドが空です。"
        ["day_empty"]="日のフィールドが空です。"
        ["hour_empty"]="時のフィールドが空です。"
        ["minute_empty"]="分のフィールドが空です。"
        ["alarm_message"]="アラームメッセージ"
        ["enter_alarm_message"]="アラームが鳴ったときに表示するメッセージを入力してください:"
        ["execute_script"]="スクリプト/コマンドを実行しますか?"
        ["execute_script_question"]="スクリプトまたはコマンドを実行しますか?"
        ["select_the_script"]="実行するスクリプト/コマンドを選択してください:"
        ["open_file"]="ファイルを開きますか?"
        ["open_file_question"]="xdg-openでファイルを開きますか?"
        ["open_file_select"]="開くファイルを選択してください:"
        ["repeat_alarm"]="アラームを繰り返しますか?"
        ["repeat_alarm_question"]="アラームを繰り返しますか?"
        ["select"]="選択"
        ["option"]="オプション"
        ["specific_days"]="特定の日"
        ["only_this_day"]="この日だけ"
        ["every_day"]="毎日"
        ["days_of_week"]="曜日"
        ["enter_days_of_week"]="繰り返す曜日を入力してください (例: 月, 火, 水):"
        ["alarm_created"]="アラームが正常に作成されました!"
        ["repeat_alarm_title"]="アラームを繰り返す"
        ["repeat_alarm_10_question"]="次の10分間にこのアラームを繰り返しますか?"
        ["unable_to_detect_screen"]="画面名を検出できません。'xrandr --listmonitors'で確認してください。"
        ["help_usage"]="使用法: ${0##*/} [オプション]"
        ["help_options"]="オプション:"
        ["help_create"]="  -c    新しいアラームを作成"
        ["help_run"]="  -r    既存のアラームをデーモンとして実行"
        ["help_help"]="  -h    このヘルプを表示"
    )
elif [[ "${LANG,,}" =~ es_ ]]; then
    MESSAGES=(
        ["alarm_year"]="Año de Alarma"
        ["enter_alarm_year"]="Ingrese el año de la alarma (4 dígitos)"
        ["alarm_month"]="Mes de Alarma"
        ["enter_alarm_month"]="Ingrese el mes de la alarma (01-12)"
        ["alarm_day"]="Día de Alarma"
        ["enter_alarm_day"]="Ingrese el día de la alarma (01-31)"
        ["alarm_hour"]="Hora de Alarma"
        ["enter_alarm_hour"]="Ingrese la hora de la alarma (00-23)"
        ["alarm_minute"]="Minuto de Alarma"
        ["enter_alarm_minute"]="Ingrese el minuto de la alarma (00-59)"
        ["year_invalid"]="¡Año inválido! Ingrese el año actual o uno posterior."
        ["month_invalid"]="¡Mes inválido! Use un valor entre 01 y 12."
        ["day_invalid"]="¡Día inválido! Use un valor entre 01 y 31."
        ["hour_invalid"]="¡Hora inválida! Use un valor entre 00 y 23."
        ["minute_invalid"]="¡Minuto inválido! Use un valor entre 00 y 59."
        ["error_data"]="Error de Datos"
        ["year_empty"]="El campo del año está vacío."
        ["month_empty"]="El campo del mes está vacío."
        ["day_empty"]="El campo del día está vacío."
        ["hour_empty"]="El campo de la hora está vacío."
        ["minute_empty"]="El campo del minuto está vacío."
        ["alarm_message"]="Mensaje de la alarma"
        ["enter_alarm_message"]="Introduce el mensaje que se mostrará cuando suene la alarma:"
        ["execute_script"]="¿Ejecutar script/comando?"
        ["execute_script_question"]="¿Quieres ejecutar un script o comando?"
        ["select_the_script"]="Selecciona el script/comando a ejecutar:"
        ["open_file"]="¿Abrir archivo?"
        ["open_file_question"]="¿Quieres abrir un archivo con xdg-open?"
        ["open_file_select"]="Selecciona el archivo a abrir:"
        ["repeat_alarm"]="¿Repetir alarma?"
        ["repeat_alarm_question"]="¿Te gustaría repetir la alarma?"
        ["select"]="Seleccionar"
        ["option"]="Opción"
        ["specific_days"]="Días específicos"
        ["only_this_day"]="Solo este día"
        ["every_day"]="Todos los días"
        ["days_of_week"]="Días de la semana"
        ["enter_days_of_week"]="Introduce los días de la semana para repetir (por ejemplo, lun, mar, mié):"
        ["alarm_created"]="¡Alarma creada con éxito!"
        ["repeat_alarm_title"]="Repetir alarma"
        ["repeat_alarm_10_question"]="¿Quieres repetir esta alarma en los próximos 10 minutos?"
        ["unable_to_detect_screen"]="No se puede detectar el nombre de la pantalla. Verifica con 'xrandr --listmonitors'."
        ["help_usage"]="Uso: ${0##*/} [opciones]"
        ["help_options"]="Opciones:"
        ["help_create"]="  -c    Crear una nueva alarma"
        ["help_run"]="  -r    Ejecutar alarmas existentes como servicio en segundo plano"
        ["help_help"]="  -h    Mostrar esta ayuda"
    )
else
    MESSAGES=(
        ["alarm_year"]="Alarm Year"
        ["enter_alarm_year"]="Enter the alarm year (4 digits)"
        ["alarm_month"]="Alarm Month"
        ["enter_alarm_month"]="Enter the alarm month (01-12)"
        ["alarm_day"]="Alarm Day"
        ["enter_alarm_day"]="Enter the alarm day (01-31)"
        ["alarm_hour"]="Alarm Hour"
        ["enter_alarm_hour"]="Enter the alarm hour (00-23)"
        ["alarm_minute"]="Alarm Minute"
        ["enter_alarm_minute"]="Enter the alarm minute (00-59)"
        ["year_invalid"]="Invalid year! Enter the current year or later."
        ["month_invalid"]="Invalid month! Use a value between 01 and 12."
        ["day_invalid"]="Invalid day! Use a value between 01 and 31."
        ["hour_invalid"]="Invalid hour! Use a value between 00 and 23."
        ["minute_invalid"]="Invalid minute! Use a value between 00 and 59."
        ["error_data"]="Data Error"
        ["year_empty"]="The year field is empty."
        ["month_empty"]="The month field is empty."
        ["day_empty"]="The day field is empty."
        ["hour_empty"]="The hour field is empty."
        ["minute_empty"]="The minute field is empty."
        ["alarm_message"]="Alarm Message"
        ["enter_alarm_message"]="Enter the message to display when the alarm goes off:"
        ["execute_script"]="Execute script/command?"
        ["execute_script_question"]="Do you want to execute a script or command?"
        ["select_the_script"]="Select the script/command to execute:"
        ["open_file"]="Open file?"
        ["open_file_question"]="Do you want to open a file with xdg-open?"
        ["open_file_select"]="Select the file to open:"
        ["repeat_alarm"]="Repeat Alarm?"
        ["repeat_alarm_question"]="Would you like the alarm to repeat?"
        ["select"]="Select"
        ["option"]="Option"
        ["specific_days"]="Specific days"
        ["only_this_day"]="Only this day"
        ["every_day"]="Every day"
        ["days_of_week"]="Days of the week"
        ["enter_days_of_week"]="Enter the days of the week to repeat (e.g., Mon, Tue, Wed):"
        ["alarm_created"]="Alarm created successfully!"
        ["repeat_alarm_title"]="Repeat Alarm"
        ["repeat_alarm_10_question"]="Do you want to repeat this alarm in the next 10 minutes?"
        ["unable_to_detect_screen"]="Unable to detect screen name. Check with 'xrandr --listmonitors'."
        ["help_usage"]="Usage: ${0##*/} [options]"
        ["help_options"]="Options:"
        ["help_create"]="  -c    Create a new alarm"
        ["help_run"]="  -r    Run existing alarms as a daemon"
        ["help_help"]="  -h    Show this help"
    )
fi

# Set environment for date
#LC_ALL=c

# Directory for alarms
ALARM_DIR="$HOME/.alarms"
mkdir -p "$ALARM_DIR"

# Set screen name
screen=$(xrandr --listmonitors | grep '+' | awk '{print $4}')

# Function for visual alert (screen flash)
visual_alert() {
    # Interval between flashes (in seconds)
    interval=0.2

    if [ -z "$screen" ]; then
        echo "${MESSAGES[unable_to_detect_screen]}"
        exit 1
    fi

    while true; do
        # Set gamma for bright colors (default 1:1:1)
        xrandr --output "$screen" --gamma 1:1:1
        sleep $interval

        # Set gamma for darker colors (altered gamma)
        xrandr --output "$screen" --gamma 0.5:0.5:0.5
        sleep $interval
    done

    # Restore default gamma after effect
    xrandr --output "$screen" --gamma 1:1:1
}

# Function for audio alert using paplay
audio_alert() {
    # Sound file for alert
    sound="/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"
    
    # Play sound repeatedly until Zenity is closed
    while true; do
        pactl upload-sample "$sound"
        paplay "$sound" --volume=76767
        sleep 1
    done
}

validate_alarm_datetime() {
    local current_year=$(date +'%Y')
    export year month day hour minute
    
    while :; do
        year=$(zenity --entry --title="${MESSAGES[alarm_year]}" --text="${MESSAGES[enter_alarm_year]}" 2>/dev/null)
        if [[ -z "$year" ]]; then
            zenity --error --title="${MESSAGES[error_data]}" --text="${MESSAGES[year_empty]}" 2>/dev/null
            exit 1
        elif [[ ! "$year" =~ ^[0-9]{4}$ ]] || (( year < current_year )); then
            zenity --error --title="${MESSAGES[error_data]}" --text="${MESSAGES[year_invalid]}" 2>/dev/null
        else
            break
        fi
    done
    
    while :; do
        month=$(zenity --entry --title="${MESSAGES[alarm_month]}" --text="${MESSAGES[enter_alarm_month]}" 2>/dev/null)
        if [[ -z "$month" ]]; then
            zenity --error --title="${MESSAGES[error_data]}" --text="${MESSAGES[month_empty]}" 2>/dev/null
            exit 1
        elif [[ ! "$month" =~ ^(0[1-9]|1[0-2])$ ]]; then
            zenity --error --title="${MESSAGES[error_data]}" --text="${MESSAGES[month_invalid]}" 2>/dev/null
        else
            break
        fi
    done
    
    while :; do
        day=$(zenity --entry --title="${MESSAGES[alarm_day]}" --text="${MESSAGES[enter_alarm_day]}" 2>/dev/null)
        if [[ -z "$day" ]]; then
            zenity --error --title="${MESSAGES[error_data]}" --text="${MESSAGES[day_empty]}" 2>/dev/null
            exit 1
        elif [[ ! "$day" =~ ^(0[1-9]|[12][0-9]|3[01])$ ]]; then
            zenity --error --title="${MESSAGES[error_data]}" --text="${MESSAGES[day_invalid]}" 2>/dev/null
        else
            break
        fi
    done
    
    while :; do
        hour=$(zenity --entry --title="${MESSAGES[alarm_hour]}" --text="${MESSAGES[enter_alarm_hour]}" 2>/dev/null)
        if [[ -z "$hour" ]]; then
            zenity --error --title="${MESSAGES[error_data]}" --text="${MESSAGES[hour_empty]}" 2>/dev/null
            exit 1
        elif [[ ! "$hour" =~ ^([01][0-9]|2[0-3])$ ]]; then
            zenity --error --title="${MESSAGES[error_data]}" --text="${MESSAGES[hour_invalid]}" 2>/dev/null
        else
            break
        fi
    done
    
    while :; do
        minute=$(zenity --entry --title="${MESSAGES[alarm_minute]}" --text="${MESSAGES[enter_alarm_minute]}" 2>/dev/null)
        if [[ -z "$minute" ]]; then
            zenity --error --title="${MESSAGES[error_data]}" --text="${MESSAGES[minute_empty]}" 2>/dev/null
            exit 1
        elif [[ ! "$minute" =~ ^([0-5][0-9])$ ]]; then
            zenity --error --title="${MESSAGES[error_data]}" --text="${MESSAGES[minute_invalid]}" 2>/dev/null
        else
            break
        fi
    done
    
    echo "$year-$month-$day $hour:$minute"
}

# Function to create an alarm
create_alarm() {
    validate_alarm_datetime

    # Ask for the message to be displayed when the alarm goes off
    message=$(zenity --entry --title="${MESSAGES[alarm_message]}" --text="${MESSAGES[enter_alarm_message]}" 2>/dev/null)

    # Ask if a script/command should be executed
    execute_script=$(zenity --question --title="${MESSAGES[execute_script]}" --text="${MESSAGES[execute_script_question]}" && echo "yes" || echo "no" 2>/dev/null)
    
    if [[ "$execute_script" == "yes" ]]; then
        script_path=$(zenity --file-selection --title="${MESSAGES[select_the_script]}" 2>/dev/null)
    fi

    # Ask if a file should be opened with xdg-open
    open_file=$(zenity --question --title="${MESSAGES[open_file]}" --text="${MESSAGES[open_file_question]}" && echo "yes" || echo "no" 2>/dev/null)
    
    if [[ "$open_file" == "yes" ]]; then
        file_to_open=$(zenity --file-selection --title="${MESSAGES[open_file_select]}" 2>/dev/null)
    fi

    # Ask about alarm repetition
    repeat_alarm=$(zenity --list --radiolist --title="${MESSAGES[repeat_alarm]}" \
        --text="${MESSAGES[repeat_alarm_question]}" \
        --column="${MESSAGES[select]}"  --column="${MESSAGES[option]}"  \
        TRUE "${MESSAGES[only_this_day]}" FALSE "${MESSAGES[every_day]}" FALSE "${MESSAGES[specific_days]}" 2>/dev/null)
    
    if [[ "$repeat_alarm" == "${MESSAGES[specific_days]}" ]]; then
        days_of_week=$(zenity --entry --title="${MESSAGES[days_of_week]}" --text="${MESSAGES[enter_days_of_week]}" 2>/dev/null)
    fi

    # Alarm file name
    alarm_file="$ALARM_DIR/alarm_$(LC_ALL=c date +'%Y-%m-%d_%H:%M:%S').alarm"

    # Create alarm file
    echo "Year: $year" > "$alarm_file"
    echo "Month: $month" >> "$alarm_file"
    echo "Day: $day" >> "$alarm_file"
    echo "Hour: $hour" >> "$alarm_file"
    echo "Minute: $minute" >> "$alarm_file"
    echo "Message: $message" >> "$alarm_file"
    echo "Execute script: $execute_script" >> "$alarm_file"
    [[ "$execute_script" == "yes" ]] && echo "Script path: $script_path" >> "$alarm_file"
    echo "Open file: $open_file" >> "$alarm_file"
    [[ "$open_file" == "yes" ]] && echo "File to open: $file_to_open" >> "$alarm_file"
    echo "Repetition: $repeat_alarm" >> "$alarm_file"
    [[ "$repeat_alarm" == "${MESSAGES[specific_days]}" ]] && echo "Days: $days_of_week" >> "$alarm_file"
    
    zenity --info --text="${MESSAGES[alarm_created]}" 2>/dev/null
}

lock_generate() { 
    touch "$1" && sleep 120 && rm "$1"
}

# Function to run and execute alarms as a daemon
run_alarms() {
    while true; do
        SCRIPT="${0##*/}"
        TMPDIR="${TMPDIR:-/tmp}"
        LOCKDIR="${TMPDIR}/${SCRIPT%.*}"
        current_year=$(LC_ALL=c date +%Y)
        current_month=$(LC_ALL=c date +%m)
        current_day=$(LC_ALL=c date +%d)
        current_hour=$(LC_ALL=c date +%H)
        current_minute=$(LC_ALL=c date +%M)
        current_weekday=$(date +%a | tr '[A-Z]' '[a-z]') # e.g., Mon, Tue, Wed
        
        for alarm_file in "$ALARM_DIR"/*.alarm; do
            # Check if the file exists
            [[ -f "$alarm_file" ]] || continue
            [[ ! -d "$LOCKDIR" ]] && mkdir -p "$LOCKDIR"

            # Read alarm variables
            base_lock="${alarm_file##*/}"
            lock_file="${LOCKDIR}/${base_lock%.*}.lock"
            year=$(grep "Year:" "$alarm_file" | sed -n 's/.*:\s*\(.*\)/\1/p') #| cut -d ' ' -f 2)
            month=$(grep "Month:" "$alarm_file" | sed -n 's/.*:\s*\(.*\)/\1/p') #| cut -d ' ' -f 2)
            day=$(grep "Day:" "$alarm_file" | sed -n 's/.*:\s*\(.*\)/\1/p') #| cut -d ' ' -f 2)
            hour=$(grep "Hour:" "$alarm_file" | sed -n 's/.*:\s*\(.*\)/\1/p') #| cut -d ' ' -f 2)
            minute=$(grep "Minute:" "$alarm_file" | sed -n 's/.*:\s*\(.*\)/\1/p') #| cut -d ' ' -f 2)
            message=$(grep "Message:" "$alarm_file" | sed -n 's/.*:\s*\(.*\)/\1/p') #| cut -d ' ' -f 2-)
            execute_script=$(grep "Execute script:" "$alarm_file" | sed -n 's/.*:\s*\(.*\)/\1/p') #| cut -d ' ' -f 3)
            script_path=$(grep "Script path:" "$alarm_file" | sed -n 's/.*:\s*\(.*\)/\1/p') #| cut -d ' ' -f 4-)
            open_file=$(grep "Open file:" "$alarm_file" | sed -n 's/.*:\s*\(.*\)/\1/p') #| cut -d ' ' -f 3)
            file_to_open=$(grep "File to open:" "$alarm_file" | sed -n 's/.*:\s*\(.*\)/\1/p') #| cut -d ' ' -f 4-)
            repeat_alarm=$(grep "Repetition:" "$alarm_file" | sed -n 's/.*:\s*\(.*\)/\1/p') #| cut -d ' ' -f 2-)
            days_of_week=$(grep "Days:" "$alarm_file" | sed -n 's/.*:\s*\(.*\)/\1/p' | tr '[A-Z]' '[a-z]') #| cut -d ' ' -f 2-)

            # Check if the alarm is for the current moment
            # In '[ "$repeat_alarm" == "${MESSAGES[every_day]}" ]', the logic '&& [ "$current_day" -ge "$day" ]' was removed because, otherwise, the alarm would last approximately two weeks in that month.
            # [[ "$days_of_week" == *"$current_weekday"* ]]
            if { [ "$current_year" -eq "$year" ] && [ "$current_month" -eq "$month" ] && [ "$current_day" -eq "$day" ] && [ "$current_hour" -eq "$hour" ] && [ "$current_minute" -eq "$minute" ]; } ||
                { [ "$repeat_alarm" == "${MESSAGES[every_day]}" ] && [ "$current_year" -ge "$year" ] && [ "$current_month" -ge "$month" ] && [ "$current_hour" -eq "$hour" ] && [ "$current_minute" -eq "$minute" ]; } ||
                { [ "$repeat_alarm" == "${MESSAGES[specific_days]}" ] && [[ "$days_of_week" =~ "$current_weekday" ]] && [ "$current_hour" -eq "$hour" ] && [ "$current_minute" -eq "$minute" ]; }; then

                # Prevents the alarm from triggering on previous days of the current month 
                # when the alarm is set to repeat daily.
                # This ensures that the alarm only rings on or after the current day.
                if [ "$repeat_alarm" == "${MESSAGES[every_day]}" ] && [ "$current_month" -eq "$month" ] && [ "$current_day" -lt "$day" ]; then
                    continue
                fi

                # Prevents daily alarms from triggering on past days, including those from previous months.  
                # This ensures that the alarm only rings on or after the current day in the current month  
                # and does not reactivate alarms from past months.
                # if [ "$repeat_alarm" == "${MESSAGES[every_day]}" ] && \
                # [ "$current_year" -eq "$year" ] && \
                # { [ "$current_month" -lt "$month" ] || [ "$current_month" -eq "$month" ] && [ "$current_day" -lt "$day" ]; }; then
                #     continue
                # fi

                if [ "$current_minute" -eq "$minute" ] && [ -f "$lock_file" ]; then
                    continue
                fi

                # Run xdg-open
                if [[ "$open_file" == "yes" ]]; then
                    xdg-open "$file_to_open" &
                    open_pid=$!
                fi

                # Run script
                if [[ "$execute_script" == "yes" ]]; then
                    read -r -a script_path_array <<< "$script_path"
                    "${script_path_array[@]}" &
                    script_pid=$!
                fi

                # Run visual and audio alert in the background
                visual_alert &
                visual_pid=$!
                audio_alert &
                audio_pid=$!

                # Kill visual and audio alerts after clicking OK
                reset_and_kill() {
                    # Kill visual and audio alerts after clicking OK
                    kill "$visual_pid"
                    kill "$audio_pid"
                    pkill paplay

                    [[ "$open_file" == "yes" ]] && pkill -9 -P "$open_pid"; kill -9 "$open_pid"
                    [[ "$execute_script" == "yes" ]] && kill -9 "$script_pid"; pkill -9 -P "$script_pid"

                    # Restore default gamma after effect
                    xrandr --output "$screen" --gamma 1:1:1
                }

                # Display message with Zenity
                zenity --info --text="$message" 2>/dev/null && reset_and_kill

                # Ask if the alarm should repeat in the next 10 minutes
                repeat_10=$(zenity --question --title="${MESSAGES[repeat_alarm_title]}" --text="${MESSAGES[repeat_alarm_10_question]}" && echo "yes" || echo "no" 2>/dev/null)

                if [[ "$repeat_10" == "yes" ]]; then
                    # Create a new alarm file for 10 minutes after the current alarm
                    new_minute=$(LC_ALL=c date -d "+10 minutes" +%M)
                    new_hour=$(LC_ALL=c date -d "+10 minutes" +%H)
                    new_alarm_file="$ALARM_DIR/alarm_$(LC_ALL=c date +'%Y-%m-%d_%H:%M:%S')_repeat.alarm"
                    cp -f "$alarm_file" "$new_alarm_file"
                    sed -i "s/^Hour:.*/Hour: $new_hour/" "$new_alarm_file"
                    sed -i "s/^Minute:.*/Minute: $new_minute/" "$new_alarm_file"
                    sed -i "s/^Repetition:.*/Repetition: ${MESSAGES[only_this_day]}/" "$new_alarm_file"
                fi

                # If the alarm is not set to repeat, delete the file after execution
                if [[ "$repeat_alarm" == "${MESSAGES[only_this_day]}" ]]; then
                    rm -f "$alarm_file"
                fi

                if [ "$current_minute" -eq "$minute" ] && [ ! -f "$lock_file" ]; then
                    lock_generate "$lock_file" &
                fi
            fi
        done
        # Wait 5 seconds before checking alarms again
        sleep 5
    done
}

# Function to display help
show_help() {
    echo "${MESSAGES[help_usage]}"
    echo
    echo "${MESSAGES[help_options]}"
    echo "${MESSAGES[help_create]}"
    echo "${MESSAGES[help_run]}"
    echo "${MESSAGES[help_help]}"
    exit 0
}

# Check options passed to the script
case "$1" in
    -c)
        create_alarm
        ;;
    -r)
        run_alarms
        ;;
    -h|*)
        show_help
        ;;
esac