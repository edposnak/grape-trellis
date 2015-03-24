-- SELECT * FROM v_summary_fks;

WITH "groups" AS (
  SELECT 
    -- plain old columns
    "id", "name", 

    -- has many through relationship
    ( SELECT array_agg(r1) FROM (
        SELECT "users"."id", "users"."email", "users"."first_name", "users"."last_name"
        FROM "users", "user_groups" 
        WHERE "user_groups"."user_id" = "users"."id" AND "user_groups"."group_id" = "groups"."id"
    ) r1 )
    AS "users",

    -- has many through relationship
    ( SELECT array_agg(r2) FROM (
        SELECT "topics"."id", "topics"."name"
        FROM "topics", "topic_assignments" 
        WHERE "topic_assignments"."topic_id" = "topics"."id" AND "topic_assignments"."group_id" = "groups"."id"
    ) r2 )
    AS "topics",

    -- plain has many relationship
    ( SELECT array_agg(r3) FROM (
        SELECT "activity_logs"."id", "activity_logs"."event_id"
        FROM "activity_logs"
        WHERE "activity_logs"."group_id" = "groups"."id"
    ) r3 )
    AS "activity_logs",

    -- more plain old columns
    "member_owned"
    
  FROM "groups" 
  WHERE ("groups"."client_id" = 70)
)
  
SELECT array_to_json(array_agg(row_to_json("groups"))) AS "groups_json"

FROM "groups";
