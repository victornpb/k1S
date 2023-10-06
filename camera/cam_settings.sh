#!/bin/sh
VERSION=v1.1.2

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

# Function to check and update the script
update_script() {
    remote_script=$(wget --no-check-certificate -qO- https://raw.githubusercontent.com/victornpb/k1S/main/camera/cam_settings.sh)
    local_script=$(cat /usr/cam_settings.sh)  # Read the current script content
    if [ "$remote_script" != "$local_script" ]; then
        second_line=$(echo "$remote_script" | cut -d$'\n' -f 2)
        echo "A new version is available ($second_line)! Do you want to update? (Y/N)"
        read -n 1 -r response && echo
        if [[ $response =~ ^[Yy]$ ]]; then
            echo "$remote_script" > /usr/cam_settings.sh  # Overwrite the local script with the remote version
            chmod +x /usr/cam_settings.sh
            echo "The script has been updated. Do you want to run the new version? (Y/N)"
            read -n 1 -r run_response && echo
            if [[ $run_response =~ ^[Yy]$ ]]; then
                exec /usr/cam_settings.sh  # Run the new version
            else
                echo "Update completed!"
                exit
            fi
        else
            echo "Update canceled!"
            read -n 1 && echo
        fi
    else
        echo "Your script is already up to date."
        read -n 1 && echo
    fi
}


while true; do
    clear
    echo "-------------------------------------------------------------------------------"
    echo " Webcam Image Controls $VERSION                             github.com/victornpb "
    echo "-------------------------------------------------------------------------------"
    printf " %s Brightness ...................... %5d\t(-64 to 64)\n" "$([ $selected -eq  1 ] && echo "▶ " || echo "")" "$BRIGHTNESS"
    printf " %s Contrast ........................ %5d\t(0 to 64)\n" "$([ $selected -eq  2 ] && echo "▶ " || echo "")" "$CONTRAST"
    printf " %s Saturation ...................... %5d\t(0 to 128)\n" "$([ $selected -eq  3 ] && echo "▶ " || echo "")" "$SATURATION"
    printf " %s Hue ............................. %5d\t(-40 to 40)\n" "$([ $selected -eq  4 ] && echo "▶ " || echo "")" "$HUE"
    printf " %s Gamma ........................... %5d\t(72 to 500)\n" "$([ $selected -eq  5 ] && echo "▶ " || echo "")" "$GAMMA"
    printf " %s Gain ............................ %5d\t(0 to 100)\n" "$([ $selected -eq  6 ] && echo "▶ " || echo "")" "$GAIN"
    printf " %s White Balance Temperature Auto .. %5d\t(0=Off / 1=On)\n" "$([ $selected -eq  7 ] && echo "▶ " || echo "")" "$WHITE_BALANCE_TEMP_AUTO"
    printf " %s Power Line Frequency ............ %5d\t(0 to 2)\n" "$([ $selected -eq  8 ] && echo "▶ " || echo "")" "$POWER_LINE_FREQ"
    printf " %s White Balance Temperature ....... %5d\t(2800 to 6500)\n" "$([ $selected -eq  9 ] && echo "▶ " || echo "")" "$WHITE_BALANCE_TEMP"
    printf " %s Sharpness ....................... %5d\t(0 to 6)\n" "$([ $selected -eq 10 ] && echo "▶ " || echo "")" "$SHARPNESS"
    printf " %s Backlight Compensation .......... %5d\t(0 to 2)\n" "$([ $selected -eq 11 ] && echo "▶ " || echo "")" "$BACKLIGHT_COMP"
    printf " %s Exposure Auto ................... %5d\t(1=Manual / 3=Auto)\n" "$([ $selected -eq 12 ] && echo "▶ " || echo "")" "$EXPOSURE_AUTO"
    printf " %s Exposure Absolute ............... %5d\t(1 to 5000)\n" "$([ $selected -eq 13 ] && echo "▶ " || echo "")" "$EXPOSURE_ABSOLUTE"
    printf " %s Exposure Auto Priority .......... %5d\t(?)\n" "$([ $selected -eq 14 ] && echo "▶ " || echo "")" "$EXPOSURE_AUTO_PRIORITY"
    echo "-------------------------------------------------------------------------------"
    echo " [W]↑ [S]↓ [A]- [D]+  [U]Update  [Q]Quit"
    echo ""

    read -n 1 -s input

    case "$input" in
        "w" | "W")
            # Select previous control
            selected=$((selected - 1))
            if [ $selected -lt 1 ]; then
                selected=14
            fi
            ;;
        "s" | "S")
            # Select previous control
            selected=$((selected + 1))
            if [ $selected -gt 14 ]; then
                selected=1
            fi
            ;;
        "d" | "D")
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
        "a" | "A")
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
        "u" | "U")
            # Update the script
            update_script
            ;;
        "q" | "Q")
            break
            ;;
    esac
done
