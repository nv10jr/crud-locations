# Locations Management API

A RESTful API for managing locations in a tree structure, built with NestJS, TypeORM, and PostgreSQL.

![image](https://github.com/user-attachments/assets/353b1b9d-3166-4ff4-833b-c458c9dd6e95)

## Features

- CRUD operations for locations
- Tree structure support with parent-child relationships
- Swagger API documentation
- Input validation
- Error handling
- Logging system
- Docker support for easy deployment

## Prerequisites

### For Local Development
- Node.js (v16 or later)
- PostgreSQL (v12 or later)
- npm or yarn

### For Docker
- Docker
- Docker Compose

## Installation

### Local Development Setup

1. Clone the repository:
```bash
git clone git@github.com:nv10jr/crud-locations.git
cd crud-locations
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables:
Copy the `.env.example` file to `.env` and update the values:
```bash
cp .env.example .env
```

4. Update the `.env` file with your PostgreSQL configuration:
```bash
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=locations_db
```

### Docker Setup

1. Clone the repository:
```bash
git clone git@github.com:nv10jr/crud-locations.git
cd crud-locations
```

2. Configure environment variables:
Copy the `.env.example` file to `.env` and update the values:
```bash
cp .env.example .env
```

3. Update the `.env` file with your desired PostgreSQL configuration:
```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=locations_db
```

## Running the Application

### Local Development

1. Start the application in development mode:
```bash
npm run start:dev
```

2. The application will be available at `http://localhost:3000`
3. Access the Swagger API documentation at `http://localhost:3000/api`

### Docker Development

1. Build and start the containers:
```bash
docker compose up --build
```

2. The application will be available at `http://localhost:3000`
3. Access the Swagger API documentation at `http://localhost:3000/api`

### Docker Production

1. Build the production image:
```bash
docker compose -f docker-compose.prod.yml up --build
```

2. The application will be available at `http://localhost:3000`

## Database Seeding

The application comes with sample data that is automatically seeded:

### Local Development
Run the seed script:
```bash
npm run seed
```

### Docker
The seeding happens automatically when the PostgreSQL container starts for the first time.

To reset the database and re-seed:
```bash
docker compose down -v
docker compose up --build
```

## API Endpoints

- `POST /locations` - Create a new location
- `GET /locations` - Get all locations as a tree structure
- `GET /locations/:id` - Get a specific location by ID
- `GET /locations/:id/tree` - Get a location's tree structure by root ID
- `PATCH /locations/:id` - Update a location
- `DELETE /locations/:id` - Delete a location

## Database Schema

### Location Table

```sql
CREATE TABLE "location" (
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
```

### Location Closure Table (for Tree Structure)

```sql
CREATE TABLE "location_closure" (
    "id_ancestor" uuid NOT NULL,
    "id_descendant" uuid NOT NULL,
    CONSTRAINT "PK_876d7bdba03c72251ec4c2dc828" PRIMARY KEY ("id_ancestor", "id_descendant"),
    CONSTRAINT "FK_876d7bdba03c72251ec4c2dc828_ancestor" FOREIGN KEY ("id_ancestor") REFERENCES "location"("id") ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT "FK_876d7bdba03c72251ec4c2dc828_descendant" FOREIGN KEY ("id_descendant") REFERENCES "location"("id") ON DELETE CASCADE ON UPDATE NO ACTION
);
```

#### Fields Description

| Field          | Type                    | Description                                    |
|----------------|-------------------------|------------------------------------------------|
| id             | UUID                    | Primary key                                    |
| building       | VARCHAR                 | Building identifier (e.g., A, B)               |
| locationName   | VARCHAR                 | Name of the location                           |
| locationNumber | VARCHAR                 | Unique location number (e.g., A-01, B-02-01)   |
| area           | DECIMAL(10, 3)          | Area in square meters                          |
| parentId       | UUID                    | Reference to parent location (self-reference)   |
| createdAt      | TIMESTAMP WITH TIME ZONE| Timestamp of record creation                   |
| updatedAt      | TIMESTAMP WITH TIME ZONE| Timestamp of last update                       |

#### Closure Table Fields

| Field          | Type                    | Description                                    |
|----------------|-------------------------|------------------------------------------------|
| id_ancestor    | UUID                    | Reference to ancestor location                 |
| id_descendant  | UUID                    | Reference to descendant location               |

#### Sample Data

The database comes pre-seeded with the following locations in a tree structure:

| Building | Location Name | Location Number | Area (m²) | Parent Location |
|----------|--------------|-----------------|-----------|-----------------|
| A        | Building A   | A               | 1000.000  | -              |
| A        | Floor 1      | A-01            | 1000.000  | A              |
| A        | Room 101     | A-01-01         | 25.000    | A-01           |
| A        | Room 102     | A-01-02         | 30.000    | A-01           |
| B        | Building B   | B               | 1500.000  | -              |
| B        | Floor 1      | B-01            | 1500.000  | B              |
| B        | Room 101     | B-01-01         | 35.000    | B-01           |
| B        | Room 102     | B-01-02         | 40.000    | B-01           |
| B        | Floor 2      | B-02            | 1500.000  | B              |
| B        | Room 201     | B-02-01         | 45.000    | B-02           |
| B        | Room 202     | B-02-02         | 50.000    | B-02           |

The locations are organized in a tree structure where:
- Building A and Building B are root locations (no parent)
- Each building has floors as direct children
- Each floor has rooms as direct children
- The closure table maintains all ancestor-descendant relationships
- Each location has a unique location number
- Areas are specified in square meters
- All locations have creation and update timestamps

## Example Usage

1. Create a new location:
```bash
curl -X POST http://localhost:3000/locations \
  -H "Content-Type: application/json" \
  -d '{
    "building": "A",
    "locationName": "Level 1",
    "locationNumber": "A-01",
    "area": 100.920
  }'
```

2. Get all locations:
```bash
curl http://localhost:3000/locations
```

## Development Tips

### Local Development
- Use `npm run start:dev` for development with hot-reload
- Use `npm run build` to build the application
- Use `npm run start:prod` to run the production build

### Docker Development
- Use `docker compose up --build` to start the development environment
- Use `docker compose down` to stop the containers
- Use `docker compose down -v` to stop the containers and remove volumes
- Changes to source files will be reflected automatically due to volume mounting

## Error Handling

The API includes proper error handling for:
- Invalid input data
- Not found resources
- Parent-child relationship conflicts
- Database errors

## Logging

The application uses Winston for logging:
- Console logging for development
- File logging for production (error.log and combined.log) 
