#!/usr/bin/bash

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/"
IMAGE_PICKER_CONFIG="$HOME/.config/rofi/rofi-wallpaper-picker/image-picker.razi"

# Find all image files in the directory (jpg, jpeg, png)
WALLPAPER_FILES=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \))

# Build rofi list with icons and highlight current wallpaper
ROFI_MENU=""
CURRENT_WALLPAPER_FILE=$(basename "$(swww query | awk '{print $NF}')")

while IFS= read -r WALLPAPER_PATH; do
  WALLPAPER_NAME=$(basename "$WALLPAPER_PATH")
  if [[ "$WALLPAPER_NAME" == "$CURRENT_WALLPAPER_FILE" ]]; then
    ROFI_MENU+="${WALLPAPER_NAME} (current)\0icon\x1f${WALLPAPER_PATH}\n"
  else
    ROFI_MENU+="${WALLPAPER_NAME}\0icon\x1f${WALLPAPER_PATH}\n"
  fi
done <<<"$WALLPAPER_FILES"

# Let user pick a wallpaper through rofi
SELECTED_WALLPAPER=$(echo -e "$ROFI_MENU" | rofi -dmenu \
  -p "Select Wallpaper:" \
  -theme "$IMAGE_PICKER_CONFIG" \
  -markup-rows)

# Remove the "(current)" tag if selected
SELECTED_WALLPAPER_NAME=$(echo "$SELECTED_WALLPAPER" | sed 's/ (current)//')

# Apply selected wallpaper through Mattugen (respects config.wallpaper)
if [[ -n "$SELECTED_WALLPAPER_NAME" ]]; then
  echo "Applying wallpaper: $SELECTED_WALLPAPER_NAME"
  matugen image "$WALLPAPER_DIR/$SELECTED_WALLPAPER_NAME"
fi
