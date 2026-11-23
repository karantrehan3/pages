#!/usr/bin/env bash
# Manage public pages served by GitHub Pages from this repo.
#   page.sh add <file.html> <slug>   copy a page to <slug>/index.html
#   page.sh default <slug>           make the site root redirect to <slug>/
#   page.sh remove <slug>            delete a page (refuses if it is the default)
#   page.sh list                     list pages, marking the default
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SLUG_RE='^[a-z0-9][a-z0-9-]*$'

die() { echo "error: $*" >&2; exit 1; }
check_slug() { [[ "$1" =~ $SLUG_RE ]] || die "slug must be lowercase letters, digits, dashes: '$1'"; }
current_default() { sed -n 's/.*data-default="\([^"]*\)".*/\1/p' "$ROOT/index.html" 2>/dev/null | head -1; }

cmd="${1:-}"; shift || true
case "$cmd" in
  add)
    [[ $# -eq 2 ]] || die "usage: page.sh add <file.html> <slug>"
    [[ -f "$1" ]] || die "no such file: $1"
    check_slug "$2"
    mkdir -p "$ROOT/$2"
    cp "$1" "$ROOT/$2/index.html"
    echo "added $2/  (run 'page.sh default $2' to make it the root page)"
    ;;
  default)
    [[ $# -eq 1 ]] || die "usage: page.sh default <slug>"
    check_slug "$1"
    [[ -f "$ROOT/$1/index.html" ]] || die "page '$1' does not exist"
    cat > "$ROOT/index.html" <<HTML
<!doctype html>
<html lang="en" data-default="$1">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Redirecting…</title>
<meta http-equiv="refresh" content="0; url=$1/">
<link rel="canonical" href="$1/">
<script>location.replace("$1/" + location.search + location.hash)</script>
</head>
<body><p><a href="$1/">Continue</a></p></body>
</html>
HTML
    echo "default page is now $1/"
    ;;
  remove)
    [[ $# -eq 1 ]] || die "usage: page.sh remove <slug>"
    check_slug "$1"
    [[ "$(current_default)" != "$1" ]] || die "'$1' is the default; set another default first"
    [[ -d "$ROOT/$1" ]] || die "page '$1' does not exist"
    rm -r "$ROOT/$1"
    echo "removed $1/"
    ;;
  list)
    def="$(current_default)"
    for d in "$ROOT"/*/index.html; do
      [[ -e "$d" ]] || continue
      s="$(basename "$(dirname "$d")")"
      [[ "$s" == scripts ]] && continue
      [[ "$s" == "$def" ]] && echo "$s  (default)" || echo "$s"
    done
    ;;
  *) die "usage: page.sh {add <file> <slug> | default <slug> | remove <slug> | list}" ;;
esac
