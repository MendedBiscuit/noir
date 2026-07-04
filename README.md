<h1 align="center">N O I R</h1>

<p align="center">
a monochrome sway rice for CachyOS — black glass, 1px hairlines, no color anywhere.<br>
contrast, spacing, transparency and motion do the work that color usually does.
</p>

![desktop](.readme/desktop.png)

## anatomy

| piece | what |
|---|---|
| wm | sway — 8px gaps, 2px hairline borders, native (daemonless) wallpaper |
| bar | waybar — glass pills, hover states, calendar, click-to-act modules |
| launcher | wofi — black glass, fuzzy matching |
| notifications | swaync — full control center: dnd, mpris, sliders, quick toggles |
| lock | swaylock over blurred sand ripples |
| terminal | alacritty (hack) · btop + fastfetch themed to match |
| everything else | plain shell scripts in `.bin/` — zero extra daemons |

<table>
  <tr>
    <td><img src=".readme/launcher.png" alt="launcher"></td>
    <td><img src=".readme/control-center.png" alt="control center"></td>
  </tr>
  <tr>
    <td><img src=".readme/power.png" alt="power menu"></td>
    <td><img src=".readme/dashboard.png" alt="dashboard"></td>
  </tr>
</table>

## the work engine

`Super+D` opens a project cockpit over everything in `~/Data`
(tagged `git` / `dvc` / `plain`, auto-discovered):

- open in vs code (claude in panel) · claude code terminal · plain terminal
- git status / sync (`pull --rebase` + push) / commit with review
- dvc status / sync via the project's own venv
- ssh remotes from `~/.ssh/config` → vs code remote window or terminal
- `claude mcp list` one entry away

## ai

two assistants, one keystroke each:

- **claude** (`Super+C`) — cloud, for the heavy multimodal/agentic work
- **noir** (`Super+Ctrl+C`) — glm4 running locally through ollama with a
  machine-aware system prompt. free, offline, open source. also: `ai` in any shell

## keys

| key | does |
|---|---|
| `Super+Space` | launcher |
| `Super+Escape` | quick actions — screenshots, wallpaper, toggles, panels |
| `Super+D` | work engine |
| `Super+C` / `Super+Ctrl+C` | claude / local ai |
| `Super+I` | floating btop dashboard |
| `Super+/` | keybind cheatsheet, parsed live from the sway config |
| `Super+Ctrl+/` | the manual — explains all of this in-system |
| `Super+Shift+E` | power menu — <em>the big sleep</em> |

![manual](.readme/manual.png)

everything is documented on the machine itself: `Super+Ctrl+/`.
