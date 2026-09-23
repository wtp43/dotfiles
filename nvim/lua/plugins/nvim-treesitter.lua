return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "css",
        "dockerfile",
        "gitignore",
        "graphql",
        "helm",
        "sql",
        "terraform",
      },
    },
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    event = "VeryLazy",
    opts = {},
  },
}
