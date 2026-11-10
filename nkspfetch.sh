#!/bin/bash
# nksp.sh — colored ASCII art banner with optional title block.
# Run `./nksp.sh --help` for details.

show_help() {
    cat <<'EOF'
NAME
    nkspfetch.sh - print a colored ASCII NKSP elephant art banner with optional title block.

SYNOPSIS
    nkspfetch.sh [--color=COLOR] [--title=N] [-h|--help]

DESCRIPTION
    Prints a fixed ASCII NKSP elephant. The lower "title" block can be toggled.
    Output color is configurable via the --color flag.

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

    -h, --help       Show this help and exit.

EXAMPLES
    ./nkspfetch.sh
        Print with default red color and title.

    ./nkspfetch.sh --color=green
        Print in green with title.

    ./nkspfetch.sh --color=cyan --no-title
        Print in cyan without the title block.

    ./nkspfetch.sh --color='1;33'
        Print in bold yellow.

    ./nkspfetch.sh --color='38;5;196' --title=off
        Print in 256-color red (196) without title.

EXIT CODES
    0   Success (or --help).
    2   Invalid argument, unknown color, or bad --title value.

EOF
}

usage() {
    echo "Usage: $0 [--color=COLOR] [--title=N] [-h|--help]" >&2
    echo "Try '$0 --help' for details." >&2
    exit 2
}

TITLE=1
COLOR_ARG=""

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)   show_help; exit 0 ;;
        --color=*)   COLOR_ARG="${1#*=}"; shift ;;
        -c)
            if [ $# -lt 2 ]; then
                echo "Option -c requires a value" >&2
                usage
            fi
            COLOR_ARG="$2"; shift 2 ;;
        --title)     TITLE=1; shift ;;
        --no-title)  TITLE=0; shift ;;
        --title=*)   TITLE="${1#*=}"; shift ;;
        -t)
            if [ $# -lt 2 ]; then
                echo "Option -t requires a value" >&2
                usage
            fi
            TITLE="$2"; shift 2 ;;
        --)          shift; break ;;
        -*)          echo "Unknown option: $1" >&2; usage ;;
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

# Resolve color
case "${COLOR_ARG:-red}" in
    red|31)     COLOR='\033[31m' ;;
    green|32)   COLOR='\033[32m' ;;
    yellow|33)  COLOR='\033[33m' ;;
    blue|34)    COLOR='\033[34m' ;;
    magenta|35) COLOR='\033[35m' ;;
    cyan|36)    COLOR='\033[36m' ;;
    white|37)   COLOR='\033[37m' ;;
    [0-9]*)     COLOR='\033['"$COLOR_ARG"'m' ;;
    *)
        echo "Unknown color: '$COLOR_ARG'" >&2
        usage
        ;;
esac
RESET='\033[0m'

