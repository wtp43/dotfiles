
SELECTED_BACKGROUND="0x8EA6c8FF"
LABEL_COLOR="0xFFFFFFFF"

SECONDARY_COLOR="0xffb5d6ff"

if [[ $SELECTED == true ]]; then
    sketchybar --set $NAME icon.color="0xFFD1D3FF" \
                           label.color="$LABEL_COLOR" \
                           background.color="$SELECTED_BACKGROUND" \
                           background.border_color="$SELECTED_BACKGROUND" \
						      background.border_width=2 \
                     background.corner_radius=10 \
                     background.padding_left=2 \
                     background.padding_right=2 \
                     background.height=32 \
                        #    background.padding_left=1 \
                        #    background.padding_right=1
else
    sketchybar --set $NAME icon.color="$SECONDARY_COLOR" \
                           label.color="$LABEL_COLOR" \
                           background.color=0xff282930 \
                           background.border_color=0xff000000 \
						      background.border_width=2 \
                     background.corner_radius=10 \
                     background.padding_left=2 \
                     background.padding_right=2 \
                     background.height=32 \
                        #    background.padding_left=0 \
                        #    background.padding_right=0
fi

if [[ $SENDER == "front_app_switched" ]]; then
    SPACES=("main" "work" "dev")

    for i in "${!SPACES[@]}"; do
        sid=$(($i+1))
        arr=()
        icons=""
        
        QUERY=$(yabai -m query --windows --space $sid | jq '.[].app')

        if grep -q "\"" <<< $QUERY; then
            
            while IFS= read -r line; do arr+=("$line"); done <<< "$QUERY"
    
            for i in "${!arr[@]}"
            do
    	        icon=$(echo ${arr[i]} | sed 's/"//g')
  	        icon=$($HOME/.config/sketchybar/plugins/icons.sh $icon)
                icons+="$icon  "
            done

        fi

        sketchybar --set space.$sid label="$icons"

    done

fi
