starship init fish | source

fish_add_path "$ASDF_DIR/bin"
fish_add_path "$HOME/.asdf/shims"

if status --is-interactive && type -q asdf
  source (brew --prefix asdf)/libexec/asdf.fish
end
