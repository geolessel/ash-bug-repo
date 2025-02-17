# Playdate (an Ash bug repo)

## Map update with authorization bug

Tag: `map-bug` (https://github.com/geolessel/ash-bug-repo/releases/tag/map-bug)

Original report/discussion: https://elixirforum.com/t/updating-map-column-fails-authorization-in-very-specific-scenarios/69433

To replicate, setup the application and in IEx run

```elixir
{:ok, geo} = Playdate.People.create_person(%{name: "Geoffrey Lessel"}, actor: nil, authorize?: false)
{:ok, zach} = Playdate.People.create_person(%{name: "Zach Daniel"}, actor: geo)

Playdate.People.update_person(zach, %{name: "Zach 'The Great' Daniel"}, actor: geo)
# Works!

Playdate.People.update_person(zach, %{birthdate: %{year: 2000, month: 1, day: 1}}, actor: geo)
# BOOM!

# 20:30:49.475 [debug] QUERY ERROR source="people" db=0.0ms queue=2.1ms idle=1068.2ms
# UPDATE "people" AS p0 SET "birthdate" = s1."__new_birthdate", "updated_at" = s1."__new_updated_at" FROM (SELECT $1::timestamp::timestamp AS "__new_updated_at", $2 AS "__new_birthdate", sp0."id" AS "id" FROM "people" AS sp0 LEFT OUTER JOIN "public"."people" AS sp1 ON sp0."user_id" = sp1."id" WHERE (sp0."id"::uuid = $3::uuid) AND ((CASE WHEN sp1."id"::uuid = $4::uuid THEN $5 ELSE ash_raise_error($6::jsonb) END))) AS s1 WHERE (p0."id" = s1."id") RETURNING p0."id", p0."name", p0."birthdate", p0."inserted_at", p0."updated_at", p0."user_id" [~U[2025-02-17 02:30:49.472281Z], %{month: 2, day: 4, year: 2000}, "f8af8361-bc73-4fe4-8891-1c7ee75c9cae", "202c002e-8bbc-45dd-89e0-623f07360d0d", true, "{\"input\":{\"authorizer\":\"Ash.Policy.Authorizer\"},\"exception\":\"Ash.Error.Forbidden.Placeholder\"}"]
# ** (Ash.Error.Unknown)
# Bread Crumbs:
#   > Exception raised in bulk update: Playdate.People.Person.update
#   > Exception raised in: Playdate.People.Person.update
#
# Unknown Error
#
# * ** (Postgrex.Error) ERROR 42804 (datatype_mismatch) column "birthdate" is of type jsonb but expression is of type text
#
#     query: UPDATE "people" AS p0 SET "birthdate" = s1."__new_birthdate", "updated_at" = s1."__new_updated_at" FROM (SELECT $1::timestamp::timestamp AS "__new_updated_at", $2 AS "__new_birthdate", sp0."id" AS "id" FROM "people" AS sp0 LEFT OUTER JOIN "public"."people" AS sp1 ON sp0."user_id" = sp1."id" WHERE (sp0."id"::uuid = $3::uuid) AND ((CASE WHEN sp1."id"::uuid = $4::uuid THEN $5 ELSE ash_raise_error($6::jsonb) END))) AS s1 WHERE (p0."id" = s1."id") RETURNING p0."id", p0."name", p0."birthdate", p0."inserted_at", p0."updated_at", p0."user_id"
#
#     hint: You will need to rewrite or cast the expression.
#   (ecto_sql 3.12.1) lib/ecto/adapters/sql.ex:1096: Ecto.Adapters.SQL.raise_sql_call_error/1
#   (ecto_sql 3.12.1) lib/ecto/adapters/sql.ex:994: Ecto.Adapters.SQL.execute/6
#   (ecto 3.12.5) lib/ecto/repo/queryable.ex:232: Ecto.Repo.Queryable.execute/4
#   (ash_postgres 2.5.3) lib/data_layer.ex:1503: AshPostgres.DataLayer.update_query/4
#   (ash 3.4.63) lib/ash/actions/update/bulk.ex:576: Ash.Actions.Update.Bulk.do_atomic_update/5
#   (ash 3.4.63) lib/ash/actions/update/bulk.ex:272: Ash.Actions.Update.Bulk.run/6
#   (ash 3.4.63) lib/ash/actions/update/update.ex:165: Ash.Actions.Update.run/4
#   (ash 3.4.63) lib/ash.ex:2736: Ash.update/3
#     (ecto_sql 3.12.1) lib/ecto/adapters/sql.ex:1096: Ecto.Adapters.SQL.raise_sql_call_error/1
#     (ecto_sql 3.12.1) lib/ecto/adapters/sql.ex:994: Ecto.Adapters.SQL.execute/6
#     (ecto 3.12.5) lib/ecto/repo/queryable.ex:232: Ecto.Repo.Queryable.execute/4
#     (ash_postgres 2.5.3) lib/data_layer.ex:1503: AshPostgres.DataLayer.update_query/4
#     (ash 3.4.63) lib/ash/actions/update/bulk.ex:576: Ash.Actions.Update.Bulk.do_atomic_update/5
#     (ash 3.4.63) lib/ash/actions/update/bulk.ex:272: Ash.Actions.Update.Bulk.run/6
#     (ash 3.4.63) lib/ash/actions/update/update.ex:165: Ash.Actions.Update.run/4
#     iex:16: (file)
```

## Actor aggregate sorting bug

Tag: `actor-bug` (https://github.com/geolessel/ash-bug-repo/releases/tag/actor-bug)

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
