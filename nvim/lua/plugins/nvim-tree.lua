local function toggle_replace()
  local api = require("nvim-tree.api")
  if api.tree.is_visible() then
    api.tree.close()
  else
    api.node.open.replace_tree_buffer()
  end
end
return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    enabled = false,
    keys = {
      {
        "<leader>e",
        function()
          require("nvim-tree.api").tree.toggle({
            path = "cwd",
          })
        end,
        desc = "Toggle Tree(cwd)",
      },
      {
        "<leader>E",
        function()
          require("nvim-tree.api").tree.toggle({
            path = "/",
          })
        end,
        desc = "Toggle Tree (Root Dir)",
      },
    },
    dependencies = {
      {
        "b0o/nvim-tree-preview.lua",
      },
    },
    config = function()
      local preview = require("nvim-tree-preview")
      local function my_on_attach(bufnr)
        local api = require("nvim-tree.api")
        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.set("n", "P", preview.watch, opts("Preview (Watch)"))
        vim.keymap.set("n", "<Esc>", preview.unwatch, opts("Close Preview/Unwatch"))
        vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
        -- Option B: Smart tab behavior: Only preview files, expand/collapse directories.
        vim.keymap.set("n", "<Tab>", function()
          local ok, node = pcall(api.tree.get_node_under_cursor)
          if ok and node then
            if node.type == "directory" then
              api.node.open.edit()
            else
              preview.watch()
              -- preview.node(node, { toggle_focus = false })
            end
          end
        end, opts("Preview"))
      end
      -- Default config:
      preview.setup({
        keymaps = {
          ["<Esc>"] = { action = "close", unwatch = true },
          ["<Tab>"] = { action = "toggle_focus" },
          ["<CR>"] = { open = "edit" },
          ["<C-t>"] = { open = "tab" },
          ["<C-v>"] = { open = "vertical" },
          ["<C-x>"] = { open = "horizontal" },
        },
        min_width = 10,
        min_height = 5,
        max_width = 85,
        max_height = 25,
        wrap = false, -- Whether to wrap lines in the preview window
        border = "rounded", -- Border style for the preview window
      })
      require("nvim-tree").setup({
        on_attach = my_on_attach,
        hijack_cursor = true,
        auto_reload_on_write = true,
        disable_netrw = false,
        hijack_netrw = false,
        hijack_unnamed_buffer_when_opening = true,
        root_dirs = {},
        prefer_startup_root = false,
        sync_root_with_cwd = true,
        reload_on_bufenter = false,
        respect_buf_cwd = false,
        select_prompts = false,
        sort = {
          sorter = "name",
          folders_first = true,
          files_first = false,
        },
        view = {

          centralize_selection = true,
          cursorline = true,
          debounce_delay = 15,
          side = "left",
          preserve_window_proportions = true,
          number = true,
          relativenumber = true,
          signcolumn = "yes",
          width = 40,
          float = {
            enable = true,
            open_win_config = function()
              local WIDTH_RATIO = 0.4
              local HEIGHT_RATIO = 0.8
              local screen_w = vim.opt.columns:get()
              local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
              local window_w = screen_w * WIDTH_RATIO
              local window_h = screen_h * HEIGHT_RATIO
              local window_w_int = math.floor(window_w)
              local window_h_int = math.floor(window_h)
              local center_x = (screen_w - window_w) / 8
              local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
              return {
                border = "rounded",
                relative = "editor",
                row = center_y,
                -- row = 0,
                col = center_x,
                width = window_w_int,
                height = window_h_int,
              }
            end,
          },
          -- float = {
          --   enable = true,
          --   quit_on_focus_loss = true,
          --   open_win_config = {
          --     relative = "editor",
          --     border = "rounded",
          --     width = 40,
          --     height = 30,
          --     row = 1,
          --     col = 2,
          --   },
          -- },
        },
        renderer = {
          add_trailing = true,
          group_empty = false,
          full_name = false,
          root_folder_label = ":~:s?$?/..?",
          indent_width = 2,
          special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
          symlink_destination = true,
          highlight_git = true,
          highlight_diagnostics = false,
          highlight_opened_files = "none",
          highlight_modified = "none",
          indent_markers = {
            enable = true,
            inline_arrows = true,
            icons = {
              corner = "└",
              edge = "│",
              item = "│",
              bottom = "─",
              none = " ",
            },
          },
          icons = {
            web_devicons = {
              file = {
                enable = true,
                color = true,
              },
              folder = {
                enable = true,
                color = true,
              },
            },
            git_placement = "before",
            diagnostics_placement = "signcolumn",
            modified_placement = "after",
            padding = " ",
            symlink_arrow = " ➛ ",
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
              diagnostics = true,
              modified = true,
            },
            glyphs = {
              default = "",
              symlink = "",
              bookmark = "󰆤",
              modified = "●",
              folder = {
                arrow_closed = "",
                arrow_open = "",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
                symlink = "",
                symlink_open = "",
              },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌",
              },
            },
          },
        },
        hijack_directories = {
          enable = true,
          auto_open = true,
        },
        update_focused_file = {
          enable = false,
          update_root = false,
        },
        system_open = {
          cmd = "",
          args = {},
        },
        git = {
          enable = true,
          show_on_dirs = true,
          show_on_open_dirs = true,
          disable_for_dirs = {},
          timeout = 400,
        },
        diagnostics = {
          enable = false,
          show_on_dirs = true,
          show_on_open_dirs = true,
          debounce_delay = 50,
          severity = {
            min = vim.diagnostic.severity.HINT,
            max = vim.diagnostic.severity.ERROR,
          },
          icons = {
            hint = "",
            info = "",
            warning = "",
            error = "",
          },
        },
        modified = {
          enable = false,
          show_on_dirs = true,
          show_on_open_dirs = true,
        },
        filters = {
          git_ignored = true,
          dotfiles = false,
          git_clean = false,
          no_buffer = false,
          custom = {},
          exclude = {},
        },
        live_filter = {
          prefix = "[FILTER]: ",
          always_show_folders = true,
        },
        filesystem_watchers = {
          enable = true,
          debounce_delay = 50,
          ignore_dirs = {},
        },
        actions = {
          use_system_clipboard = true,
          change_dir = {
            enable = true,
            global = true,
            restrict_above_cwd = false,
          },
          expand_all = {
            max_folder_discovery = 300,
            exclude = {},
          },
          file_popup = {
            open_win_config = {
              col = 1,
              row = 1,
              relative = "cursor",
              border = "shadow",
              style = "minimal",
            },
          },
          open_file = {
            quit_on_open = true,
            eject = true,
            resize_window = true,
            window_picker = {
              enable = true,
              picker = "default",
              chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
              exclude = {
                filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
                buftype = { "nofile", "terminal", "help" },
              },
            },
          },
          remove_file = {
            close_window = true,
          },
        },
        -- trash = {
        --   cmd = "gio trash",
        -- },
        tab = {
          sync = {
            open = false,
            close = false,
            ignore = {},
          },
        },
        notify = {
          threshold = vim.log.levels.INFO,
          absolute_path = false,
        },
        ui = {
          confirm = {
            remove = true,
            trash = true,
          },
        },
        experimental = {},
        log = {
          enable = false,
          truncate = false,
          types = {
            all = false,
            config = false,
            copy_paste = false,
            dev = false,
            diagnostics = false,
            git = false,
            profile = false,
            watcher = false,
          },
        },
      }) -- END_DEFAULT_OPTS
    end,
  },
}
-- vim vinegar-esque in-place explore/pick
--
-- local function edit_or_open()
--   local api = require("nvim-tree.api")
--   local node = api.tree.get_node_under_cursor()
--   if node.nodes ~= nil then
--     -- expand or collapse folder
--     api.node.open.edit()
--   else
--     -- open file
--     api.node.open.edit()
--     -- Close the tree if file was opened
--     api.tree.close()
--   end
-- end
--
-- -- open as vsplit on current node
-- local function vsplit_preview()
--   local api = require("nvim-tree.api")
--   local node = api.tree.get_node_under_cursor()
--   if node.nodes ~= nil then
--     -- expand or collapse folder
--     api.node.open.edit()
--   else
--     -- open file as vsplit
--     api.node.open.vertical()
--   end
--   -- Finally refocus on tree if it was lost
--   api.tree.focus()
-- end
--
-- -- mappings etc...
-- local function on_attach(bufnr)
--   local api = require("nvim-tree.api")
--
--   -- floatpreview
--   local floatpreview = require("float-preview")
--   local float_close_wrap = floatpreview.close_wrap
--   local Event = api.events.Event
--
--   floatpreview.attach_nvimtree(bufnr)
--
--   api.events.subscribe(Event.TreeClose, function()
--     vim.schedule(function()
--       float_close_wrap(function() end)()
--     end)
--   end)
--
--   local function opts(desc)
--     return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
--   end
--   api.config.mappings.default_on_attach(bufnr)
--
--   -- this allows float preview to not throw errors on exit
--   vim.keymap.set("n", "-", float_close_wrap(api.tree.close), opts("Close"))
--   vim.keymap.set("n", "q", float_close_wrap(api.tree.close), opts("Close"))
--
--   -- halp
--   vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
--
--   -- hjkl
--   vim.keymap.set("n", "l", edit_or_open, opts("Edit/Open"))
--   vim.keymap.set("n", "h", api.tree.close, opts("Close"))
--   vim.keymap.set("n", "H", api.tree.collapse_all, opts("Collapse All"))
-- end
--
-- -- plugin setup
-- return {
--   "nvim-tree/nvim-tree.lua",
--   dependencies = {
--     {
--       "yamatsum/nvim-nonicons",
--       dependencies = { "kyazdani42/nvim-web-devicons" },
--     },
--     {
--       "JMarkin/nvim-tree.lua-float-preview",
--       lazy = true,
--       -- default
--       opts = {
--         -- Whether the float preview is enabled by default. When set to false, it has to be "toggled" on.
--         toggled_on = true,
--         -- wrap nvimtree commands
--         wrap_nvimtree_commands = false,
--         -- lines for scroll
--         scroll_lines = 20,
--         mapping = {
--           -- scroll down float buffer
--           down = { "<C-f>" },
--           -- scroll up float buffer
--           up = { "<C-b>" },
--           -- enable/disable float windows
--           toggle = { "<c-p>" },
--         },
--         -- hooks if return false preview doesn't shown
--         hooks = {
--           pre_open = function(path)
--             -- if file > 5 MB or not text -> not preview
--             local size = require("float-preview.utils").get_size(path)
--             if type(size) ~= "number" then
--               return false
--             end
--             local is_text = require("float-preview.utils").is_text(path)
--             return size < 5 and is_text
--           end,
--           post_open = function(bufnr)
--             return true
--           end,
--         },
--         window = {
--           style = "minimal",
--           relative = "win",
--           border = "rounded",
--           wrap = false,
--           trim_height = false,
--           open_win_config = function(buf)
--             local WIDTH_RATIO = 0.4
--             local HEIGHT_RATIO = 0.8
--             -- calc position of nvimtree main window
--             local screen_w = vim.opt.columns:get()
--             local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
--             local window_w = screen_w * WIDTH_RATIO
--             local window_h = screen_h * HEIGHT_RATIO
--             local window_w_int = math.floor(window_w)
--             local window_h_int = math.floor(window_h)
--             local center_x = (screen_w - window_w) * 7 / 8
--             local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
--             -- return preview window
--             return {
--               border = "rounded",
--               relative = "editor",
--               row = center_y,
--               -- row = 0,
--               col = center_x,
--               width = window_w_int,
--               height = window_h_int,
--               title = buf,
--             }
--           end,
--         },
--       },
--     },
--   },
--   keys = {
--     {
--       "-",
--       function()
--         require("nvim-tree.api").tree.toggle({ focus = true })
--       end,
--       desc = "NvimTree Toggle",
--     },
--   },
--   config = function()
--     vim.opt.termguicolors = true
--
--     local WIDTH_RATIO = 0.4
--     local HEIGHT_RATIO = 0.8
--
--     local nonicons_extension = require("nvim-nonicons.extentions.nvim-tree")
--
--     -- automatically resize the nvimtree when neovim's window size changes
--     local tree_api = require("nvim-tree")
--     local tree_view = require("nvim-tree.view")
--     vim.api.nvim_create_augroup("NvimTreeResize", {
--       clear = true,
--     })
--     vim.api.nvim_create_autocmd({ "VimResized" }, {
--       group = "NvimTreeResize",
--       callback = function()
--         if tree_view.is_visible() then
--           tree_view.close()
--           tree_api.open()
--         end
--       end,
--     })
--
--     -- call setup
--     require("nvim-tree").setup({
--       on_attach = on_attach,
--       filters = {
--         dotfiles = false,
--         exclude = { vim.fn.stdpath("config") .. "/lua/custom" },
--         custom = { "^.git$" },
--       },
--       disable_netrw = true,
--       hijack_netrw = true,
--       hijack_cursor = true,
--       hijack_unnamed_buffer_when_opening = true,
--       sync_root_with_cwd = true,
--       update_focused_file = {
--         enable = true,
--         update_root = false,
--       },
--       view = {
--         float = {
--           enable = true,
--           open_win_config = function()
--             local screen_w = vim.opt.columns:get()
--             local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
--             local window_w = screen_w * WIDTH_RATIO
--             local window_h = screen_h * HEIGHT_RATIO
--             local window_w_int = math.floor(window_w)
--             local window_h_int = math.floor(window_h)
--             local center_x = (screen_w - window_w) / 8
--             local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
--             return {
--               border = "rounded",
--               relative = "editor",
--               row = center_y,
--               -- row = 0,
--               col = center_x,
--               width = window_w_int,
--               height = window_h_int,
--             }
--           end,
--         },
--       },
--       modified = {
--         enable = true,
--       },
--       git = {
--         enable = true,
--         ignore = true,
--       },
--       filesystem_watchers = {
--         enable = true,
--       },
--       actions = {
--         open_file = {
--           quit_on_open = true,
--           resize_window = false,
--           window_picker = {
--             enable = true,
--             picker = "default",
--             chars = "ASDFGHJKL",
--             exclude = {
--               filetype = { "notify", "lazy", "qf", "diff", "fugitive", "fugitiveblame", "trouble" },
--               buftype = { "nofile", "terminal", "help" },
--             },
--           },
--         },
--         remove_file = {
--           close_window = true,
--         },
--       },
--       renderer = {
--         root_folder_label = ":t",
--         highlight_git = true,
--         -- highlight_modified = false,
--         indent_markers = {
--           enable = true,
--         },
--         icons = {
--           show = {
--             file = true,
--             folder = true,
--             folder_arrow = true,
--             git = false,
--             modified = true,
--           },
--           glyphs = nonicons_extension.glyphs,
--         },
--       },
--     })
--   end,
-- }
