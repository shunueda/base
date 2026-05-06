{ ... }:
{
  perSystem.treefmt = {
    programs = {
      # keep-sorted start block=yes
      actionlint.enable = true;
      autocorrect.enable = true;
      keep-sorted.enable = true;
      mdformat = {
        enable = true;
        settings = {
          wrap = 80;
        };
      };
      nixfmt = {
        enable = true;
        strict = true;
      };
      shellcheck.enable = true;
      typos.enable = true;
      # keep-sorted end
    };
    settings.global.excludes = [ "*/gen/*" ];
  };
}
