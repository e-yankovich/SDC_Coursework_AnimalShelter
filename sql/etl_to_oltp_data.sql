-- Upload for Country
DROP TABLE IF EXISTS tmp_country_data;
CREATE TEMP TABLE tmp_country_data (
    country_name TEXT
);

-- Manually upload data for Country in psql:
\copy tmp_country_data(country_name) FROM 'data/countries.csv' DELIMITER ',' CSV HEADER;

INSERT INTO Country (country_name)
SELECT t.country_name
FROM tmp_country_data t
LEFT JOIN Country c ON c.country_name = t.country_name
WHERE c.country_id IS NULL;

SELECT * FROM Country;

-- Upload for City
DROP TABLE IF EXISTS tmp_city_data;
CREATE TEMP TABLE tmp_city_data (
    city_name TEXT,
    country_name TEXT
);

-- Manually upload data for City in psql:
\copy tmp_city_data(city_name, country_name) FROM 'data/cities.csv' DELIMITER ',' CSV HEADER;

INSERT INTO City (city_name, country_id)
SELECT t.city_name, c.country_id
FROM tmp_city_data t
JOIN Country c ON c.country_name = t.country_name
LEFT JOIN City existing ON existing.city_name = t.city_name AND existing.country_id = c.country_id
WHERE existing.city_id IS NULL;

SELECT * FROM City;

-- Upload for Species
DROP TABLE IF EXISTS tmp_species_data;
CREATE TEMP TABLE tmp_species_data (
    species_name TEXT
);

-- Manually upload data for Species in psql:
\copy tmp_species_data(species_name) FROM 'data/species.csv' DELIMITER ',' CSV HEADER;

INSERT INTO Species (species_name)
SELECT t.species_name
FROM tmp_species_data t
LEFT JOIN Species s ON s.species_name = t.species_name
WHERE s.species_id IS NULL;

SELECT * FROM Species;

-- Upload for Breeds
DROP TABLE IF EXISTS tmp_breed_data;
CREATE TEMP TABLE tmp_breed_data (
    breed_name TEXT,
    species_name TEXT
);

-- Manually upload data for Breeds in psql:
\copy tmp_breed_data(breed_name, species_name) FROM 'data/breeds.csv' DELIMITER ',' CSV HEADER;

INSERT INTO Breed (breed_name, species_id)
SELECT t.breed_name, s.species_id
FROM tmp_breed_data t
JOIN Species s ON s.species_name = t.species_name
LEFT JOIN Breed b ON b.breed_name = t.breed_name AND b.species_id = s.species_id
WHERE b.breed_id IS NULL;

SELECT * FROM Breed;

-- Upload for Shelters
DROP TABLE IF EXISTS tmp_shelter_data;
CREATE TEMP TABLE tmp_shelter_data (
    shelter_name TEXT,
    address TEXT,
    city_name TEXT,
    phone TEXT
);

-- Manually upload data for Shelters in psql:
\copy tmp_shelter_data(shelter_name, address, city_name, phone) FROM 'data/shelters.csv' DELIMITER ',' CSV HEADER;

INSERT INTO Shelter (shelter_name, address, city_id, phone)
SELECT t.shelter_name, t.address, c.city_id, t.phone
FROM tmp_shelter_data t
JOIN City c ON c.city_name = t.city_name
LEFT JOIN Shelter s ON s.shelter_name = t.shelter_name AND s.city_id = c.city_id
WHERE s.shelter_id IS NULL;

SELECT * FROM Shelter;

-- Upload for Adopters
DROP TABLE IF EXISTS tmp_adopter_data;
CREATE TEMP TABLE tmp_adopter_data (
    username TEXT,
    email TEXT,
    password TEXT,
    first_name TEXT,
    last_name TEXT,
    phone TEXT,
    passport_number TEXT,
    address TEXT,
    city_name TEXT
);

