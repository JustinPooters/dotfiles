# cross-shell .NET TFM detector for bash/zsh
_update_dotnet_version() {
  local here tfm file first
  here="$(pwd)"

  # If at ~/Development root, clear it (like your pwsh logic)
  if [ "$here" = "$HOME/Development" ]; then
    export DOTNET_VERSION=""
    return
  fi

  # find nearest *.csproj in current dir, else one level deep
  first="$(find . -maxdepth 1 -type f -name '*.csproj' -print -quit)"
  if [ -z "$first" ]; then
    first="$(find . -maxdepth 2 -type f -name '*.csproj' -print -quit)"
  fi
  if [ -z "$first" ]; then
    export DOTNET_VERSION=""
    return
  fi

  # extract TargetFramework OR TargetFrameworks
  tfm="$(grep -oE '<TargetFrameworks?>[^<]+' "$first" | sed -E 's/<TargetFrameworks?>//')"
  # if multiple, split by ';'
  tfm="$(echo "$tfm" | tr ';' '\n' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '/^$/d' | sort -Vr | head -n1)"
  export DOTNET_VERSION="$tfm"
}

# Hook into prompt:
# bash: PROMPT_COMMAND
if [ -n "$BASH_VERSION" ]; then
  case "$PROMPT_COMMAND" in
    *"_update_dotnet_version"* ) : ;; # already added
    * ) PROMPT_COMMAND="_update_dotnet_version; $PROMPT_COMMAND" ;;
  esac
fi

# zsh: precmd hook
if [ -n "$ZSH_VERSION" ]; then
  precmd_functions+=(_update_dotnet_version)
fi
