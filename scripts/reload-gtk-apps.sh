# تحقق إذا Nautilus شغال
if pgrep -x "nautilus" > /dev/null 2>&1; then
    # احفظ أي نوافذ مفتوحة (OpenLocations)
    LOCATIONS=$(gdbus introspect --session --dest org.gnome.Nautilus \
                --object-path /org/freedesktop/FileManager1 2>/dev/null | \
                grep "OpenLocations" | grep -o "file://[^']*" | sed 's|file://||')

    # أوقف Nautilus مؤقتًا
    nautilus -q

    # أعد فتحه مع استرجاع المواقع المفتوحة
    for path in $LOCATIONS; do
        [ -d "$path" ] && nohup nautilus "$path" &>/dev/null &
    done
fi
