{
  runCommand,
  terraform,
  writeShellApplication,
}:

# Wrapper to package a Nix-expressed Terraform configuration.
#
# Mainly does two things:
#  1. Converts configuration defined as Nix-attrset into `main.tf.json`.
#  2. Prepopulates `.terraform` directory in Nix sandboxed nix builder to
#     eliminate local states and ensure reproducibility. Normally,
#     `terraform init` must be run before any Terraform operations (apply,
#     validate, etc.) to populate `.terraform`, but it is a major source of
#     impurity: it requires internet access to download providers / modules etc,
#     and leaves a  stateful `.terraform` directory in the project that must be
#     re-run manually whenever the config changes.
#
# Assumes cloud backend and doesn't support local backend. Very easy but I don't
# use it and I'm lazy.
#
# Example:
# ```nix
# { nix2terraform }:
#
# nix2terraform {
#   name = "my-infra";
#   mainTf = { ... };
# }
# ```
#
# Usage:
#
# `$ op run -- nix run .#my-infra -- apply`
#
# etc.
#
# TODO: support OpenTofu after nixpkgs-terraform-providers-bin reliably supports
# it.
# https://github.com/nix-community/nixpkgs-terraform-providers-bin/issues/52

{ name, mainTf }:

let
  dotTerraform =
    let
      tfState = {
        # TODO: Assumes the version - is there a nicer way? It doesn't even
        # have to be eval-time.
        version = 3;
        backend = {
          type = "cloud";
          config = mainTf.terraform.cloud;
        };
      };
    in
    runCommand "dot-terraform"
      {
        nativeBuildInputs = [ terraform ];

        mainTfJson = builtins.toJSON mainTf;
        lockJson = builtins.toJSON tfState;

        workspaceName = tfState.backend.config.workspaces.name;

        passAsFile = [
          "mainTfJson"
          "lockJson"
        ];
      }
      ''
        mkdir -p $out

        cp $mainTfJsonPath $out/main.tf.json

        # `-get=false` prevents internet access, and `backend=false` makes
        # Terraform assume local backend and skip the backend initialization,
        # which requires internet.
        terraform -chdir=$out init -get=false -backend=false

        # Manually populate the cloud backend config.
        cp $lockJsonPath $out/.terraform/terraform.tfstate

        # Not sure why Terraform can't infer this from `main.tf.json` 🤷
        echo "$workspaceName" > $out/.terraform/environment
      '';
in
writeShellApplication {
  inherit name;
  runtimeInputs = [ terraform ];
  text = ''
    exec terraform -chdir=${dotTerraform} "$@"
  '';
}
