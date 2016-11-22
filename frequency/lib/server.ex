defmodule Server do
  
  def start(name, args) do
    Process.register(spawn(__MODULE__, :init, [name, args]), name)
  end

  def stop(name) do
    send(name, {:stop, self})
    receive do {:reply, response} -> response end
  end

  def call(name, request) do
    send(name, {:request, self, request})
    receive do {:reply, response} -> response end
  end

  def init(mod, args) do
    state = apply(mod, :init, [args])
    loop(mod, state)
  end

  defp reply(to, response) do
    send(to, {:reply, response})
  end

  defp loop(mod, state) do
    receive do
      {:request, sender, request} ->
        {new_state, response} = apply(mod, :handle, [request, sender, state])
        reply(sender, response)
        loop(mod, new_state)
      {:stop, sender} ->
        response = apply(mod, :terminate, [state])
        reply(sender, response)
    end
  end
end