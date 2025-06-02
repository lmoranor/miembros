create database miembros;
use miembros;

DELIMITER //
create procedure limp()
begin
	select * from club;
end //
DELIMITER ;

call limp();

ALTER TABLE club ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;

## Cambiar nombres de columnas
alter table club change column martial_status marital_status varchar (20);

## Valores duplicados
select email, count(*) as cant_dup
from club 
group by email
having cant_dup>1;

select count(*) as Cant_dup 
from (select email, count(*) as Cant_dup
from club
group by email
having Cant_dup >1) as sq1;

DELETE c1
FROM club c1
JOIN club c2 
  ON c1.email = c2.email 
  AND c1.id > c2.id;

set sql_safe_updates = 0;

select LOWER(
  REGEXP_REPLACE(
    SUBSTRING_INDEX(TRIM(full_name), ' ', 1),
    '[^a-z0-9]+',
    ''
  )
) AS first_name from club;

SELECT 
  full_name,
  CASE
    WHEN LENGTH(TRIM(full_name)) - LENGTH(REPLACE(TRIM(full_name), ' ', '')) = 2 THEN
      CONCAT(
        SUBSTRING_INDEX(SUBSTRING_INDEX(TRIM(LOWER(full_name)), ' ', 3), ' ', -2)
      )
    WHEN LENGTH(TRIM(full_name)) - LENGTH(REPLACE(TRIM(full_name), ' ', '')) = 3 THEN
      CONCAT(
        SUBSTRING_INDEX(SUBSTRING_INDEX(TRIM(LOWER(full_name)), ' ', 4), ' ', -3)
      )
    ELSE
      SUBSTRING_INDEX(SUBSTRING_INDEX(TRIM(LOWER(full_name)), ' ', 2), ' ', -1)
  END AS last_name
FROM club;

alter table club add column first_name varchar(20);
UPDATE club 
SET first_name = LOWER(
  REGEXP_REPLACE(
    SUBSTRING_INDEX(TRIM(full_name), ' ', 1),
    '[^a-z0-9]+',
    ''
  )
);

alter table club add column last_name varchar(20);
update club set last_name = (  CASE
    WHEN LENGTH(TRIM(full_name)) - LENGTH(REPLACE(TRIM(full_name), ' ', '')) = 2 THEN
      CONCAT(
        SUBSTRING_INDEX(SUBSTRING_INDEX(TRIM(LOWER(full_name)), ' ', 3), ' ', -2)
      )
    WHEN LENGTH(TRIM(full_name)) - LENGTH(REPLACE(TRIM(full_name), ' ', '')) = 3 THEN
      CONCAT(
        SUBSTRING_INDEX(SUBSTRING_INDEX(TRIM(LOWER(full_name)), ' ', 4), ' ', -3)
      )
    ELSE
      SUBSTRING_INDEX(SUBSTRING_INDEX(TRIM(LOWER(full_name)), ' ', 2), ' ', -1)
  END);
  
ALTER TABLE club DROP COLUMN full_name;

select marital_status, count(*) from club group by marital_status;

select
CASE
			WHEN trim(marital_status) = '' THEN NULL
			ELSE trim(marital_status)
		END AS marital_status from club;

update club  set marital_status = ( CASE
			WHEN trim(marital_status) = '' THEN NULL
			ELSE trim(marital_status)
		END);

select email, trim(lower(email)) AS member_email from club;
update club set email = trim(lower(email));

select phone, 
case
when trim(phone) = "''" THEN NULL
			WHEN length(trim(phone)) < 12 THEN NULL
			ELSE trim(phone)
		END AS phone1 from club;
        
update club set phone = (case
when trim(phone) = "''" THEN NULL
			WHEN length(trim(phone)) < 12 THEN NULL
			ELSE trim(phone)
		END);

SELECT 
  full_address,
  LOWER(TRIM(SUBSTRING_INDEX(full_address, ',', 1))) AS street_address,
  LOWER(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(full_address, ',', 2), ',', -1))) AS city,
  LOWER(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(full_address, ',', 3), ',', -1))) AS state
FROM club;

alter table club add column street_address varchar(70); 
alter table club change column city city varchar(70) null;
alter table club add column city varchar(20); 
alter table club add column state varchar(20); 
alter table club change column state state varchar(70) null;

update club set street_address = LOWER(TRIM(SUBSTRING_INDEX(full_address, ',', 1)));
update club set city = LOWER(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(full_address, ',', 2), ',', -1)));
update club set state = LOWER(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(full_address, ',', 3), ',', -1)));

