SELECT first_name, employees.department_id, departments.department_id, department_name FROM employees, departments
WHERE employees.department_id = departments.department_id
ORDER BY first_name;

SELECT * FROM employees WHERE department_id is null;
SELECT COUNT(*) FROM employees;