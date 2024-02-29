// 0
select *
from employees A,
    (
      select *
      from departments
      where department_id=20
      )B
    where a.department_id = B.department_id;


-- 3.1
select *
    from employees;
    
-- 3.2    
select Employee_id,first_name,last_name
from employees;


-- 3.3
select Employee_id,first_name,last_name
from employees
order by employee_id asc;
