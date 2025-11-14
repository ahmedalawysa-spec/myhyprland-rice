#!/usr/bin/bash
# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/"
IMAGE_PICKER_CONFIG="$SCRIPT_DIR/image-picker.razi"

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

# Apply wallpaper if selected
if [[ -n "$SELECTED_WALLPAPER_NAME" ]]; then
  FULL_PATH="$WALLPAPER_DIR/$SELECTED_WALLPAPER_NAME"
  echo "Applying wallpaper: $SELECTED_WALLPAPER_NAME"
  
  # Random transition types supported by swww
  TRANSITIONS=("simple" "fade" "left" "right" "top" "bottom" "wipe" "grow" "center" "outer" "wave")
  RANDOM_TRANSITION=$(printf "%s\n" "${TRANSITIONS[@]}" | shuf -n 1)
  
  # Apply wallpaper with swww first (instant visual feedback)
  swww img "$FULL_PATH" \
    --transition-type "$RANDOM_TRANSITION" \
    --transition-fps 180 \
    --transition-duration 1 &
  
  # Then generate colors with matugen (only once!)
  matugen image "$FULL_PATH"
fi