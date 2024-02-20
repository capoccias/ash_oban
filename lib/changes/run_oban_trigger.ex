defmodule AshOban.Changes.RunObanTrigger do
  @moduledoc """
  Runs an oban trigger by name.
  """

  use Ash.Resource.Change

  def change(changeset, opts, context) do
    trigger = AshOban.Info.oban_trigger(changeset.resource, opts[:trigger])

    if !trigger do
      raise "No such trigger #{opts[:trigger]} for resource #{inspect(changeset.resource)}"
    end

    Ash.Changeset.after_action(changeset, fn _changeset, result ->
      AshOban.run_trigger(
        result,
        trigger,
        Keyword.put(opts[:oban_job_opts] || [], :actor, context.actor)
      )

      {:ok, result}
    end)
  end
end
