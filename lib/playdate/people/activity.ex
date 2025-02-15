defmodule Playdate.People.Activity do
  @moduledoc false
  use Ash.Resource,
    otp_app: :playdate,
    domain: Playdate.People,
    data_layer: AshPostgres.DataLayer

  alias Playdate.People.Person

  postgres do
    table "activities"
    repo Playdate.Repo
  end

  actions do
    defaults [:read]

    create :create do
      accept [:date, :person_id]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :date, :date do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :person, Person, allow_nil?: false
  end
end
