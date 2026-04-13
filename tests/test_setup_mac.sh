#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash -n "$repo_root/scripts/setup-mac.sh"

output="$("$repo_root/scripts/setup-mac.sh" --help)"

grep -q "TARGET_HOME" <<<"$output"
grep -q "DRY_RUN" <<<"$output"
grep -q "font-maple-mono-nf-cn" <<<"$output"
grep -q "MonacoLigaturizedNerdFont.zip" <<<"$output"
grep -q "~/Library/Fonts" <<<"$output"
grep -q "com.googlecode.iterm2.plist" <<<"$output"
grep -q ".zshrc.local" <<<"$output"

dry_run_log="$(mktemp)"
TARGET_HOME="$(mktemp -d)" DRY_RUN=1 "$repo_root/scripts/setup-mac.sh" >"$dry_run_log" 2>&1
grep -q "MonacoLigaturizedNerdFont.zip" "$dry_run_log"
grep -q "Library/Fonts" "$dry_run_log"
if grep -q "No such file or directory" "$dry_run_log"; then
  cat "$dry_run_log" >&2
  exit 1
fi
