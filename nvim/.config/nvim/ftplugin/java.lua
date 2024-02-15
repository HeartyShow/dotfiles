local lsp = require("lsp-zero")

local home = vim.env.HOME
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = home .. '/.cache/jdtls/workspace/' .. project_name
local lombokjar = "/usr/local/lib/lombok_common/lombok-1.18.28.jar"
local config = {
    cmd = { 'jdtls', '--jvm-arg=-javaagent:' .. lombokjar, 'data', workspace_dir }
}

config.on_attach = lsp.on_attach
config.capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
config.on_init = function(client, _)
    client.notify('workspace/didChangeConfiguration', {settings = client.config.settings})
end

require('jdtls').start_or_attach(config)
