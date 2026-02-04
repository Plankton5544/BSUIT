# BSUIT - Bash Builtins-only TUI Library

A lightweight, dependency-free Terminal User Interface (TUI) library for Bash that uses **only bash builtins** and ANSI escape sequences. No external dependencies like `tput`, `ncurses`, or other terminal manipulation tools required.

## Features

- **Zero Dependencies** - Uses only bash builtins and ANSI escape codes
-  **Rich Styling** - Comprehensive color and text formatting options
-  **Box Drawing** - Multiple border styles (single, double, bold, rounded, block)
-  **UI Components** - Menus, progress bars, spinners, text fields, and more
-  **Cursor Control** - Precise cursor positioning and visibility management
-  **Mode-based Rendering** - Efficient state management and rendering system
-  **Keyboard Input** - Arrow keys, special characters, and timed reads
-  **Alternative Buffer** - Non-destructive screen management

## Limitations

-   Visual Artifacts - Screen flickering and redraw artifacts during rapid updates
-   Performance - Slower than ncurses-based TUIs due to character-by-character drawing
-   No Double Buffering - Lacks proper frame buffering, causing **visual tearing**
-   Coordinate Quirks - Manual cursor positioning can be error-prone
-   Full Redraws Required - Each mode change clears and redraws entire screen
-   Terminal Dependency - Rendering quality varies significantly between terminal emulators
-   Limited Input - No mouse support, basic keyboard handling only
-   Single-threaded - No async updates or background processing

Trade-off: This library prioritizes portability and zero dependencies over rendering performance. For production TUIs with complex layouts, consider dedicated frameworks.

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd BSUIT
```

2. Source the library in your script:
```bash
source ~/BSUIT/components/bsuit.sh
```

## Quick Start

Here's a minimal example to get started:

```bash
#!/bin/bash
source ~/BSUIT/components/bsuit.sh

my_screen() {
  header
  draw_box 10 10 40 10 single
  draw_text 12 12 "Hello, BSUIT!"
  
  read_keys 1
  case "$REPLY" in
    q) MODE="break" ;;
  esac
}

main() {
  init
  MODE="my_screen"
  
  while [[ "$MODE" != "break" ]]; do
    dispatch my_screen
  done
  
  cleanup
}

main $@
```

## Core Concepts

### Initialization and Cleanup

Always wrap your TUI application with `init` and `cleanup`:

```bash
init      # Sets up: hides cursor, enters alt buffer, initializes state
cleanup   # Restores: shows cursor, exits alt buffer, clears state
```

### Mode-based Rendering

BSUIT uses a mode system for managing application state:

```bash
MODE="screen_name"  # Current mode/screen
dispatch mode1 mode2 mode3  # Renders current mode from provided list
```

### Global State Variables

- `MODE` - Current screen/mode name
- `SELECTED` - Currently selected menu item index
- `ACTIVE` - Activation flag for menu items
- `HISTORY` - Array of user input characters
- `ITEMS` - Array of menu items
- `REPLY` - Last key pressed (from `read_keys`)

## API Reference

### Cursor Control

#### `curs_goto x y`
Position cursor at coordinates (x, y). Origin (1,1) is top-left.

```bash
curs_goto 10 5  # Move to column 10, row 5
```

#### `curs_center x y width height`
Position cursor at center of a box.

```bash
curs_center 1 1 $COLUMNS $LINES  # Center of screen
```

#### `curs_vis [hide|show]`
Control cursor visibility.

```bash
curs_vis hide  # Hide cursor
curs_vis show  # Show cursor (default)
```

### Screen Management

#### `buffer [alt|normal]`
Switch between normal and alternative screen buffer.

```bash
buffer alt     # Enter alternative buffer
buffer normal  # Exit to normal buffer
```

#### `clears [mode]`
Clear portions of the screen.

**Modes:**
- `display` - Clear from cursor to end
- `screen` - Clear entire screen
- `saved` - Clear scrollback buffer
- `line` - Clear entire line
- `curs-line` - Clear from cursor to end of line
- `line-curs` - Clear from start of line to cursor

```bash
clears screen  # Clear entire screen
clears line    # Clear current line
```

### Drawing Functions

#### `draw_box x y width height [style]`
Draw a box with specified style.

**Styles:** `single` (default), `double`, `bold`, `rounded`, `block`

```bash
draw_box 5 5 30 10 double
```

#### `colored_draw_box x y width height style color`
Draw a colored box.

```bash
colored_draw_box 5 5 30 10 rounded "$BLDGRN"
```

#### `draw_text x y text`
Draw text at position.

```bash
draw_text 10 5 "Hello World"
```

#### `draw_aligned_text x y text [center|right|left]`
Draw aligned text.

```bash
draw_aligned_text 40 10 "Centered" center
```

#### `truncate_text x y text limit`
Draw text truncated to limit.

```bash
truncate_text 5 5 "Very long text here" 10
```

### UI Components

#### `display_menu x y width height`
Interactive menu using `ITEMS` array.

```bash
ITEMS=("Option 1" "Option 2" "Option 3")
SELECTED=0
display_menu 10 10 30 5
```

Navigation:
- `[A` / `[B` - Up/Down arrows (move selection)
- Enter - Sets `ACTIVE=1` and executes item as function

#### `display_field x y width`
Text input field using `HISTORY` array.

```bash
HISTORY=()
display_field 10 10 30
```

#### `draw_progress x y width progress [callback]`
Draw a progress bar.

```bash
draw_progress 10 10 40 75        # 75% progress
draw_progress 10 10 40 "50%"     # With % sign
draw_progress 10 10 40 100 done  # Calls 'done' function at 100%
```

#### `spinner x y state`
Draw an animated spinner (states 1-8).

```bash
spinner 10 10 $STATE
STATE=$(( (STATE % 8) + 1 ))  # Cycle through states
```

### Input Handling

#### `read_keys [timeout]`
Read a single keypress with optional timeout.

```bash
read_keys       # Wait indefinitely
read_keys 0.5   # 500ms timeout
read_keys 2     # 2 second timeout

# Check response
case "$REPLY" in
  q) MODE="break" ;;
  "[A") echo "Up arrow" ;;
  "[B") echo "Down arrow" ;;
  "[C") echo "Right arrow" ;;
  "[D") echo "Left arrow" ;;
