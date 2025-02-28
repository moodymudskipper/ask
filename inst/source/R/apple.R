# * `key`: Press a key or key-combination on the keyboard.
# - This supports xdotool's `key` syntax.
#   - Examples: "a", "Return", "alt+Tab", "ctrl+s", "Up", "KP_0" (for the numpad 0 key).
# * `type`: Type a string of text on the keyboard.
# * `cursor_position`: Get the current (x, y) pixel coordinate of the cursor on the screen.
# * `mouse_move`: Move the cursor to a specified (x, y) pixel coordinate on the screen.
# * `left_click`: Click the left mouse button.
# * `left_click_drag`: Click and drag the cursor to a specified (x, y) pixel coordinate on the screen.
# * `right_click`: Click the right mouse button.
# * `middle_click`: Click the middle mouse button.
# * `double_click`: Double-click the left mouse button.
# * `screenshot`: Take a screenshot of the screen.

apple_screenshot <- function(file = tempfile(fileext = ".png")) {
  cmd <- sprintf("screencapture -xC %s", file)
  system(cmd)
  invisible(file)
}

apple_keystroke <- function(x) {
  cmd <- sprintf(
    "osascript -e 'tell application \"System Events\" to keystroke \"%s\"'",
    x
  )
  system(cmd)
}

# hotkey is in the format "control shft command opt f D"

# note about numbered keys, this doesn't work apple_hotkey("shft cmd 4")
# but this does apple_hotkey("cmd ç")
apple_hotkey <- function(hotkey) {
  hotkey <- tolower(gsub("[ +]+", " ", hotkey))
  hotkey_split <- strsplit(hotkey, " ")[[1]]
  modifiers <- head(hotkey_split, -1)
  key <- tail(hotkey_split, 1)
  n <- length(hotkey_split)
  key_map <- c(
    "F1" = 122, "F2" = 120, "F3" = 99, "F4" = 118, "F5" = 96, "F6" = 97,
    "F7" = 98, "F8" = 100, "F9" = 101, "F10" = 109, "F11" = 103, "F12" = 111,
    "esc" = 53, "enter" = 36, "return" = 36, "delete" = 51, "backspace" = 51,
    "space" = 49, "tab" = 48, "left" = 123, "right" = 124, "down" = 125, "up" = 126,
    "home" = 115, "end" = 119, "page_down" = 121, "page_up" = 116
  )

  if (n > 1) {
    modifiers <- match.arg(modifiers, c("control", "command", "super", "shift", "fn", "option", "cmd", "shft", "ctrl", "alt"), several.ok = TRUE)
    modifiers[modifiers == "cmd"] <- "command"
    modifiers[modifiers == "ctrl"] <- "control"
    modifiers[modifiers == "shft"] <- "shift"
    modifiers[modifiers == "alt"] <- "option"
    modifiers[modifiers == "super"] <- "command"
    if (nchar(key) == 1) {
      cmd <- sprintf(
        'osascript -e \'tell application "System Events" to keystroke "%s" using {%s}\'',
        key,
        toString(paste(modifiers, "down"))
      )
    } else {
      key <- key_map[[key]]
      cmd <- sprintf(
        'osascript -e \'tell application "System Events" to key code %s using {%s}\'',
        key,
        toString(paste(modifiers, "down"))
      )
    }
  } else {
    if (nchar(key) == 1) {
      cmd <- sprintf(
        'osascript -e \'tell application "System Events" to keystroke "%s"\'',
        key
      )
    } else {
      key <- key_map[[key]]
      cmd <- sprintf(
        'osascript -e \'tell application "System Events" to key code %s\'',
        key
      )
    }
  }

  # Execute the AppleScript command
  system(cmd)
}

apple_move_cursor <- function(x, y) {
  cmd <- sprintf("cliclick m:%d,%d", x, y)
  system(cmd)
}

# Single left click at the current mouse position or at given coordinates
apple_left_click <- function(x = NULL, y = NULL) {
  cmd <- "cliclick p:"
  position <- system(cmd, intern = TRUE)
  coords <- unlist(strsplit(position, ","))
  if (is.null(x)) x <- coords[[1]]
  if (is.null(y)) y <- coords[[2]]
  cmd <- sprintf("cliclick c:%s,%s", x, y)
  system(cmd)
}

# Single right click at the current mouse position or at given coordinates
apple_right_click <- function(x = NULL, y = NULL) {
  cmd <- "cliclick p:"
  position <- system(cmd, intern = TRUE)
  coords <- unlist(strsplit(position, ","))
  if (is.null(x)) x <- coords[[1]]
  if (is.null(y)) y <- coords[[2]]
  cmd <- sprintf("cliclick rc:%s,%s", x, y)
  system(cmd)
}

# Double left click at the current mouse position or at given coordinates
apple_double_left_click <- function(x = NULL, y = NULL) {
  cmd <- "cliclick p:"
  position <- system(cmd, intern = TRUE)
  coords <- unlist(strsplit(position, ","))
  if (is.null(x)) x <- coords[[1]]
  if (is.null(y)) y <- coords[[2]]
  cmd <- sprintf("cliclick dc:%s,%s", x, y)
  system(cmd)
}

apple_get_cursor_position <- function() {
  cmd <- "cliclick p:"
  position <- system(cmd, intern = TRUE)
  coords <- unlist(strsplit(position, ","))
  list(x = as.integer(coords[1]), y = as.integer(coords[2]))
}

apple_open_app <- function(app, file = NULL) {
  if (is.null(file)) {
    cmd <- sprintf("open -a \"%s\"", app)
  } else {
    cmd <- sprintf("open -a \"%s\" \"%s\"", app, file)
  }
  system(cmd)
}







