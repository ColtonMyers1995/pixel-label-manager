#!/bin/bash
# Pixel Toolkit FINAL

THEME_DIR="/roms/themes/es-theme-PIXEL-OS"
GITHUB_URL="https://github.com/ColtonMyers1995/es-theme-PIXEL-OS.git"

if [ "$(id -u)" -ne 0 ]; then
    exec sudo -- "$0" "$@"
fi
set -uo pipefail

CURR_TTY="/dev/tty1"
printf "\033c" > "$CURR_TTY"

if command -v /opt/inttools/gptokeyb &> /dev/null; then
    [[ -e /dev/uinput ]] && chmod 666 /dev/uinput 2>/dev/null || true
    export SDL_GAMECONTROLLERCONFIG_FILE="/opt/inttools/gamecontrollerdb.txt"
    pkill -f "gptokeyb -1 PixelToolkit.sh" 2>/dev/null || true
    /opt/inttools/gptokeyb -1 "PixelToolkit.sh" -c "/opt/inttools/keys.gptk" >/dev/null 2>&1 &
fi

safe_msgbox(){ dialog --msgbox "$1" 7 60 > "$CURR_TTY"; }

post_message(){
safe_msgbox "Saved!

A Custom Collection that uses this image's name will automatically assign the image!"
}


HowToUse(){
safe_msgbox "All visible pictures in the system-list are called 'labels'. PIXEL OS uses 3 system-list view-types (icons, logos and images). 

This tool allows you to create a label for any of the 3 view-types and saves them to the proper theme 'art' folder.

After making a label for the view-type you prefer (icon, logo or image), create a custom collection using 'Game Collection Settings' in the ES menu. Match the name of the new custom collection to the name of the label you made. Your label will apply to your new custom collection based on view-type. To see created icon labels, set to 'Console Icons'; created logo labels, set to 'Console Logos'; created image labels, set to 'Console Images'; in 'UI Settings / Theme Configuration' in ES menu.

-Individual custom collections may need to be enabled (Game Collection Settings)
-'Group Unthemed Custom Collections' may need to be disabled (Game Collection Settings)
-ES may need to be restarted for a label to apply to a custom collection"
}


# ---------------- UPDATE (TOOL + THEME) ----------------
UpdateToolkit(){
dialog --yesno "Update Toolkit + Theme from GitHub?\nRequires internet connection." 8 60 || return

# Check internet first
ping -c 1 github.com >/dev/null 2>&1 || {
    safe_msgbox "No internet connection. Update cancelled."
    return
}

TMP="/tmp/pixel_update"
rm -rf "$TMP"
mkdir -p "$TMP"

TOOL_GIT_URL="https://github.com/ColtonMyers1995/pixel-label-manager.git"
TOOL_PATH="/roms/tools/Custom-Collection Label-Maker.sh"

# Clone tool repo
git clone "$TOOL_GIT_URL" "$TMP/tool" || {
    safe_msgbox "Tool update failed"
    return
}

# Clone theme repo
git clone "$GITHUB_URL" "$TMP/theme" || {
    safe_msgbox "Theme update failed"
    return
}

# ---- TOOL UPDATE (FULL REPLACE) ----
if [ -f "$TMP/tool/Custom-Collection Label-Maker.sh" ]; then
    rm -f "$TOOL_PATH"
    cp "$TMP/tool/Custom-Collection Label-Maker.sh" "$TOOL_PATH"
    chmod +x "$TOOL_PATH"
fi

# ---- THEME UPDATE (MERGE / PRESERVE USER FILES) ----
cp -rn "$TMP/theme/"* "$THEME_DIR/"
cp -r "$TMP/theme/art2/"* "$THEME_DIR/art2/" 2>/dev/null || true
cp -r "$TMP/theme/art3/"* "$THEME_DIR/art3/" 2>/dev/null || true
cp -r "$TMP/theme/assets/"* "$THEME_DIR/assets/" 2>/dev/null || true

safe_msgbox "Update complete! Restart tool to apply."
}


# ---- CORRECT OUTLINE (EDGE ONLY, NO BOX) ----
apply_outline(){
SRC="$1"
DST="$2"

convert "$SRC" \
  \( +clone -alpha extract -morphology Dilate Disk:1 \) \
  \( +clone -alpha extract \) \
  -compose minus -composite \
  -alpha copy -fill black -colorize 100 \
  \( "$SRC" \) -compose over -composite PNG32:"$DST"
}

