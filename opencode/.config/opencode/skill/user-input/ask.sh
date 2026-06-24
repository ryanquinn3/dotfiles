#!/usr/bin/env bash
RETURN_PANE=$1
MANIFEST=$2

declare -a ANSWERS
COUNT=$(jq 'length' "$MANIFEST")

for i in $(seq 0 $((COUNT - 1))); do
  MARKDOWN=$(jq -r ".[$i].markdown" "$MANIFEST")
  TYPE=$(jq -r ".[$i].type" "$MANIFEST")

  echo "$MARKDOWN" | glow -

  case "$TYPE" in
    choose)
      OPTIONS=()
      while IFS= read -r line; do OPTIONS+=("$line"); done < <(jq -r ".[$i].options[]" "$MANIFEST")
      ANSWER=$(gum choose "${OPTIONS[@]}")
      ;;
    checkbox)
      OPTIONS=()
      while IFS= read -r line; do OPTIONS+=("$line"); done < <(jq -r ".[$i].options[]" "$MANIFEST")
      ANSWER=$(gum choose --no-limit "${OPTIONS[@]}" | tr '\n' ',' | sed 's/,$//')
      ;;
    input)
      PLACEHOLDER=$(jq -r ".[$i].placeholder // \"\"" "$MANIFEST")
      ANSWER=$(gum input --placeholder "$PLACEHOLDER")
      ;;
    write)
      ANSWER=$(gum write)
      ;;
    confirm)
      gum confirm "$(jq -r ".[$i].prompt // \"Confirm?\"" "$MANIFEST")" && ANSWER="yes" || ANSWER="no"
      ;;
  esac

  ANSWERS+=("$ANSWER")
done

if [ ${#ANSWERS[@]} -eq 1 ]; then
  RESULT="${ANSWERS[0]}"
else
  RESULT=""
  for i in "${!ANSWERS[@]}"; do
    if [ -n "$RESULT" ]; then RESULT+=" | "; fi
    RESULT+="$((i+1)): ${ANSWERS[$i]}"
  done
fi

tmux send-keys -t "$RETURN_PANE" "$RESULT" Enter
tmux kill-pane
