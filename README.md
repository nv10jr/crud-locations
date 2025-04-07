# Locations Management API

A RESTful API for managing locations in a tree structure, built with NestJS, TypeORM, and PostgreSQL.

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
```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=locations_db
```

5. Create the PostgreSQL database:
```sql
CREATE DATABASE locations_db;
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