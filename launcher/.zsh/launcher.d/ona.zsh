# ona (gitpod) environments — launcher plugin. Mac-only (lives in the launcher
# package, never stowed on ona/cde), so no IS_ON_ONA guard needed.
#
# Prints one row per gitpod env that has NO live local tmux session bound to it:
#   - stopped env            -> row; exec starts it, then ssh-attaches.
#   - running, not bound      -> row; exec ssh-attaches (start is a no-op).
#   - running, session bound  -> NOTHING; the tmux plugin already shows it.
#
# Binding is by tmux SESSION name `ona-<short>` (<short> = first UUID segment).
# The exec creates a detached local session with that name and switches to it;
# detection is `tmux has-session`. Connecting is a local session (not a window in
# the current session) so it stands alone and the tmux plugin lists it normally.
#
# Safety (the core evals EXEC; fzf evals PREVIEW/ALT): the only value reaching a
# command field is the env id (UUID: hex + dashes, injection-safe). branch/repo
# are repo-influenced, so they appear ONLY in DISPLAY and are control-stripped.

# Defined unconditionally — the spawned session re-sources THIS file (in a fresh
# `zsh -c`, where _LAUNCHER_DELIM is unset) purely to obtain this helper.
_ona_connect() {
  local id=$1 host="${1}.gitpod.environment"
  if [[ $(gitpod env get "$id" -f phase) != "running" ]]; then
    gum spin --spinner dot --title "Starting $id" -- gitpod env start "$id"
  fi
  echo "Connecting to ${host}..."
  ssh -tt "$host" "tmux new-session -A -s main"
  # reset mouse reporting that the remote session may have left on
  [[ -t 1 ]] && print -n -- $'\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1015l'
  exec zsh   # keep the session's window alive as a shell after disconnect
}

# Emit rows only when sourced by the launcher core (it sets _LAUNCHER_DELIM,
# inherited by the emit subshell). The helper re-source above leaves it unset;
# return 0 (not the failed test's 1) so `source … && _ona_connect` still runs.
[[ -n $_LAUNCHER_DELIM ]] || return 0

local d=$_LAUNCHER_DELIM
gitpod env list -o json 2>/dev/null \
  | jq -r '.[] | [
      .id,
      (.status.phase // "" | sub("ENVIRONMENT_PHASE_";"") | ascii_downcase),
      (.status.content.git.branch // "?"),
      (.status.content.git.cloneUrl // "" | sub("\\.git$";"") | split("/") | last)
    ] | join("\u001e")' \
  | while IFS=$'\x1e' read -r id phase branch repo; do
      local short=${id%%-*}
      # running + a local session already bound -> tmux plugin shows it; skip.
      if [[ $phase == running ]] && tmux has-session -t "=ona-$short" 2>/dev/null; then
        continue
      fi
      branch=${branch//[[:cntrl:]]/ }   # repo-influenced -> sanitize for DISPLAY
      repo=${repo//[[:cntrl:]]/ }
      local disp
      # leading icon (cloud, magenta) + branch/phase/repo padded to the shared
      # grid widths so columns align with other plugins' rows.
      disp=$(printf "\033[35m%s\033[0m  \033[36m%-${_LAUNCHER_COLW[1]}s\033[0m \033[90m%-${_LAUNCHER_COLW[2]}s\033[0m \033[32m%-${_LAUNCHER_COLW[3]}s\033[0m" \
        $'\uf0c2' "$branch" "$phase" "$repo")
      local preview="gitpod env get $id"
      # detached local session named ona-<short>; stamp it @is_remote 1 so the
      # tmux.conf pane-focus-in hook drops into "dumb terminal" mode (no local
      # prefix/status/key-table) on entry and passes keys through to the remote
      # tmux; then switch the client to it. quote the =name target on switch: a
      # leading '=' forces exact match but would also trigger zsh EQUALS filename
      # expansion when the core evals this string, hence both quoted and =.
      # set-option's -t rejects the '=' prefix, so the stamp targets the bare
      # name (unambiguous: <short> is a full UUID segment).
      local exec="tmux new-session -d -s ona-$short \"zsh -c 'source ~/.zsh/launcher.d/ona.zsh && _ona_connect $id'\" \\; set-option -t \"ona-$short\" @is_remote 1 \\; switch-client -t \"=ona-$short\""
      local alt=":"
      [[ $phase == running ]] && alt="gitpod env stop $id"
      print -r -- "$disp$d$preview$d$exec$d$alt"
    done
