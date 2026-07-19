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

    colorscheme = "nightfox";

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
        action = "<cmd>Explore<CR>";
        options.silent = true;
      }
    ];

    opts =  {
      number = true;
      relativenumber = true;
      wrap = false;
      cursorline = true;
      signcolumn ="yes";
      showmode = false;
      scrolloff = 8; sidescrolloff = 5;

      expandtab = true;
      shiftwidth = 2;
      tabstop = 4;
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
        };
      };

      blink-cmp = {
        enable = true;
        settings = {
          keymap = {
            # Replaces complex mapping boilerplate with a single preset
            preset = "super-tab"; 
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
          enable = true;          # enable fzf-native extension
          settings = {
            fuzzy = true;
            override_file_sorter = true;
            override_generic_sorter = true;
            case_mode = "smart_case";
          };
        };
        settings = {
          defaults = {
            layout_config = { prompt_position = "top"; };
            sorting_strategy = "ascending";
          };
          pickers.find_files.hidden = true;
        };
      };

      "indent-blankline" = {
        enable = true;
        settings = {
          indent = { char = "▏"; tab_char = "▏"; };
          scope = {
            enabled = true;
            show_start = true;
            show_end = false;
          };
        };
      };

      "web-devicons".enable = false;
    };

    colorschemes.nightfox.enable = true;
  };
}
