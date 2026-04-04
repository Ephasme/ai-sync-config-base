set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default:
    @just --list

release bump:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{bump}}" in
      major|minor|patch) ;;
      *) echo "Usage: just release major|minor|patch" >&2; exit 1 ;;
    esac
    current=$(git tag --sort=-v:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -1 | sed 's/^v//')
    if [[ -z "$current" ]]; then
      echo "No existing semver tag found. Creating v0.1.0" >&2
      current="0.0.0"
    fi
    IFS='.' read -r major minor patch <<< "$current"
    case "{{bump}}" in
      major) version="$((major+1)).0.0" ;;
      minor) version="$major.$((minor+1)).0" ;;
      patch) version="$major.$minor.$((patch+1))" ;;
    esac
    echo "Releasing v$version ({{bump}} bump from v$current)"
    git tag -a "v$version" -m "v$version"
    git push origin "v$version"
