defmodule Counter do
  use JenServer

  def start_link do
    JenServer.start_link(__MODULE__, 0)
  end

  def init(total) do
    {:ok, total}
  end

  def handle_call(:inc, _from, state) do
    new_total = state + 1
    {:reply, new_total, new_total}
  end

  def handle_call(:dec, _from, state) do
    new_total = state - 1
    {:reply, new_total, new_total}
  end
end
