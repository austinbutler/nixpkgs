# nixpkgs `prek` wrapper and Python-support packaging plan

## Goal

Make nixpkgs `prek` work correctly for installed Git hooks, including hooks run
outside the original `nix develop` shell, while keeping Python hook support
opt-in to avoid increasing the default closure.

The key packaging issue is that `prek install` can write the wrong executable
path into `.git/hooks/pre-commit`. If a Nix wrapper sets the correct runtime
environment but upstream `prek` writes the unwrapped binary path into the hook,
Git later bypasses the wrapper. That can cause Python hooks to download and run
a generic Linux `uv`, which does not execute on NixOS.

Related context:

- `NixOS/nixpkgs#500949`: adds runtime dependency groups for `prek`, including
  an opt-in Python group.
- `j178/prek#1707`: upstream NixOS `uv` failure caused by downloaded generic
  Linux `uv`.
- Planned upstream `prek` PR: add `PREK_PATH` so packagers can control the
  executable path embedded in generated hooks.

## Intended package behavior

Default `pkgs.prek`:

- Provides a wrapped `prek` executable.
- Ensures `git` is on `PATH` at runtime.
- Sets `PREK_PATH` to the wrapped public executable path so `prek install`
  writes hooks that call the wrapper, not the hidden unwrapped binary.
- Does not include Python hook runtime dependencies by default.

`pkgs.prek.override { withPythonSupport = true; }`:

- Includes default runtime behavior above.
- Also puts nixpkgs `uv` and `python312` on `PATH`.
- Allows Python-based hooks to create environments without falling back to a
  managed downloaded `uv`.

## Implementation details

Edit `pkgs/by-name/pr/prek/package.nix`.

Add inputs:

```nix
makeWrapper,
withPythonSupport ? false,
```

Define runtime dependency groups near the top:

```nix
let
  pythonRuntimeDeps = [
    python312
    uv
  ];

  runtimeDeps = [
    git
  ] ++ lib.optionals withPythonSupport pythonRuntimeDeps;
in
```

Update `nativeBuildInputs`:

```nix
nativeBuildInputs = [
  installShellFiles
  makeWrapper
];
```

Keep `nativeCheckInputs` for build/check tools. It can include `git`,
`python312`, and `uv` as before.

Wrap `prek` after installation:

```nix
postInstall = ''
  wrapProgram "$out/bin/prek" \
    --prefix PATH : ${lib.makeBinPath runtimeDeps} \
    --set PREK_PATH "$out/bin/prek"
'' + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
  installShellCompletion --cmd prek \
    --bash <(COMPLETE=bash $out/bin/prek) \
    --fish <(COMPLETE=fish $out/bin/prek) \
    --zsh <(COMPLETE=zsh $out/bin/prek)
'';
```

If completions should be generated from the unwrapped binary to avoid wrapper
side effects, preserve the original `postInstall` completion command before
wrapping or call the hidden wrapped target. Prefer the simplest version first
unless tests show a problem.

Temporary upstream patch:

- Until upstream `prek` releases `PREK_PATH`, add a patch in the nixpkgs package
  that implements the upstream plan:
  - `PREK_PATH` env var constant.
  - `install.rs` uses install-time `PREK_PATH` instead of `current_exe()` when
    present.
  - hook template uses runtime `PREK_PATH` override:

```sh
PREK="${PREK_PATH:-[PREK_PATH]}"
```

- Add a comment above the patch:

```nix
# TODO: remove after prek releases the upstream PREK_PATH hook executable
# override. This lets the nixpkgs wrapper be the path embedded in generated
# Git hooks instead of the hidden unwrapped binary.
```

Avoid `propagatedBuildInputs` for this fix unless nixpkgs maintainers strongly
prefer it. Propagated dependencies help inside Nix environments but do not by
themselves fix Git hooks run outside the shell; the wrapper is the important
part.

## Tests

Build tests:

```sh
nix-build -A prek
nix-build -E 'with import ./. {}; prek.override { withPythonSupport = true; }'
```

Functional hook-path test:

1. Build `prek.override { withPythonSupport = true; }`.
2. Create a temporary Git repo with a minimal `.pre-commit-config.yaml`.
3. Run the built `prek/bin/prek install`.
4. Inspect `.git/hooks/pre-commit`.
5. Assert the hook defaults to the public wrapped `$out/bin/prek`, not the
   hidden wrapped target or unwrapped binary.

Functional Python-hook test:

1. Use a cold `PREK_HOME`.
2. Use a config with a Python hook from `pre-commit-hooks`, such as
   `check-shebang-scripts-are-executable` or `trailing-whitespace`.
3. Run the built `prek/bin/prek run <hook-id> --files <test-file>`.
4. Confirm the hook succeeds.
5. Confirm no managed generic Linux `uv` appears under `$PREK_HOME/tools/uv/uv`
   when `withPythonSupport = true`.

Outside-shell test:

1. Run `prek install` in an environment where the wrapper is available.
2. Invoke `.git/hooks/pre-commit` with a minimal `PATH` that does not include
   `uv`, `python`, or `git` except through the wrapper's baked runtime `PATH`.
3. Confirm the hook still finds Nix `git`, `uv`, and Python through the wrapper.

Suggested nixpkgs review command:

```sh
nixpkgs-review pr <PR_NUMBER>
```

## Pull request framing

Title suggestion:

```text
prek: wrap runtime dependencies and support Python hooks opt-in
```

PR summary:

- `prek` needs `git` at runtime.
- Python hooks need a compatible `uv` and Python.
- On NixOS, `prek`'s managed downloaded `uv` may not execute because it expects
  a conventional dynamic loader path.
- Runtime dependency propagation is not sufficient for installed Git hooks run
  outside the originating Nix shell.
- Wrap `prek` so hooks call a stable Nix entrypoint with the required runtime
  `PATH`.
- Carry a temporary upstream `PREK_PATH` patch so `prek install` embeds the
  wrapper path rather than the hidden unwrapped binary.

Mention `NixOS/nixpkgs#500949`:

- This PR builds on the dependency-group direction from `#500949`.
- It adds the missing wrapper/hook behavior raised by review feedback asking
  whether the package was tested outside a `nix-shell`.

Compatibility notes:

- `withPythonSupport` defaults to `false`.
- Users who need Python hooks can use:

```nix
prek.override { withPythonSupport = true; }
```

- Once upstream `prek` releases `PREK_PATH`, remove the temporary patch and keep
  the wrapper/package logic.