-- Manually upload data for Adopters in psql:
\copy tmp_adopter_data(username, email, password, first_name, last_name, phone, passport_number, address, city_name) FROM 'data/adopters.csv' DELIMITER ',' CSV HEADER;

INSERT INTO Adopter (
    username, email, password, first_name, last_name,
    phone, passport_number, address, city_id
)
SELECT
    t.username, t.email, t.password, t.first_name, t.last_name,
    t.phone, t.passport_number, t.address, c.city_id
FROM tmp_adopter_data t
JOIN City c ON c.city_name = t.city_name
LEFT JOIN Adopter a ON a.username = t.username OR a.email = t.email
WHERE a.adopter_id IS NULL;

SELECT * FROM Adopter;

-- Upload for Employees
DROP TABLE IF EXISTS tmp_employee_data;
CREATE TEMP TABLE tmp_employee_data (
    first_name TEXT,
    last_name TEXT,
    is_vet BOOLEAN,
    shelter_name TEXT
);

-- Manually upload data for Employees in psql:
\copy tmp_employee_data(first_name, last_name, is_vet, shelter_name) FROM 'data/employees.csv' DELIMITER ',' CSV HEADER;

INSERT INTO ShelterEmployee (
    first_name, last_name, is_vet, shelter_id
)
SELECT
    t.first_name, t.last_name, t.is_vet, s.shelter_id
FROM tmp_employee_data t
JOIN Shelter s ON s.shelter_name = t.shelter_name
LEFT JOIN ShelterEmployee e
    ON e.first_name = t.first_name AND e.last_name = t.last_name AND e.shelter_id = s.shelter_id
WHERE e.employee_id IS NULL;

SELECT * FROM ShelterEmployee;

-- Upload for Pets
DROP TABLE IF EXISTS tmp_pet_data;
CREATE TEMP TABLE tmp_pet_data (
    name TEXT,
    sex CHAR(1),
    color TEXT,
    age_months INT,
    weight NUMERIC(6,3),
    photo TEXT,
    vaccinated BOOLEAN,
    admission_date DATE,
    special_care_required BOOLEAN,
    breed_name TEXT,
    species_name TEXT,
    shelter_name TEXT,
    curator_last_name TEXT
);

-- Manually upload data for Pets in psql:
\copy tmp_pet_data(name, sex, color, age_months, weight, photo, vaccinated, admission_date, special_care_required, breed_name, species_name, shelter_name, curator_last_name) FROM 'data/pets.csv' DELIMITER ',' CSV HEADER;

INSERT INTO Pet (
    name, sex, color, age_months, weight, photo,
    vaccinated, admission_date, special_care_required,
    breed_id, shelter_id, curator_id
)
SELECT
    t.name, t.sex, t.color, t.age_months, t.weight, t.photo,
    t.vaccinated, t.admission_date, t.special_care_required,
    b.breed_id, s.shelter_id, e.employee_id
FROM tmp_pet_data t
JOIN Species sp ON sp.species_name = t.species_name
JOIN Breed b ON b.breed_name = t.breed_name AND b.species_id = sp.species_id
JOIN Shelter s ON s.shelter_name = t.shelter_name
JOIN ShelterEmployee e ON e.last_name = t.curator_last_name AND e.shelter_id = s.shelter_id
LEFT JOIN Pet p ON p.name = t.name AND p.admission_date = t.admission_date
WHERE p.pet_id IS NULL;

SELECT * FROM Pet;

-- Upload for Adoption Requests
DROP TABLE IF EXISTS tmp_adoption_request;
CREATE TEMP TABLE tmp_adoption_request (
    adopter_username TEXT,
    pet_name TEXT,
    species_name TEXT,
    status TEXT
);

-- Manually upload data for Adoption Requests in psql:
\copy tmp_adoption_request(adopter_username, pet_name, species_name, status) FROM 'data/adoption_requests.csv' DELIMITER ',' CSV HEADER;

