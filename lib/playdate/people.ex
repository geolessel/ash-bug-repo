defmodule Playdate.People do
  @moduledoc false
  use Ash.Domain, otp_app: :playdate, extensions: [AshAdmin.Domain]

  resources do
    resource Playdate.People.Person do
      define :create_person, action: :create
      define :list_people, action: :list
    end
  end

  authorization do
    require_actor? true
  end
end
