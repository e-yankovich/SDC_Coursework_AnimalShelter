DROP TABLE IF EXISTS fact_adoption, fact_medical_visit, bridge_employee_role, dim_pet, dim_adopter, dim_employee, dim_role, dim_shelter, dim_breed, dim_date CASCADE;

CREATE TABLE IF NOT EXISTS fact_adoption (
     adoption_id INT PRIMARY KEY,
     date_key INT,
     pet_key INT,
     adopter_key INT,
     shelter_key INT,
     adoption_count INT
);

CREATE TABLE IF NOT EXISTS fact_medical_visit (
    visit_id INT PRIMARY KEY,
    date_key INT,
    full_date DATE,
    pet_key INT,
    vet_key INT,
    shelter_key INT,
    visit_count INT,
    next_visit_days INT,
    next_visit_date DATE
);

CREATE TABLE IF NOT EXISTS dim_pet (
    pet_key SERIAL PRIMARY KEY,
    pet_id INT,
    name VARCHAR(50),
    sex CHAR(1),
    color VARCHAR(30),
    breed_key INT,
    vaccinated BOOLEAN,
    special_care_required BOOLEAN,
    weight NUMERIC(6,3),
    age_months INT,
    is_current BOOLEAN
    );

CREATE TABLE IF NOT EXISTS dim_adopter (
    adopter_key INT PRIMARY KEY,
    full_name VARCHAR(100),
    city_name VARCHAR(100),
    country_name VARCHAR(100)
    );

CREATE TABLE IF NOT EXISTS dim_employee (
    employee_key INT PRIMARY KEY,
    full_name VARCHAR(100),
    shelter_key INT
    );

CREATE TABLE IF NOT EXISTS dim_role (
    role_key INT PRIMARY KEY,
    role_name VARCHAR(50)
    );

CREATE TABLE IF NOT EXISTS dim_shelter (
    shelter_key INT PRIMARY KEY,
    shelter_name VARCHAR(100),
    city_name VARCHAR(100),
    country_name VARCHAR(100)
    );

CREATE TABLE IF NOT EXISTS dim_breed (
    breed_key INT PRIMARY KEY,
    breed_name VARCHAR(50),
    species_name VARCHAR(50)
    );

CREATE TABLE IF NOT EXISTS dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    day INT,
    month INT,
    year INT,
    quarter INT,
    weekday_name VARCHAR(10)
    );

CREATE TABLE IF NOT EXISTS bridge_employee_role (
    PRIMARY KEY (employee_key, role_key)
    employee_key INT,
    role_key INT
);
