#!/bin/bash
# nkspfetch.sh — colored ASCII art banner with optional title block.
# Run `./nkspfetch.sh --help` for details.

DEFAULT_LINE_DELAY="0.03"
DEFAULT_CHAR_DELAY="0.003"

show_help() {
    cat <<'EOF'
NAME
    nkspfetch.sh - print a colored ASCII NKSP elephant art banner with optional title block.

SYNOPSIS
    nkspfetch.sh [--color=COLOR] [--title=N]
                 [--slow | --slow-chars] [--delay=SECONDS] [--char-delay=SECONDS]
                 [-h|--help]

DESCRIPTION
    Prints a fixed ASCII NKSP elephant. The lower "title" block can be toggled.
    Output color is configurable via the --color flag.
    Output can be printed line-by-line (--slow) or character-by-character
    (--slow-chars) with a small delay.

OPTIONS
    -c COLOR, --color=COLOR
                     Named color or raw ANSI SGR code. Case-sensitive names.
                     Named:    red, green, yellow, blue, magenta, cyan, white
                     Numeric:  any SGR code, e.g. 31, 1;32, 38;5;196
                     Default:  red

    -t N, --title=N  Toggle the title block. Accepted values:
                     1|true|yes|on  -> print (default)
                     0|false|no|off -> skip
                     --title         is equivalent to --title=1
                     --no-title      is equivalent to --title=0

    -s, --slow       Print line-by-line with a delay (default 0.03s).

    -S, --slow-chars Print character-by-character with a delay (default 0.003s).
                     Overrides --slow if both are given (last one wins).

    -d N, --delay=N  Line delay in seconds. Implies --slow if no mode was set.
                     Accepts fractional values, e.g. 0.1, 0.5, 1.
                     Default: 0.03

    --char-delay=N   Character delay in seconds. Implies --slow-chars if no
                     mode was set. Accepts fractional values, e.g. 0.003, 0.01.
                     Default: 0.003

    -h, --help       Show this help and exit.

EXAMPLES
    ./nkspfetch.sh
        Print with default red color and title.

    ./nkspfetch.sh --color=green
        Print in green with title.

    ./nkspfetch.sh --color=cyan --no-title
        Print in cyan without the title block.

    ./nkspfetch.sh --slow
        Line-by-line output, default 0.03s per line.

    ./nkspfetch.sh --slow --delay=0.1
        Slower line-by-line output.

    ./nkspfetch.sh --slow-chars
        Character-by-character output, default 0.003s per char.

    ./nkspfetch.sh --slow-chars --char-delay=0.01
        Slower character-by-character output.

    ./nkspfetch.sh --char-delay=0.001 --color='1;33'
        Bold yellow, fast character typing.

EXIT CODES
    0   Success (or --help).
    2   Invalid argument, unknown color, bad --title/--delay/--char-delay value.

EOF
}

usage() {
    echo "Usage: $0 [--color=COLOR] [--title=N] [--slow|--slow-chars] [--delay=SECONDS] [--char-delay=SECONDS] [-h|--help]" >&2
    echo "Try '$0 --help' for details." >&2
    exit 2
}

TITLE=1
COLOR_ARG=""
MODE="none"          # none | line | char
DELAY="$DEFAULT_LINE_DELAY"
CHAR_DELAY="$DEFAULT_CHAR_DELAY"

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)     show_help; exit 0 ;;
        --color=*)     COLOR_ARG="${1#*=}"; shift ;;
        -c)
            [ $# -lt 2 ] && { echo "Option -c requires a value" >&2; usage; }
            COLOR_ARG="$2"; shift 2 ;;
        --title)       TITLE=1; shift ;;
        --no-title)    TITLE=0; shift ;;
        --title=*)     TITLE="${1#*=}"; shift ;;
        -t)
            [ $# -lt 2 ] && { echo "Option -t requires a value" >&2; usage; }
            TITLE="$2"; shift 2 ;;
        -s|--slow)     MODE="line"; shift ;;
        -S|--slow-chars) MODE="char"; shift ;;
        --delay=*)     DELAY="${1#*=}"; [ "$MODE" = "none" ] && MODE="line"; shift ;;
        -d)
            [ $# -lt 2 ] && { echo "Option -d requires a value" >&2; usage; }
            DELAY="$2"; [ "$MODE" = "none" ] && MODE="line"; shift 2 ;;
        --char-delay=*) CHAR_DELAY="${1#*=}"; [ "$MODE" = "none" ] && MODE="char"; shift ;;
        --)            shift; break ;;
        -*)            echo "Unknown option: $1" >&2; usage ;;
        *)
            echo "Unexpected argument: '$1'" >&2
            echo "Color must be passed via --color=... (or -c ...)" >&2
            usage
            ;;
    esac
