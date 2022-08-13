local api = vim.api
local map = vim.keymap.set

-- Null-LS --
local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
	return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

api.nvim_create_user_command("Format", "lua vim.lsp.buf.formatting()", {}) -- Builtin Formatting of NVim LSP

null_ls.setup({
	debug = false,
	sources = {
		formatting.prettier,
		formatting.black,
		formatting.fprettify,
		formatting.shfmt,
		formatting.clang_format,
		formatting.cmake_format,
		formatting.stylua,
	},
})

-- LSP servers --
local servers = {
	bashls = {},
	cssls = {},
	emmet_ls = {},
	fortls = {},
	html = {},
	pyright = {
		analysis = {
			typeCheckingMode = "off",
		},
	},
	sumneko_lua = {
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
					path = vim.split(package.path, ";"),
				},
				diagnostics = {
					globals = { "vim", "describe", "it", "before_each", "after_each", "packer_plugins" },
					-- disable = { "lowercase-global", "undefined-global", "unused-local", "unused-vararg", "trailing-space" },
				},
				workspace = {
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
						[vim.fn.stdpath("config") .. "/lua"] = true,
					},
					-- library = api.nvim_get_runtime_file("", true),
					maxPreload = 2000,
					preloadFileSize = 50000,
				},
				completion = { callSnippet = "Both" },
				telemetry = { enable = false },
				hint = {
					enable = true,
				},
			},
		},
	},
	texlab = {},
	tsserver = { disable_formatting = true },
	vimls = {},
}

-- LSP functions --
local function keymaps(client, bufnr)
	local opts = { noremap = true, silent = true }
	map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
	map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	map("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
	map("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	map("n", "<leader>f", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	map("n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
	map("n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	map("n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts)
	map("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
end

local function highlighter(client, bufnr)
	if client.server_capabilities.documentHighlightProvider then
		local lsp_highlight_grp = api.nvim_create_augroup("LspDocumentHighlight", { clear = true })
		api.nvim_create_autocmd("CursorHold", {
			callback = function()
				vim.schedule(vim.lsp.buf.document_highlight)
			end,
			group = lsp_highlight_grp,
			buffer = bufnr,
		})
		api.nvim_create_autocmd("CursorMoved", {
			callback = function()
				vim.schedule(vim.lsp.buf.clear_references)
			end,
			group = lsp_highlight_grp,
			buffer = bufnr,
		})
	end
end

local function formatting(client, bufnr)
	if client.server_capabilities.documentFormattingProvider then
		local function format()
			local view = vim.fn.winsaveview()
			vim.lsp.buf.formatting({
				async = true,
				filter = function(attached_client)
					return attached_client.name ~= ""
				end,
			})
			vim.fn.winrestview(view)
			print("Buffer formatted")
		end

		local lsp_format_grp = api.nvim_create_augroup("LspFormat", { clear = true })
		api.nvim_create_autocmd("BufWritePre", {
			callback = function()
				vim.schedule(format)
			end,
			group = lsp_format_grp,
			buffer = bufnr,
		})
	end
end

local function lsp_handlers()
	-- Diagnostic Signs
	local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
	for type, icon in pairs(signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
	end

	-- LSP handlers configuration
	local config = {
		float = { focusable = true, style = "minimal", border = "rounded", },
		diagnostic = {
			-- virtual_text = false,
			-- virtual_text = { spacing = 4, prefix = "●" },
			virtual_text = { severity = vim.diagnostic.severity.ERROR },
			signs = { active = signs, },
			underline = true,
			update_in_insert = false,
			severity_sort = true,
			float = { focusable = true, style = "minimal", border = "rounded", source = "always", header = "", prefix = "", },
			-- virtual_lines = true,
		},
	}

	vim.diagnostic.config(config.diagnostic)
	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, config.float)
	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, config.float)
	vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
		underline = true,
		virtual_text = { spacing = 5, severity_limit = "Warning", },
		update_in_insert = true,
	})
end

local function on_attach(client, bufnr)
	-- Enable completion triggered by <C-X><C-O>
	api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
	-- Use LSP as the handler for formatexpr.
	api.nvim_buf_set_option(0, "formatexpr", "v:lua.vim.lsp.formatexpr()")
	-- tagfunc
	if client.server_capabilities.definitionProvider then
		api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")
	end
	-- Disable Formatting for tsserver, sumneko-lua
	if client.name == "tsserver" or client.name == "sumneko_lua" then
		client.resolved_capabilities.document_formatting = false
	end

	-- require("keymaps").setup(client, bufnr)
	-- require("highlighter").setup(client, bufnr)
	-- require("formatting").setup(client, bufnr)
end

-- LSP setup --
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

lsp_handlers()

local opts = {
	on_attach = on_attach,
	capabilities = capabilities,
	flags = { debounce_text_changes = 150 },
}

local ms_status_ok, mason = pcall(require, "mason")
if not ms_status_ok then
	return
end
local msls_status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not msls_status_ok then
	return
end

mason.setup({
	ui = {
		border = "single",
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

mason_lspconfig.setup({
	ensure_installed = vim.tbl_keys(servers),
	automatic_installation = false,
})

-- Set up LSP servers
local lspconfig = require("lspconfig")
for server_name, _ in pairs(servers) do
	local options = vim.tbl_deep_extend("force", opts, servers[server_name] or {})

	lspconfig[server_name].setup(options)
end
