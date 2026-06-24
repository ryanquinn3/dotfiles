dl(){
  if [[ $1 == *"soundcloud.com"* ]]; then
    yt-dlp -x --audio-format mp3 -o "~/Music/%(uploader)s - %(title)s.%(ext)s" $1
  else
    youtube-dl -x --audio-format mp3 -o "~/Music/%(title)s.%(ext)s" $1
  fi
}
