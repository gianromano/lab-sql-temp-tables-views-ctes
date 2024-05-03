USE sakila;
-- Step 1: Create a View
CREATE VIEW rental_information_for_customer
AS 
SELECT customer.customer_id, customer.first_name,customer.last_name, customer.email, COUNT(rental.rental_id) AS rental_count
FROM customer
LEFT JOIN rental
ON customer.customer_id=rental.customer_id
GROUP BY customer.customer_id, customer.first_name,customer.last_name, customer.email;

-- Step 2: Create a Temporary Table
CREATE TEMPORARY TABLE temp_customer_payments AS
SELECT rental_information_for_customer.customer_id, SUM(payment.amount) AS total_paid
FROM rental_information_for_customer
LEFT JOIN payment 
ON rental_information_for_customer.customer_id = payment.customer_id
GROUP BY rental_information_for_customer.customer_id;
    
-- Step 3:
WITH customer_summary_cte AS (
    SELECT
        rental_information_for_customer.customer_id,
        rental_information_for_customer.first_name,
        rental_information_for_customer.last_name,
        rental_information_for_customer.email,
        rental_information_for_customer.rental_count,
        temp_customer_payments.total_paid,
        CASE
            WHEN rental_information_for_customer.rental_count > 0 THEN temp_customer_payments.total_paid / rental_information_for_customer.rental_count
            ELSE 0
        END AS average_payment_per_rental
    FROM
        rental_information_for_customer
    JOIN
        customer ON rental_information_for_customer.customer_id = customer.customer_id
    JOIN
        temp_customer_payments ON rental_information_for_customer.customer_id = temp_customer_payments.customer_id
)
SELECT
    first_name,
    last_name,
    email,
    rental_count,
    total_paid,
    average_payment_per_rental
FROM
    customer_summary_cte;
 


