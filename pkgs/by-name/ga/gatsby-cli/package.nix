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
  pname = "gatsby-cli";
  version = "5.14.0";

  src = fetchFromGitHub {
    owner = "gatsbyjs";
    repo = "gatsby";
    rev = "refs/tags/gatsby-cli@${finalAttrs.version}";
    hash = "sha256-5RnECvAY3lh1fQ0v0R+8etp/flZ1Oalconjdvr5MC4M=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-1jWfku0Sp80Z0Ql68/mizvG+coPXOCDFLarbql/zfq4=";
  };

  yarnBuildScript = "workspace";
  yarnBuildFlags = [
    "gatsby-cli"
    "run"
    "build"
  ];

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    # Needed for executing package.json scripts
    nodejs
  ];

  preInstall = ''
    cd packages/gatsby-cli
  '';

  meta = {
    changelog = "https://github.com/gatsbyjs/gatsby/releases/tag/gatsby%2540${finalAttrs.version}";
    description = "The Gatsby command line interface";
    homepage = "https://github.com/gatsbyjs/gatsby/tree/master/packages/gatsby-cli#readme";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pyrox0 ];
    mainProgram = "gatsby";
  };
})
