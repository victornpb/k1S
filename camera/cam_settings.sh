#!/bin/sh
VERSION=v1.7.0

# Initialize selected control and step value
selected=1
step=10
CONFIG_FILE=/usr/cam.ini

# Function to get current control values using v4l2-ctl
read_current_values() {
    BRIGHTNESS=$(v4l2-ctl -d /dev/video4 --get-ctrl brightness | cut -d' ' -f2)
    CONTRAST=$(v4l2-ctl -d /dev/video4 --get-ctrl contrast | cut -d' ' -f2)
    SATURATION=$(v4l2-ctl -d /dev/video4 --get-ctrl saturation | cut -d' ' -f2)
    HUE=$(v4l2-ctl -d /dev/video4 --get-ctrl hue | cut -d' ' -f2)
    GAMMA=$(v4l2-ctl -d /dev/video4 --get-ctrl gamma | cut -d' ' -f2)
    GAIN=$(v4l2-ctl -d /dev/video4 --get-ctrl gain | cut -d' ' -f2)
    WHITE_BALANCE_TEMP_AUTO=$(v4l2-ctl -d /dev/video4 --get-ctrl white_balance_temperature_auto | cut -d' ' -f2)
    POWER_LINE_FREQ=$(v4l2-ctl -d /dev/video4 --get-ctrl power_line_frequency | cut -d' ' -f2)
    WHITE_BALANCE_TEMP=$(v4l2-ctl -d /dev/video4 --get-ctrl white_balance_temperature | cut -d' ' -f2)
    SHARPNESS=$(v4l2-ctl -d /dev/video4 --get-ctrl sharpness | cut -d' ' -f2)
    BACKLIGHT_COMP=$(v4l2-ctl -d /dev/video4 --get-ctrl backlight_compensation | cut -d' ' -f2)
    EXPOSURE_AUTO=$(v4l2-ctl -d /dev/video4 --get-ctrl exposure_auto | cut -d' ' -f2)
    EXPOSURE_ABSOLUTE=$(v4l2-ctl -d /dev/video4 --get-ctrl exposure_absolute | cut -d' ' -f2)
    EXPOSURE_AUTO_PRIORITY=$(v4l2-ctl -d /dev/video4 --get-ctrl exposure_auto_priority | cut -d' ' -f2)
}

# Function to set control value using v4l2-ctl
set_control() {
    local control_name="$1"
    local control_value="$2"
    v4l2-ctl -d /dev/video4 --set-ctrl "$control_name=$control_value"
}


# Function to save current control values to a file
save_to_file() {
    echo "BRIGHTNESS=$BRIGHTNESS" > "$CONFIG_FILE"
    echo "CONTRAST=$CONTRAST" >> "$CONFIG_FILE"
    echo "SATURATION=$SATURATION" >> "$CONFIG_FILE"
    echo "HUE=$HUE" >> "$CONFIG_FILE"
    echo "GAMMA=$GAMMA" >> "$CONFIG_FILE"
    echo "GAIN=$GAIN" >> "$CONFIG_FILE"
    echo "WHITE_BALANCE_TEMP_AUTO=$WHITE_BALANCE_TEMP_AUTO" >> "$CONFIG_FILE"
    echo "POWER_LINE_FREQ=$POWER_LINE_FREQ" >> "$CONFIG_FILE"
    echo "WHITE_BALANCE_TEMP=$WHITE_BALANCE_TEMP" >> "$CONFIG_FILE"
    echo "SHARPNESS=$SHARPNESS" >> "$CONFIG_FILE"
    echo "BACKLIGHT_COMP=$BACKLIGHT_COMP" >> "$CONFIG_FILE"
    echo "EXPOSURE_AUTO=$EXPOSURE_AUTO" >> "$CONFIG_FILE"
    echo "EXPOSURE_ABSOLUTE=$EXPOSURE_ABSOLUTE" >> "$CONFIG_FILE"
    echo "EXPOSURE_AUTO_PRIORITY=$EXPOSURE_AUTO_PRIORITY" >> "$CONFIG_FILE"
    echo "Configuration saved to $CONFIG_FILE"
}

# Function to load control values from a file
load_from_file() {
    if [ -e "$CONFIG_FILE" ]; then
        . "$CONFIG_FILE"
        # Apply loaded values to controls
        set_control "brightness" "$BRIGHTNESS"
        set_control "contrast" "$CONTRAST"
        set_control "saturation" "$SATURATION"
        set_control "hue" "$HUE"
        set_control "gamma" "$GAMMA"
        set_control "gain" "$GAIN"
        set_control "white_balance_temperature_auto" "$WHITE_BALANCE_TEMP_AUTO"
        set_control "power_line_frequency" "$POWER_LINE_FREQ"
        set_control "white_balance_temperature" "$WHITE_BALANCE_TEMP"
        set_control "sharpness" "$SHARPNESS"
        set_control "backlight_compensation" "$BACKLIGHT_COMP"
        set_control "exposure_auto" "$EXPOSURE_AUTO"
        set_control "exposure_absolute" "$EXPOSURE_ABSOLUTE"
        set_control "exposure_auto_priority" "$EXPOSURE_AUTO_PRIORITY"
        echo "Configuration loaded from $CONFIG_FILE"
    else
        echo "Configuration file $CONFIG_FILE does not exist. Please save values first (option 'O')."
    fi
}

