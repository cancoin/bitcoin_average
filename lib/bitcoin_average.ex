defmodule BitcoinAverage do
  use Application
  alias BitcoinAverage.Client

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = []

    opts = [strategy: :one_for_one, name: BitcoinAverage.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def all_symbols do
    Client.get("constants/symbols").body
  end

  def symbols_per_market(market) when market in [:local, :global] do
    Client.get("constants/symbols/#{market}").body
  end

  def exchange_rates(market) when market in [:local, :global] do
    Client.get("constants/exchangerates/#{market}").body
  end

  def server_time do
    Client.get("constants/time").body
  end

  def ticker_all(market, crypto \\ "", fiat \\ "") when market in [:local, :global] do
    Client.get("indices/#{market}/ticker/all", query: [crypto: crypto, fiat: fiat]).body
  end

  def get_ticker_data_per_symbol(market, symbol) when market in [:local, :global] do
    Client.get("indices/#{market}/ticker/#{symbol}").body
  end

  def ticker_short(market) when market in [:local, :global] do
    Client.get("/indices/#{market}/ticker/short").body
  end

  def ticker_changes(market, symbol) when market in [:local, :global] do
    Client.get("indices/#{market}/ticker/#{symbol}/changes").body
  end

  def get_history(market, symbol, period) when market in [:local, :global] do
    Client.get("indices/#{market}/history/#{symbol}", query: [period: period, format: :json]).body
  end

  def data_since_timestamp(market, symbol, since \\ "") when market in [:local, :global] do
    Client.get("indices/#{market}/history/#{symbol}", query: [since: since, format: :json]).body
  end

  def price_at_timestamp(market, symbol, timestamp)  when market in [:local, :global] do
    Client.get("indices/#{market}/history/#{symbol}", query: [at: timestamp, format: :json]).body
  end

  def all_exchange_data(crypto \\ ["BTC"], fiat \\ []) do
    query = [crypto: Enum.join(crypto, ","), fiat: Enum.join(fiat, ",")]
    Client.get("exchanges/all", query: query).body
  end

  def all_exchange_data_for_symbol(symbol \\ "") do
    Client.get("exchanges/all", query: [symbol: symbol]).body
  end

  def per_exchange_data(name) do
    Client.get("exchanges/#{name}").body
  end

  def exchange_count do
    Client.get("exchanges/count").body
  end

  def outlier_exchanges do
    Client.get("exchanges/outliers").body
  end

  def outlier_exchanges do
    Client.get("exchanges/ignored").body
  end

  def inactive_exchanges do
    Client.get("exchanges/ignored").body
  end

  def currency_weights do
    Client.get("weighting/currencies").body
  end

  def exchange_weights do
    Client.get("weighting/exchanges").body
  end

  def perform_conversion(type, from, to, amount) when type in [:global, :local] do
    Client.get("convert/#{type}", query: [from: from, to: to, amount: amount]).body
  end

  def blockchain_tx_price(symbol, hash) do
    Client.get("blockchain/tx_price/#{symbol}/#{hash}").body
  end

  def get_ticket do
    Client.get("websocket/get_ticket").body
  end

end
