#!/usr/bin/env bash
# noir agenda — upcoming events from ICS feeds (outlook, uni timetable, …).
#
# feeds live in ~/.config/noir/calendars.conf (NOT in git — the URLs carry
# secret tokens), one per line:   name|https://…/calendar.ics
#
#   agenda.sh            events in the next 3 days, one per line:
#                        "epoch<TAB>ddd HH:MM<TAB>name<TAB>summary"
#   agenda.sh 7          same, next 7 days
#   agenda.sh setup      how to get the outlook / timetable URLs
#
# fetches are cached in ~/.cache/noir/agenda; offline falls back to the cache.

set -u

CONF="$HOME/.config/noir/calendars.conf"
CACHE="$HOME/.cache/noir/agenda"
DAYS="${1:-3}"

if [ "${1:-}" = "setup" ]; then
    cat <<'EOF'
agenda feeds — one-time setup, paste links into ~/.config/noir/calendars.conf

outlook (covers teams meetings too — they live in the same calendar):
  outlook web (firefox) → gear → Calendar → Shared calendars
  → "Publish a calendar" → select calendar, "Can view all details"
  → Publish → copy the ICS link, then add a line:
      outlook|https://outlook.office365.com/owa/calendar/…/calendar.ics

unimelb timetable (once sem2 allocations open in mytimetable):
  mytimetable → top right → "Export calendar" / subscribe → copy ICS URL:
      uni|https://mytimetable.students.unimelb.edu.au/…/calendar.ics

then: systemctl --user start noir-hud.service   (or wait for the timer)
EOF
    exit 0
fi

mkdir -p "$CACHE"
[ -f "$CONF" ] || exit 0    # no feeds configured yet — quietly output nothing

# refresh caches (10s timeout each; keep the old file on failure)
while IFS='|' read -r name url; do
    case "$name" in ''|\#*) continue ;; esac
    tmp="$CACHE/$name.ics.tmp"
    if curl -fsSL --max-time 10 "$url" -o "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
        mv "$tmp" "$CACHE/$name.ics"
    else
        rm -f "$tmp"
    fi
done < "$CONF"

# parse every cached feed; expand recurrences; print upcoming events
python3 - "$CACHE" "$DAYS" <<'PY'
import sys, os, glob, re
from datetime import datetime, date, timedelta, timezone
from dateutil.rrule import rrulestr
from dateutil import tz

cache, days = sys.argv[1], int(sys.argv[2])
local = tz.tzlocal()
now = datetime.now(local)
horizon = now + timedelta(days=days)

def unfold(text):
    return re.sub(r'\r?\n[ \t]', '', text).splitlines()

def parse_dt(val, params):
    tzid = params.get('TZID')
    if re.fullmatch(r'\d{8}', val):                      # all-day
        d = datetime.strptime(val, '%Y%m%d')
        return d.replace(tzinfo=local), True
    dt = datetime.strptime(val[:15], '%Y%m%dT%H%M%S')
    if val.endswith('Z'):
        return dt.replace(tzinfo=timezone.utc).astimezone(local), False
    zone = tz.gettz(tzid) if tzid else local
    return dt.replace(tzinfo=zone or local).astimezone(local), False

events = []
for path in glob.glob(os.path.join(cache, '*.ics')):
    name = os.path.basename(path)[:-4]
    try:
        lines = unfold(open(path, encoding='utf-8', errors='replace').read())
    except OSError:
        continue
    cur, in_event = {}, False
    for line in lines:
        if line == 'BEGIN:VEVENT':
            cur, in_event = {}, True
        elif line == 'END:VEVENT' and in_event:
            in_event = False
            if 'DTSTART' not in cur:
                continue
            val, params = cur['DTSTART']
            try:
                start, allday = parse_dt(val, params)
            except ValueError:
                continue
            summ = cur.get('SUMMARY', ('(untitled)', {}))[0]
            summ = summ.replace('\\,', ',').replace('\\;', ';').replace('\\n', ' ').strip()
            status = cur.get('STATUS', ('', {}))[0]
            if status == 'CANCELLED':
                continue
            if 'RRULE' in cur:
                try:
                    naive = start.tzinfo is None
                    rule = rrulestr(cur['RRULE'][0], dtstart=start)
                    for occ in rule.between(now - timedelta(hours=12), horizon):
                        events.append((occ, allday, name, summ))
                except (ValueError, TypeError):
                    pass
            else:
                events.append((start, allday, name, summ))
        elif in_event and ':' in line:
            key, val = line.split(':', 1)
            parts = key.split(';')
            params = dict(p.split('=', 1) for p in parts[1:] if '=' in p)
            if parts[0] in ('DTSTART', 'RRULE', 'SUMMARY', 'STATUS'):
                cur[parts[0]] = (val, params)

seen = set()
for start, allday, name, summ in sorted(events, key=lambda e: e[0]):
    if start < now - timedelta(hours=1) or start > horizon:
        continue
    key = (start.strftime('%Y%m%d%H%M'), summ)
    if key in seen:
        continue
    seen.add(key)
    when = start.strftime('%a all day') if allday else start.strftime('%a %H:%M')
    print(f"{int(start.timestamp())}\t{when}\t{name}\t{summ}")
PY