# Function to set controls to default values
reset_defaults() {
    BRIGHTNESS=0
    CONTRAST=32
    SATURATION=56
    HUE=0
    GAMMA=80
    GAIN=0
    WHITE_BALANCE_TEMP_AUTO=1
    POWER_LINE_FREQ=1
    WHITE_BALANCE_TEMP=4600
    SHARPNESS=3
    BACKLIGHT_COMP=1
    EXPOSURE_AUTO=3
    EXPOSURE_ABSOLUTE=156
    EXPOSURE_AUTO_PRIORITY=0
    # Apply defaults to controls
    set_control "brightness" "$BRIGHTNESS"
    set_control "contrast" "$CONTRAST"
    set_control "saturation" "$SATURATION"
    set_control "hue" "$HUE"
    set_control "gamma" "$GAMMA"
    set_control "gain" "$GAIN"
    set_control "white_balance_temperature_auto" "$WHITE_BALANCE_TEMP_AUTO"
    set_control "power_line_frequency" "$POWER_LINE_FREQ"
    set_control "white_balance_temperature" "$WHITE_BALANCE_TEMP"
    set_control "sharpness" "$SHARPNESS"
    set_control "backlight_compensation" "$BACKLIGHT_COMP"
    set_control "exposure_auto" "$EXPOSURE_AUTO"
    set_control "exposure_absolute" "$EXPOSURE_ABSOLUTE"
    set_control "exposure_auto_priority" "$EXPOSURE_AUTO_PRIORITY"
}

