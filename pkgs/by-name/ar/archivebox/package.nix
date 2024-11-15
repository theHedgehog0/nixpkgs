{
  lib,
  stdenv,
  python3,
  fetchFromGitHub,
  curl,
  wget,
  git,
  ripgrep,
  postlight-parser,
  readability-extractor,
  chromium,
  yt-dlp,
}:

let
  python = python3.override {
    self = python;
    packageOverrides = _: super: {
      django = super.django_5;
      django-extensions = super.django-extensions.overridePythonAttrs {
        # Django 5.1 compat issues
        # https://github.com/django-extensions/django-extensions/issues/1885
        doCheck = false;
      };
      bx-django-utils = super.bx-django-utils.overridePythonAttrs {
        # Upstream has test cases for django 5.0 and 4.2 for these tests, but not 5.1, so they have to be disabled here.
        # Note that this isn't a direct dependency, but a dependency chain.
        # archivebox <- django-huey-monitor <- manage-django-project <- django-tools <- bx-django-utils
        disabledTests = [
          "test_index_page"
          "test_basic"
          "test_assert_html_response_snapshot"
        ];
      };
      manage-django-project = super.manage-django-project.overridePythonAttrs (old: {
        # Same reason and dependency chain as above, no Django 5.1 test snapshots so this test fails.
        disabledTests = (old.disabledTests or [ ]) ++ [
          "test_help"
        ];
      });
      django-taggit = super.django-taggit.overridePythonAttrs rec {
        version = "6.1.0";
        src = fetchFromGitHub {
          owner = "jazzband";
          repo = "django-taggit";
          rev = "refs/tags/${version}";
          hash = "sha256-QLJhO517VONuf+8rrpZ6SXMP/WWymOIKfd4eyviwCsU=";
        };
      };
    };
  };
in

python.pkgs.buildPythonApplication rec {
  pname = "archivebox";
  version = "0.8.6rc0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ArchiveBox";
    repo = "ArchiveBox";
    rev = "refs/tags/v${version}";
    hash = "sha256-scZZnzgl+tKx/Ee2QkFePBXv1+xeZj2fvk324ay0cdw=";
  };

  nativeBuildInputs = with python.pkgs; [
    pdm-backend
    hatchling
    uv
  ];

  buildPhase = ''
    runHook preBuild

    export UV_NO_CACHE=1
    export UV_PYTHON_DOWNLOADS=never
    export UV_PYTHON=${python.interpreter}
    export UV_NO_BUILD_ISOLATION=1
    uv build --offline --wheel --all

    runHook postBuild
  '';

  dontCheckRuntimeDeps = true;

  propagatedBuildInputs =
    with python.pkgs;
    [
      # Core Libraries
      django
      # Tests do not pass in the Nix build environment, so disable them.
      # It still works properly
      (django-ninja.overridePythonAttrs { doCheck = false; })
      django-extensions
      mypy-extensions
      typing-extensions
      channels
      daphne
      django-signal-webhooks
      django-admin-data-views
      django-object-actions
      django-charid-field
      django-pydantic-field
      django-jsonform
      django-stubs
      django-huey
      django-huey-monitor
      # Helper Libraries
      pluggy
      requests
      dateparser
      tzdata
      feedparser
      w3lib
      rich
      rich-argparse
      ulid-py
      typeid-python
      psutil
      supervisor
      python-crontab
      croniter
      ipython
      py-machineid
      python-benedict
      pydantic-settings
      atomicwrites
      django-taggit
      base32-crockford
      platformdirs
      pydantic-pkgr
      pocket
      sonic-client
      yt-dlp

    ]
    ++ lib.flatten (lib.attrValues python.pkgs.python-benedict.optional-dependencies);

  optional-dependencies = {
    ldap = with python.pkgs; [
      python-ldap
      django-auth-ldap
    ];
    debug = with python.pkgs; [
      django-debug-toolbar
      djdt-flamegraph
      ipdb
      requests-tracker
      django-autotyping
    ];
  };


  makeWrapperArgs = [
    "--set USE_NODE True" # used through dependencies, not needed explicitly
    "--set READABILITY_BINARY ${lib.meta.getExe readability-extractor}"
    "--set MERCURY_BINARY ${lib.meta.getExe postlight-parser}"
    "--set CURL_BINARY ${lib.meta.getExe curl}"
    "--set RIPGREP_BINARY ${lib.meta.getExe ripgrep}"
    "--set WGET_BINARY ${lib.meta.getExe wget}"
    "--set GIT_BINARY ${lib.meta.getExe git}"
    "--set YOUTUBEDL_BINARY ${lib.meta.getExe yt-dlp}"
  ] ++ (if (lib.meta.availableOn stdenv.hostPlatform chromium) then [
    "--set CHROME_BINARY ${chromium}/bin/chromium-browser"
  ] else [
    "--set-default USE_CHROME False"
  ]);

  meta = with lib; {
    description = "Open source self-hosted web archiving";
    homepage = "https://archivebox.io";
    license = licenses.mit;
    maintainers = with maintainers; [
      siraben
      viraptor
    ];
    platforms = platforms.unix;
  };
}
