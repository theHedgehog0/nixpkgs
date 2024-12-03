{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "browser-sync";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "BrowserSync";
    repo = "browser-sync";
    rev = "v${version}";
    hash = "sha256-AQZfSdzAGsLnZf7q5YWy5v4W4Iv3f0s4eOV1tC7yhXw=";
  };

  npmWorkspace = "browser-sync";

  npmDepsHash = "sha256-LVnTLf8aKnBmrWI4MciGc/QuQV8JJYesxsRoAw3jbTs=";

  meta = {
    description = "Modern web UI for various torrent clients with a Node.js backend and React frontend";
    homepage = "https://flood.js.org";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ winter ];
  };
}
