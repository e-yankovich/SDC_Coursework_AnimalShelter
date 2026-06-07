INSERT INTO dim_date (date_key, full_date, day, month, year, quarter, weekday_name)
SELECT
    EXTRACT(YEAR FROM d)::INT * 1000 + EXTRACT(DOY FROM d)::INT AS date_key,
        d::DATE AS full_date,
        EXTRACT(DAY FROM d)::INT AS day,
    EXTRACT(MONTH FROM d)::INT AS month,
    EXTRACT(YEAR FROM d)::INT AS year,
    EXTRACT(QUARTER FROM d)::INT AS quarter,
    TO_CHAR(d, 'Day') AS weekday_name
FROM generate_series('2023-01-01'::DATE, '2025-12-31'::DATE, interval '1 day') AS d;

SELECT * FROM dim_date

    INSERT INTO dim_breed (breed_key, breed_name, species_name)
SELECT
    b.breed_id,
    b.breed_name,
    s.species_name
FROM breed b
         JOIN species s ON s.species_id = b.species_id
         LEFT JOIN dim_breed db ON db.breed_key = b.breed_id
WHERE db.breed_key IS NULL;

SELECT * FROM dim_breed

    INSERT INTO dim_shelter (shelter_key, shelter_name, city_name, country_name)
SELECT
    s.shelter_id,
    s.shelter_name,
    ci.city_name,
    co.country_name
FROM shelter s
         JOIN city ci ON s.city_id = ci.city_id
         JOIN country co ON ci.country_id = co.country_id
         LEFT JOIN dim_shelter ds ON ds.shelter_key = s.shelter_id
WHERE ds.shelter_key IS NULL;

SELECT * FROM dim_shelter

    INSERT INTO dim_employee (employee_key, full_name, shelter_key)
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name,
    e.shelter_id
FROM shelteremployee e
         LEFT JOIN dim_employee de ON de.employee_key = e.employee_id
WHERE de.employee_key IS NULL;

SELECT * FROM dim_employee

    INSERT INTO dim_role (role_key, role_name)
SELECT * FROM (VALUES
                   (1, 'vet'),
                   (2, 'curator')
              ) AS roles(role_key, role_name)
WHERE NOT EXISTS (
    SELECT 1 FROM dim_role r WHERE r.role_key = roles.role_key
);

SELECT * FROM dim_role

    INSERT INTO bridge_employee_role (employee_key, role_key)
SELECT
    e.employee_id,
    1  -- vet
FROM shelteremployee e
         LEFT JOIN bridge_employee_role br ON br.employee_key = e.employee_id AND br.role_key = 1
WHERE e.is_vet = TRUE AND br.employee_key IS NULL;

INSERT INTO bridge_employee_role (employee_key, role_key)
SELECT DISTINCT
    p.curator_id,
    2  -- curator
FROM pet p
         LEFT JOIN bridge_employee_role br ON br.employee_key = p.curator_id AND br.role_key = 2
WHERE p.curator_id IS NOT NULL AND br.employee_key IS NULL;

SELECT * FROM bridge_employee_role

-- SCD Type 2
    INSERT INTO dim_pet (
    pet_id, name, sex, color, breed_key,
    vaccinated, special_care_required, weight, age_months, is_current
)
SELECT
    p.pet_id, p.name, p.sex, p.color, b.breed_id,
    p.vaccinated, p.special_care_required, p.weight, p.age_months,
    TRUE
FROM pet p
         JOIN breed b ON b.breed_id = p.breed_id
         LEFT JOIN dim_pet dp ON dp.pet_id = p.pet_id AND dp.is_current = TRUE
WHERE dp.pet_id IS NULL
   OR dp.weight IS DISTINCT FROM p.weight
    OR dp.color IS DISTINCT FROM p.color
    OR dp.vaccinated IS DISTINCT FROM p.vaccinated
    OR dp.special_care_required IS DISTINCT FROM p.special_care_required;

-- Deactivate previous current versions
UPDATE dim_pet
SET is_current = FALSE
WHERE pet_id IN (SELECT pet_id FROM dim_pet GROUP BY pet_id HAVING COUNT(*) > 1)
AND pet_key NOT IN (SELECT MAX(pet_key) FROM dim_pet GROUP BY pet_id);

SELECT * FROM dim_pet;

INSERT INTO dim_adopter (adopter_key, full_name, city_name, country_name)
SELECT
    a.adopter_id,
    a.first_name || ' ' || a.last_name,
    ci.city_name,
    co.country_name
FROM adopter a
         JOIN city ci ON a.city_id = ci.city_id
         JOIN country co ON ci.country_id = co.country_id
         LEFT JOIN dim_adopter da ON da.adopter_key = a.adopter_id
WHERE da.adopter_key IS NULL;

SELECT * FROM dim_adopter;

INSERT INTO fact_adoption (
    adoption_id, date_key, pet_key, adopter_key, shelter_key, adoption_count
)
SELECT
    ah.history_id,
    EXTRACT(DOY FROM ah.adoption_date)::INT + EXTRACT(YEAR FROM ah.adoption_date)::INT * 1000,  -- example date_key
        dp.pet_key,
    a.adopter_id,
    p.shelter_id,
    1
FROM adoptionhistory ah
         JOIN pet p ON p.pet_id = ah.pet_id
         JOIN dim_pet dp ON dp.pet_id = p.pet_id AND dp.is_current = TRUE
         JOIN adopter a ON a.adopter_id = ah.adopter_id
         LEFT JOIN fact_adoption fa ON fa.adoption_id = ah.history_id
WHERE fa.adoption_id IS NULL;

SELECT * FROM fact_adoption;

INSERT INTO fact_medical_visit (
    visit_id, date_key, full_date, pet_key, vet_key, shelter_key, visit_count, next_visit_days, next_visit_date
)
SELECT
    mr.record_id,
    EXTRACT(DOY FROM mr.record_date)::INT + EXTRACT(YEAR FROM mr.record_date)::INT * 1000 AS date_key,
        mr.record_date::DATE AS full_date,
        dp.pet_key,
    se.employee_id,
    p.shelter_id,
    1 AS visit_count,
    CASE
        WHEN mr.next_visit_date IS NOT NULL THEN mr.next_visit_date - mr.record_date
        ELSE NULL
        END AS next_visit_days,
    mr.next_visit_date::DATE AS next_visit_date
FROM medicalrecord mr
         JOIN pet p ON p.pet_id = mr.pet_id
         JOIN dim_pet dp ON dp.pet_id = p.pet_id AND dp.is_current = TRUE
         JOIN shelteremployee se ON se.employee_id = mr.vet_id
         LEFT JOIN fact_medical_visit fmv ON fmv.visit_id = mr.record_id
WHERE fmv.visit_id IS NULL;

SELECT * FROM fact_medical_visit;
