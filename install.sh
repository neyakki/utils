#!/usr/bin/env bash

set -e

chmod +x ./bash_scripts/*

for file in ./bash_scripts/*.sh; do
    cp "$file" "$HOME/.local/bin/$(basename ${file%.sh})"
done

chmod +x ./python_scripts/*
for file in ./python_scripts/*.py; do
    cp "$file" "$HOME/.local/bin/$(basename ${file%.py})"
done

chmod -x ./bash_scripts/*
chmod -x ./python_scripts/*
