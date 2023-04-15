DROP DATABASE IF EXISTS medical_center;

CREATE DATABASE medical_center;
USE medical_center;

CREATE TABLE administrator(
    admin_id INTEGER UNSIGNED AUTO_INCREMENT NOT NULL,
    name VARCHAR(50) NOT NULL,
    username VARCHAR(20)  NOT NULL UNIQUE,
    password VARCHAR(70) NOT NULL,
    email VARCHAR(40) NOT NULL,
    birthdate DATE NOT NULL,
    funds DECIMAL(9,2) NOT NULL,
    CONSTRAINT pk_admin PRIMARY KEY (admin_id)
);

CREATE TABLE patient(
    patient_id INTEGER UNSIGNED AUTO_INCREMENT NOT NULL,
    cui VARCHAR(13) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    username VARCHAR(20)  NOT NULL UNIQUE,
    password VARCHAR(70) NOT NULL,
    email VARCHAR(40) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    address VARCHAR(50) NOT NULL,
    birthdate DATE NOT NULL,
    funds DECIMAL(9,2) NOT NULL,
    CONSTRAINT pk_patient PRIMARY KEY (patient_id)
);

CREATE TABLE doctor(
    doctor_id INTEGER UNSIGNED AUTO_INCREMENT NOT NULL,
    cui VARCHAR(13) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    username VARCHAR(20)  NOT NULL UNIQUE,
    password VARCHAR(70) NOT NULL,
    email VARCHAR(40) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    address VARCHAR(50) NOT NULL,
    birthdate DATE NOT NULL,
    funds DECIMAL(9,2) NOT NULL,
    state ENUM('active', 'inactive') NOT NULL,
    CONSTRAINT pk_doctor PRIMARY KEY (doctor_id)
);

CREATE TABLE laboratory(
    laboratory_id INTEGER UNSIGNED AUTO_INCREMENT NOT NULL,
    cui VARCHAR(13) NOT NULL,
    name VARCHAR(50) NOT NULL,
    username VARCHAR(20)  NOT NULL UNIQUE,
    password VARCHAR(70) NOT NULL,
    email VARCHAR(40) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    address VARCHAR(50) NOT NULL,
    foundation_date DATE NOT NULL,
    funds DECIMAL(9,2) NOT NULL,
    state ENUM('active', 'inactive') NOT NULL,
    CONSTRAINT pk_laboratory PRIMARY KEY (laboratory_id)
);

CREATE TABLE specialty(
    specialty_id INTEGER UNSIGNED AUTO_INCREMENT NOT NULL,
    name VARCHAR(70) NOT NULL UNIQUE,
    description VARCHAR(300) NOT NULL UNIQUE,
    CONSTRAINT pk_specialty PRIMARY KEY (specialty_id)
);

CREATE TABLE doctor_specialty(
    doctor_specialty_id INTEGER UNSIGNED AUTO_INCREMENT NOT NULL,
    doctor_id INTEGER UNSIGNED NOT NULL,
    specialty_id INTEGER UNSIGNED NOT NULL,
    price DECIMAL(6,2) NOT NULL,
    state ENUM('active', 'inactive') NOT NULL,
    CONSTRAINT pk_doctor_specialty PRIMARY KEY (doctor_specialty_id),
    CONSTRAINT fk_doctor_specialty_to_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id),
    CONSTRAINT fk_doctor_specialty_to_specialty
        FOREIGN KEY (specialty_id) REFERENCES specialty(specialty_id)
);

CREATE TABLE schedule(
    schedule_id INTEGER UNSIGNED AUTO_INCREMENT NOT NULL,
    upper_limit TIME NOT NULL,
    lower_limit TIME NOT NULL,
    CONSTRAINT pk_schedule PRIMARY KEY (schedule_id)
);

