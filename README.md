# Playdate (an Ash bug repo)

This exists to exercise an Ash bug when sorting by an aggregate when also requiring an actor.

Original bug report/discussion: https://elixirforum.com/t/forbidden-error-when-trying-to-sort-on-aggregate-while-an-actor-is-required/69371

To replicate, set up the application as normal (including setting up the postgres db and repo), then in IEx...

```elixir
{:ok, geo} = Playdate.People.create_person(%{name: "Geoffrey Lessel"}, actor: nil)
{:ok, _activity} = Playdate.People.create_activity(%{date: ~D[2025-02-15], person_id: geo.id}, actor: nil)

Playdate.People.list_people!(actor: nil, query: Ash.Query.sort(Playdate.People.Person, [name: :desc]))
# Runs just fine and includes the `date_of_latest_activity` aggregate!

Playdate.People.list_people!(actor: nil, query: Ash.Query.sort(Playdate.People.Person, [date_of_latest_activity: :desc]))
# BOOM!

# ** (Ash.Error.Forbidden)
# Bread Crumbs:
#   > Exception raised in: Playdate.People.Person.list
#
# Forbidden Error
#
# * The domain Playdate.People requires that an actor is provided at all times and none was provided.
#   (ash 3.4.63) lib/ash/error/forbidden/domain_requires_actor.ex:4: Ash.Error.Forbidden.DomainRequiresActor.exception/1
#   (ash 3.4.63) lib/ash/actions/helpers.ex:198: Ash.Actions.Helpers.add_actor/3
#   (ash 3.4.63) lib/ash/actions/helpers.ex:150: Ash.Actions.Helpers.set_opts/3
#   (ash 3.4.63) lib/ash/actions/helpers.ex:139: Ash.Actions.Helpers.set_context_and_get_opts/3
#   (ash 3.4.63) lib/ash/query/query.ex:537: Ash.Query.for_read/4
#   (ash 3.4.63) lib/ash/actions/read/read.ex:2994: Ash.Actions.Read.query_aggregate_from_resource_aggregate/2
#   (ash 3.4.63) lib/ash/actions/read/read.ex:1199: anonymous fn/3 in Ash.Actions.Read.hydrate_sort/6
#     (ash 3.4.63) lib/ash/actions/helpers.ex:197: Ash.Actions.Helpers.add_actor/3
#     (ash 3.4.63) lib/ash/actions/helpers.ex:150: Ash.Actions.Helpers.set_opts/3
#     (ash 3.4.63) lib/ash/actions/helpers.ex:139: Ash.Actions.Helpers.set_context_and_get_opts/3
#     (ash 3.4.63) lib/ash/query/query.ex:537: Ash.Query.for_read/4
#     (ash 3.4.63) lib/ash/actions/read/read.ex:2994: Ash.Actions.Read.query_aggregate_from_resource_aggregate/2
#     (ash 3.4.63) lib/ash/actions/read/read.ex:1199: anonymous fn/3 in Ash.Actions.Read.hydrate_sort/6
#     (elixir 1.17.1) lib/enum.ex:4858: Enumerable.List.reduce/3
#     iex:19: (file)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `playdate` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:playdate, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/playdate>.
