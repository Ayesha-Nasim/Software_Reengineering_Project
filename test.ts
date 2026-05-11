import "dotenv/config";

import { PrismaClient } from "./generated/prisma/client";
import { PrismaMariaDb } from "@prisma/adapter-mariadb";

const adapter = new PrismaMariaDb({
  host: "localhost",
  port: 3306,
  user: "root",
  password: "",
  database: "healthbridge",
});

const prisma = new PrismaClient({ adapter });

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