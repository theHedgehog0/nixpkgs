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
  pname = "cdktf-cli";
  version = "0.20.10";

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "terraform-cdk";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-IXYHhG8qBDE6G8hW/IxVVAFZXQRrbaOzJH9lsQY3guI=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-hkjsVpgvOY6JLxDcgV4eDwVyufHuTUdbmVOISELACY4=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    # Needed for executing package.json scripts
    nodejs
  ];

  meta = {
    # ...
  };
})
