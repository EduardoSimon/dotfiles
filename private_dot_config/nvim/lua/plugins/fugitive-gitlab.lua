return {
  "shumphrey/fugitive-gitlab.vim", dependencies = { "tpope/vim-fugitive"  },
  config = function()
    vim.g.fugitive_gitlab_domains = {
      ["git.gitlab.flywire.tech"] = os.getenv("FLYWIRE_GIT_DOMAIN")
    }
  end
}
