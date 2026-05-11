-- R1 - Fix Derived Data in billing
ALTER TABLE billing DROP COLUMN tax_amt;
ALTER TABLE billing DROP COLUMN grand_total;
ALTER TABLE billing DROP COLUMN balance;

CREATE OR REPLACE VIEW v_billing_summary AS
SELECT
    bill_no,
    pid,
    svc_cost,
    tax_pct,
    ROUND(svc_cost * tax_pct / 100, 2) AS tax_amt,
    ROUND(svc_cost + svc_cost * tax_pct / 100, 2) AS grand_total,
    paid,
    ROUND(svc_cost + svc_cost * tax_pct / 100 - paid, 2) AS balance
FROM billing;

-- R2 - Fix Overloaded Column in appointments.status
CREATE TABLE appt_status_ref (
    status_code CHAR(1) PRIMARY KEY,
    description VARCHAR(50) NOT NULL
);

INSERT INTO appt_status_ref VALUES
('P','Pending'),
('C','Completed'),
('X','Cancelled'),
('H','On Hold'),
('R','Rescheduled');

ALTER TABLE appointments
ADD CONSTRAINT fk_appt_status
FOREIGN KEY (status) REFERENCES appt_status_ref(status_code);

-- R3 - Fix Inconsistent Naming across doctors
ALTER TABLE doctors CHANGE DoctorID doctor_id INT;
ALTER TABLE doctors CHANGE FullName full_name VARCHAR(255);
ALTER TABLE doctors CHANGE Speciality speciality VARCHAR(255);
ALTER TABLE doctors CHANGE ContactNo contact_no VARCHAR(255);
ALTER TABLE doctors CHANGE JoinDt join_date VARCHAR(50);
ALTER TABLE doctors CHANGE Salary salary_monthly FLOAT;
ALTER TABLE doctors CHANGE isActive is_active CHAR(1);

-- R4 - Fix Missing Constraints in billing and appointments
ALTER TABLE pat_master
ADD PRIMARY KEY (pid);

ALTER TABLE billing
ADD PRIMARY KEY (bill_no);

DELETE FROM billing
WHERE pid NOT IN (
    SELECT pid FROM pat_master
);

DELETE FROM appointments
WHERE patient_id NOT IN (
    SELECT pid FROM pat_master
);

DELETE FROM appointments
WHERE doc_id NOT IN (
    SELECT doctor_id FROM doctors
);

ALTER TABLE billing
ADD CONSTRAINT fk_billing_patient
FOREIGN KEY (pid) REFERENCES pat_master(pid);

ALTER TABLE appointments
ADD CONSTRAINT fk_appt_patient
FOREIGN KEY (patient_id) REFERENCES pat_master(pid);

ALTER TABLE appointments
ADD CONSTRAINT fk_appt_doctor
FOREIGN KEY (doc_id) REFERENCES doctors(doctor_id);

-- R5 - Add Audit Trail to appointments
ALTER TABLE appointments
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
ON UPDATE CURRENT_TIMESTAMP;