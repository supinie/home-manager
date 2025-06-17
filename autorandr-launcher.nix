{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  pkgs,
  xorg,
}:

stdenv.mkDerivation rec {
  pname = "autorandr-launcher";
  version = "1.15"; # Update as needed

  src = fetchFromGitHub {
    owner = "phillipberndt";
    repo = "autorandr";
    rev = "1.15"; # Or a release tag like "1.14"
    sha256 = "sha256-8FMfy3GCN4z/TnfefU2DbKqV3W35I29/SuGGqeOrjNg="; # Replace with the actual hash!
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    xorg.libX11
    xorg.libxcb
    xorg.libXrandr
  ];

  sourceRoot = "${src.name}/contrib/autorandr_launcher";

  patchPhase = ''
    substituteInPlace autorandr_launcher.c \
      --replace-fail /usr/bin/autorandr ${pkgs.autorandr}/bin/autorandr
    substituteInPlace makefile \
      --replace 'USER_DEFS="-DAUTORANDR_PATH=\"$(shell which autorandr 2>/dev/null)\""' \
      'USER_DEFS="-DAUTORANDR_PATH=\"${pkgs.autorandr}/bin/autorandr\""'
  '';

  configurePhase = ''
    cat autorandr_launcher.c
    cat makefile
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp autorandr-launcher $out/bin/
  '';
}
