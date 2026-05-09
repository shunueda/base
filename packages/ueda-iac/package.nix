{ sopsWrapper, nix2terraform }:
let
  name = "ueda-iac";

  main = nix2terraform {
    inherit name;
    mainTf = import ./main.tf.nix;
  };
in
sopsWrapper {
  inherit name main;
  secrets = ../../secrets/common.yaml;
}