esac
```

### Helper Functions

#### `center x y [x|y] dimension`
Calculate center position.

```bash
x_center=$(center 0 0 x $COLUMNS)
y_center=$(center 0 0 y $LINES)
```

#### `header`
Draw a block-style header with current MODE name.

```bash
header  # Draws MODE name centered in header
```

#### `subber text`
Draw a block-style subheader.

```bash
subber "Press Q to quit"
```

## Style Variables

BSUIT includes extensive styling through `style.sh`:

### Text Styles
```bash
$BLD   # Bold
$DIM   # Dim
$ITL   # Italic
$UND   # Underline
$REV   # Reverse
$RST   # Reset
```

### Colors
```bash
# Regular
$RED $GRN $YLW $BLU $MAG $CYN $WHT $BLK

# Bright
$BRED $BGRN $BYLW $BBLU $BMAG $BCYN $BWHT

# Backgrounds
$BGRED $BGGRN $BGBLU $BGMAG $BGCYN $BGWHT

# Bold Colors
$BLDRED $BLDGRN $BLDYLW $BLDBLU $BLDMAG $BLDCYN
```

### Box Drawing Characters
```bash
# Single line
$BX_TL $BX_TR $BX_BL $BX_BR  # Corners
$BX_H $BX_V                   # Horizontal/Vertical
$BX_CR                        # Cross

# Double line
$DBX_TL $DBX_TR $DBX_BL $DBX_BR
$DBX_H $DBX_V

# Bold/Heavy
$HBX_TL $HBX_TR $HBX_BL $HBX_BR
$HBX_H $HBX_V

# Rounded
$RBX_TL $RBX_TR $RBX_BL $RBX_BR
```

### Blocks and Symbols
```bash
$BLK_FULL $BLK_DARK $BLK_MED $BLK_LIGHT  # Shades
$BLK_LEFT $BLK_RIGHT $BLK_TOP $BLK_BOT   # Half blocks
$BAR_FULL $BAR_EMPTY                      # Progress bars
$SPIN_1 through $SPIN_8                   # Spinner frames
$CHK $CRS                                 # Check/Cross marks
$ARW_UP $ARW_DN $ARW_LT $ARW_RT          # Arrows
$TRI_UP $TRI_DN $TRI_LT $TRI_RT          # Triangles
```

## Examples

### Simple Menu

```bash
#!/bin/bash
source ~/BSUIT/components/bsuit.sh

