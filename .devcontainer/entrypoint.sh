#!/bin/bash
if [[ -z "$FAST_USER_MODE" ]]; then
  # Install analyzer deps
  # Something up with spacy - the double install helps
  cd /workspaces/src/presidio/presidio-analyzer \
    && pipenv install --dev --sequential \
    && pipenv install spacy

  # Install go deps
  cd /workspaces/src/presidio \
    && echo "Running dep ensure..." \
    && dep ensure \
    && echo "Dep ensure ran."

else
  echo "[FUM]: Skipping dependency installation"
fi

# Restore top-level folder
cd /workspaces/src/presidio

$@