# --- Artwork (always printed) ---
echo -e "${COLOR}            #%*#%${RESET}"
echo -e "${COLOR}           %:-%#%${RESET}"
echo -e "${COLOR}          %#*--=#%${RESET}"
echo -e "${COLOR}         #%-==-%###${RESET}"
echo -e "${COLOR}%%%%%%%%%%::%%-:%%%%%%%%%${RESET}"
echo -e "${COLOR}%=:--::::::*##*::::=:--:=%${RESET}"
echo -e "${COLOR}##%*:::*%#%#%%#%%%*=::*%#%${RESET}"
echo -e "${COLOR}   ##%=::*#%%%%#%::=%##%${RESET}"
echo -e "${COLOR}     ##*-*##%%##%-=##%             %###################%${RESET}"
echo -e "${COLOR}       ::%%*::=%#=-%#%          %###%*==::==*%**=====*%%##%${RESET}"
echo -e "${COLOR}     #*-==::**=::=-=#%        %##%*:-:==*=:---::=====:-:=%#%${RESET}"
echo -e "${COLOR}    #%:-:=%####%*:--*#%%#######%%=:-:=*%*::::=*%%#####%%=--=%${RESET}"
echo -e "${COLOR}    #*=*%##    ##%%=*##%%**==::---::---:=*%###%%%%%%%%##*:-=#%${RESET}"
echo -e "${COLOR}      ##         ###%*:::::==***%%%*==%%###%%%%%%%%%%%%%#%--*#%${RESET}"
echo -e "${COLOR}                #%*:-:=*%%%############%%%%%%%%%%%%%%%%%%#=-:%${RESET}"
echo -e "${COLOR}               #*:-:*%###%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#%:-*#%${RESET}"
echo -e "${COLOR}              #*--*%#%%*=:::====%#%%%%%%%%%%%%%%%%%%%%%%%%#:-=#%${RESET}"
echo -e "${COLOR}             #%--*#%%%=-=*%%###%%%%%%%%%%%%%%%%%%%%%%%%%%%#=-=#%${RESET}"
echo -e "${COLOR}             #=-:%%%%%%%##%%*=*%#%%%%%%%%%%%%%%%%%%%%%%%%%#*-=#%${RESET}"
echo -e "${COLOR}             #:-*#%%%%###%:-::=*%%%%%%%%%%%%%%%%%%%%%%%%%%#=-=#%${RESET}"
echo -e "${COLOR}            #%--*#%%%%%%#=-*%::::%%%%%#%%%###%%%%%%%%%%%%%%:-=#%${RESET}"
echo -e "${COLOR}            #%--%#%%%%%%#%=%%:--=%%%%%%%##%=*#%%%%%%%%%%##*-:%#%${RESET}"
echo -e "${COLOR}            #%--%#%%%%%%%#%****%#%%%#%::==::%#%%%%%%####%=--*#%${RESET}"
echo -e "${COLOR}            #%--%#%%%%%%%%######%%%%%%%%=-*##%%%##%%%%*=:-=%#%${RESET}"
echo -e "${COLOR}            #%-:%#%%%%%%%%%%%%%%%%%%%%##::%#%%%%*=::::::=%##%${RESET}"
echo -e "${COLOR}            #%-:%#%%%%%%%%%%%%%%%%%%%%#*-*#%%%#=-:*%%%%###%${RESET}"
echo -e "${COLOR}            #%-:%#%%%%%%%%%%%%%######%=-=%%%%%%=:*####%${RESET}"
echo -e "${COLOR}            #%-:%#%%%%%%%%%%##%%%***=:-*###%${RESET}"
echo -e "${COLOR}            #%-:%#%%%%%%%%%#%=::::::--:::==:=#%${RESET}"
echo -e "${COLOR}            #%-:%#%%%%%%%%#*:-=%%%%%%%%%*=::=#%${RESET}"
echo -e "${COLOR}            #%-:%#%%%%%%%#%--*###%%%#######%${RESET}"
echo -e "${COLOR}            #%-:%#%%%%%%%#=-:#%${RESET}"
echo -e "${COLOR}            #%--%#%%%%%%%%:-=#%${RESET}"
echo -e "${COLOR}            #%--%#%%%%%%%%:-*#%${RESET}"
echo -e "${COLOR}            #%--%#%%%%%%#%--%#%${RESET}"
echo -e "${COLOR}            #%--%#%%%%%%#*-:%%${RESET}"
echo -e "${COLOR}            #%--%#%%%%%%#=-:%%${RESET}"
echo -e "${COLOR}            #%--%#%%%%%%#:-=#%${RESET}"
echo -e "${COLOR}            #%--%#%%%%%%%:-*#%${RESET}"
echo -e "${COLOR}            #%--*#######%--*#%${RESET}"
echo -e "${COLOR}             #%:-:*%%%%%*:-:%${RESET}"
echo -e "${COLOR}             #%*=:::::::=*%#%${RESET}"
echo -e "${COLOR}               ##%%%%%%%##%${RESET}"
echo -e "${COLOR}                  #####${RESET}"

# --- Title block (controlled by --title) ---
if [ "$TITLE" -eq 1 ]; then
    echo -e "${COLOR}                            %%%%%%%%%%%%%%%%%#%%%%%#%%%%%%##%%%%%%%%%%%%%%${RESET}"
    echo -e "${COLOR}                           %#*-:%%#%--%#=-=##%=-:%%%*-----*%#%--------*#%%%%${RESET}"
    echo -e "${COLOR}                           %#*.:###%.-%#:.=%*--=%%%-.=***:.=#%.-****-.*#%%%%${RESET}"
    echo -e "${COLOR}                           %#*.-====.-%#=.::-=%%#%%-.*###%%%#%.-%###-.*#%%%%${RESET}"
    echo -e "${COLOR}                           %#*.-----.-%#=.--:*##%%%-.*#%%####%.-%#%%-.*#%%%%${RESET}"
    echo -e "${COLOR}                           %#*.:###%.-%#=.=*:-:%#%%-.*#%#=:*#%.-%#%%-.*#%%%%${RESET}"
    echo -e "${COLOR}                           %#*.-%%#%..%#:.=##=:-:%%*:-----:*#%.-%#%%-.*#%%%%${RESET}"
    echo -e "${COLOR}                           %#%**%%%%**%#*=%#%#%=*%%#%*===*##%%**%%%%**%%%%%%${RESET}"
    echo -e "${COLOR}                            %###%%%%##%%###%%%###%%%######%%%%##%%%%###%%%%${RESET}"
    echo -e "${COLOR}                             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%${RESET}"
fi
