#!/usr/bin/env sh

pkill awww-daemon
awww-daemon --format xrgb &

while ! awww query >/dev/null 2>&1; do
    sleep 0.2
done

awww img ~/.config/sway/assets/3.jpg
