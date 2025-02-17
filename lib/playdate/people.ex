defmodule Playdate.People do
  @moduledoc false
  use Ash.Domain, otp_app: :playdate, extensions: [AshAdmin.Domain]

  resources do
    resource Playdate.People.Person do
      define :create_person, action: :create
      define :update_person, action: :update
      define :list_people, action: :list
    end

    resource Playdate.People.Activity do
      define :create_activity, action: :create
    end
  end

  authorization do
    require_actor? true
  end
end
