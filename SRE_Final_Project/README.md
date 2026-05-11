# HealthBridge Database Migration Project

### 1. **Project Overview**

This project involves the migration and refactoring of the HealthBridge Hospital Management System's database. The goal is to normalize and refactor the legacy schema, implement an ETL pipeline to migrate data, and apply best practices for schema management and security.

### 2. **Setup Instructions**

1. **Install Prerequisites**
    - **MySQL**: Install MySQL or use **XAMPP** to run MySQL locally.
    - **Prisma**: Install Prisma by running:
      ```bash
      npm install prisma @prisma/client --save-dev
      ```

2. **Set Up `.env` for MySQL Connection**
    - Create a `.env` file in the root directory and set the database URL:
    ```env
    DATABASE_URL="mysql://root:@localhost:3306/healthbridge"
    ```

3. **Run SQL Refactoring Scripts**
    - Navigate to the `sql/` directory, and run the refactoring SQL scripts.
    - The SQL file **`refactoring.sql`** includes scripts for table normalization, constraint fixing, and other schema updates.
    - Execute the SQL file in MySQL or phpMyAdmin.

    ```bash
    mysql -u root -p healthbridge < path/to/sql/refactoring.sql
    ```

4. **Run Prisma Migrations**
    - Apply schema changes by running Prisma migration:
    ```bash
    npx prisma migrate dev --name healthbridge_init
    ```

5. **Install Required Python Libraries**
    - For data migration, install the required Python libraries:
    ```bash
    pip install mysql-connector-python
    ```

6. **Run the Data Migration Script**
    - Run the ETL migration script to migrate data from the legacy CSV to the refactored schema:
    ```bash
    python migration_etl.py
    ```

### 3. **SQL Scripts**

- **`refactoring.sql`**: Contains SQL scripts for the normalization and refactoring of the legacy database schema (R1 to R5).
- These scripts refactor the existing database by fixing derived data, overloaded columns, naming issues, and adding necessary constraints.

### 4. **Prisma Migrations**
- Use **Prisma** for schema management and to push any new changes to the database.
    - Generate Prisma Client:
    ```bash
    npx prisma generate
    ```

    - Apply schema changes using Prisma:
    ```bash
    npx prisma db push
    ```

### 5. **Testing the Database**
- Use **test.ts** to query the `doctors` table and ensure the data migration works as expected.

```ts
import "dotenv/config";
import { PrismaClient } from "./generated/prisma/client";

const prisma = new PrismaClient();

async function main() {
  const doctors = await prisma.doctors.findMany();
  console.log("Doctors Table Data:");
  console.log(doctors);
}

main()
  .catch(console.error)
  .finally(async () => {
    await prisma.$disconnect();
  });