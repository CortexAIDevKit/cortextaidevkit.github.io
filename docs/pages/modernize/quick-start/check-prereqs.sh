#!/usr/bin/env bash
#
# Checks that this machine and the Maven project in the current folder are
# ready for the Java & Spring Boot modernization pipeline.
#
#   curl -fsSL <url>/check-prereqs.sh | bash                    check only
#   curl -fsSL <url>/check-prereqs.sh | bash -s -- --install    install anything missing
#
# Run it from your project root. Project checks run when the folder has a pom.xml.
# JDK_VERSION=25 sets the JDK that --install installs (default 21).

set -u

INSTALL=false
PROJECT_DIR=""
JDK_VERSION="${JDK_VERSION:-21}"

for arg in "$@"; do
  case "$arg" in
    --install) INSTALL=true ;;
    -h|--help)
      echo "Usage: check-prereqs.sh [--install] [project-dir]"
      echo "  Checks the tools the modernization pipeline needs, and the project in"
      echo "  project-dir (default: the current folder, if it has a pom.xml)."
      echo "  --install   install anything missing (JDK_VERSION=25 picks the JDK, default 21)"
      exit 0 ;;
    *) PROJECT_DIR="$arg" ;;
  esac
done

if [ -z "$PROJECT_DIR" ] && [ -f pom.xml ]; then PROJECT_DIR="$PWD"; fi

if [ -t 1 ]; then
  GREEN=$'\033[32m'; RED=$'\033[31m'; YELLOW=$'\033[33m'; BOLD=$'\033[1m'; RESET=$'\033[0m'
else
  GREEN=""; RED=""; YELLOW=""; BOLD=""; RESET=""
fi

ok()   { printf '  %s✔%s %-12s %s\n' "$GREEN" "$RESET" "$1" "$2"; }
fail() { printf '  %s✘%s %-12s %s\n' "$RED" "$RESET" "$1" "$2"; }
warn() { printf '  %s!%s %-12s %s\n' "$YELLOW" "$RESET" "$1" "$2"; }
have() { command -v "$1" >/dev/null 2>&1; }

MISSING=0

# ---------------------------------------------------------------- installers

PM=""
if have brew; then PM=brew
elif have apt-get; then PM=apt
elif have dnf; then PM=dnf
fi

SUDO=""
if [ "$(id -u 2>/dev/null || echo 0)" != "0" ] && have sudo; then SUDO=sudo; fi
APT_UPDATED=false

pkg_install() {
  # $1 = brew package, $2 = apt package, $3 = dnf package
  case "$PM" in
    brew) brew install "$1" ;;
    apt)
      if [ "$APT_UPDATED" = false ]; then $SUDO apt-get update -y; APT_UPDATED=true; fi
      $SUDO apt-get install -y "$2" ;;
    dnf) $SUDO dnf install -y "$3" ;;
    *) echo "    No supported package manager (brew, apt, dnf) found. Install it manually."; return 1 ;;
  esac
}

install_tool() {
  case "$1" in
    claude) curl -fsSL https://claude.ai/install.sh | bash ;;
    java)
      pkg_install "openjdk@$JDK_VERSION" "openjdk-$JDK_VERSION-jdk" "java-$JDK_VERSION-openjdk-devel"
      if [ "$PM" = brew ]; then
        echo "    Add it to your PATH: export PATH=\"$(brew --prefix)/opt/openjdk@$JDK_VERSION/bin:\$PATH\""
      fi ;;
    mvn)     pkg_install maven maven maven ;;
    git)     pkg_install git git git ;;
    jq)      pkg_install jq jq jq ;;
    python3) pkg_install python3 python3 python3 ;;
    grype)
      if [ "$PM" = brew ]; then brew install grype
      else curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | $SUDO sh -s -- -b /usr/local/bin
      fi ;;
  esac
}

# --------------------------------------------------------------------- tools

version_of() {
  case "$1" in
    java)  java -version 2>&1 | head -n 1 ;;
    mvn)   mvn -B -v 2>/dev/null | head -n 1 | sed $'s/\033\[[0-9;]*m//g' ;;
    grype) grype version 2>/dev/null | awk '/^Version:/ {print $2}' ;;
    *)     "$1" --version 2>/dev/null | head -n 1 ;;
  esac
}

check_tool() {
  # $1 = command, $2 = required|optional, $3 = why it is needed
  local cmd="$1" level="$2" why="$3"
  if ! have "$cmd" && [ "$INSTALL" = true ]; then
    echo "    Installing $cmd..."
    install_tool "$cmd" || true
    hash -r
  fi
  if have "$cmd"; then
    ok "$cmd" "$(version_of "$cmd")"
  elif [ "$level" = optional ]; then
    warn "$cmd" "not found (optional: $why)"
  else
    fail "$cmd" "not found ($why)"
    MISSING=$((MISSING + 1))
  fi
}

echo "${BOLD}Tools${RESET}"
check_tool claude  required "runs the pipeline"
check_tool git     required "isolates builds in worktrees"
check_tool java    required "builds your project"
if [ -n "$PROJECT_DIR" ] && [ -x "$PROJECT_DIR/mvnw" ] && ! have mvn; then
  ok "mvn" "using the project's ./mvnw"
else
  check_tool mvn   required "builds your project"
fi
check_tool jq      required "reads the pipeline's state files"
check_tool python3 required "writes reports and edits pom.xml"
check_tool grype   optional "vulnerability scan is skipped without it"

if (( BASH_VERSINFO[0] < 3 )); then
  fail "bash" "$BASH_VERSION is too old"
  MISSING=$((MISSING + 1))
else
  ok "bash" "$BASH_VERSION"
fi

if have mvn; then
  MVN_JAVA="$(mvn -B -v 2>/dev/null | awk -F': ' '/^Java version/ {print $2}' | cut -d, -f1)"
  [ -n "$MVN_JAVA" ] && echo "  Maven runs on Java $MVN_JAVA. It must be at least your target Java version."
fi

# ------------------------------------------------------------------- project

if [ -n "$PROJECT_DIR" ]; then
  echo
  echo "${BOLD}Project: $PROJECT_DIR${RESET}"
  if [ -f "$PROJECT_DIR/pom.xml" ]; then
    ok "pom.xml" "found at the project root"
  else
    fail "pom.xml" "not found. Point the script at the folder that contains pom.xml"
    MISSING=$((MISSING + 1))
  fi
  if [ -e "$PROJECT_DIR/.git" ]; then
    ok "git repo" ".git is next to pom.xml"
  else
    fail "git repo" "no .git next to pom.xml. Run git init in the project root"
    MISSING=$((MISSING + 1))
  fi
  if [ -e "$PROJECT_DIR/CLAUDE.md" ] || [ -e "$PROJECT_DIR/.claude" ]; then
    warn "CLAUDE.md" "CLAUDE.md or .claude/ already exists. Back them up before installing the pipeline"
  fi
fi

# ------------------------------------------------------------------- summary

echo
if [ "$MISSING" -eq 0 ]; then
  echo "${GREEN}${BOLD}Ready.${RESET} Everything required is in place."
else
  echo "${RED}${BOLD}$MISSING required item(s) missing.${RESET}"
  [ "$INSTALL" = false ] && echo "Fix the items above. Missing tools can be installed by re-running with --install."
  exit 1
fi
