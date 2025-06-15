DROP TABLE IF EXISTS MedicalRecord CASCADE;
DROP TABLE IF EXISTS AdoptionHistory CASCADE;
DROP TABLE IF EXISTS AdoptionRequest CASCADE;
DROP TABLE IF EXISTS Pet CASCADE;
DROP TABLE IF EXISTS ShelterEmployee CASCADE;
DROP TABLE IF EXISTS Adopter CASCADE;
DROP TABLE IF EXISTS Breed CASCADE;
DROP TABLE IF EXISTS Species CASCADE;
DROP TABLE IF EXISTS Shelter CASCADE;
DROP TABLE IF EXISTS City CASCADE;
DROP TABLE IF EXISTS Country CASCADE;

CREATE TABLE IF NOT EXISTS Country (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS City (
    city_id SERIAL PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    country_id INT REFERENCES Country(country_id)
);

CREATE TABLE IF NOT EXISTS Species (
    species_id SERIAL PRIMARY KEY,
    species_name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS Breed (
    breed_id SERIAL PRIMARY KEY,
    breed_name VARCHAR(50) NOT NULL,
    species_id INT NOT NULL REFERENCES Species(species_id)
);

CREATE TABLE IF NOT EXISTS Shelter (
    shelter_id SERIAL PRIMARY KEY,
    shelter_name VARCHAR(100) NOT NULL,
    address TEXT,
    city_id INT REFERENCES City(city_id),
    phone VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS Adopter (
    adopter_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(120) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(20),
    passport_number VARCHAR(20),
    address TEXT,
    city_id INT REFERENCES City(city_id)
);

CREATE TABLE IF NOT EXISTS ShelterEmployee (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    is_vet BOOLEAN DEFAULT FALSE,
    shelter_id INT NOT NULL REFERENCES Shelter(shelter_id)
);

CREATE TABLE IF NOT EXISTS Pet (
    pet_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    sex CHAR(1) CHECK (sex IN ('M', 'F')),
    color VARCHAR(30),
    age_months INT,
    weight NUMERIC(6,3),
    photo TEXT,
    vaccinated BOOLEAN DEFAULT FALSE,
    admission_date DATE NOT NULL,
    special_care_required BOOLEAN DEFAULT FALSE,
    breed_id INT REFERENCES Breed(breed_id),
    shelter_id INT REFERENCES Shelter(shelter_id),
    curator_id INT REFERENCES ShelterEmployee(employee_id)
);

CREATE TABLE IF NOT EXISTS AdoptionRequest (
    request_id SERIAL PRIMARY KEY,
    adopter_id INT NOT NULL REFERENCES Adopter(adopter_id),
    pet_id INT NOT NULL REFERENCES Pet(pet_id),
    status VARCHAR(20) CHECK (status IN ('pending', 'approved', 'rejected'))
);

CREATE TABLE IF NOT EXISTS AdoptionHistory (
    history_id SERIAL PRIMARY KEY,
    adopter_id INT NOT NULL REFERENCES Adopter(adopter_id),
    pet_id INT NOT NULL REFERENCES Pet(pet_id),
    adoption_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS MedicalRecord (
    record_id SERIAL PRIMARY KEY,
    pet_id INT NOT NULL REFERENCES Pet(pet_id),
    vet_id INT NOT NULL REFERENCES ShelterEmployee(employee_id),
    record_date DATE NOT NULL,
    next_visit_date DATE,
    description TEXT
);