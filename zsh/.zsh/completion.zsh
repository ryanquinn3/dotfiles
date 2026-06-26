# Cache a tool's zsh completion into $fpath once, as _<cmd> so compinit autoloads
# it (next shell). Regenerate by deleting the file. Extra args override the
# generator when it isn't the conventional `<cmd> completion zsh`.
gen_completion() {
    local cmd=$1; shift
    command -v "$cmd" &>/dev/null || return
    mkdir -p "$ZSH_COMPLETIONS_DIR"
    local out="$ZSH_COMPLETIONS_DIR/_$cmd"
    [ -f "$out" ] && return
    if (( $# )); then "$@" > "$out"; else "$cmd" completion zsh > "$out"; fi
}

# extract the contiguous leading comment block above a function definition.
# add a comment directly above any function to document it here / in previews.
fn_doc() {
    local fn=$1
    zmodload zsh/parameter 2>/dev/null
    local src=${functions_source[$fn]}
    [ -n "$src" ] || return 1
    awk -v fn="$fn" '
        /^[[:space:]]*#/ { buf = buf $0 "\n"; next }
        $0 ~ "^[[:space:]]*(function[[:space:]]+)?" fn "[[:space:]]*\\(\\)" { printf "%s", buf; exit }
        { buf = "" }
    ' "$src" | sed -E 's/^[[:space:]]*#[[:space:]]?//'
}

# show docs for a binary: tldr, then man, then --help as a last resort
# (--help actually executes the binary, so it's only used when nothing else exists)
bin_help() {
    local bin=$1 out
    if command -v tldr >/dev/null 2>&1; then
        out=$(tldr --color always "$bin" 2>/dev/null)
        [ -n "$out" ] && { print -r -- "$out"; return; }
    fi
    if man "$bin" >/dev/null 2>&1; then
        man "$bin" 2>/dev/null | col -bx | head -200
        return
    fi
    "$bin" --help </dev/null 2>&1 | head -200
}

# preview helper for fzf-tab command-name completion (see .zshrc fzf-preview)
cmd_preview() {
    local word=$1
    case "$(whence -w -- "$word" 2>/dev/null | cut -d' ' -f2)" in
        alias)    echo "alias: $(whence -- "$word")" ;;
        function)
            local doc=$(fn_doc "$word")
            [ -n "$doc" ] && print -r -- $'\e[1m'"$doc"$'\e[0m\n'
            whence -f -- "$word" | head -200
            ;;
        builtin)  echo "$word: shell builtin" ;;
        reserved) echo "$word: reserved word" ;;
        command)
            print -r -- $'\e[1m'"$(whence -- "$word")"$'\e[0m\n'
            bin_help "$word"
            ;;
        *)        whence -v -- "$word" ;;
    esac
}
