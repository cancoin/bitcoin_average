defmodule BitcoinAverage.Client do

  use HTTPotion.Base

  def process_url(url) do
   "https://apiv2.bitcoinaverage.com/" <> url
  end

  def process_request_headers(headers) do
    headers
      |> Dict.put(:"Content-Type", "application/json")
      |> Dict.put(:"X-Signature", signed_request_header)
  end

  def process_response_body(body) do
    body |> IO.iodata_to_binary |> JSX.decode!
  end

  def signed_request_header do
    {:ok, public_key} = :application.get_env(:bitcoin_average, :public_key)
    {:ok, private_key} = :application.get_env(:bitcoin_average, :private_key)
    now = Timex.now |> Timex.to_unix
    request = "#{now}.#{public_key}"
    signature = :crypto.hmac(:sha256, String.to_char_list(private_key), String.to_char_list(request))
    encoded_signature = Base.encode16(signature, case: :lower)
    "#{now}.#{public_key}.#{encoded_signature}"
  end

end