INSERT INTO AdoptionRequest (
    adopter_id, pet_id, status
)
SELECT
    a.adopter_id,
    p.pet_id,
    t.status
FROM tmp_adoption_request t
JOIN Adopter a ON a.username = t.adopter_username
JOIN Species sp ON sp.species_name = t.species_name
JOIN Breed b ON b.species_id = sp.species_id
JOIN Pet p ON p.name = t.pet_name AND p.breed_id = b.breed_id
LEFT JOIN AdoptionRequest ar ON ar.adopter_id = a.adopter_id AND ar.pet_id = p.pet_id
WHERE ar.request_id IS NULL;

SELECT * FROM AdoptionRequest;

-- Upload for Adoption History
DROP TABLE IF EXISTS tmp_adoption_history;
CREATE TEMP TABLE tmp_adoption_history (
    adopter_username TEXT,
    pet_name TEXT,
    species_name TEXT,
    adoption_date DATE
);

-- Upload for Adoption History:
\copy tmp_adoption_history(adopter_username, pet_name, species_name, adoption_date) FROM 'data/adoption_history.csv' DELIMITER ',' CSV HEADER;

INSERT INTO AdoptionHistory (
    adopter_id, pet_id, adoption_date
)
SELECT
    a.adopter_id,
    p.pet_id,
    t.adoption_date
FROM tmp_adoption_history t
JOIN Adopter a ON a.username = t.adopter_username
JOIN Species sp ON sp.species_name = t.species_name
JOIN Breed b ON b.species_id = sp.species_id
JOIN Pet p ON p.name = t.pet_name AND p.breed_id = b.breed_id
LEFT JOIN AdoptionHistory h ON h.adopter_id = a.adopter_id AND h.pet_id = p.pet_id
WHERE h.history_id IS NULL;

SELECT * FROM AdoptionHistory;

SELECT ah.*
FROM AdoptionHistory ah
LEFT JOIN AdoptionRequest ar
  ON ar.adopter_id = ah.adopter_id AND ar.pet_id = ah.pet_id
WHERE ar.status IS DISTINCT FROM 'approved';

-- Upload for Medical Records
DROP TABLE IF EXISTS tmp_medical_records;
CREATE TEMP TABLE tmp_medical_records (
    pet_name TEXT,
    species_name TEXT,
    breed_name TEXT,
    gender TEXT,
    vet_last_name TEXT,
    record_date DATE,
    next_visit_date TEXT,
    description TEXT
);

-- Manually upload data for Medical records in psql:
\copy tmp_medical_records(pet_name, species_name, breed_name, gender, vet_last_name, record_date, next_visit_date, description) FROM 'data/medical_records.csv' DELIMITER ',' CSV HEADER;

INSERT INTO MedicalRecord (
    pet_id,
    vet_id,
    record_date,
    next_visit_date,
    description
)
SELECT
    p.pet_id,
    e.employee_id,
    t.record_date,
    CASE
        WHEN t.next_visit_date ~ '^\d{4}-\d{2}-\d{2}$' THEN t.next_visit_date::DATE
        ELSE NULL
    END,
    t.description
FROM tmp_medical_records t
JOIN Species s ON s.species_name = t.species_name
JOIN Breed b ON b.breed_name = t.breed_name AND b.species_id = s.species_id
JOIN Pet p ON p.name = t.pet_name AND p.breed_id = b.breed_id AND p.sex = t.gender
JOIN ShelterEmployee e ON e.last_name = t.vet_last_name AND e.is_vet = TRUE
WHERE e.shelter_id = p.shelter_id
AND NOT EXISTS (
    SELECT 1 FROM MedicalRecord m
    WHERE m.pet_id = p.pet_id AND m.vet_id = e.employee_id AND m.record_date = t.record_date
);

SELECT * FROM MedicalRecord ORDER BY record_date DESC;
