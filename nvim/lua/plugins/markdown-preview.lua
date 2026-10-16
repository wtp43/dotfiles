-- Sessions reach this machine over `et`, so the preview opens in the Mac's browser
-- over the LAN: listen on every interface (ufw admits 8099 from 192.168.50.0/24 only),
-- put this machine's LAN IP in the URL, and show it instead of opening a browser here.
return {
  "iamcco/markdown-preview.nvim",
  -- The prebuilt markdown-preview-linux segfaults here (exit 139); without it the
  -- plugin runs app/index.js on node. The lockfile restore keeps lazy updates clean.
  build = "cd app && npm install --no-audit --no-fund && git checkout -- yarn.lock && rm -f package-lock.json bin/markdown-preview-linux",
  init = function()
    vim.g.mkdp_port = "8099"
    vim.g.mkdp_open_to_the_world = 1
    vim.g.mkdp_open_ip = "192.168.50.60"
    vim.g.mkdp_auto_close = 0
    vim.cmd([[
      function! MkdpNotifyUrl(url)
        call v:lua.vim.notify('Markdown preview: ' . a:url)
      endfunction
    ]])
    vim.g.mkdp_browserfunc = "MkdpNotifyUrl"
  end,
}
