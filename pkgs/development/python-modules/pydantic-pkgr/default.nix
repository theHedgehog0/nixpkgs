{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pdm-backend,
  typing-extensions,
  platformdirs,
  pydantic,
  pydantic-core,
  pytestCheckHook,
  yt-dlp,
}:

buildPythonPackage rec {
  pname = "pydantic-pkgr";
  version = "0.5.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ArchiveBox";
    repo = "pydantic-pkgr";
    rev = "refs/tags/v${version}";
    hash = "sha256-RSUse0dEv1MQBpCGrW78Y0d8V+3L8KGtb47ht6IVqbg=";
  };

  build-system = [
    pdm-backend
  ];

  dependencies = [
    typing-extensions
    platformdirs
    pydantic
    pydantic-core
  ];

  # Tests require network access
  doCheck = false;

  pythonImportsCheck = [ "pydantic_pkgr" ];

  meta = {
    changelog = "https://github.com/ArchiveBox/pydantic-pkgr/releases/tag/v${version}";
    description = "Modern Python library for managing system dependencies with package managers like apt, brew, pip, npm, etc.";
    homepage = "https://github.com/ArchiveBox/pydantic-pkgr";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pyrox0 ];
  };
}