menu_screen() {
  header
  draw_text 5 5 "Select an option:"
  
  ITEMS=("Start" "Settings" "Quit")
  display_menu 5 7 20 5
  
  if [[ "$ACTIVE" == "1" ]]; then
    case "$SELECTED" in
      0) MODE="start" ;;
      1) MODE="settings" ;;
      2) MODE="break" ;;
    esac
    ACTIVE=0
  fi
  
  read_keys 0.1
}

main() {
  init
  MODE="menu_screen"
  
  while [[ "$MODE" != "break" ]]; do
    dispatch menu_screen
  done
  
  cleanup
}

main $@
```

### Progress Bar Demo

```bash
#!/bin/bash
source ~/BSUIT/components/bsuit.sh

progress_screen() {
  header
  subber "Loading..."
  
  draw_progress 10 10 50 $PROGRESS
  
  PROGRESS=$((PROGRESS + 5))
  
  if [[ $PROGRESS -ge 100 ]]; then
    MODE="break"
  fi
  
  read_keys 0.1
}

main() {
  init
  MODE="progress_screen"
  PROGRESS=0
  
  while [[ "$MODE" != "break" ]]; do
    dispatch progress_screen
  done
  
  cleanup
}

main $@
```

### Advanced Examples

Check the `examples/` directory for complete applications:
- **example.sh** - Debug script for unofficial testing
- **sysmon.sh** - System monitoring dashboard
- **visualizer.sh** - CSV data visualization
Note:
- Some examples are AI generated, please know what you're executing

## External Mode

For applications requiring external commands (non-builtin), load the external module:

```bash
source ~/BSUIT/components/bsuit.sh external
# or
source ~/BSUIT/components/bsuit.sh ext
```

This loads `ext.sh` which may include additional functions requiring external tools.

## Best Practices

1. **Always call `init` before and `cleanup` after** your TUI code
2. **Use the dispatch pattern** for managing multiple screens/modes
3. **Set a timeout in `read_keys`** for animated components (spinners, progress bars)
4. **Clear the screen** in each mode render function using `clears screen`
5. **Use `$COLUMNS` and `$LINES`** bash variables for responsive layouts
6. **Reset styles** with `$RST` after using colors to prevent bleeding

## Terminal Compatibility

BSUIT uses standard ANSI escape sequences and should work on:
- ✅ **Linux terminals** (gnome-terminal, konsole, xterm, **kitty** etc.)
- ✅ macOS Terminal.app and iTerm2
- ✅ Windows Terminal
- ✅ **Most modern terminal emulators supporting ANSI codes**
Note:
- Some legacy terminals may have limited box-drawing character support.
- Emphasized terminals above have shown success in running

## Troubleshooting

### Cursor still visible after cleanup
Some terminals don't respect cursor visibility commands. Try:
```bash
trap cleanup EXIT  # Ensure cleanup runs on script exit
```
Note:
- This does call an external function, or not builtins-only

### Box characters appear as question marks
Your terminal font may not support Unicode box-drawing characters. Use a modern monospace font like:
- JetBrains Mono
- **Fira Code**
- Cascadia Code
- DejaVu Sans Mono

Note:
- Emphasized fonts above have tested to be working

### Arrow keys not working
Ensure you're reading the full escape sequence:
```bash
read_keys  # Automatically handles escape sequences
```
Note:
- There may be variances in how systems interpret arrows, this is currently limited

## Performance Notes

- **Minimize redraws**: Only clear and redraw when state changes
- **Use timeouts wisely**: Lower timeouts = higher CPU usage
- **Batch cursor movements**: Multiple `echo -en` calls are faster than separate `curs_goto` calls

## Contributing

Contributions welcome! Please ensure:
- Functions use only bash builtins (no external commands)
- Code follows existing style conventions
- Examples demonstrate new features

Note:
- Check if bash builtins (type -t <command>)
- Please pardon my inexperience in managing github repos

## License

                      GNU GENERAL PUBLIC LICENSE
                       Version 3, 29 June 2007

## Credits

Created for building fast, portable TUI applications in pure Bash.

---

**Note:** This library intentionally avoids external dependencies for maximum portability. For more feature-rich TUIs with broader terminal support, consider libraries like `dialog`, `whiptail`, or language-specific frameworks.
