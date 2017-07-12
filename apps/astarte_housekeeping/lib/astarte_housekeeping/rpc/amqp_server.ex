defmodule Astarte.Housekeeping.RPC.AMQPServer do
  use Astarte.RPC.AMQPServer,
    queue: Application.fetch_env!(:astarte_housekeeping, :rpc_queue),
    amqp_options: Application.get_env(:astarte_housekeeping, :amqp_connection, [])
  alias Astarte.RPC.Protocol.Housekeeping.{Call,CreateRealm}

  def process_rpc(payload) do
    process_decoded_call(Call.decode(payload))
  end

  defp process_decoded_call(%Call{call: nil}) do
    Logger.warn "Received empty call"
    {:error, :empty_call}
  end

  defp process_decoded_call(%Call{call: call_tuple}) do
    process_call_tuple(call_tuple)
  end

  defp process_call_tuple({:create_realm, %CreateRealm{realm: nil}}) do
    Logger.warn "CreateRealm with realm == nil"
    {:error, :invalid_argument}
  end

  defp process_call_tuple({:create_realm, %CreateRealm{realm: realm}}) do
    Astarte.Housekeeping.Engine.create_realm(realm)
  end
end
