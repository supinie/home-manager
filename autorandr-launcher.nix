{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  autorandr,
  libx11,
  libxcb,
  libxrandr,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "autorandr-launcher";
  version = "1.15";

  src = fetchFromGitHub {
    owner = "phillipberndt";
    repo = "autorandr";
    tag = finalAttrs.version;
    hash = "sha256-8FMfy3GCN4z/TnfefU2DbKqV3W35I29/SuGGqeOrjNg=";
  };

  sourceRoot = "${finalAttrs.src.name}/contrib/autorandr_launcher";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    libx11
    libxcb
    libxrandr
  ];

  postPatch = ''
    substituteInPlace autorandr_launcher.c \
      --replace-fail /usr/bin/autorandr ${lib.getExe autorandr}
    substituteInPlace makefile \
      --replace-fail 'USER_DEFS="-DAUTORANDR_PATH=\"$(shell which autorandr 2>/dev/null)\""' \
      'USER_DEFS="-DAUTORANDR_PATH=\"${lib.getExe autorandr}\""'
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 autorandr-launcher -t $out/bin
    runHook postInstall
  '';

  meta = {
    description = "Daemon that runs autorandr when monitors are connected or disconnected";
    homepage = "https://github.com/phillipberndt/autorandr";
    license = lib.licenses.gpl3Plus;
    mainProgram = "autorandr-launcher";
    platforms = lib.platforms.linux;
  };
})