done

# Normalize TITLE
case "$TITLE" in
    1|true|yes|on|TRUE|YES|ON)   TITLE=1 ;;
    0|false|no|off|FALSE|NO|OFF) TITLE=0 ;;
    *)
        echo "Invalid --title value: '$TITLE'" >&2
        echo "Expected one of: 0,1,true,false,yes,no,on,off" >&2
        exit 2
        ;;
esac

# Validate delays for active modes
DELAY_RE='^([0-9]+(\.[0-9]+)?|\.[0-9]+)$'
if [ "$MODE" = "line" ] && ! [[ "$DELAY" =~ $DELAY_RE ]]; then
    echo "Invalid --delay value: '$DELAY'" >&2
    echo "Expected a non-negative number, e.g. 0.03 or 1" >&2
    exit 2
fi
if [ "$MODE" = "char" ] && ! [[ "$CHAR_DELAY" =~ $DELAY_RE ]]; then
    echo "Invalid --char-delay value: '$CHAR_DELAY'" >&2
    echo "Expected a non-negative number, e.g. 0.003 or 0.01" >&2
    exit 2
fi

# Resolve color (actual escape bytes, not printf-interpreted)
case "${COLOR_ARG:-red}" in
    red|31)     COLOR=$'\033[31m' ;;
    green|32)   COLOR=$'\033[32m' ;;
    yellow|33)  COLOR=$'\033[33m' ;;
    blue|34)    COLOR=$'\033[34m' ;;
    magenta|35) COLOR=$'\033[35m' ;;
    cyan|36)    COLOR=$'\033[36m' ;;
    white|37)   COLOR=$'\033[37m' ;;
    [0-9]*)     COLOR=$'\033['"$COLOR_ARG"'m' ;;
    *)
        echo "Unknown color: '$COLOR_ARG'" >&2
        usage
        ;;
esac
RESET=$'\033[0m'

