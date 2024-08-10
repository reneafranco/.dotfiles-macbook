return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
    { "mfussenegger/nvim-jdtls", lazy = true }, -- Asegúrate de que jdtls esté aquí
  },
  config = function()
    -- Importar plugins necesarios
    local lspconfig = require("lspconfig")
    local mason_lspconfig = require("mason-lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local keymap = vim.keymap -- para abreviar

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- Mapeo de teclas para LSP
        local opts = { buffer = ev.buf, silent = true }

        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts)

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
      end,
    })

    -- Usar capacidades de autocompletar
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Cambiar símbolos de diagnóstico en la columna de signos
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    mason_lspconfig.setup_handlers({
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = capabilities,
        })
      end,

      ["jdtls"] = function()
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
        local workspace_dir = vim.env.HOME .. '/jdtls-workspace/' .. project_name

        local bundles = {
          vim.fn.glob(vim.env.HOME .. '/.local/share/nvim/mason/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar'),
        }
        
        vim.list_extend(bundles, vim.split(vim.fn.glob(vim.env.HOME .. "/.local/share/nvim/mason/share/java-test/*.jar", 1), "\n"))

        -- Configuración del servidor JDTLS
        lspconfig.jdtls.setup({
          capabilities = capabilities,
          cmd = {
            'java',
            '-Declipse.application=org.eclipse.jdt.ls.core.id1',
            '-Dosgi.bundles.defaultStartLevel=4',
            '-Declipse.product=org.eclipse.jdt.ls.core.product',
            '-Dlog.protocol=true',
            '-Dlog.level=ALL',
            '-javaagent:' .. vim.env.HOME .. '/.local/share/nvim/mason/share/jdtls/lombok.jar',
            '-Xmx4g',
            '--add-modules=ALL-SYSTEM',
            '--add-opens', 'java.base/java.util=ALL-UNNAMED',
            '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
            '-jar', vim.env.HOME .. '/.local/share/nvim/mason/share/jdtls/plugins/org.eclipse.equinox.launcher.jar',
            '-configuration', vim.env.HOME .. '/.local/share/nvim/mason/packages/jdtls/config_mac',
            '-data', workspace_dir
          },
          root_dir = function(fname)
            return lspconfig.util.root_pattern('.git', 'pom.xml', 'build.gradle')(fname) or vim.loop.os_homedir()
          end,
          settings = {
            java = {
              home = os.getenv("HOME") .. '/.sdkman/candidates/java/current',
              eclipse = {
                downloadSources = true,
              },
              configuration = {
                updateBuildConfiguration = "interactive",
                runtimes = {
                  {
                    name = "JavaSE-17",
                    path = '/Users/renea/.sdkman/candidates/java/current',
                  },
                },
              },
            },
          },
          filetypes = { "java" },
        })
      end,
    })
  end,
}