# Function to check and update the script
update_script() {
    remote_script=$(wget --no-check-certificate -qO- https://raw.githubusercontent.com/victornpb/k1S/main/camera/cam_settings.sh)
    local_script=$(cat /usr/cam_settings.sh)  # Read the current script content
    if [ "$remote_script" != "$local_script" ]; then
        second_line=$(echo "$remote_script" | cut -d$'\n' -f 2)
        echo "A new version is available ($second_line)! Do you want to update? (Y/N)"
        read -n 1 -r response
        if [ "$response" = "Y" ] || [ "$response" = "y" ]; then
            echo "$remote_script" > /usr/cam_settings.sh  # Overwrite the local script with the remote version
            chmod +x /usr/cam_settings.sh
            echo "The script has been updated. Do you want to run the new version? (Y/N)"
            read -n 1 -r run_response
            if [ "$run_response" = "Y" ] || [ "$run_response" = "y" ]; then
                exec /usr/cam_settings.sh  # Run the new version
            else
                echo "Update completed!"
                exit
            fi
        else
            echo "Update canceled!"
            read -n 1
        fi

    else
        echo "Your script is already up to date."
        read -n 1
    fi
}


# main

read_current_values

# Check for the -r flag
if [ "$1" = "-r" ]; then
    reset_defaults
    exit
fi
# Check for the -s flag
if [ "$1" = "-s" ]; then
    save_to_file
    exit
fi
# Check for the -l flag
if [ "$1" = "-l" ]; then
    load_from_file
    exit
fi

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
    printf " %s Power Line Frequency ............ %5d\t(0=Off 1=50Hz 2=60Hz)\n" "$([ $selected -eq  8 ] && echo "▶ " || echo "")" "$POWER_LINE_FREQ"
    printf " %s White Balance Temperature ....... %5d\t(2800 to 6500)\n" "$([ $selected -eq  9 ] && echo "▶ " || echo "")" "$WHITE_BALANCE_TEMP"
    printf " %s Sharpness ....................... %5d\t(0 to 6)\n" "$([ $selected -eq 10 ] && echo "▶ " || echo "")" "$SHARPNESS"
    printf " %s Backlight Compensation .......... %5d\t(0 to 2)\n" "$([ $selected -eq 11 ] && echo "▶ " || echo "")" "$BACKLIGHT_COMP"
    printf " %s Exposure Auto ................... %5d\t(1=Manual / 3=Auto)\n" "$([ $selected -eq 12 ] && echo "▶ " || echo "")" "$EXPOSURE_AUTO"
    printf " %s Exposure Absolute ............... %5d\t(1 to 5000)\n" "$([ $selected -eq 13 ] && echo "▶ " || echo "")" "$EXPOSURE_ABSOLUTE"
    printf " %s Exposure Auto Priority .......... %5d\t(?)\n" "$([ $selected -eq 14 ] && echo "▶ " || echo "")" "$EXPOSURE_AUTO_PRIORITY"
    echo "-------------------------------------------------------------------------------"
    echo " [W] ↑   [S] ↓   [A] -$step   [D] +$step   [F] Fine ajust   [C] Coarse ajust"
    echo ""
    echo " [O] Save   [L] Load   [R] Reset defaults   [E] Refresh"
    echo " [U] Check for Update   [X] Quit"
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
            # Select next control
            selected=$((selected + 1))
            if [ $selected -gt 14 ]; then
                selected=1
            fi
            ;;
        "d" | "D")
            # Increase control value
            case "$selected" in
                1) BRIGHTNESS=$((BRIGHTNESS + step)); set_control "brightness" "$BRIGHTNESS";;
                2) CONTRAST=$((CONTRAST + step)); set_control "contrast" "$CONTRAST";;
                3) SATURATION=$((SATURATION + step)); set_control "saturation" "$SATURATION";;
                4) HUE=$((HUE + step)); set_control "hue" "$HUE";;
                5) GAMMA=$((GAMMA + step)); set_control "gamma" "$GAMMA";;
                6) GAIN=$((GAIN + step)); set_control "gain" "$GAIN";;
                7) WHITE_BALANCE_TEMP_AUTO=$((WHITE_BALANCE_TEMP_AUTO + 1)); set_control "white_balance_temperature_auto" "$WHITE_BALANCE_TEMP_AUTO";;
                8) POWER_LINE_FREQ=$((POWER_LINE_FREQ + 1)); set_control "power_line_frequency" "$POWER_LINE_FREQ";;
                9) WHITE_BALANCE_TEMP=$((WHITE_BALANCE_TEMP + step)); set_control "white_balance_temperature" "$WHITE_BALANCE_TEMP";;
                10) SHARPNESS=$((SHARPNESS + 1)); set_control "sharpness" "$SHARPNESS";;
                11) BACKLIGHT_COMP=$((BACKLIGHT_COMP + 1)); set_control "backlight_compensation" "$BACKLIGHT_COMP";;
                12) EXPOSURE_AUTO=$((EXPOSURE_AUTO + 1)); set_control "exposure_auto" "$EXPOSURE_AUTO";;
                13) EXPOSURE_ABSOLUTE=$((EXPOSURE_ABSOLUTE + step)); set_control "exposure_absolute" "$EXPOSURE_ABSOLUTE";;
                14) EXPOSURE_AUTO_PRIORITY=$((EXPOSURE_AUTO_PRIORITY + 1)); set_control "exposure_auto_priority" "$EXPOSURE_AUTO_PRIORITY";;
            esac
            ;;
        "a" | "A")
            # Decrease control value
            case "$selected" in
                1) BRIGHTNESS=$((BRIGHTNESS - step)); set_control "brightness" "$BRIGHTNESS";;
                2) CONTRAST=$((CONTRAST - step)); set_control "contrast" "$CONTRAST";;
                3) SATURATION=$((SATURATION - step)); set_control "saturation" "$SATURATION";;
                4) HUE=$((HUE - step)); set_control "hue" "$HUE";;
                5) GAMMA=$((GAMMA - step)); set_control "gamma" "$GAMMA";;
                6) GAIN=$((GAIN - step)); set_control "gain" "$GAIN";;
                7) WHITE_BALANCE_TEMP_AUTO=$((WHITE_BALANCE_TEMP_AUTO - 1)); set_control "white_balance_temperature_auto" "$WHITE_BALANCE_TEMP_AUTO";;
                8) POWER_LINE_FREQ=$((POWER_LINE_FREQ - 1)); set_control "power_line_frequency" "$POWER_LINE_FREQ";;
                9) WHITE_BALANCE_TEMP=$((WHITE_BALANCE_TEMP - step)); set_control "white_balance_temperature" "$WHITE_BALANCE_TEMP";;
                10) SHARPNESS=$((SHARPNESS - 1)); set_control "sharpness" "$SHARPNESS";;
                11) BACKLIGHT_COMP=$((BACKLIGHT_COMP - 1)); set_control "backlight_compensation" "$BACKLIGHT_COMP";;
                12) EXPOSURE_AUTO=$((EXPOSURE_AUTO - 1)); set_control "exposure_auto" "$EXPOSURE_AUTO";;
                13) EXPOSURE_ABSOLUTE=$((EXPOSURE_ABSOLUTE - step)); set_control "exposure_absolute" "$EXPOSURE_ABSOLUTE";;
                14) EXPOSURE_AUTO_PRIORITY=$((EXPOSURE_AUTO_PRIORITY - 1)); set_control "exposure_auto_priority" "$EXPOSURE_AUTO_PRIORITY";;
            esac
            ;;
        "f" | "F")
            # Fine adjust
            step=1
            ;;
        "c" | "C")
            # Coarse adjust
            step=10
            ;;
        "r" | "R")
            # Reset defaults
            reset_defaults
            ;;
        "e" | "E")
            # Read values
            read_current_values
            ;;
         "o" | "O")
            # Save values to a file
            save_to_file
            read -n 1
            ;;
        "l" | "L")
            # Load values from a file
            load_from_file
            read -n 1
            ;;
        "u" | "U")
            # Update the script
            update_script
            ;;
        "x" | "X")
            break
            ;;
    esac
done
