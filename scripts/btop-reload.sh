#!/bin/bash
# إعادة تحميل btop بدون إنهاء الجلسة

if pgrep -x btop >/dev/null; then
    echo "🔁 Reloading btop theme..."
    pkill -SIGUSR2 btop
else
    echo "🚀 btop not running, starting it now..."
    kitty -e btop &
fi
