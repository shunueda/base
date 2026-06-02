{
  writeShellApplication,
  fzf,
  nix-search-tv,
}:

writeShellApplication {
  name = "ns";
  runtimeInputs = [
    fzf
    nix-search-tv
  ];
  text = ''
    nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history
  '';
}
