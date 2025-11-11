#!/bin/bash

# -------------------------
# CONFIGURATION
# -------------------------
theme_name="matugen"
spicetify_theme_dir="$HOME/.config/spicetify/Themes/$theme_name"
alacritty_colors="$HOME/.config/alacritty/colors.toml"

# -------------------------
# FUNCTIONS
# -------------------------
success() { echo -e "\e[32m[SUCCESS]\e[0m $1"; }
warning() { echo -e "\033[0;33m[WARNING]\033[0;37m $1"; }

# Extract color from Alacritty colors.toml
extract_color() {
    local section="$1"
    local key="$2"
    awk -v section="[$section]" -v key="$key" '
        $0 == section { in_section=1; next }
        /^\[/ { in_section=0 }
        in_section && $1 == key {
            if (match($0, /(#|0x)[0-9a-fA-F]{6}/))
                print substr($0, RSTART+1, RLENGTH-1)
        }
    ' "$alacritty_colors"
}

# -------------------------
# CHECKS
# -------------------------
if ! command -v spicetify >/dev/null 2>&1; then
    warning "Spicetify not found. Install 'spicetify-cli'."
    exit 1
fi

if [[ ! -f "$alacritty_colors" ]]; then
    warning "Alacritty colors file not found: $alacritty_colors"
    exit 1
fi

# -------------------------
# CREATE THEME DIRECTORY
# -------------------------
mkdir -p "$spicetify_theme_dir"

# -------------------------
# CREATE user.css
# -------------------------
cat > "$spicetify_theme_dir/user.css" << EOF
*,
html,
body {
    font-family: "JetBrains Mono" !important;
}
:root,
.encore-dark-theme,
.encore-base-set,
.encore-inverted-light-set {
    --background-highlight: rgba(var(--spice-rgb-highlight), 0.25) !important;
}
.main-nowPlayingBar-container {
    background-color: var(--background-base);
    border-radius: 0.5rem;
    padding: 0.5rem;
    color: var(--spice-text);
}
.main-entityHeader-backgroundColor,
.main-actionBarBackground-background,
.main-home-homeHeader {
    display: none !important;
}
.main-topBar-background,
.main-home-filterChipsSection {
    background-color: var(--spice-main) !important;
}
EOF

# -------------------------
# CREATE color.ini BASED ON ALACRITTY COLORS
# -------------------------
color_main=$(extract_color "colors.primary" "background")
color_text=$(extract_color "colors.primary" "foreground")
color_error=$(extract_color "colors.normal" "red")
color_active=$(extract_color "colors.normal" "green")
color_highlight=$(extract_color "colors.normal" "blue")

cat > "$spicetify_theme_dir/color.ini" << EOF
[base]
main                = ${color_main:-1d1f21}
player              = ${color_main:-1d1f21}
card                = ${color_main:-1d1f21}
main-elevated       = ${color_main:-1d1f21}
sidebar             = ${color_main:-1d1f21}
shadow              = ${color_text:-c5c8c6}
notification-error  = ${color_error:-cc6666}
button-active       = ${color_active:-b5bd68}
text                = ${color_text:-c5c8c6}
highlight           = ${color_highlight:-81a2be}
EOF

# -------------------------
# APPLY SPICETIFY THEME
# -------------------------
spotify_was_running=false
if pgrep -x "spotify" >/dev/null 2>&1; then
    spotify_was_running=true
fi

spicetify config current_theme "$theme_name"
spicetify config color_scheme base
spicetify apply

# -------------------------
# RESTART SPOTIFY IF NEEDED
# -------------------------
if [ "$spotify_was_running" = true ]; then
    killall spotify
    spotify &
fi

success "Spotify theme '$theme_name' applied successfully!"
