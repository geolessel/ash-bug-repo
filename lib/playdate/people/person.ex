defmodule Playdate.People.Person do
  use Ash.Resource,
    otp_app: :playdate,
    domain: Playdate.People,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "people"
    repo Playdate.Repo
  end

  actions do
    defaults [:read, create: :*]

    read :list
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    timestamps()
  end
end
