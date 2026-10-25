{ inputs, ... }:
{
  imports = [
    # inputs.nixvim.homeManager.nixvim
    inputs.nixvim.homeModules.default
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;

    globals.have_nerd_font = true;

    luaLoader.enable = true;

    globals.mapleader = " ";

    keymaps = [
      {
        mode = "n";
        key = "<leader>sf";
        action = "<cmd>Telescope find_files<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>sg";
        action = "<cmd>Telescope live_grep<CR>";
        options.silent = true;
      }

      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Oil<CR>";
        options.silent = true;
      }

      {
        mode = "n";
        key = "<leader>ca";
        action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
        options.desc = "LSP Code Action (Extract/Inline)";
      }
      {
        mode = "n";
        key = "<leader>tt";
        action = "<cmd>lua require('neotest').run.run()<CR>";
        options.desc = "Run nearest test";
      }
      {
        mode = "n";
        key = "<leader>tf";
        action = "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>";
        options.desc = "Run tests in file";
      }
      {
        mode = "";
        key = "<leader>f";
        action.__raw = ''
            function()
            require('conform').format { async = true, lsp_fallback = true }
          end
        '';
        options = {
          desc = "[F]ormat buffer";
        };
      }
    ];

    opts = {
      number = true;
      relativenumber = true;
      wrap = false;
      cursorline = true;
      signcolumn = "yes";
      showmode = false;
      scrolloff = 8;
      sidescrolloff = 5;

      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      autoindent = true;
      smartindent = true;

      ignorecase = true;
      smartcase = true;
      incsearch = true;
      hlsearch = true;

      swapfile = false;
      writebackup = false;
      undofile = true;

      splitright = true;
      splitbelow = true;

      list = true;
      listchars = {
        tab = "» ";
        trail = "·";
        nbsp = "␣";
      };
    };

    plugins = {
      oil = {
        enable = true;
      };

      treesitter = {
        enable = true;
        settings.highlight.enable = true;
      };

      lsp = {
        enable = true;
        servers = {
          ts_ls.enable = true;
          cssls.enable = true;
          svelte.enable = true;
          jsonls.enable = true;
          nixd.enable = true;
          gopls.enable = true;
          clangd.enable = true;
        };
        keymaps = {
          lspBuf = {
            "K" = "hover";
            "gd" = "definition";
            "gr" = "references";
            "<leader>rn" = "rename";
          };
        };
      };

      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = {
            lsp_format = "fallback";
            timeout_ms = 1500;
          };
          formatters_by_ft = {
            go = [
              "goimports"
              "gofmt"
            ];
            nix = [ "nixfmt" ];
            c = [ "clang-format" ];
          };
        };
      };

      neotest = {
        enable = true;
        adapters.go.enable = true;
      };

      blink-cmp = {
        enable = true;
        settings = {
          keymap = {
            # Disable the preset so it doesn't conflict with our manual bindings
            preset = "none";

            # Manually trigger the completion menu
            "<C-space>" = [
              "show"
              "show_documentation"
              "hide_documentation"
            ];

            # The Classic Vim Completion Bindings
            "<C-n>" = [
              "select_next"
              "fallback"
            ];
            "<C-p>" = [
              "select_prev"
              "fallback"
            ];
            "<C-y>" = [ "select_and_accept" ];

            # Cancel/Hide the completion menu
            "<C-e>" = [
              "hide"
              "fallback"
            ];

            # Snippet navigation (since Tab is no longer doing this)
            "<C-k>" = [
              "snippet_forward"
              "fallback"
            ];
            "<C-j>" = [
              "snippet_backward"
              "fallback"
            ];
          };
          completion = {
            # Automatically show documentation window for the selected item
            documentation.auto_show = true;
          };
        };
      };

      gitsigns = {
        enable = true;
        settings = {
          attach_to_untracked = true;
          current_line_blame = true;
          current_line_blame_opts = {
            delay = 0;
            virt_text_post = "eol";
          };
        };
      };

      lazygit = {
        enable = true;
        settings = {
          floating_window_winblend = 0;
          floating_window_scaling_factor = 0.9;
        };
      };

      telescope = {
        enable = true;
        extensions."fzf-native" = {
          enable = true; # enable fzf-native extension
          settings = {
            fuzzy = true;
            override_file_sorter = true;
            override_generic_sorter = true;
            case_mode = "smart_case";
          };
        };
        settings = {
          defaults = {
            layout_config = {
              prompt_position = "top";
            };
            sorting_strategy = "ascending";
          };
          pickers.find_files.hidden = true;
        };
      };

      "indent-blankline" = {
        enable = true;
        settings = {
          indent = {
            char = "▏";
            tab_char = "▏";
          };
          scope = {
            enabled = true;
            show_start = true;
            show_end = false;
          };
        };
      };

      "web-devicons".enable = true;
    };

    colorschemes.nightfox = {
      enable = true;
      # Flavours: carbonfox, dawnfox, dayfox, duskfox, nightfox, nordfox, terafox.
      # The module emits `colorscheme <flavor>` itself, so there is no separate
      # top-level `colorscheme` option any more.
      flavor = "nordfox";
      # Transparent Normal/NormalNC/WinBar so the terminal's background (and the
      # compositor blur behind it) shows through NeoVim.
      settings.options.transparent = true;
    };

    # Nightfox keeps these opaque even with transparent = true.
    extraConfigLua = ''
      for _, g in ipairs({
        "NormalFloat",
        "FloatBorder",
        "CursorLine",
        "StatusLine",
        "StatusLineNC",
        "WinSeparator",
      }) do
        local hl = vim.api.nvim_get_hl(0, { name = g, link = false })
        hl.bg = nil
        vim.api.nvim_set_hl(0, g, hl)
      end
    '';
  };
}
