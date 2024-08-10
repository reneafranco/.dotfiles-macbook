-- Debugging Support
return {
  -- https://github.com/rcarriga/nvim-dap-ui
  'rcarriga/nvim-dap-ui',
  event = 'VeryLazy',
  dependencies = {
    -- https://github.com/mfussenegger/nvim-dap
    'mfussenegger/nvim-dap',
    -- https://github.com/theHamsta/nvim-dap-virtual-text
    'theHamsta/nvim-dap-virtual-text', -- inline variable text while debugging
    -- https://github.com/nvim-telescope/telescope-dap.nvim
    'nvim-telescope/telescope-dap.nvim', -- telescope integration with dap
    'nvim-neotest/nvim-nio',
  },
  opts = {
    controls = {
      element = "repl",
      enabled = false,
      icons = {
        disconnect = "",
        pause = "",
        play = "",
        run_last = "",
        step_back = "",
        step_into = "",
        step_out = "",
        step_over = "",
        terminate = ""
      }
    },
    element_mappings = {},
    expand_lines = true,
    floating = {
      border = "single",
      mappings = {
        close = { "q", "<Esc>" }
      }
    },
    force_buffers = true,
    icons = {
      collapsed = "",
      current_frame = "",
      expanded = ""
    },
    layouts = {
      {
        elements = {
          {
            id = "scopes",
            size = 0.50
          },
          {
            id = "stacks",
            size = 0.30
          },
          {
            id = "watches",
            size = 0.10
          },
          {
            id = "breakpoints",
            size = 0.10
          }
        },
        size = 40,
        position = "left", -- Can be "left" or "right"
      },
      {
        elements = {
          "repl",
          "console",
        },
        size = 10,
        position = "bottom", -- Can be "bottom" or "top"
      }
    },
    mappings = {
      edit = "e",
      expand = { "<CR>", "<2-LeftMouse>" },
      open = "o",
      remove = "d",
      repl = "r",
      toggle = "t"
    },
    render = {
      indent = 1,
      max_value_lines = 100
    }
  },
  config = function (_, opts)
    local dap = require('dap')
    require('dapui').setup(opts)

    dap.listeners.after.event_initialized["dapui_config"] = function()
      require('dapui').open()
    end

    dap.listeners.before.event_terminated["dapui_config"] = function()
      -- Commented to prevent DAP UI from closing when unit tests finish
      -- require('dapui').close()
    end

    dap.listeners.before.event_exited["dapui_config"] = function()
      -- Commented to prevent DAP UI from closing when unit tests finish
      -- require('dapui').close()
    end

    -- Add dap configurations based on your language/adapter settings
    -- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
    dap.configurations.java = {
      {
        name = "Debug Launch (2GB)",
        type = 'java',
        request = 'launch',
        vmArgs = "" ..
          "-Xmx2g "
      },
      {
        name = "Debug Attach (8000)",
        type = 'java',
        request = 'attach',
        hostName = "127.0.0.1",
        port = 8000,
      },
      {
        name = "Debug Attach (5005)",
        type = 'java',
        request = 'attach',
        hostName = "127.0.0.1",
        port = 5005,
      },
      {
        name = "My Custom Java Run Configuration",
        type = "java",
        request = "launch",
        -- You need to extend the classPath to list your dependencies.
        -- `nvim-jdtls` would automatically add the `classPaths` property if it is missing
        -- classPaths = {},

        -- If using multi-module projects, remove otherwise.
        -- projectName = "yourProjectName",

        -- javaExec = "java",
        mainClass = "replace.with.your.fully.qualified.MainClass",

        -- If using the JDK9+ module system, this needs to be extended
        -- `nvim-jdtls` would automatically populate this property
        -- modulePaths = {},
        vmArgs = "" ..
          "-Xmx2g "
      },
    }

    -- Debugging key mappings
    local keymap = vim.keymap -- para abreviar

    keymap.set("n", "<leader>bb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", { desc = "Toggle breakpoint" }) -- Alterna un punto de interrupción en la línea actual
    keymap.set("n", "<leader>bc", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>", { desc = "Set conditional breakpoint" }) -- Establece un punto de interrupción condicional
    keymap.set("n", "<leader>bl", "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>", { desc = "Set log point" }) -- Establece un punto de registro con un mensaje personalizado
    keymap.set("n", "<leader>br", "<cmd>lua require'dap'.clear_breakpoints()<cr>", { desc = "Clear breakpoints" }) -- Limpia todos los puntos de interrupción
    keymap.set("n", "<leader>ba", "<cmd>Telescope dap list_breakpoints<cr>", { desc = "List breakpoints" }) -- Lista todos los puntos de interrupción establecidos
    keymap.set("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", { desc = "Continue execution" }) -- Continúa la ejecución hasta el siguiente punto de interrupción
    keymap.set("n", "<leader>dj", "<cmd>lua require'dap'.step_over()<cr>", { desc = "Step over" }) -- Avanza a la siguiente línea de código, saltando funciones
    keymap.set("n", "<leader>dk", "<cmd>lua require'dap'.step_into()<cr>", { desc = "Step into" }) -- Entra en la función actual para depurar
    keymap.set("n", "<leader>do", "<cmd>lua require'dap'.step_out()<cr>", { desc = "Step out" }) -- Sale de la función actual y vuelve a la llamada
    keymap.set("n", "<leader>dd", function() require('dap').disconnect(); require('dapui').close(); end, { desc = "Disconnect debugger" }) -- Desconecta el depurador y cierra la interfaz
    keymap.set("n", "<leader>dt", function() require('dap').terminate(); require('dapui').close(); end, { desc = "Terminate debugger" }) -- Termina la sesión de depuración
    keymap.set("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", { desc = "Toggle REPL" }) -- Alterna el panel REPL (Read-Eval-Print Loop)
    keymap.set("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>", { desc = "Run last configuration" }) -- Ejecuta la última configuración de depuración utilizada
    keymap.set("n", "<leader>di", function() require "dap.ui.widgets".hover() end, { desc = "Hover over variable" }) -- Muestra información sobre la variable en el cursor
    keymap.set("n", "<leader>d?", function() local widgets = require "dap.ui.widgets"; widgets.centered_float(widgets.scopes) end, { desc = "Show variable scopes" }) -- Muestra el contexto de variables
    keymap.set("n", "<leader>df", "<cmd>Telescope dap frames<cr>", { desc = "List stack frames" }) -- Lista los frames de la pila de llamadas
    keymap.set("n", "<leader>dh", "<cmd>Telescope dap commands<cr>", { desc = "List DAP commands" }) -- Lista todos los comandos disponibles en DAP
    keymap.set("n", "<leader>de", function() require('telescope.builtin').diagnostics({default_text=":E:"}) end, { desc = "Show diagnostics" }) -- Muestra los diagnósticos actuales
  end
}

