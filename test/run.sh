#!/bin/sh
# Run the test suite headless in Vim and, if installed, Neovim.
set -eu
cd "$(dirname "$0")/.."
status=0
if command -v vim >/dev/null 2>&1; then
  echo "== $(vim --version | head -n 1)"
  vim -Nu NONE -i NONE -es -S test/test_foldtext.vim </dev/null 2>&1 || status=1
  echo
fi
if command -v nvim >/dev/null 2>&1; then
  echo "== $(nvim --version | head -n 1)"
  nvim --clean --headless -S test/test_foldtext.vim </dev/null 2>&1 || status=1
fi
[ "$status" -eq 0 ] && echo "All tests passed." || echo "Some tests FAILED."
exit "$status"