# --- Artwork (always printed) ---
LINES=(
"            #%*#%"
"           %:-%#%"
"          %#*--=#%"
"         #%-==-%###"
"%%%%%%%%%%::%%-:%%%%%%%%%"
"%=:--::::::*##*::::=:--:=%"
"##%*:::*%#%#%%#%%%*=::*%#%"
"   ##%=::*#%%%%#%::=%##%"
"     ##*-*##%%##%-=##%             %###################%"
"       ::%%*::=%#=-%#%          %###%*==::==*%**=====*%%##%"
"     #*-==::**=::=-=#%        %##%*:-:==*=:---::=====:-:=%#%"
"    #%:-:=%####%*:--*#%%#######%%=:-:=*%*::::=*%%#####%%=--=%"
"    #*=*%##    ##%%=*##%%**==::---::---:=*%###%%%%%%%%##*:-=#%"
"      ##         ###%*:::::==***%%%*==%%###%%%%%%%%%%%%%#%--*#%"
"                #%*:-:=*%%%############%%%%%%%%%%%%%%%%%%#=-:%"
"               #*:-:*%###%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#%:-*#%"
"              #*--*%#%%*=:::====%#%%%%%%%%%%%%%%%%%%%%%%%%#:-=#%"
"             #%--*#%%%=-=*%%###%%%%%%%%%%%%%%%%%%%%%%%%%%%#=-=#%"
"             #=-:%%%%%%%##%%*=*%#%%%%%%%%%%%%%%%%%%%%%%%%%#*-=#%"
"             #:-*#%%%%###%:-::=*%%%%%%%%%%%%%%%%%%%%%%%%%%#=-=#%"
"            #%--*#%%%%%%#=-*%::::%%%%%#%%%###%%%%%%%%%%%%%%:-=#%"
"            #%--%#%%%%%%#%=%%:--=%%%%%%%##%=*#%%%%%%%%%%##*-:%#%"
"            #%--%#%%%%%%%#%****%#%%%#%::==::%#%%%%%%####%=--*#%"
"            #%--%#%%%%%%%%######%%%%%%%%=-*##%%%##%%%%*=:-=%#%"
"            #%-:%#%%%%%%%%%%%%%%%%%%%%##::%#%%%%*=::::::=%##%"
"            #%-:%#%%%%%%%%%%%%%%%%%%%%#*-*#%%%#=-:*%%%%###%"
"            #%-:%#%%%%%%%%%%%%%######%=-=%%%%%%=:*####%"
"            #%-:%#%%%%%%%%%%##%%%***=:-*###%"
"            #%-:%#%%%%%%%%%#%=::::::--:::==:=#%"
"            #%-:%#%%%%%%%%#*:-=%%%%%%%%%*=::=#%"
"            #%-:%#%%%%%%%#%--*###%%%#######%"
"            #%-:%#%%%%%%%#=-:#%"
"            #%--%#%%%%%%%%:-=#%"
"            #%--%#%%%%%%%%:-*#%"
"            #%--%#%%%%%%#%--%#%"
"            #%--%#%%%%%%#*-:%%"
"            #%--%#%%%%%%#=-:%%"
"            #%--%#%%%%%%#:-=#%"
"            #%--%#%%%%%%%:-*#%"
"            #%--*#######%--*#%"
"             #%:-:*%%%%%*:-:%"
"             #%*=:::::::=*%#%"
"               ##%%%%%%%##%"
"                  #####"
)

# --- Title block (controlled by --title) ---
TITLE_LINES=(
"                            %%%%%%%%%%%%%%%%%#%%%%%#%%%%%%##%%%%%%%%%%%%%%"
"                           %#*-:%%#%--%#=-=##%=-:%%%*-----*%#%--------*#%%%%"
"                           %#*.:###%.-%#:.=%*--=%%%-.=***:.=#%.-****-.*#%%%%"
"                           %#*.-====.-%#=.::-=%%#%%-.*###%%%#%.-%###-.*#%%%%"
"                           %#*.-----.-%#=.--:*##%%%-.*#%%####%.-%#%%-.*#%%%%"
"                           %#*.:###%.-%#=.=*:-:%#%%-.*#%#=:*#%.-%#%%-.*#%%%%"
"                           %#*.-%%#%..%#:.=##=:-:%%*:-----:*#%.-%#%%-.*#%%%%"
"                           %#%**%%%%**%#*=%#%#%=*%%#%*===*##%%**%%%%**%%%%%%"
"                            %###%%%%##%%###%%%###%%%######%%%%##%%%%###%%%%"
"                             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
)

print_line() {
    local line="$1"
    case "$MODE" in
        char)
            printf '%s' "$COLOR"
            local i=0 len=${#line}
            while [ "$i" -lt "$len" ]; do
                printf '%s' "${line:$i:1}"
                sleep "$CHAR_DELAY"
                i=$((i + 1))
            done
            printf '%s\n' "$RESET"
            ;;
        line)
            printf '%s%s%s\n' "$COLOR" "$line" "$RESET"
            sleep "$DELAY"
            ;;
        *)
            printf '%s%s%s\n' "$COLOR" "$line" "$RESET"
            ;;
    esac
}

for line in "${LINES[@]}"; do
    print_line "$line"
done

if [ "$TITLE" -eq 1 ]; then
    for line in "${TITLE_LINES[@]}"; do
        print_line "$line"
    done
fi
