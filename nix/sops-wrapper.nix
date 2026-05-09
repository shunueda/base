{
  writeShellApplication,
  sops,
  lib,
}:
{
  name,
  main,
  secrets,
  passthru ? { },
}:
writeShellApplication {
  inherit name passthru;
  runtimeInputs = [ sops ];
  text = ''
    exec sops exec-env ${secrets} "${lib.getExe main} $*"
  '';
}