SELECT 
  job_title,
  CASE
    WHEN TRIM(LOWER(job_title)) = '' THEN NULL
    ELSE
      (CASE
        WHEN INSTR(LOWER(job_title), ' i') > 0 AND SUBSTRING_INDEX(job_title, ' ', -1) = 'i'
          THEN REPLACE(LOWER(job_title), ' i', ', level 1')
        WHEN INSTR(LOWER(job_title), ' ii') > 0 AND SUBSTRING_INDEX(job_title, ' ', -1) = 'ii'
          THEN REPLACE(LOWER(job_title), ' ii', ', level 2')
        WHEN INSTR(LOWER(job_title), ' iii') > 0 AND SUBSTRING_INDEX(job_title, ' ', -1) = 'iii'
          THEN REPLACE(LOWER(job_title), ' iii', ', level 3')
        WHEN INSTR(LOWER(job_title), ' iv') > 0 AND SUBSTRING_INDEX(job_title, ' ', -1) = 'iv'
          THEN REPLACE(LOWER(job_title), ' iv', ', level 4')
        ELSE TRIM(LOWER(job_title))
      END)
  END AS occupation
FROM club;

update club set job_title = CASE
    WHEN TRIM(LOWER(job_title)) = '' THEN NULL
    ELSE
      (CASE
        WHEN INSTR(LOWER(job_title), ' i') > 0 AND SUBSTRING_INDEX(job_title, ' ', -1) = 'i'
          THEN REPLACE(LOWER(job_title), ' i', ', level 1')
        WHEN INSTR(LOWER(job_title), ' ii') > 0 AND SUBSTRING_INDEX(job_title, ' ', -1) = 'ii'
          THEN REPLACE(LOWER(job_title), ' ii', ', level 2')
        WHEN INSTR(LOWER(job_title), ' iii') > 0 AND SUBSTRING_INDEX(job_title, ' ', -1) = 'iii'
          THEN REPLACE(LOWER(job_title), ' iii', ', level 3')
        WHEN INSTR(LOWER(job_title), ' iv') > 0 AND SUBSTRING_INDEX(job_title, ' ', -1) = 'iv'
          THEN REPLACE(LOWER(job_title), ' iv', ', level 4')
        ELSE TRIM(LOWER(job_title))
      END)
  END;

SELECT 
  membership_date,
  CASE 
    WHEN YEAR(membership_date) < 2000 THEN
      STR_TO_DATE(
        CONCAT(
          REPLACE(YEAR(membership_date), '19', '20'), '-', 
          LPAD(MONTH(membership_date), 2, '0'), '-', 
          LPAD(DAY(membership_date), 2, '0')
        ), 
        '%Y-%m-%d'
      )
    ELSE membership_date
  END AS fixed_membership_date 
FROM club order by membership_date asc;

UPDATE club
SET membership_date = CASE
  WHEN STR_TO_DATE(membership_date, '%m/%d/%Y') IS NOT NULL
       AND YEAR(STR_TO_DATE(membership_date, '%m/%d/%Y')) < 2000
  THEN STR_TO_DATE(
           CONCAT(
             '20', 
             RIGHT(YEAR(STR_TO_DATE(membership_date, '%m/%d/%Y')), 2), '-',
             LPAD(MONTH(STR_TO_DATE(membership_date, '%m/%d/%Y')), 2, '0'), '-',
             LPAD(DAY(STR_TO_DATE(membership_date, '%m/%d/%Y')), 2, '0')
           ),
           '%Y-%m-%d'
       )
  ELSE STR_TO_DATE(membership_date, '%m/%d/%Y')
END;

select marital_status, count(*) from club group by marital_status;

update club set marital_status =
case 
	when marital_status = 'divored' then 'divorced'
    else marital_status
    end;
    
select state, count(*) from club group by state order by count(*) asc;

select state,
case
	when state = 'kansus' then 'kansas'
    when state = 'tej+f823as' then 'texas'
    when state = 'south dakotaaa' then 'south dakota'
    when state = 'tennesseeee' then 'tennessee'
    when state = 'northcarolina' then 'north carolina'
    when state = 'tejas' then 'texas'
    when state = 'kalifornia' then 'california'
    when state = 'newyork' then 'new york'
    when state = 'districts of columbia' then 'district of columbia'
    else state
    end as state_2 from club;

update club set state = ( case
	when state = 'kansus' then 'kansas'
    when state = 'tej+f823as' then 'texas'
    when state = 'south dakotaaa' then 'south dakota'
    when state = 'tennesseeee' then 'tennessee'
    when state = 'northcarolina' then 'north carolina'
    when state = 'tejas' then 'texas'
    when state = 'kalifornia' then 'california'
    when state = 'newyork' then 'new york'
    when state = 'districts of columbia' then 'district of columbia'
    else state
    end);

