{
  gitMinimal,
  prek,
  python312,
  runCommand,
}:
{
  hook-path =
    runCommand "prek-hook-path"
      {
        nativeBuildInputs = [
          gitMinimal
          prek
        ];
      }
      ''
        cd "$(mktemp --directory)"
        export HOME="$PWD"

        git config --global user.email "you@example.com"
        git config --global user.name "Your Name"
        git init --initial-branch=main

        cat > .pre-commit-config.yaml <<'EOF'
        repos:
          - repo: local
            hooks:
              - id: echo
                name: echo
                entry: echo
                language: system
                always_run: true
                pass_filenames: false
        EOF

        prek install

        if ! grep -F "${prek}/bin/prek" .git/hooks/pre-commit > /dev/null; then
          echo "ERROR: hook does not reference the wrapper at ${prek}/bin/prek" >&2
          cat .git/hooks/pre-commit >&2
          exit 1
        fi

        if grep -F ".prek-wrapped" .git/hooks/pre-commit > /dev/null; then
          echo "ERROR: hook leaks the hidden wrapped binary path" >&2
          cat .git/hooks/pre-commit >&2
          exit 1
        fi

        # Prove the embedded path actually executes the hook.
        git commit --allow-empty -m "test"

        touch $out
      '';

  python-hook =
    let
      prekWithPython = prek.override { withPythonSupport = true; };
    in
    runCommand "prek-python-hook"
      {
        nativeBuildInputs = [
          gitMinimal
          prekWithPython
        ];
      }
      ''
        cd "$(mktemp --directory)"
        export HOME="$PWD"
        export PREK_HOME="$PWD/prek-home"
        mkdir -p "$PREK_HOME"

        git config --global user.email "you@example.com"
        git config --global user.name "Your Name"
        git init --initial-branch=main

        # language_version is pinned to nix's python so uv gets `--python
        # <store-path>` and does not need to discover managed Python
        # installations. That discovery probes /bin/sh, /usr/bin/env, etc.
        # for an ELF interpreter, which the FHS-free build sandbox lacks.
        cat > .pre-commit-config.yaml <<EOF
        repos:
          - repo: local
            hooks:
              - id: pyhook
                name: pyhook
                entry: python -c "import sys; sys.exit(0)"
                language: python
                language_version: ${python312}/bin/python3
                always_run: true
                pass_filenames: false
        EOF

        git add .pre-commit-config.yaml

        # Sandbox PATH already excludes uv/python (they are not in
        # nativeBuildInputs), so this run only succeeds if the wrapper's
        # PATH augmentation makes nix's uv visible to prek.
        prek run --all-files

        if [ -e "$PREK_HOME/tools/uv/uv" ]; then
          echo "ERROR: prek downloaded a managed uv at $PREK_HOME/tools/uv/uv" >&2
          echo "       The wrapper should have surfaced nix's uv instead." >&2
          exit 1
        fi

        touch $out
      '';
}
