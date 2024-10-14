
USE airport;
-- SQL WARMUP

-- a. List the name of all airlines with the international airport code (iata) ’AU’, ’BR’ and ’CZ’.
SELECT airlinename 
FROM airline 
WHERE iata='AU' OR iata='BR' OR iata='CZ';

-- b. Which airports (name) have no international airport code (iata)?
SELECT name 
FROM airport 
WHERE iata IS NULL;

-- c. Which employee (firstname, lastname, salary) earns the most? What happens if two persons earn the same?
SELECT firstname, lastname, max(salary) as salary
FROM employee;

SELECT firstname, lastname, salary 
FROM employee ORDER BY salary DESC;
-- wenn zwei gleich
-- => nächste Spalte von vorne (=firstname) verwendet. Hier allerdings auch Desc, also alphabetisch von hinten



-- SQL QUERIES WITH JOINS

-- a. List all scheduled flights (output everything) of the airline with the name Australia Airlines
SELECT * 
FROM flightschedule 
JOIN airline ON flightschedule.airline_id = airline.airline_id 
where airline.airlinename='Australia Airlines'

-- b. Which airline (name) does not fly on mondays? (result: 0 tuples).
SELECT DISTINCT airlinename
FROM airline 
LEFT JOIN flightschedule ON airline.airline_id = flightschedule.airline_id AND flightschedule.monday = 0
WHERE flightschedule.airline_id IS NULL;

-- List the names of the passengers Buzz Aldrin and Jack Clarke together with all destinations that they visited (result: 207 tuples).
SELECT firstname, lastname, city, country, airport_id 
FROM airport_geo
JOIN flight ON flight.to=airport_geo.airport_id
JOIN booking USING (flight_id)
JOIN passenger USING (passenger_id)
WHERE passenger.firstname='Buzz' AND passenger.lastname='Aldrin' OR passenger.firstname='Jack' AND passenger.lastname='Clarke'
ORDER BY passenger.lastname



-- SQL SUBQUERIES PART 1

-- a. Prove that all airplanes in the whole database are used for at least one flight. Use a correlated subquery.
SELECT airplane_id 
FROM airplane 
WHERE NOT EXISTS(
    SELECT FROM flight WHERE flight.airline_id=airplane.airline_id
)

-- b. Formulate a query with a subquery to find all flights booked by a passenger who already booked more than 100 flights.
SELECT lastname, firstname, flight_id 
FROM booking 
JOIN passenger USING (passenger_id)
WHERE passenger_id IN(
    SELECT passenger_id 
    FROM booking 
    GROUP BY passenger_id 
    HAVING count(booking_id)>100
)

-- c. Create a query to compute how many bookings have a price equivalent to the average price of all bookings +/- 100.
SELECT count(*) 
FROM booking
WHERE price BETWEEN 
    (SELECT avg(price)-100 
    FROM booking)
    AND (SELECT avg(price)+100 FROM booking)



-- SQL SUBQUERIES PART 2

--a. List the flight numbers and the corresponding number of bookings for the 10 flights which have the highest number of bookings.
SELECT flightno, count(*) AS amount 
FROM booking 
JOIN flight USING (flight_id)
GROUP BY flightno ORDER BY  amount DESC LIMIT 10

-- b. Output the id and names of all airlines which use more than 85 different aircrafts. Sort the result in descending order of the number of aircrafts.
SELECT airline_id, airlinename, count(airplane_id) AS airplane_number 
FROM airline 
JOIN airplane USING (airline_id)
GROUP BY airline_id HAVING count(airplane_id)>85 
ORDER BY count(airplane_id) DESC

-- c. Calculate the load factor of each flight and list only those flights which have a load factor of more than 8%. Output the flight_id, the capacity and the load factor and order the result ascendingly by load factor. The load factor can be computed as: load factor = 100 × number of bookings / capacity.
SELECT flight_id, capacity, (100 * count(booking_id/capacity)) AS load_factor 
FROM flight
   JOIN airplane USING (airplane_id)
   LEFT JOIN booking USING (flight_id)
        GROUP BY flight_id, capacity 
        HAVING (100 * count(booking_id/capacity))>8 
        ORDER BY load_factor;