CREATE TABLE doctor_schedule(
    doctor_schedule_id INTEGER UNSIGNED AUTO_INCREMENT NOT NULL,
    doctor_id INTEGER UNSIGNED NOT NULL,
    schedule_id INTEGER UNSIGNED NOT NULL,
    state ENUM('active', 'inactive') NOT NULL,
    init_date DATE NOT NULL,
    final_date DATE NULL,
    CONSTRAINT pk_doctor_schedule PRIMARY KEY (doctor_schedule_id),
    CONSTRAINT fk_doctor_schedule_to_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id),
    CONSTRAINT fk_doctor_schedule_to_schedule
        FOREIGN KEY (schedule_id) REFERENCES schedule(schedule_id)
);

CREATE TABLE exam(
    exam_id INTEGER UNSIGNED AUTO_INCREMENT NOT NULL,
    name VARCHAR(70) NOT NULL UNIQUE,
    description VARCHAR(300) NOT NULL UNIQUE,
    CONSTRAINT pk_exam PRIMARY KEY (exam_id)
);

CREATE TABLE laboratory_exam(
    laboratory_exam_id INTEGER UNSIGNED AUTO_INCREMENT NOT NULL,
    laboratory_id INTEGER UNSIGNED NOT NULL,
    exam_id INTEGER UNSIGNED NOT NULL,
    price DECIMAL(6,2) NOT NULL,
    state ENUM('active', 'inactive') NOT NULL,
    CONSTRAINT pk_laboratory_exam PRIMARY KEY (laboratory_exam_id),
    CONSTRAINT fk_laboratory_exam_to_laboratory
        FOREIGN KEY (laboratory_id) REFERENCES laboratory(laboratory_id),
    CONSTRAINT fk_laboratory_exam_to_exam
        FOREIGN KEY (exam_id) REFERENCES exam(exam_id)
);

CREATE TABLE consultation(
    consultation_id INTEGER UNSIGNED AUTO_INCREMENT NOT NULL,
    patient_id INTEGER UNSIGNED NOT NULL,
    doctor_specialty_id INTEGER UNSIGNED NOT NULL,
    doctor_schedule_id INTEGER UNSIGNED NOT NULL,
    state ENUM('scheduled', 'finished', 'pending exam', 'pending review') NOT NULL,
    scheduled_date DATE NOT NULL,
    creation_date DATE NOT NULL,
    report VARCHAR(300) NOT NULL,
    price DECIMAL(6,2) NOT NULL,
    revenue DECIMAL(6,2) NOT NULL,
    CONSTRAINT pk_consultation PRIMARY KEY (consultation_id),
    CONSTRAINT fk_consultation_to_patient
        FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    CONSTRAINT fk_consultation_to_doctor_specialty
        FOREIGN KEY (doctor_specialty_id) REFERENCES doctor_specialty(doctor_specialty_id),
    CONSTRAINT fk_consultation_to_doctor_schedule
        FOREIGN KEY (doctor_schedule_id) REFERENCES doctor_schedule(doctor_schedule_id)
);

CREATE TABLE required_exam(
    consultation_id INTEGER UNSIGNED NOT NULL,
    exam_id INTEGER UNSIGNED NOT NULL,
    results_route VARCHAR(80) NOT NULL UNIQUE,
    CONSTRAINT pk_required_exam PRIMARY KEY (consultation_id, exam_id),
    CONSTRAINT fk_required_exam_to_consultation
        FOREIGN KEY (consultation_id) REFERENCES consultation(consultation_id),
    CONSTRAINT fk_required_exam_to_exam
        FOREIGN KEY (exam_id) REFERENCES exam(exam_id)
);

CREATE TABLE exam_request(
    exam_request_id INTEGER UNSIGNED AUTO_INCREMENT NOT NULL,
    patient_id INTEGER UNSIGNED NOT NULL,
    laboratory_id INTEGER UNSIGNED NOT NULL,
    state ENUM('pending', 'finished') NOT NULL,
    creation_date DATE NOT NULL,
    finished_date DATE NOT NULL,
    price DECIMAL(6,2) NOT NULL,
    revenue DECIMAL(6,2) NOT NULL,
    CONSTRAINT pk_exam_request PRIMARY KEY (exam_request_id),
    CONSTRAINT fk_exam_request_to_patient
        FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    CONSTRAINT fk_exam_request_to_laboratory
        FOREIGN KEY (laboratory_id) REFERENCES laboratory(laboratory_id)
);

