self: super:
let
  cargoBuild = file: attrs: (
    self.callPackage file {
    }).rootCrate.build;
in
  {

    crashcart = cargoBuild ./cli/Cargo.nix {};
    builder   = self.callPackage ./builder/default.nix {
      inherit (self) dockerTools;
    };

  }
