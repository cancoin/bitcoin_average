defmodule BitcoinAverage.Websocket do

  defmodule State do
    defstruct [conn: nil, type: nil, owner: nil]
  end

  def ticker do
    start_link(:ticker)
  end

  def exchanges do
    start_link(:exchanges)
  end

  def subscribe(client, options, owner \\ self) when is_map(options) do
    GenServer.call(client, {:send_message, owner, %{
      event: "message",
      data: %{
        operation: "subscribe",
        options: options
      }
    }})
  end

  def start_link(type) when type in [:ticker, :exchanges] do
    GenServer.start_link(__MODULE__, [type])
  end

  def init([type]) do
    send self, :connect
    {:ok, %State{type: type}}
  end

  def handle_info(:connect, %State{type: type} = state) do
    conn = open_connection!
    _ref = :gun.ws_upgrade(conn, build_url!(type), [
      {"Authorization", BitcoinAverage.Client.signed_request_header}])
    {:noreply, %State{state | conn: conn}}
  end

  def handle_info({:gun_ws, conn, {:text, json}}, state) do
    {:ok, data} = JSX.decode(json)
    {:ok, state} = send_to_owner(data, state)
    {:noreply, state}
  end

  def handle_info(other, state) do
    {:noreply, state}
  end

  def handle_call({:send_message, owner, message}, _from, state) do
    {:ok, state} = send_message(message, state)
    {:reply, :ok, %State{state | owner: owner}}
  end

  def terminate(:normal, state) do
    :ok
  end

  defp open_connection! do
    host = :application.get_env(:bitcoin_average, :api_host, 'apiv2.bitcoinaverage.com')
    port = :application.get_env(:bitcoin_average, :api_port, 443)
    {:ok, conn} = :gun.open(@host, @port)
    Process.link(conn)
    conn
  end

  defp build_url!(type) do
    %{"ticket" => ticket} = BitcoinAverage.get_websocket_ticket
    {:ok, public_key} = :application.get_env(:bitcoin_average, :public_key)
    "/websocket/#{type}?public_key=#{public_key}&ticket=#{ticket}"
  end

  defp send_message(message, %State{conn: conn} = state) do
    command = JSX.encode!(message)
    :ok = :gun.ws_send(conn, {:text, command})
    {:ok, state}
  end

  defp send_to_owner(data, %State{owner: owner, type: type} = state) do
    send(owner, {:bitcoin_average, self, {type, data}})
    {:ok, state}
  end
end
