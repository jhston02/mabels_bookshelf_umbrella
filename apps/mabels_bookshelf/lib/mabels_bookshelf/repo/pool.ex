defmodule MabelsBookshelf.Repo.Pool do
  def run(action) do
    :poolboy.transaction(:repo_pool_supervisor, fn pid ->
      action.(pid)
    end)
  end
end
