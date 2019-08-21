defmodule JenServer do
  @moduledoc """
  Documentation for JenServer.
  """

  def start_link(module, state \\ nil) do
    spawn_recv_loop({module, state})
  end

  def call(pid, msg) do
    ref = :erlang.make_ref()
    send(pid, {:call, self(), ref, msg})

    receive do
      {:reply, ^ref, msg} -> msg
    end
  end

  def cast(pid, msg) do
    send(pid, {:cast, msg})
    :ok
  end

  defp spawn_recv_loop({module, state}) do
    spawn_link(fn ->
      case module.init(state) do
        {:ok, initial_state} ->
          recv_loop({module, initial_state})

        _else ->
          raise "we did it bad"
      end
    end)
  end

  defp recv_loop({module, state}) do
    receive do
      {:call, from, ref, msg} ->
        state =
          msg
          |> module.handle_call({ref, from}, state)
          |> reply_if_needed({ref, from})

        recv_loop({module, state})

      {:cast, msg} ->
        state =
          msg
          |> module.handle_cast(state)
          |> reply_if_needed(nil)

        recv_loop({module, state})

      msg ->
        state =
          msg
          |> module.handle_info(state)
          |> reply_if_needed(nil)

        recv_loop({module, state})
    end
  end

  defp reply_if_needed({:reply, msg, state}, {ref, from}) do
    send(from, {:reply, ref, msg})
    state
  end

  defp reply_if_needed({:noreply, state}, _from) do
    state
  end

  defmacro __using__(_) do
    quote location: :keep do
      def init(state) do
        raise "this is not implemented"
      end

      def handle_call(msg, from, state) do
        raise "this is not implemented"
      end

      def handle_cast(_msg, _state) do
        raise "this is not implemented"
      end

      def handle_info(msg, state) do
        {:noreply, state}
      end

      defoverridable init: 1, handle_call: 3, handle_cast: 2, handle_info: 2
    end
  end
end
