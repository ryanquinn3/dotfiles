tmux_current_session(){
  tmux display-message -p '#S'
}

tmux_new_window() {
  tmux new-window -t "$(tmux_current_session)" -n "$1" "$2"
}

# The fzf window switcher (tmux_fzf_window / tjump) moved to the launcher
# package: ~/.zsh/launcher.zsh + ~/.zsh/launcher.d/tmux.zsh. `tjump` now aliases
# the generic launcher there.

tmux_rename() {
    # Safety check: Ensure we are actually inside a tmux session
    if [ -z "$TMUX" ]; then
        echo "❌ Error: You must be inside a tmux session to run this." >&2
        return 1
    fi

    # 1. Interactively choose what to rename
    local target
    target=$(gum choose --header "What do you want to rename?" "Session" "Window" "Pane")

    # Exit cleanly if the user escapes or cancels
    [ -z "$target" ] && return 0

    # 2. Fetch the current name to use as a default value
    local current_name=""
    case "$target" in
        Session) current_name=$(tmux display-message -p '#S') ;;
        Window)  current_name=$(tmux display-message -p '#W') ;;
        Pane)    current_name=$(tmux display-message -p '#T') ;;
    esac

    # 3. Prompt for the new name (pre-filled with the current name)
    local new_name
    new_name=$(gum input --value "$current_name" --placeholder "Enter new $target name...")

    # Exit if the user clears the input or cancels
    [ -z "$new_name" ] && return 0

    # 4. Execute the appropriate tmux rename command
    case "$target" in
        Session)
            tmux rename-session "$new_name"
            gum log --level info "Renamed session to: $new_name"
            ;;
        Window)
            tmux rename-window "$new_name"
            gum log --level info "Renamed window to: $new_name"
            ;;
        Pane)
            tmux select-pane -T "$new_name"
            gum log --level info "Renamed pane title to: $new_name"
            ;;
    esac
}

# Optional: Alias it to something quick and memorable
alias trn="tmux_rename"

tmux_open_code() {
  tmux_new_window "opencode" "opencode"
}
alias oc="tmux_open_code"


# Get information on current tmux pane, window, and session. Supports --json flag for structured output.
tmux_info() {
    if [ -z "$TMUX" ]; then
        gum log --level error "Not inside a tmux session."
        return 1
    fi

    # key|tmux-format-string pairs
    local fmt='session|#S
session_id|#{session_id}
windows|#{session_windows}
window|#I: #W
window_id|#{window_id}
pane|#P
pane_id|#D
pane_pid|#{pane_pid}
command|#{pane_current_command}
path|#{pane_current_path}
size|#{pane_width}x#{pane_height}
client|#{client_termname} (#{client_width}x#{client_height})'

    local rows
    rows=$(tmux display-message -p "$fmt")

    if [ "$1" = "--json" ]; then
        echo "$rows" | jq -R 'split("|") | {(.[0]): .[1]}' | jq -s 'add'
        return
    fi

    # escape underscores so glamour doesn't treat them as italics
    echo "$rows" | awk -F'|' '{ gsub(/_/, "\\_", $1); print "- **" $1 "**: " $2 }' | gum format
}
alias tinfo="tmux_info"
