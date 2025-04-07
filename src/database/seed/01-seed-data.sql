-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create location table
CREATE TABLE IF NOT EXISTS "location" (
    "id" uuid NOT NULL,
    "building" character varying NOT NULL,
    "locationName" character varying NOT NULL,
    "locationNumber" character varying NOT NULL,
    "area" decimal(10,3) NOT NULL,
    "parentId" uuid,
    "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
    "updatedAt" timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT "PK_876d7bdba03c72251ec4c2dc827" PRIMARY KEY ("id"),
    CONSTRAINT "UQ_876d7bdba03c72251ec4c2dc827" UNIQUE ("locationNumber"),
    CONSTRAINT "FK_876d7bdba03c72251ec4c2dc827" FOREIGN KEY ("parentId") REFERENCES "location"("id") ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Create closure table for tree structure
CREATE TABLE IF NOT EXISTS "location_closure" (
    "id_ancestor" uuid NOT NULL,
    "id_descendant" uuid NOT NULL,
    CONSTRAINT "PK_876d7bdba03c72251ec4c2dc828" PRIMARY KEY ("id_ancestor", "id_descendant"),
    CONSTRAINT "FK_876d7bdba03c72251ec4c2dc828_ancestor" FOREIGN KEY ("id_ancestor") REFERENCES "location"("id") ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT "FK_876d7bdba03c72251ec4c2dc828_descendant" FOREIGN KEY ("id_descendant") REFERENCES "location"("id") ON DELETE CASCADE ON UPDATE NO ACTION
);

-- Create indexes
CREATE INDEX IF NOT EXISTS "IDX_location_parent" ON "location"("parentId");
CREATE INDEX IF NOT EXISTS "IDX_location_closure_ancestor" ON "location_closure"("id_ancestor");
CREATE INDEX IF NOT EXISTS "IDX_location_closure_descendant" ON "location_closure"("id_descendant");

-- Declare variables for storing UUIDs
DO $$
DECLARE
    building_a_id uuid;
    building_a_floor1_id uuid;
    building_a_room101_id uuid;
    building_a_room102_id uuid;
    building_b_id uuid;
    building_b_floor1_id uuid;
    building_b_room101_id uuid;
    building_b_room102_id uuid;
    building_b_floor2_id uuid;
    building_b_room201_id uuid;
    building_b_room202_id uuid;
BEGIN
    -- Generate UUIDs
    building_a_id := uuid_generate_v4();
    building_a_floor1_id := uuid_generate_v4();
    building_a_room101_id := uuid_generate_v4();
    building_a_room102_id := uuid_generate_v4();
    building_b_id := uuid_generate_v4();
    building_b_floor1_id := uuid_generate_v4();
    building_b_room101_id := uuid_generate_v4();
    building_b_room102_id := uuid_generate_v4();
    building_b_floor2_id := uuid_generate_v4();
    building_b_room201_id := uuid_generate_v4();
    building_b_room202_id := uuid_generate_v4();

    -- Building A
    INSERT INTO "location" ("id", "building", "locationName", "locationNumber", "area", "createdAt", "updatedAt")
    VALUES (building_a_id, 'A', 'Building A', 'A', 1000.000, NOW(), NOW());

    -- Building A - Floor 1
    INSERT INTO "location" ("id", "building", "locationName", "locationNumber", "area", "parentId", "createdAt", "updatedAt")
    VALUES (building_a_floor1_id, 'A', 'Floor 1', 'A-01', 1000.000, building_a_id, NOW(), NOW());

    -- Building A - Floor 1 - Rooms
    INSERT INTO "location" ("id", "building", "locationName", "locationNumber", "area", "parentId", "createdAt", "updatedAt")
    VALUES 
        (building_a_room101_id, 'A', 'Room 101', 'A-01-01', 25.000, building_a_floor1_id, NOW(), NOW()),
        (building_a_room102_id, 'A', 'Room 102', 'A-01-02', 30.000, building_a_floor1_id, NOW(), NOW());

    -- Building B
    INSERT INTO "location" ("id", "building", "locationName", "locationNumber", "area", "createdAt", "updatedAt")
    VALUES (building_b_id, 'B', 'Building B', 'B', 1500.000, NOW(), NOW());

    -- Building B - Floor 1
    INSERT INTO "location" ("id", "building", "locationName", "locationNumber", "area", "parentId", "createdAt", "updatedAt")
    VALUES (building_b_floor1_id, 'B', 'Floor 1', 'B-01', 1500.000, building_b_id, NOW(), NOW());

    -- Building B - Floor 1 - Rooms
    INSERT INTO "location" ("id", "building", "locationName", "locationNumber", "area", "parentId", "createdAt", "updatedAt")
    VALUES 
        (building_b_room101_id, 'B', 'Room 101', 'B-01-01', 35.000, building_b_floor1_id, NOW(), NOW()),
        (building_b_room102_id, 'B', 'Room 102', 'B-01-02', 40.000, building_b_floor1_id, NOW(), NOW());

    -- Building B - Floor 2
    INSERT INTO "location" ("id", "building", "locationName", "locationNumber", "area", "parentId", "createdAt", "updatedAt")
    VALUES (building_b_floor2_id, 'B', 'Floor 2', 'B-02', 1500.000, building_b_id, NOW(), NOW());

    -- Building B - Floor 2 - Rooms
    INSERT INTO "location" ("id", "building", "locationName", "locationNumber", "area", "parentId", "createdAt", "updatedAt")
    VALUES 
        (building_b_room201_id, 'B', 'Room 201', 'B-02-01', 45.000, building_b_floor2_id, NOW(), NOW()),
        (building_b_room202_id, 'B', 'Room 202', 'B-02-02', 50.000, building_b_floor2_id, NOW(), NOW());

    -- Insert closure table entries for Building A hierarchy
    -- Building A self-reference
    INSERT INTO "location_closure" ("id_ancestor", "id_descendant")
    VALUES (building_a_id, building_a_id);

    -- Building A -> Floor 1
    INSERT INTO "location_closure" ("id_ancestor", "id_descendant")
    VALUES (building_a_id, building_a_floor1_id);

    -- Floor 1 self-reference
    INSERT INTO "location_closure" ("id_ancestor", "id_descendant")
    VALUES (building_a_floor1_id, building_a_floor1_id);

    -- Floor 1 -> Rooms
    INSERT INTO "location_closure" ("id_ancestor", "id_descendant")
    VALUES 
        (building_a_floor1_id, building_a_room101_id),
        (building_a_floor1_id, building_a_room102_id);

    -- Room self-references
    INSERT INTO "location_closure" ("id_ancestor", "id_descendant")
    VALUES 
        (building_a_room101_id, building_a_room101_id),
        (building_a_room102_id, building_a_room102_id);

    -- Building A -> Rooms (indirect)
    INSERT INTO "location_closure" ("id_ancestor", "id_descendant")
    VALUES 
        (building_a_id, building_a_room101_id),
        (building_a_id, building_a_room102_id);

    -- Insert closure table entries for Building B hierarchy
    -- Building B self-reference
    INSERT INTO "location_closure" ("id_ancestor", "id_descendant")
    VALUES (building_b_id, building_b_id);

    -- Building B -> Floors
    INSERT INTO "location_closure" ("id_ancestor", "id_descendant")
    VALUES 
        (building_b_id, building_b_floor1_id),
        (building_b_id, building_b_floor2_id);

    -- Floor self-references
    INSERT INTO "location_closure" ("id_ancestor", "id_descendant")
    VALUES 
        (building_b_floor1_id, building_b_floor1_id),
        (building_b_floor2_id, building_b_floor2_id);

    -- Floor 1 -> Rooms
    INSERT INTO "location_closure" ("id_ancestor", "id_descendant")
    VALUES 
        (building_b_floor1_id, building_b_room101_id),
        (building_b_floor1_id, building_b_room102_id);

    -- Floor 2 -> Rooms
    INSERT INTO "location_closure" ("id_ancestor", "id_descendant")
    VALUES 
        (building_b_floor2_id, building_b_room201_id),
        (building_b_floor2_id, building_b_room202_id);

    -- Room self-references
    INSERT INTO "location_closure" ("id_ancestor", "id_descendant")
    VALUES 
        (building_b_room101_id, building_b_room101_id),
        (building_b_room102_id, building_b_room102_id),
        (building_b_room201_id, building_b_room201_id),
        (building_b_room202_id, building_b_room202_id);

    -- Building B -> Rooms (indirect)
    INSERT INTO "location_closure" ("id_ancestor", "id_descendant")
    VALUES 
        (building_b_id, building_b_room101_id),
        (building_b_id, building_b_room102_id),
        (building_b_id, building_b_room201_id),
        (building_b_id, building_b_room202_id);
END $$;
