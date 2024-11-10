{
  lib,
  buildGoModule,
  chromium,
  fetchFromGitHub,
  libreoffice,
  makeBinaryWrapper,
  pdftk,
  qpdf,
  unoconv,
  mktemp,
  makeFontsConf,
  liberation_ttf_v2,
  exiftool,
  pdfcpu,
  nixosTests,
  nix-update-script,
}:
let
  fontsConf = makeFontsConf { fontDirectories = [ liberation_ttf_v2 ]; };
  jre' = libreoffice.unwrapped.jdk;
  libreoffice' = "${libreoffice}/lib/libreoffice/program/soffice.bin";
  inherit (lib) getExe;
in
buildGoModule rec {
  pname = "gotenberg";
  version = "8.13.0";

  src = fetchFromGitHub {
    owner = "gotenberg";
    repo = "gotenberg";
    rev = "refs/tags/v${version}";
    hash = "sha256-ooKemeeEmHtPwvnKofTEb8XR9mz6ayxww3Sy7HiU3zg=";
  };

  vendorHash = "sha256-bflfZX7AX/B5KAkhz3v3HjKJ6ccwxOtRkqKKJ6NZ1zI=";

  postPatch = ''
    find ./pkg -name '*_test.go' -exec sed -i -e 's#/tests#${src}#g' {} \;
  '';

  nativeBuildInputs = [ makeBinaryWrapper ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/gotenberg/gotenberg/v8/cmd.Version=${version}"
  ];

  checkInputs = [
    chromium
    libreoffice
    pdftk
    qpdf
    unoconv
    pdfcpu
    mktemp
    jre'
  ];

  preCheck = ''
    export CHROMIUM_BIN_PATH=${getExe chromium}
    export PDFTK_BIN_PATH=${getExe pdftk}
    export QPDF_BIN_PATH=${getExe qpdf}
    export UNOCONVERTER_BIN_PATH=${getExe unoconv}
    export EXIFTOOL_BIN_PATH=${getExe exiftool}
    export PDFCPU_BIN_PATH=${getExe pdfcpu}
    # LibreOffice needs all of these set to work properly
    export LIBREOFFICE_BIN_PATH=${libreoffice'}
    export FONTCONFIG_FILE=${fontsConf}
    export HOME=$(mktemp -d)
    export JAVA_HOME=${jre'}
  '';

  checkFlags =
    let
      skippedTests = [
        # These tests fail with a panic, so disable them.
        "TestChromiumBrowser_screenshot"
        "TestChromiumBrowser_pdf"
        # Require network access
        "TestNewContext"
      ];
    in
    [
      "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$"
    ];

  preFixup = ''
    wrapProgram $out/bin/gotenberg \
      --set PDFTK_BIN_PATH "${getExe pdftk}" \
      --set QPDF_BIN_PATH "${getExe qpdf}" \
      --set UNOCONVERTER_BIN_PATH "${getExe unoconv}" \
      --set EXIFTOOL_BIN_PATH "${getExe exiftool}" \
      --set PDFCPU_BIN_PATH "${getExe pdfcpu}" \
      --set JAVA_HOME "${jre'}"
  '';

  passthru.updateScript = nix-update-script { };
  passthru.tests = {
    inherit (nixosTests) gotenberg;
  };

  meta = {
    description = "Converts numerous document formats into PDF files";
    mainProgram = "gotenberg";
    homepage = "https://gotenberg.dev";
    changelog = "https://github.com/gotenberg/gotenberg/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pyrox0 ];
  };
}
