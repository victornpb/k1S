#!/bin/bash

# Initial values for webcam controls
BRIGHTNESS=-10
CONTRAST=50
SATURATION=128
HUE=0
GAMMA=180
GAIN=0
WHITE_BALANCE_TEMP_AUTO=1
POWER_LINE_FREQ=2
WHITE_BALANCE_TEMP=4600
SHARPNESS=3
BACKLIGHT_COMP=2
EXPOSURE_AUTO=1
EXPOSURE_ABSOLUTE=245
EXPOSURE_AUTO_PRIORITY=1

# Initialize selected control
selected=1

# Function to set control value using v4l2-ctl
set_control() {
    local control_name="$1"
    local control_value="$2"
    v4l2-ctl -d /dev/video4 --set-ctrl "$control_name=$control_value"
}

while true; do
    clear
echo "Webcam Controls:"
echo "-----------------"
echo "$([ $selected -eq  1 ] && echo "=>" || echo "  ") Brightness ...................... $BRIGHTNESS    (-64 to 64)"
echo "$([ $selected -eq  2 ] && echo "=>" || echo "  ") Contrast ........................ $CONTRAST    (0 to 64)"
echo "$([ $selected -eq  3 ] && echo "=>" || echo "  ") Saturation ...................... $SATURATION    (0 to 128)"
echo "$([ $selected -eq  4 ] && echo "=>" || echo "  ") Hue ............................. $HUE    (-40 to 40)"
echo "$([ $selected -eq  5 ] && echo "=>" || echo "  ") Gamma ........................... $GAMMA    (72 to 500)"
echo "$([ $selected -eq  6 ] && echo "=>" || echo "  ") Gain ............................ $GAIN    (0 to 100)"
echo "$([ $selected -eq  7 ] && echo "=>" || echo "  ") White Balance Temperature Auto .. $WHITE_BALANCE_TEMP_AUTO    (On/Off)"
echo "$([ $selected -eq  8 ] && echo "=>" || echo "  ") Power Line Frequency ............ $POWER_LINE_FREQ    (0 to 2)"
echo "$([ $selected -eq  9 ] && echo "=>" || echo "  ") White Balance Temperature ....... $WHITE_BALANCE_TEMP    (2800 to 6500)"
echo "$([ $selected -eq 10 ] && echo "=>" || echo "  ") Sharpness ....................... $SHARPNESS    (0 to 6)"
echo "$([ $selected -eq 11 ] && echo "=>" || echo "  ") Backlight Compensation .......... $BACKLIGHT_COMP    (0 to 2)"
echo "$([ $selected -eq 12 ] && echo "=>" || echo "  ") Exposure Auto ................... $EXPOSURE_AUTO    (1=Manual or 3=Auto)"
echo "$([ $selected -eq 13 ] && echo "=>" || echo "  ") Exposure Absolute ............... $EXPOSURE_ABSOLUTE    (1 to 5000)"
echo "$([ $selected -eq 14 ] && echo "=>" || echo "  ") Exposure Auto Priority ......... $EXPOSURE_AUTO_PRIORITY    "
echo "-----------------"
echo "W/S: Select a control"
echo "A: Value +  D: Value -"
echo "Q: Quit"
echo "-----------------"



    read -n 1 -s input

    case "$input" in
        "w")
            # Select previous control
            selected=$((selected - 1))
            if [ $selected -lt 1 ]; then
                selected=14
            fi
            ;;
        "s")
            # Select previous control
            selected=$((selected + 1))
            if [ $selected -gt 14 ]; then
                selected=1
            fi
            ;;
        "d")
            # Increase control value
            case "$selected" in
                1) BRIGHTNESS=$((BRIGHTNESS + 5)); set_control "brightness" "$BRIGHTNESS";;
                2) CONTRAST=$((CONTRAST + 5)); set_control "contrast" "$CONTRAST";;
                3) SATURATION=$((SATURATION + 5)); set_control "saturation" "$SATURATION";;
                4) HUE=$((HUE + 1)); set_control "hue" "$HUE";;
                5) GAMMA=$((GAMMA + 10)); set_control "gamma" "$GAMMA";;
                6) GAIN=$((GAIN + 1)); set_control "gain" "$GAIN";;
                7) WHITE_BALANCE_TEMP_AUTO=$((1 - WHITE_BALANCE_TEMP_AUTO)); set_control "white_balance_temperature_auto" "$WHITE_BALANCE_TEMP_AUTO";;
                8) POWER_LINE_FREQ=$((POWER_LINE_FREQ + 1)); set_control "power_line_frequency" "$POWER_LINE_FREQ";;
                9) WHITE_BALANCE_TEMP=$((WHITE_BALANCE_TEMP + 50)); set_control "white_balance_temperature" "$WHITE_BALANCE_TEMP";;
                10) SHARPNESS=$((SHARPNESS + 1)); set_control "sharpness" "$SHARPNESS";;
                11) BACKLIGHT_COMP=$((BACKLIGHT_COMP + 1)); set_control "backlight_compensation" "$BACKLIGHT_COMP";;
                12) EXPOSURE_AUTO=$((EXPOSURE_AUTO + 1)); set_control "exposure_auto" "$EXPOSURE_AUTO";;
                13) EXPOSURE_ABSOLUTE=$((EXPOSURE_ABSOLUTE + 10)); set_control "exposure_absolute" "$EXPOSURE_ABSOLUTE";;
                14) EXPOSURE_AUTO_PRIORITY=$((1 - EXPOSURE_AUTO_PRIORITY)); set_control "exposure_auto_priority" "$EXPOSURE_AUTO_PRIORITY";;
            esac
            ;;
        "a")
            # Decrease control value
            case "$selected" in
                1) BRIGHTNESS=$((BRIGHTNESS - 5)); set_control "brightness" "$BRIGHTNESS";;
                2) CONTRAST=$((CONTRAST - 5)); set_control "contrast" "$CONTRAST";;
                3) SATURATION=$((SATURATION - 5)); set_control "saturation" "$SATURATION";;
                4) HUE=$((HUE - 1)); set_control "hue" "$HUE";;
                5) GAMMA=$((GAMMA - 10)); set_control "gamma" "$GAMMA";;
                6) GAIN=$((GAIN - 1)); set_control "gain" "$GAIN";;
                7) WHITE_BALANCE_TEMP_AUTO=$((50 - WHITE_BALANCE_TEMP_AUTO)); set_control "white_balance_temperature_auto" "$WHITE_BALANCE_TEMP_AUTO";;
                8) POWER_LINE_FREQ=$((POWER_LINE_FREQ - 1)); set_control "power_line_frequency" "$POWER_LINE_FREQ";;
                9) WHITE_BALANCE_TEMP=$((WHITE_BALANCE_TEMP - 1)); set_control "white_balance_temperature" "$WHITE_BALANCE_TEMP";;
                10) SHARPNESS=$((SHARPNESS - 1)); set_control "sharpness" "$SHARPNESS";;
                11) BACKLIGHT_COMP=$((BACKLIGHT_COMP - 1)); set_control "backlight_compensation" "$BACKLIGHT_COMP";;
                12) EXPOSURE_AUTO=$((EXPOSURE_AUTO - 1)); set_control "exposure_auto" "$EXPOSURE_AUTO";;
                13) EXPOSURE_ABSOLUTE=$((EXPOSURE_ABSOLUTE - 10)); set_control "exposure_absolute" "$EXPOSURE_ABSOLUTE";;
                14) EXPOSURE_AUTO_PRIORITY=$((1 - EXPOSURE_AUTO_PRIORITY)); set_control "exposure_auto_priority" "$EXPOSURE_AUTO_PRIORITY";;
            esac
            ;;
        "q")
            break
            ;;
    esac
done
