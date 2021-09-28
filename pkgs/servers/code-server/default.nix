{ lib, stdenv, fetchFromGitHub, buildGoModule, makeWrapper, runCommand
, moreutils, jq, git, zip, rsync, pkg-config, yarn, python3
, nodejs-14_x, libsecret, xorg, ripgrep
, AppKit, Cocoa, Security, cctools }:

let
  system = stdenv.hostPlatform.system;

  nodejs = nodejs-14_x;
  python = python3;
  yarn' = yarn.override { inherit nodejs; };
  defaultYarnOpts = [ "frozen-lockfile" "non-interactive" "no-progress"];

in stdenv.mkDerivation rec {
  pname = "code-server";
  version = "3.12.0";
  commit = "c04198697698dc72b5981fd1b70d6ecbd9b22caa";

  src = fetchFromGitHub {
    owner = "cdr";
    repo = "code-server";
    rev = "v${version}";
    sha256 = "17v3sz0wjrmikmzyh9xswr4kf1vcj9njlibqb4wwj0pq0d72wdvl";
  };

  cloudAgent = buildGoModule rec {
    pname = "cloud-agent";
    version = "0.2.3";

    src = fetchFromGitHub {
      owner = "cdr";
      repo = "cloud-agent";
      rev = "v${version}";
      sha256 = "14i1qq273f0yn5v52ryiqwj7izkd1yd212di4gh4bqypmmzhw3jj";
    };

    vendorSha256 = "0k9v10wkzx53r5syf6bmm81gr4s5dalyaa07y9zvx6vv5r2h0661";

    postPatch = ''
      # the cloud-agent release tag has an empty version string, so add it back in
      substituteInPlace internal/version/version.go \
        --replace 'var Version string' 'var Version string = "v${version}"'
    '';
  };

  yarnCache = stdenv.mkDerivation {
    name = "${pname}-${version}-${system}-yarn-cache";
    inherit src;
    nativeBuildInputs = [ yarn' git ];
    buildPhase = ''
      export HOME=$PWD
      yarn config set yarn-offline-mirror $out
      find "$PWD" -name "yarn.lock" -printf "%h\n" | \
        xargs -I {} yarn --cwd {} \
          --frozen-lockfile --ignore-scripts --ignore-platform \
          --ignore-engines --no-progress --non-interactive
    '';
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";

    # to get hash values use nix-build -A code-server.prefetchYarnCache
    outputHash = {
      x86_64-linux = "1rlj5ja0ms0jdzagl3gi62wybn904f284xjpsd54lvpd5nl3d3ra";
      aarch64-linux = "1rlj5ja0ms0jdzagl3gi62wybn904f284xjpsd54lvpd5nl3d3ra";
      x86_64-darwin = "1rlj5ja0ms0jdzagl3gi62wybn904f284xjpsd54lvpd5nl3d3ra";
    }.${system} or (throw "Unsupported system ${system}");
  };

  # Extract the Node.js source code which is used to compile packages with
  # native bindings
  nodeSources = runCommand "node-sources" {} ''
    tar --no-same-owner --no-same-permissions -xf ${nodejs.src}
    mv node-* $out
  '';

  nativeBuildInputs = [
    nodejs yarn' python pkg-config zip makeWrapper git rsync jq moreutils
  ];
  buildInputs = lib.optionals (!stdenv.isDarwin) [ libsecret ]
    ++ (with xorg; [ libX11 libxkbfile ])
    ++ lib.optionals stdenv.isDarwin [
      AppKit Cocoa Security cctools
    ];

  patches = [
    # remove download of coder-cloud agent
    ./remove-cloud-agent-download.patch
  ];

  postPatch = ''
    export HOME=$PWD

    patchShebangs ./ci

    # remove unnecessary git config command
    #substituteInPlace lib/vscode/build/npm/postinstall.js \
    #  --replace "cp.execSync('git config pull.rebase true');" ""

    substituteInPlace ci/dev/postinstall.sh \
      --replace 'yarn' 'yarn --ignore-scripts'

    # use offline cache when installing release packages
    substituteInPlace ci/build/npm-postinstall.sh \
      --replace 'yarn --production' 'yarn --production --offline'

    # disable automatic updates
    echo "Disabling automatic updates"
    #sed -i '/update.mode/,/\}/{s/default:.*/default: "none",/g}' \
    #  lib/vscode/src/vs/platform/update/common/update.config.contribution.ts

    # inject git commit
    substituteInPlace ci/build/build-release.sh \
      --replace '$(git rev-parse HEAD)' "$commit"

    # remove all built-in extensions, as these are 3rd party extensions that
    # gets downloaded from vscode marketplace
    #jq --slurp '.[0] * .[1]' "lib/vscode/product.json" <(
    #  cat << EOF
    #{
    #  "builtInExtensions": []
    #}
    #EOF
    #) | sponge lib/vscode/product.json
  '';

  configurePhase = ''
    # run yarn offline by default
    echo '--install.offline true' >> .yarnrc

    # set default yarn opts
    ${lib.concatMapStrings (option: ''
      yarn --offline config set ${option}
    '') defaultYarnOpts}

    # set offline mirror to yarn cache we created in previous steps
    yarn --offline config set yarn-offline-mirror "${yarnCache}"

    # link coder-cloud agent from nix store
    ln -s "${cloudAgent}/bin/cloud-agent" ./lib/coder-cloud-agent

    # skip unnecessary electron download
    export ELECTRON_SKIP_BINARY_DOWNLOAD=1
  '' + lib.optionalString stdenv.isLinux ''
    # set nodedir, so we can build binaries later
    npm config set nodedir "${nodeSources}"
  '';

  buildPhase = ''
    # install code-server dependencies
    yarn --offline

    # install vscode dependencies without running script for all vscode packages
    # that require patching for postinstall scripts to succeed
    for d in lib/vscode lib/vscode/build; do
      yarn --offline --cwd $d --offline --ignore-scripts
    done

    # put ripgrep binary into bin, so postinstall does not try to download it
    find -name vscode-ripgrep -type d \
      -execdir mkdir -p {}/bin \; \
      -execdir ln -s ${ripgrep}/bin/rg {}/bin/rg \;

    # patch shebangs of everything, also cached files, as otherwise postinstall
    # will not be able to find /usr/bin/env, as it does not exist in sandbox
    patchShebangs .

    # Playwright is only needed for tests, we can disable it for builds.
    # There's an environment variable to disable downloads, but the package makes a breaking call to
    # sw_vers before that variable is checked.
    patch -p1 -i ${./playwright.patch}
  '' + ''
    # rebuild binaries, we use npm here, as yarn does not provide an alternative
    # that would not attempt to try to reinstall everything and break our
    # patching attempts
    npm rebuild --prefix lib/vscode --update-binary

    # run postinstall scripts, which eventually do yarn install on all
    # additional requirements
    yarn --cwd lib/vscode postinstall --frozen-lockfile --offline

    # build code-server
    yarn build

    # build vscode
    yarn build:vscode

    # create release
    yarn release
  '';

  installPhase = ''
    mkdir -p $out/libexec/code-server $out/bin

    # copy release to libexec path
    cp -R -T release "$out/libexec/code-server"

    # install only production dependencies
    yarn --offline --cwd "$out/libexec/code-server" --production

    # link coder-cloud agent from nix store
    ln -s "${cloudAgent}/bin/cloud-agent" $out/libexec/code-server/lib/coder-cloud-agent

    # create wrapper
    makeWrapper "${nodejs-14_x}/bin/node" "$out/bin/code-server" \
      --add-flags "$out/libexec/code-server/out/node/entry.js"
  '';

  passthru = {
    prefetchYarnCache = lib.overrideDerivation yarnCache (d: {
      outputHash = lib.fakeSha256;
    });
  };

  meta = with lib; {
    description = "Run VS Code on a remote server";
    longDescription = ''
      code-server is VS Code running on a remote server, accessible through the
      browser.
    '';
    homepage = "https://github.com/cdr/code-server";
    license = licenses.mit;
    maintainers = with maintainers; [ offline ];
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
  };
}
