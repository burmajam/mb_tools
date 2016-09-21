defmodule MbTools.GenFacade do
  defmacro route(cmd, {controller, action}) do
    quote do
	  def handle_call({unquote(cmd), params}, from, request_sup) do
        execute(request_sup, from, fn ->
	      unquote(controller).unquote(action)(params)
        end)
      end
	  def handle_call({unquote(cmd), params, metadata}, from, request_sup) do
        execute(request_sup, from, fn ->
          Logger.metadata metadata
	      unquote(controller).unquote(action)(params)
        end)
	    {:noreply, request_sup}
	  end
    end
  end
  defmacro route(cmd, controller) do
    quote do
	  def handle_call({unquote(cmd), params}, from, request_sup) do
        execute(request_sup, from, fn ->
	      unquote(controller).unquote(cmd)(params)
        end)
      end
	  def handle_call({unquote(cmd), params, metadata}, from, request_sup) do
        execute(request_sup, from, fn ->
          Logger.metadata metadata
	      unquote(controller).unquote(cmd)(params)
        end)
	    {:noreply, request_sup}
	  end
    end
  end

  defmacro __using__(_) do
    quote do
      use GenServer
      require MbTools.GenFacade
      import MbTools.GenFacade
      require Logger

      def start_link(request_sup, opts \\ []), 
        do: GenServer.start_link(__MODULE__, request_sup, opts)
      
      def init(request_sup), do: {:ok, request_sup}

      defp execute(request_sup, from, fun) do
        Task.Supervisor.start_child(request_sup, fn ->
          response = fun.()
          GenServer.reply from, response
        end)
        {:noreply, request_sup}
      end
    end
  end
end
