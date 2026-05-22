{
  writeShellApplication,
  sops,
  typst,
  ...
}:

writeShellApplication {
  name = "ueda-cv";
  runtimeInputs = [
    sops
    typst
  ];
  text = ''
    typst compile ${./cv.typ} - \
      --format pdf \
      --ignore-system-fonts \
      --input data="$(sops --decrypt ${../../secrets/cv.yaml})"
  '';
}
