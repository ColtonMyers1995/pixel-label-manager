#!/bin/bash
# Pixel Toolkit (extrasprite added)

THEME_DIR="/roms/themes/es-theme-PIXEL-OS"
GITHUB_URL="https://github.com/ColtonMyers1995/es-theme-PIXEL-OS.git"

if [ "$(id -u)" -ne 0 ]; then
    exec sudo -- "$0" "$@"
fi
set -euo pipefail

CURR_TTY="/dev/tty1"
printf "\033c" > "$CURR_TTY"

# controller
if command -v /opt/inttools/gptokeyb &> /dev/null; then
    [[ -e /dev/uinput ]] && chmod 666 /dev/uinput 2>/dev/null || true
    export SDL_GAMECONTROLLERCONFIG_FILE="/opt/inttools/gamecontrollerdb.txt"
    pkill -f "gptokeyb -1 PixelToolkit_extrasprite.sh" 2>/dev/null || true
    /opt/inttools/gptokeyb -1 "PixelToolkit_extrasprite.sh" -c "/opt/inttools/keys.gptk" >/dev/null 2>&1 &
fi

safe_msgbox() {
    dialog --msgbox "$1" 7 60 > "$CURR_TTY"
}

post_message() {
    safe_msgbox "Saved!\n\nA Custom Collection that uses this image's name will automatically assign the image!"
}

keyboard() {
    TEXT=""
    while true; do
        DISPLAY="${TEXT:-_}"
        CHOICE=$(dialog --output-fd 1 --menu "$DISPLAY" 20 60 10 \
        A A B B C C D D E E F F G G \
        H H I I J J K K L L M M N N \
        O O P P Q Q R R S S T T U U \
        V V W W X X Y Y Z Z \
        SPACE "Space" DEL "Backspace" OK "Done" \
        2>"$CURR_TTY") || return

        case "$CHOICE" in
            OK) echo "$TEXT"; return ;;
            SPACE) TEXT="$TEXT " ;;
            DEL) TEXT="${TEXT%?}" ;;
            *) TEXT="$TEXT$CHOICE" ;;
        esac
    done
}

# UPDATED: added extrasprite option
select_icon_source() {
    SRC=$(dialog --output-fd 1 --menu "Select Source" 18 60 4 \
        1 "Icons (art2)" \
        2 "Extra (art2/extra)" \
        3 "Systems (art3)" \
        4 "ExtraSprite (assets/extrasprite)" \
        2>"$CURR_TTY") || return 1

    case $SRC in
        1) echo "$THEME_DIR/art2" ;;
        2) echo "$THEME_DIR/art2/extra" ;;
        3) echo "$THEME_DIR/art3" ;;
        4) echo "$THEME_DIR/assets/extrasprite" ;;
    esac
}

