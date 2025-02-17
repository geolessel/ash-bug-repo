defmodule Playdate.People.Person do
  use Ash.Resource,
    otp_app: :playdate,
    domain: Playdate.People,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer

  postgres do
    table "people"
    repo Playdate.Repo
  end

  actions do
    # defaults [:read, create: :*] # this always works
    defaults [:read]

    create :create do
      accept [:birthdate, :name]
      change relate_actor(:user)
    end

    read :list do
      prepare build(load: [:date_of_latest_activity])
    end

    update :update do
      accept :*
      # accept [:birthdate, name]
    end
  end

  policies do
    policy action_type(:create) do
      authorize_if always()
    end

    # This always works
    # policy action_type(:update) do
    #   authorize_if always()
    # end

    policy action_type([:destroy, :read, :update]) do
      authorize_if relates_to_actor_via(:user)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :birthdate, :map do
      allow_nil? true
      public? true

      constraints fields: [
                    year: [
                      type: :integer,
                      allow_nil?: true
                    ],
                    month: [
                      type: :integer,
                      allow_nil?: false,
                      constraints: [
                        min: 1,
                        max: 12
                      ]
                    ],
                    day: [
                      type: :integer,
                      allow_nil?: false,
                      constraints: [
                        min: 1,
                        max: 31
                      ]
                    ]
                  ]
    end

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :user, Playdate.People.Person
    has_many :activities, Playdate.People.Activity
  end

  aggregates do
    first :date_of_latest_activity, :activities, :date do
      sort date: :desc
      public? true
    end
  end
end
