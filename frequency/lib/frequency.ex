defmodule Frequency do
  ## Client API

  def start do
    Process.register(spawn(__MODULE__, :init, []), __MODULE__)
  end

  def stop do
    call(:stop)
  end

  def allocate do
    call(:allocate)
  end

  def deallocate(frequency) do
    call({:deallocate, frequency})
  end

  ## Callbacks

  def init do
    state = {get_frequencies(), []}
    loop(state)
  end

  def loop(frequencies) do
    receive do
      {:request, from, :allocate} ->
        {new_frequencies, reply} = allocate(frequencies, from)
        reply(from, reply)
        loop(new_frequencies)
      {:request, from, {:deallocate, freq}} ->
        new_frequencies = deallocate(frequencies, freq)
        reply(from, :ok)
        loop(new_frequencies)
      {:request, from, :stop} ->
        reply(from, :ok)
    end
  end

  ## Helpers

  defp get_frequencies do
    [10, 11, 12, 13, 14, 15]
  end

  defp call(message) do
    send(__MODULE__, {:request, self, message})
    receive do
      {:reply, reply} -> reply
    end
  end

  defp reply(pid, reply) do
    send(pid, {:reply, reply})
  end

  defp allocate({[], _} = state, _), do: {state, {:error, :no_frequency}}
  defp allocate({[freq | rest], allocated}, pid), do: {{rest, [{freq, pid} | allocated]}, {:ok, freq}}

  defp deallocate({available, allocated}, freq) do
    new_allocated = :lists.keydelete(freq, 1, allocated)
    {[freq | available], new_allocated}
  end 

end
