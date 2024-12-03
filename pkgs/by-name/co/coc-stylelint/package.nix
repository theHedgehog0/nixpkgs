{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  nodejs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "coc-stylelint";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "neoclide";
    repo = "coc-stylelint";
    rev = "refs/tags/${finalAttrs.version}";
    hash = "sha256-EurfiE1xeJhyH4Idb/hf/eItwmv75lan1csz0KJMBXs=";
  };

  postPatch = ''
    substitute yarn.lock yarn.lock2 \
      --replace-fail 'http://' 'https://'
  '';

  patches = [ ./fix-yarnlock.patch ];

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    # Needed for executing package.json scripts
    nodejs
  ];

  meta = {
    description = "Stylelint language server extension for coc.nvim";
    homepage = "https://github.com/neoclide/coc-stylelint";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pyrox0 ];
  };
})