CREATE TABLE requested_exam(
    laboratory_exam_id INTEGER UNSIGNED NOT NULL,
    exam_request_id INTEGER UNSIGNED NOT NULL,
    results_route VARCHAR(80) NOT NULL UNIQUE,
    CONSTRAINT pk_requested_exam PRIMARY KEY (laboratory_exam_id, exam_request_id),
    CONSTRAINT fk_requested_exam_to_laboratory_exam
        FOREIGN KEY (laboratory_exam_id) REFERENCES laboratory_exam(laboratory_exam_id),
    CONSTRAINT fk_requested_exam_to_exam_request_id
        FOREIGN KEY (exam_request_id) REFERENCES exam_request(exam_request_id)
);

CREATE TABLE suggested_exam(
    suggested_exam_id INTEGER UNSIGNED AUTO_INCREMENT NOT NULL,
    laboratory_id INTEGER UNSIGNED NOT NULL,
    name VARCHAR(70) NOT NULL UNIQUE,
    description VARCHAR(300) NOT NULL UNIQUE,
    state ENUM('pending', 'accepted', 'rejected') NOT NULL,
    CONSTRAINT pk_suggested_exam PRIMARY KEY (suggested_exam_id),
    CONSTRAINT fk_suggested_exam_to_laboratory
        FOREIGN KEY (laboratory_id) REFERENCES laboratory(laboratory_id)
);

CREATE TABLE suggested_specialty(
    suggested_specialty_id INTEGER UNSIGNED AUTO_INCREMENT NOT NULL,
    doctor_id INTEGER UNSIGNED NOT NULL,
    name VARCHAR(70) NOT NULL UNIQUE,
    description VARCHAR(300) NOT NULL UNIQUE,
    state ENUM('pending', 'accepted', 'rejected') NOT NULL,
    CONSTRAINT pk_suggested_specialty PRIMARY KEY (suggested_specialty_id),
    CONSTRAINT fk_suggested_specialty_to_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id)
);

CREATE TABLE fund_recharge(
    recharge_id INTEGER UNSIGNED AUTO_INCREMENT NOT NULL,
    patient_id INTEGER UNSIGNED NOT NULL,
    amount DECIMAL(6,2) NOT NULL,
    date_time DATETIME NOT NULL,
    CONSTRAINT pk_fund_recharge PRIMARY KEY (recharge_id),
    CONSTRAINT fk_fund_recharge_to_patient
        FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
);

CREATE TABLE revenue_percentage(
    init_date DATETIME NOT NULL,
    percentage INTEGER UNSIGNED NOT NULL,
    CONSTRAINT pk_revenue_percentage PRIMARY KEY (init_date)
);

INSERT INTO revenue_percentage SET init_date=NOW(), percentage=4;

INSERT INTO schedule SET schedule_id=1, upper_limit='08:00:00', lower_limit='09:00:00';
INSERT INTO schedule SET schedule_id=2, upper_limit='09:00:00', lower_limit='10:00:00';
INSERT INTO schedule SET schedule_id=3, upper_limit='10:00:00', lower_limit='11:00:00';
INSERT INTO schedule SET schedule_id=4, upper_limit='11:00:00', lower_limit='12:00:00';
INSERT INTO schedule SET schedule_id=5, upper_limit='13:00:00', lower_limit='14:00:00';
INSERT INTO schedule SET schedule_id=6, upper_limit='14:00:00', lower_limit='15:00:00';
INSERT INTO schedule SET schedule_id=7, upper_limit='15:00:00', lower_limit='16:00:00';
