-- List of all animals with curators
SELECT
    p.pet_id,
    p.name,
    p.sex,
    p.age_months,
    s.species_name,
    b.breed_name,
    CONCAT(e.first_name, ' ', e.last_name) AS curator_name
FROM pet p
         JOIN breed b ON b.breed_id = p.breed_id
         JOIN species s ON s.species_id = b.species_id
         LEFT JOIN shelteremployee e ON e.employee_id = p.curator_id;

-- Number of animals in each shelter
SELECT
    s.shelter_name,
    COUNT(p.pet_id) AS pet_count
FROM pet p
         JOIN shelter s ON s.shelter_id = p.shelter_id
GROUP BY s.shelter_name
ORDER BY pet_count DESC;

-- For how long the pet has been in shelter before adoption
SELECT
    p.pet_id,
    p.name,
    ah.adoption_date,
    p.admission_date,
    (ah.adoption_date - p.admission_date) AS days_in_shelter
FROM adoptionhistory ah
         JOIN pet p ON p.pet_id = ah.pet_id
WHERE p.admission_date IS NOT NULL;