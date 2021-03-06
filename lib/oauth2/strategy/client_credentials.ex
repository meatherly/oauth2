defmodule OAuth2.Strategy.ClientCredentials do
  @moduledoc """
  The Client Credentials Strategy

  http://tools.ietf.org/html/rfc6749#section-1.3.4

  The client credentials (or other forms of client authentication) can
  be used as an authorization grant when the authorization scope is
  limited to the protected resources under the control of the client,
  or to protected resources previously arranged with the authorization
  server. Client credentials are used as an authorization grant
  typically when the client is acting on its own behalf (the client is
  also the resource owner) or is requesting access to protected
  resources based on an authorization previously arranged with the
  authorization server.
  """

  use OAuth2.Strategy

  @doc """
  Not used for this strategy.
  """
  def authorize_url(_client, _params) do
    raise OAuth2.Error, reason: "Not implemented."
  end

  @doc """
  Retrieve an access token given the specified strategy.
  """
  def get_token(client, params, headers) do
    {auth_scheme, params} = Keyword.pop(params, :auth_scheme, "auth_header")

    client
    |> put_param(:grant_type, "client_credentials")
    |> auth_scheme(auth_scheme)
    |> merge_params(params)
    |> put_headers(headers)
  end

  defp auth_scheme(client, "auth_header"),  do: auth_header(client)
  defp auth_scheme(client, "request_body"), do: request_body(client)

  defp auth_header(%{client_id: id, client_secret: secret} = client) do
    put_header(client, "Authorization", "Basic " <> Base.encode64(id <> ":" <> secret))
  end

  defp request_body(client) do
    client
    |> put_param(:client_id, client.client_id)
    |> put_param(:client_secret, client.client_secret)
  end
end