pick_icon() {
    ICON_DIR="$1"
    FILES=(); MENU=(); i=0
    for f in "$ICON_DIR"/*.png; do
        [ -e "$f" ] || continue
        FILES[$i]="$f"
        MENU+=("$i" "$(basename "$f")")
        i=$((i+1))
    done

    IDX=$(dialog --output-fd 1 --menu "Select PNG" 20 60 12 "${MENU[@]}" 2>"$CURR_TTY") || return 1
    echo "${FILES[$IDX]}"
}

select_size() {
    S=$(dialog --output-fd 1 --menu "Size" 12 40 3 \
        1 "Small" \
        2 "Medium" \
        3 "Big" \
        2>"$CURR_TTY") || return 1

    case $S in
        1) echo 48 ;;
        2) echo 64 ;;
        3) echo 80 ;;
    esac
}

select_text_size() {
    S=$(dialog --output-fd 1 --menu "Text Size" 12 40 3 \
        1 "Small" \
        2 "Medium" \
        3 "Big" \
        2>"$CURR_TTY") || return 1

    case $S in
        1) echo 24 ;;
        2) echo 28 ;;
        3) echo 34 ;;
    esac
}

select_font() {
    F=$(dialog --output-fd 1 --menu "Font" 20 50 8 \
        1 "default (miss)" \
        2 "soft" \
        3 "old" \
        4 "small" \
        5 "bold" \
        6 "fancy" \
        7 "gothic" \
        8 "sharp" \
        2>"$CURR_TTY") || return 1

    case $F in
        1) echo "$THEME_DIR/assets/miss.ttf" ;;
        2) echo "$THEME_DIR/assets/Soft.ttf" ;;
        3) echo "$THEME_DIR/assets/Old.ttf" ;;
        4) echo "$THEME_DIR/assets/Small.ttf" ;;
        5) echo "$THEME_DIR/assets/Bold.ttf" ;;
        6) echo "$THEME_DIR/assets/Fancy.ttf" ;;
        7) echo "$THEME_DIR/assets/Gothic.ttf" ;;
        8) echo "$THEME_DIR/assets/Sharp.ttf" ;;
    esac
}

select_color() {
    C=$(dialog --output-fd 1 --menu "Text Color" 20 50 10 \
        1 "Red" \
        2 "Green" \
        3 "Blue" \
        4 "Yellow" \
        5 "Orange" \
        6 "Magenta" \
        7 "Pink" \
        8 "White" \
        9 "Medium Grey" \
        10 "Brown" \
        2>"$CURR_TTY") || return 1

    case $C in
        1) echo "#FF0000" ;;
        2) echo "#00FF00" ;;
        3) echo "#0000FF" ;;
        4) echo "#FFFF00" ;;
        5) echo "#FFA500" ;;
        6) echo "#FF00FF" ;;
        7) echo "#FF69B4" ;;
        8) echo "#FFFFFF" ;;
        9) echo "#888888" ;;
        10) echo "#8B4513" ;;
    esac
}

LogoMaker() {
    TMP="/tmp/pixel"; mkdir -p "$TMP"

    DIR=$(select_icon_source) || return
    ICON=$(pick_icon "$DIR") || return
    NAME=$(keyboard) || return

    SIZE=$(select_size) || return
    TEXTSIZE=$(select_text_size) || return
    FONT=$(select_font) || return
    COLOR=$(select_color) || return

    convert "$ICON" -filter point -resize ${SIZE}x${SIZE} "$TMP/l.png"
    convert "$ICON" -filter point -resize ${SIZE}x${SIZE} -flop "$TMP/r.png"

    convert -background none -font "$FONT" \
        -stroke black -strokewidth 1 \
        -fill "$COLOR" \
        -pointsize $TEXTSIZE label:"$(echo $NAME | tr a-z A-Z)" "$TMP/t.png"

    convert "$TMP/t.png" -gravity center -background none -extent x${SIZE} "$TMP/t.png"
    convert "$TMP/t.png" -bordercolor none -border 6x0 "$TMP/t.png"

    convert "$TMP/l.png" "$TMP/t.png" "$TMP/r.png" +append "$TMP/f.png"
    convert "$TMP/f.png" "$THEME_DIR/art/${NAME}.png"

    safe_msgbox "Saved as logo!"
    post_message
}

IconMaker() {
    DIR=$(select_icon_source) || return
    ICON=$(pick_icon "$DIR") || return
    NAME=$(keyboard) || return
    SIZE=$(select_size) || return

    convert "$ICON" -resize ${SIZE}x${SIZE} "$THEME_DIR/art2/${NAME}.png"
    safe_msgbox "Saved as icon!"
    post_message
}

SystemMaker() {
    DIR=$(select_icon_source) || return
    ICON=$(pick_icon "$DIR") || return
    NAME=$(keyboard) || return
    SIZE=$(select_size) || return

    convert "$ICON" -resize ${SIZE}x${SIZE} "$THEME_DIR/art3/${NAME}.png"
    safe_msgbox "Saved as system!"
    post_message
}

ResetArt() {
    dialog --yesno "Are you sure?" 7 40 || return
    dialog --yesno "Are you VERY sure?" 7 40 || return
    rm -rf "$THEME_DIR"
    git clone "$GITHUB_URL" "$THEME_DIR"
    safe_msgbox "Theme reset complete!"
}

RestartES() {
    systemctl restart emulationstation
}

while true; do
    CH=$(dialog --output-fd 1 --menu "Pixel Toolkit" 15 50 6 \
        1 "Logo Maker" \
        2 "Icon Maker" \
        3 "System Maker" \
        4 "Reset All Art - CAUTION" \
        5 "Restart EmulationStation" \
        6 "Exit" \
        2>"$CURR_TTY") || exit

    case $CH in
        1) LogoMaker ;;
        2) IconMaker ;;
        3) SystemMaker ;;
        4) ResetArt ;;
        5) RestartES ;;
        6) exit ;;
    esac
done
