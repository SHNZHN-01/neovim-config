{
  symlinkJoin,
  neovim-unwrapped,
  makeWrapper,
  runCommandLocal,
  vimPlugins,
  lib,
  src,
  # Lua
  emmylua-ls,
  emmylua-check,
  stylua,
  # Nix
  nixd,
  nixfmt,
  statix,
  deadnix,
  # C/C++
  clang,
  clang-tools,
  # Python
  ruff,
  ty,
  # Bash
  bash-language-server,
  shellcheck,
  shfmt,
  # JavaScript/TypeScript
  vtsls,
  vscode-langservers-extracted,
  prettierd,
  vscode-js-debug,
  nodejs,
  # Tools the plugins call, and the debuggers' runtimes
  stdenv,
  ripgrep,
  git,
  imagemagick,
  xclip,
  wl-clipboard,
  python3,
  delve,
  go,
}:
let
  packageName = "neovim-shnzhn";

  # The Python debugger's adapter (dap_python.lua): a Python with debugpy.
  # The program itself runs with the project's Python (its venv, or the
  # python3 on PATH).
  debugpyPython = python3.withPackages (ps: [ ps.debugpy ]);

  # Put after the user's PATH, not before: a machine's or project's own
  # versions win (its git and its config, a dev shell's node or go), these
  # only fill in where it has none.
  fallbackDeps = [
    ripgrep # Telescope's live grep
    git # git pickers, gitsigns, git-conflict, project_diagnostics
    imagemagick # image.nvim (magick)
    nodejs # the program the JS/TS debugger runs (dap_js.lua)
    debugpyPython # python3 for the Python debugger's program, if none
    delve # dlv: the Go debugger (dap_go.lua)
    go # dlv builds the program it debugs
  ]
  # the system clipboard (clipboard=unnamedplus) and img-clip: X11, Wayland
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    xclip
    wl-clipboard
  ];

  runtimeDeps = [
    # Lua
    emmylua-ls
    emmylua-check
    stylua
    # Nix
    nixd
    nixfmt
    statix
    deadnix
    # C/C++
    clang
    clang-tools
    # Python
    ruff
    ty
    # Bash
    bash-language-server
    shellcheck
    shfmt
    # JavaScript/TypeScript
    vtsls
    vscode-langservers-extracted # vscode-eslint-language-server
    prettierd
    vscode-js-debug # js-debug
  ];

  startPlugins = [
    vimPlugins.telescope-nvim
    vimPlugins.telescope-fzf-native-nvim
    vimPlugins.nvim-treesitter-textobjects
    vimPlugins.plenary-nvim
    vimPlugins.nvim-treesitter.withAllGrammars
    vimPlugins.nvim-autopairs
    vimPlugins.nvim-ts-autotag
    vimPlugins.nvim-cmp
    vimPlugins.cmp-nvim-lsp
    vimPlugins.cmp-buffer
    vimPlugins.cmp-path
    vimPlugins.cmp-nvim-lua
    vimPlugins.cmp_luasnip
    vimPlugins.cmp-cmdline
    vimPlugins.nvim-dap
    vimPlugins.nvim-dap-go
    vimPlugins.nvim-dap-python
    vimPlugins.nvim-dap-disasm
    vimPlugins.nvim-dap-ui
    vimPlugins.git-conflict-nvim
    vimPlugins.gitsigns-nvim
    vimPlugins.hardtime-nvim
    vimPlugins.image-nvim
    vimPlugins.img-clip-nvim
    vimPlugins.indent-blankline-nvim
    vimPlugins.lualine-nvim
    vimPlugins.luasnip
    vimPlugins.markdown-preview-nvim
    vimPlugins.nabla-nvim
    vimPlugins.neogen
    vimPlugins.no-neck-pain-nvim
    vimPlugins.nvim-highlight-colors
    vimPlugins.nvterm
    vimPlugins.nvim-surround
    vimPlugins.telescope-file-browser-nvim
    vimPlugins.conform-nvim
    vimPlugins.opencode-nvim
  ];

  foldPlugins = builtins.foldl' (
    acc: next:
    acc
    ++ [
      next
    ]
    ++ (foldPlugins (next.dependencies or [ ]))
  ) [ ];

  startPluginsWithDeps = lib.unique (foldPlugins startPlugins);

  # A derivation whose output is a valid Neovim packpath:
  #
  #   $out/pack/neovim-shnzhn/start/telescope.nvim -> /nix/store/...-telescope...
  #   $out/pack/neovim-shnzhn/start/plenary.nvim   -> /nix/store/...-plenary...
  #   $out/pack/neovim-shnzhn/opt/                    (empty)
  #
  # concatMapStringsSep generates one `ln` shell line per plugin:
  #   * ${plugin} coerces the derivation to its store path
  #   * lib.getName strips the version suffix so the symlink gets a clean
  #     name (telescope.nvim, not telescope.nvim-2024-xx-xx)
  #   * ln flags: -v verbose, -s symbolic, -f force,
  #     -T treat dest as the link itself (never descend into a dir)
  packpath = runCommandLocal "packpath" { } ''
    mkdir -p $out/pack/${packageName}/{start,opt}

    ${lib.concatMapStringsSep "\n" (
      plugin: "ln -vsfT ${plugin} $out/pack/${packageName}/start/${lib.getName plugin}"
    ) startPluginsWithDeps}
  '';
in
symlinkJoin {
  name = "neovim-shnzhn";
  paths = [ neovim-unwrapped ];
  meta.mainProgram = "nvim";
  # Build-time-only dependency providing `wrapProgram`.
  nativeBuildInputs = [ makeWrapper ];

  # wrapProgram moves the real binary to .nvim-wrapped and drops in a
  # shell script that injects flags before any user-supplied args.
  # The language tools go before the user's PATH, fallbackDeps after it.
  postBuild = ''
    wrapProgram $out/bin/nvim \
      --add-flags '-u' \
      --add-flags '${src}/init.lua' \
      --add-flags '--cmd' \
      --add-flags "'set packpath^=${packpath} | set runtimepath^=${packpath},${src}'" \
      --prefix PATH : ${lib.makeBinPath runtimeDeps} \
      --suffix PATH : ${lib.makeBinPath fallbackDeps} \
      --set-default NVIM_SHNZHN_DEBUGPY_PYTHON ${lib.getExe debugpyPython} \
      --set-default NVIM_APPNAME nvim-shnzhn
  '';

  # Expose the packpath derivation on the final package without
  # affecting the build. Handy for inspection:
  #   nix build .#neovim-shnzhn.packpath && ls -l result/pack/*/start
  passthru = {
    inherit packpath;
  };
}
