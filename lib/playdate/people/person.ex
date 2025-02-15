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

    read :list do
      prepare build(load: [:date_of_latest_activity])
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  relationships do
    has_many :activities, Playdate.People.Activity
  end

  aggregates do
    first :date_of_latest_activity, :activities, :date do
      sort date: :desc
      public? true
    end
  end
end
