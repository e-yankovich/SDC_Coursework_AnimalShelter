# Animal Shelter — Database Coursework

A database project for an animal shelter management system, covering the full data pipeline: from operational database design to a data warehouse and visual reports.

---

## Project Structure

```
SDC_Coursework_AnimalShelter/
├── data/                        # Source CSV files and OLAP model (Excel)
├── diagrams/                    # Database schema diagrams (DBML + PNG)
│   ├── oltp_schema.png
│   └── olap_schema.png
├── sql/
│   ├── create_oltp.sql          # OLTP database schema
│   ├── create_olap.sql          # DWH schema (star schema)
│   ├── etl_to_oltp_data.sql     # Load data from CSV into OLTP
│   ├── etl_oltp_to_olap.sql     # ETL from OLTP to DWH
│   ├── queries_for_oltp.sql     # Analytical queries on OLTP
│   └── queries_for_olap.sql     # Analytical queries on DWH
└── reports/                     # Power BI report and documentation
```

---

## OLTP Database

Operational database for day-to-day shelter management. Stores detailed information related to:

- Adopters and their personal data
- Pets including species, breed, health info, and current shelter
- Adoption requests and adoption history
- Medical records of animals
- Shelter employees and their roles (e.g., veterinarian, curator)
- Shelter locations, cities, and countries

The schema includes 11 main tables where primary keys and foreign keys ensure relational integrity.

---

## DWH (Star Schema)

OLAP model optimized for complex queries and analytical reporting. Helps answer business questions such as:

- How many adoptions occurred per year, per country?
- Which employees perform both as curators and veterinarians?
- What is the monthly number of veterinary visits?
- What is the average weight of adopted animals by breed and species?

**Fact tables:** `fact_adoption`, `fact_medical_visit`

**Dimension tables:** `dim_pet` (SCD Type 2), `dim_adopter`, `dim_employee`, `dim_shelter`, `dim_breed`, `dim_date`

**Bridge table:** `bridge_employee_role` — handles employees with multiple roles (vet + curator)

Key relationships:
- Each pet is related to one breed and one shelter
- Each adoption links a pet and an adopter
- Each employee can have multiple roles
- Each medical record is linked to a pet and a veterinarian

See ER diagrams in the `diagrams/` folder for both OLTP and OLAP schemas.

---

## ETL

Two-stage ETL pipeline:

1. **CSV → OLTP** (`etl_to_oltp_data.sql`) — loads raw data from CSV files into the operational database using temporary staging tables
2. **OLTP → DWH** (`etl_oltp_to_olap.sql`) — transforms and loads data into the star schema, handles SCD Type 2 for pets, populates the date dimension, and assigns employee roles via the bridge table

### How to Run

1. Run `create_oltp.sql` to create the OLTP schema
2. Load datasets into OLTP using `etl_to_oltp_data.sql` (via psql `\copy` commands)
3. Run `create_olap.sql` to create the OLAP schema
4. Execute `etl_oltp_to_olap.sql` to extract and transform data into the OLAP structure
5. Optionally run `queries_for_oltp.sql` and `queries_for_olap.sql` to validate and explore the data

> Note: Scripts use SCD Type 2 for dimensional changes (e.g., pets).

---

## Analytical Queries

**OLTP queries:**
- List of all pets with their assigned curators
- Number of animals per shelter
- Days each pet spent in the shelter before adoption

**DWH queries:**
- Adoption count by year and adopter's country
- Employees working as both curator and veterinarian
- Monthly veterinary visit activity
- Average weight of adopted animals by species and breed

---

## Power BI Report

The Power BI report connects to the OLAP model and presents:

- Distribution of species in shelter
- Number of adoptions trends
- Medical procedures performed over time
- Trends of pets fur colours

> Note: Due to Power BI Online limitations, two tables are excluded in the online version (bridge table and auxiliary dimension table).

---

## Stack

PostgreSQL · Power BI
