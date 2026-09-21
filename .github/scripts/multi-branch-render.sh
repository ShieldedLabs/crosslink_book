#! /usr/bin/env bash
set -efuo pipefail

SCRIPT_NAME="$(basename "$0")"

PAGES_BRANCH='gh-pages'
PAGES_DIR='docs'
PAGES_INDEX="${PAGES_DIR}/index.html"
PAGES_BRANCHES="${PAGES_DIR}/branches"

RENDERED_DIR="book"

function main
{
  [[ $# -eq 0 ]] || usage-error "unexpected arguments: $*"
  expect-git-clean

  local to_render
  to_render="$(get-current-branch '!=')"

  switch-to-pages-branch "$to_render"
  commit-spliced-merge "$to_render"
  render-latest-branch "$to_render"
  generate-index > "$PAGES_INDEX"

  git add "$PAGES_DIR"
  git commit -m "Update multi-branch index with \"$to_render\" rendering."
  git-show-tip

  sed 's/^    //' <<__EOF

    -=*=- Success! -=*=-

    Note: you are now on the "$PAGES_BRANCH" tip. Have a nice day!

__EOF
}

## Top-level steps as functions
function expect-git-clean
{
  local dirty
  dirty="$(
    git status \
      --porcelain=v1 \
      --untracked-files=all \
      | tee /dev/stderr
  )"

  [[ -z "$dirty" ]] || usage-error 'dirty worktree'

  local tl
  tl="$(git rev-parse --show-toplevel)"

  local pwd
  pwd="$(pwd -P)"

  [[ "$tl" == "$pwd" ]] \
   || usage-error "expected to be in working tree root \"$tl\" rather than \"$pwd\""
}

function get-current-branch
{
  [[ $# -eq 1 ]] && local op="$1"

  local branch
  branch="$(git branch --show-current)"

  local binop=("$branch" "$op" "$PAGES_BRANCH")

  [[ "${binop[@]}" ]] \
    || usage-error "expected current branch ${binop[*]}"

  echo "$branch"
}

function switch-to-pages-branch
{
  [[ $# -eq 1 ]] && local to_render="$1"

  if ! git switch "$PAGES_BRANCH" 2> /dev/null
  then
    initialize-pages-branch "$to_render"
  fi
}

function initialize-pages-branch
{
  [[ $# -eq 1 ]] && local to_render="$1"

  git switch --orphan "$PAGES_BRANCH"
  mkdir "$PAGES_DIR"

  local mbrstub
  mbrstub='multi-branch-render stub'

  sed 's/^    //' > "$PAGES_INDEX" << __EOF
    <html>
      <head><title>${mbrstub}</title></head>
      <body>${mbrstub}; stay tuned!</body>
    </html>
__EOF

  git restore --source="$to_render" \
    --staged --worktree \
    -- .gitignore

  touch .nojekyll

  git add "$PAGES_INDEX" .gitignore .nojekyll
  git commit -m "initial \"$PAGES_BRANCH\" stub"

  # Give the user an understanding of the stub:
  git-show-tip
}

function commit-spliced-merge
{
  [[ $# -eq 1 ]] && local to_render="$1"

  # precondition checks:
  get-current-branch '==' > /dev/null # We're on the pages branch
  expect-git-clean

  # Overlay everything from "$to_render" _except_ the docs dir which is "owned" by "$PAGES_BRANCH":
  git restore --source="$to_render" \
    --staged --worktree \
    -- . ":!${PAGES_DIR}"

  git add .

  local tree
  tree="$(git write-tree)"

  local msg="merge ${to_render} contents into ${PAGES_BRANCH} (without render update)"

  local commit
  commit="$(
    git commit-tree "$tree" \
      -p "$PAGES_BRANCH" \
      -p "$to_render" \
      -m "$msg"
  )"

  git update-ref -m "merge ${to_render} (custom): $msg" HEAD "$commit"
}

function render-latest-branch
{
  [[ $# -eq 1 ]] && local to_render="$1"

  echo "Rendering the \"$to_render\" contents..."
  command -v mdbook > /dev/null \
    || usage-error 'expected `mdbook` on PATH; run inside the configured Nix environment'
  rmdir-recursive-if-there "$RENDERED_DIR"
  if book-configures-mermaid-preprocessor
  then
    command -v mdbook-mermaid > /dev/null \
      || usage-error 'expected `mdbook-mermaid` on PATH; run inside the configured Nix environment'
    mdbook-mermaid install
  fi
  mdbook build

  local render_path="$PAGES_BRANCHES/$to_render"

  rmdir-recursive-if-there "$render_path"
  mkdir -p "$(dirname "$render_path")"
  mv "$RENDERED_DIR" "$render_path"
}

function generate-index
{
  sed 's/^    //' <<__EOF
    <html>
      <head>
        <title>multi-branch renders</title>
      </head>
      <body>
        <ul>
__EOF

  for b in $(ls "$PAGES_BRANCHES" | sort)
  do
    echo "      <li><a href=\"./branches/${b}/index.html\">${b}</a></li>"
  done

  sed 's/^    //' <<__EOF
        </ul>
      </body>
    </html>
__EOF
}

## Reusable utilities
function git-show-tip
{
  echo 'Created commit:'
  git --no-pager log -1
}

function rmdir-recursive-if-there
{
  [[ $# -eq 1 ]]
  if [[ -d "$1" ]]
  then
    rm -r "$1"
  fi
}

function book-configures-mermaid-preprocessor
{
  [[ $# -eq 0 ]]
  [[ -f book.toml ]] || return 1

  python3 - <<'__EOF'
import pathlib
import re
import sys

book_toml = pathlib.Path("book.toml").read_text(encoding="utf-8")

try:
    import tomllib
except ImportError:
    has_mermaid = any(
        re.match(r"^\s*\[preprocessor\.mermaid\]\s*(?:#.*)?$", line)
        for line in book_toml.splitlines()
    )
else:
    try:
        book = tomllib.loads(book_toml)
    except Exception:
        has_mermaid = False
    else:
        has_mermaid = "mermaid" in book.get("preprocessor", {})

sys.exit(0 if has_mermaid else 1)
__EOF
}

function usage-error
{
  {
    echo -en '\nincorrect usage: '
    echo "$@"
    echo
  } >&2

  exit 1
}

main "$@"
