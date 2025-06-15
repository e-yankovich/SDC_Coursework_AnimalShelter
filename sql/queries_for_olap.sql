-- Number of adoptions by year and adopter's country
SELECT
    d.year,
    da.country_name,
    COUNT(*) AS adoption_count
FROM fact_adoption fa
         JOIN dim_date d ON d.date_key = fa.date_key
         JOIN dim_adopter da ON da.adopter_key = fa.adopter_key
GROUP BY d.year, da.country_name
ORDER BY d.year, adoption_count DESC;

-- Employees who work as both curator and veterinarian
SELECT
    de.full_name,
    STRING_AGG(dr.role_name, ', ') AS roles
FROM dim_employee de
         JOIN bridge_employee_role ber ON ber.employee_key = de.employee_key
         JOIN dim_role dr ON dr.role_key = ber.role_key
GROUP BY de.full_name
HAVING COUNT(DISTINCT dr.role_name) > 1;

-- Veterinary visits: monthly activity
SELECT
    d.year,
    d.month,
    COUNT(*) AS total_visits
FROM fact_medical_visit fmv
         JOIN dim_date d ON d.date_key = fmv.date_key
GROUP BY d.year, d.month
ORDER BY d.year, d.month;

-- Average weight of adopted animals by species and breed
SELECT
    db.species_name,
    db.breed_name,
    ROUND(AVG(dp.weight), 2) AS avg_weight
FROM fact_adoption fa
         JOIN dim_pet dp ON dp.pet_key = fa.pet_key
         JOIN dim_breed db ON db.breed_key = dp.breed_key
WHERE dp.is_current = TRUE
GROUP BY db.species_name, db.breed_name
ORDER BY db.species_name, avg_weight DESC;