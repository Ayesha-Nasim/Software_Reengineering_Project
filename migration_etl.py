import csv
import re
import mysql.connector
from datetime import datetime

VALID_STATUSES = {'P', 'C', 'X', 'H', 'R'}

def parse_appt_date(raw):
    parsed_date = datetime.strptime(raw.strip(), "%d/%m/%Y %H:%M")
    return parsed_date.strftime("%Y-%m-%d %H:%M:%S")

def split_room(raw):
    match = re.match(r"Room\s+(\d+)\s+(Block\s+[A-Za-z])", raw.strip())

    if not match:
        raise ValueError(f"Invalid room format: {raw}")

    room_number = int(match.group(1))
    building_block = match.group(2)

    return room_number, building_block

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",
    database="healthbridge"
)

cursor = conn.cursor()

# Create refactored appointments table
cursor.execute("""
CREATE TABLE IF NOT EXISTS appointments_refactored (
    appt_id INT PRIMARY KEY,
    patient_id INT,
    doc_id INT,
    appt_datetime DATETIME,
    status CHAR(1),
    fee FLOAT,
    discount FLOAT,
    room_number INT,
    building_block VARCHAR(50)
)
""")

inserted = 0
skipped = []

with open("appointments_legacy.csv", newline='', encoding='utf-8') as f:
    reader = csv.DictReader(f)

    for row in reader:

        if row['status'] not in VALID_STATUSES:
            skipped.append(row['appt_id'])
            continue

        appt_dt = parse_appt_date(row['appt_date'])

        room_no, block = split_room(row['room'])

        cursor.execute("""
        INSERT INTO appointments_refactored
        (appt_id, patient_id, doc_id, appt_datetime,
         status, fee, discount, room_number, building_block)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """,
        (
            int(row['appt_id']),
            int(row['patient_id']),
            int(row['doc_id']),
            appt_dt,
            row['status'],
            float(row['fee']),
            float(row['discount']),
            room_no,
            block
        ))

        inserted += 1

conn.commit()

print("Migration completed successfully.")
print(f"Inserted rows: {inserted}")
print(f"Skipped rows: {len(skipped)}")
print(f"Skipped appointment IDs: {skipped}")

cursor.close()
conn.close()