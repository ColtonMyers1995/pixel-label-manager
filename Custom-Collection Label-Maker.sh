#!/bin/bash
# Pixel Label Manager (FINAL - RELIABLE PREVIEW + ORANGE + OUTLINE)

if [ "$(id -u)" -ne 0 ]; then
    exec sudo -- "$0" "$@"
fi
set -euo pipefail

CURR_TTY="/dev/tty1"

export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export TERM=linux
unset FBTERM

printf "\033c" > "$CURR_TTY"

safe_msgbox() {
    dialog --msgbox "${1:-Done.}" 6 50 > "$CURR_TTY" || true
}

# controller
if command -v /opt/inttools/gptokeyb &> /dev/null; then
    [[ -e /dev/uinput ]] && chmod 666 /dev/uinput 2>/dev/null || true
    export SDL_GAMECONTROLLERCONFIG_FILE="/opt/inttools/gamecontrollerdb.txt"
    pkill -f "gptokeyb -1 PixelLabelManager.sh" 2>/dev/null || true
    /opt/inttools/gptokeyb -1 "PixelLabelManager.sh" -c "/opt/inttools/keys.gptk" >/dev/null 2>&1 &
fi

keyboard() {
    TEXT=""
    while true; do
        DISPLAY="${TEXT:-_}"
        CHOICE=$(dialog --output-fd 1 --title "Enter Name"         --menu "$DISPLAY" 20 60 10         A A B B C C D D E E F F G G         H H I I J J K K L L M M N N         O O P P Q Q R R S S T T U U         V V W W X X Y Y Z Z         SPACE "Space" DEL "Backspace" OK "Done"         2>"$CURR_TTY") || return

        case "$CHOICE" in
            OK) echo "$TEXT"; return ;;
            SPACE) TEXT="$TEXT " ;;
            DEL) TEXT="${TEXT%?}" ;;
            *) TEXT="$TEXT$CHOICE" ;;
        esac
    done
}

CreateLabel() {

    THEME_DIR="/roms/themes/es-theme-PIXEL-OS"
    ART2_DIR="$THEME_DIR/art2"
    ASSETS_DIR="$THEME_DIR/assets"
    TMP_DIR="/tmp/pixel_label"
    mkdir -p "$TMP_DIR"

    SRC=$(dialog --output-fd 1 --menu "Select Icon Source" 15 50 2         1 "Icons (art2)"         2 "Extra (art2/extra)"         2>"$CURR_TTY") || return

    case $SRC in
        1) ICON_DIR="$ART2_DIR" ;;
        2) ICON_DIR="$ART2_DIR/extra" ;;
    esac

    FILES=(); MENU_OPTS=(); i=0
    for f in "$ICON_DIR"/*.png; do
        [ -e "$f" ] || continue
        FILES[$i]="$f"
        MENU_OPTS+=("$i" "$(basename "$f")")
        i=$((i+1))
    done

    IDX=$(dialog --output-fd 1 --menu "Select icon" 20 60 12         "${MENU_OPTS[@]}" 2>"$CURR_TTY") || return

    ICON_PATH="${FILES[$IDX]}"

    NAME=$(keyboard) || return
    TEXT=$(echo "$NAME" | tr '[:lower:]' '[:upper:]')

    FONT_CHOICE=$(dialog --output-fd 1 --menu "Select Font" 15 50 8         1 "default (miss)"         2 "soft"         3 "old"         4 "small"         5 "bold"         6 "fancy"         7 "gothic"         8 "sharp"         2>"$CURR_TTY") || return

    case $FONT_CHOICE in
        1) FONT_PATH="$ASSETS_DIR/miss.ttf" ;;
        2) FONT_PATH="$ASSETS_DIR/Soft.ttf" ;;
        3) FONT_PATH="$ASSETS_DIR/Old.ttf" ;;
        4) FONT_PATH="$ASSETS_DIR/Small.ttf" ;;
        5) FONT_PATH="$ASSETS_DIR/Bold.ttf" ;;
        6) FONT_PATH="$ASSETS_DIR/Fancy.ttf" ;;
        7) FONT_PATH="$ASSETS_DIR/Gothic.ttf" ;;
        8) FONT_PATH="$ASSETS_DIR/Sharp.ttf" ;;
    esac

    COLOR_CHOICE=$(dialog --output-fd 1 --menu "Select Text Color" 15 50 10         1 "Red"         2 "Green"         3 "Blue"         4 "Yellow"         5 "Orange"         6 "Magenta"         7 "Pink"         8 "White"         9 "Medium Grey"         10 "Brown"         2>"$CURR_TTY") || return

    case $COLOR_CHOICE in
        1) TEXT_COLOR="#FF0000" ;;
        2) TEXT_COLOR="#00FF00" ;;
        3) TEXT_COLOR="#0000FF" ;;
        4) TEXT_COLOR="#FFFF00" ;;
        5) TEXT_COLOR="#FFA500" ;;
        6) TEXT_COLOR="#FF00FF" ;;
        7) TEXT_COLOR="#FF69B4" ;;
        8) TEXT_COLOR="#FFFFFF" ;;
        9) TEXT_COLOR="#888888" ;;
        10) TEXT_COLOR="#8B4513" ;;
    esac

    LEFT="$TMP_DIR/l.png"
    RIGHT="$TMP_DIR/r.png"
    TEXTIMG="$TMP_DIR/t.png"
    FINAL="$TMP_DIR/f.png"

    convert "$ICON_PATH" -filter point -resize 64x64 "$LEFT"
    convert "$ICON_PATH" -filter point -resize 64x64 -flop "$RIGHT"

    convert -background none -font "$FONT_PATH"         -stroke black -strokewidth 1         -fill "$TEXT_COLOR"         -pointsize 28 label:"$TEXT" "$TEXTIMG"

    convert "$TEXTIMG" -gravity center -background none -extent x64 "$TEXTIMG"
    convert "$TEXTIMG" -bordercolor none -border 6x0 "$TEXTIMG"

    convert "$LEFT" "$TEXTIMG" "$RIGHT" +append "$FINAL"

    # RELIABLE PREVIEW
    if command -v fbi &> /dev/null; then
        clear > "$CURR_TTY"
        chvt 1 2>/dev/null || true

        fbi -T 1 -noverbose -a "$FINAL"

        dialog --msgbox "Preview shown. Press OK to continue." 8 40 > "$CURR_TTY"

        killall fbi 2>/dev/null || true
    fi

    CONFIRM=$(dialog --output-fd 1 --menu "Save this image?" 10 40 2         1 "Yes"         2 "No"         2>"$CURR_TTY") || return

    [ "$CONFIRM" != "1" ] && return

    OUT=$(dialog --output-fd 1 --menu "Select Output Type" 15 40 3         1 "Logos (art)"         2 "Icons (art2)"         3 "Images (art3)"         2>"$CURR_TTY") || return

    case $OUT in
        1) OUTFOLDER="art" ;;
        2) OUTFOLDER="art2" ;;
        3) OUTFOLDER="art3" ;;
    esac

    OUTPUT="$THEME_DIR/$OUTFOLDER/${NAME}.png"
    convert "$FINAL" "$OUTPUT"

    safe_msgbox "Saved:\n$OUTPUT"
}

while true; do
    CH=$(dialog --output-fd 1 --menu "Pixel Label Tool" 15 50 2         1 "Create Label"         2 "Exit"         2>"$CURR_TTY") || exit

    case $CH in
        1) CreateLabel ;;
        2) exit ;;
    esac
done
