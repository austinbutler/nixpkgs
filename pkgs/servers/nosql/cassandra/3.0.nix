{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "3.0.26";
  sha256 = "09wim1w2yizcqpja62jk64fhaw3jgnrgrjlrm4kgmcc3g3bsmw6i";
  generation = "3_0";
})