keyboard(){
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

select_layout(){
dialog --output-fd 1 --menu "Label Layout" 15 60 3 \
1 "Icon + Text + Mirrored Icon" \
2 "Icon + Text (Centered)" \
3 "Icon + Text + Second Icon" \
2>"$CURR_TTY"
}

select_icon_source(){
SRC=$(dialog --output-fd 1 --menu "Select Source" 18 60 4 \
1 "Icons (art2)" \
2 "Tiny Pkmn (art2/extra)" \
3 "Images (art3)" \
4 "Sprites (assets/extrasprite)" \
2>"$CURR_TTY") || return 1
case $SRC in
1) echo "$THEME_DIR/art2" ;;
2) echo "$THEME_DIR/art2/extra" ;;
3) echo "$THEME_DIR/art3" ;;
4) echo "$THEME_DIR/assets/extrasprite" ;;
esac
}

pick_icon(){
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

select_size(){
S=$(dialog --output-fd 1 --menu "Image Size" 12 40 3 \
1 "Small" 2 "Medium" 3 "Big" \
2>"$CURR_TTY") || return 1
case $S in
1) echo 14 ;;
2) echo 36 ;;
3) echo 64 ;;
esac
}

select_text_size(){
S=$(dialog --output-fd 1 --menu "Text Size" 12 40 3 \
1 "Small" 2 "Medium" 3 "Big" \
2>"$CURR_TTY") || return 1
case $S in
1) echo 14 ;;
2) echo 36 ;;
3) echo 64 ;;
esac
}

select_spacing(){
S=$(dialog --output-fd 1 --menu "Icon/Text Spacing" 12 40 3 \
1 "Close" 2 "Normal" 3 "Far" \
2>"$CURR_TTY") || return 1
case $S in
1) echo 0 ;;
2) echo 20 ;;
3) echo 40 ;;
esac
}

select_font(){
F=$(dialog --output-fd 1 --menu "Font" 30 70 21 \
1 "Theme" 2 "Soft" 3 "Old" 4 "Small" 5 "Bold" 6 "Fancy" 7 "Gothic" 8 "Sharp" \
9 "1989" 10 "Stencil" 11 "Scribbles" 12 "Retro" 13 "Jagged" 14 "Evil" \
15 "Ancient" 16 "Fun" 17 "Simple" 18 "Bubble" 19 "Castle" 20 "Big" 21 "Cute+Thick" \
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
9) echo "$THEME_DIR/assets/1989.ttf" ;;
10) echo "$THEME_DIR/assets/stencil.ttf" ;;
11) echo "$THEME_DIR/assets/scribbles.ttf" ;;
12) echo "$THEME_DIR/assets/retro.ttf" ;;
13) echo "$THEME_DIR/assets/jagged.ttf" ;;
14) echo "$THEME_DIR/assets/evil.ttf" ;;
15) echo "$THEME_DIR/assets/ancent.ttf" ;;
16) echo "$THEME_DIR/assets/fun.ttf" ;;
17) echo "$THEME_DIR/assets/simple.ttf" ;;
18) echo "$THEME_DIR/assets/bubble.ttf" ;;
19) echo "$THEME_DIR/assets/castle.ttf" ;;
20) echo "$THEME_DIR/assets/big.TTF" ;;
21) echo "$THEME_DIR/assets/thick.ttf" ;;
esac
}

select_color(){
C=$(dialog --output-fd 1 --menu "Text Color" 25 60 15 \
1 "Red" 2 "Green" 3 "Blue" 4 "Yellow" 5 "Orange" \
6 "Magenta" 7 "Pink" 8 "White" 9 "Medium Grey" 10 "Brown" \
11 "Black" 12 "Cyan" 13 "Lime" 14 "Purple" 15 "Gold" \
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
11) echo "#000000" ;;
12) echo "#00FFFF" ;;
13) echo "#32CD32" ;;
14) echo "#800080" ;;
15) echo "#FFD700" ;;
esac
}

select_padding(){
P=$(dialog --output-fd 1 --menu "Horizontal Padding" 12 40 3 \
1 "More Padding" 2 "Normal" 3 "Less Padding" \
2>"$CURR_TTY") || return 1
case $P in
1) echo 30 ;;
2) echo 12 ;;
3) echo 1 ;;
esac
}

select_vpadding(){
P=$(dialog --output-fd 1 --menu "Vertical Padding" 12 40 3 \
1 "More Padding" 2 "Normal" 3 "Less Padding" \
2>"$CURR_TTY") || return 1
case $P in
1) echo 25 ;;
2) echo 10 ;;
3) echo 1 ;;
esac
}

LogoMaker(){
TMP="/tmp/pixel"; mkdir -p "$TMP"

LAYOUT=$(select_layout) || return
DIR=$(select_icon_source) || return
ICON=$(pick_icon "$DIR") || return

if [ "$LAYOUT" = "3" ]; then
DIR2=$(select_icon_source) || return
ICON2=$(pick_icon "$DIR2") || return
fi

NAME=$(keyboard) || return

SIZE=$(select_size) || return
TEXTSIZE=$(select_text_size) || return
SPACING=$(select_spacing) || return
FONT=$(select_font) || return
COLOR=$(select_color) || return
PAD=$(select_padding) || return
VPAD=$(select_vpadding) || return

convert "$ICON" -background none -resize x${SIZE} PNG32:"$TMP/l_raw.png"
apply_outline "$TMP/l_raw.png" "$TMP/l.png"

if [ "$LAYOUT" = "1" ]; then
convert "$ICON" -background none -resize x${SIZE} -flop PNG32:"$TMP/r_raw.png"
apply_outline "$TMP/r_raw.png" "$TMP/r.png"
elif [ "$LAYOUT" = "3" ]; then
convert "$ICON2" -background none -resize x${SIZE} PNG32:"$TMP/r_raw.png"
apply_outline "$TMP/r_raw.png" "$TMP/r.png"
fi

convert -background none -stroke black -strokewidth 2 -fill "$COLOR" -font "$FONT" \
-pointsize $TEXTSIZE label:"$(echo $NAME | tr a-z A-Z)" PNG32:"$TMP/t.png"

if [ "$SPACING" -gt 0 ]; then
convert "$TMP/t.png" -background none -gravity center -bordercolor none -border ${SPACING}x0 PNG32:"$TMP/t.png"
fi

if [ "$LAYOUT" = "2" ]; then
convert -background none -gravity center "$TMP/l.png" "$TMP/t.png" +append PNG32:"$TMP/f.png"
else
convert -background none -gravity center "$TMP/l.png" "$TMP/t.png" "$TMP/r.png" +append PNG32:"$TMP/f.png"
fi

convert "$TMP/f.png" -background none -gravity center \
-bordercolor none -border ${PAD}x${VPAD} PNG32:"$THEME_DIR/art/${NAME}.png"

safe_msgbox "Saved as logo!"
post_message
}

IconMaker(){
DIR=$(select_icon_source) || return
ICON=$(pick_icon "$DIR") || return
NAME=$(keyboard) || return
SIZE=$(select_size) || return
PAD=$(select_padding) || return
VPAD=$(select_vpadding) || return

TMP="/tmp/pixel"; mkdir -p "$TMP"
convert "$ICON" -background none -resize ${SIZE}x${SIZE} PNG32:"$TMP/icon_raw.png"
apply_outline "$TMP/icon_raw.png" "$TMP/icon.png"

convert "$TMP/icon.png" -background none -gravity center \
-bordercolor none -border ${PAD}x${VPAD} PNG32:"$THEME_DIR/art2/${NAME}.png"

safe_msgbox "Saved as icon!"
post_message
}

SystemMaker(){
DIR=$(select_icon_source) || return
ICON=$(pick_icon "$DIR") || return
NAME=$(keyboard) || return
SIZE=$(select_size) || return
PAD=$(select_padding) || return
VPAD=$(select_vpadding) || return

TMP="/tmp/pixel"; mkdir -p "$TMP"
convert "$ICON" -background none -resize ${SIZE}x${SIZE} PNG32:"$TMP/system_raw.png"
apply_outline "$TMP/system_raw.png" "$TMP/system.png"

convert "$TMP/system.png" -background none -gravity center \
-bordercolor none -border ${PAD}x${VPAD} PNG32:"$THEME_DIR/art3/${NAME}.png"

safe_msgbox "Saved as image!"
post_message
}

ResetArt(){
dialog --yesno "Are you sure?\nRequires internet connection." 7 40 || return
dialog --yesno "Are you SURE?\n(Delete all created labels)." 7 40 || return

# Check internet before destructive reset
ping -c 1 github.com >/dev/null 2>&1 || {
    safe_msgbox "No internet connection. Reset cancelled."
    return
}

rm -rf "$THEME_DIR"

git clone "$GITHUB_URL" "$THEME_DIR" || {
    safe_msgbox "Reset failed. Theme not restored."
    return
}

safe_msgbox "Theme reset complete!"
}

RestartES(){ systemctl restart emulationstation; }

while true; do
CH=$(dialog --output-fd 1 --menu "Pixel Toolkit" 17 60 3 \
1 "Makers" \
2 "Settings" \
3 "Exit" \
2>"$CURR_TTY") || continue

case $CH in

1)
SUB=$(dialog --output-fd 1 --menu "Makers" 15 60 3 \
1 "Logo Maker" \
2 "Icon Maker" \
3 "Image Maker" \
2>"$CURR_TTY") || continue

case $SUB in
1) LogoMaker ;;
2) IconMaker ;;
3) SystemMaker ;;
esac
;;

2)
SUB=$(dialog --output-fd 1 --menu "Settings" 17 60 4 \
1 "Update Toolkit + Theme" \
2 "Reset All Art - CAUTION" \
3 "Restart EmulationStation" \
4 "How To Use" \
2>"$CURR_TTY") || continue

case $SUB in
1) UpdateToolkit ;;
2) ResetArt ;;
3) RestartES ;;
4) HowToUse ;;
esac
;;

3) exit ;;

esac
done
