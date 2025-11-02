CREATE DATABASE event_management;
USE event_management;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(15),
    role ENUM('attendee', 'organizer', 'admin') DEFAULT 'attendee',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    event_date DATETIME NOT NULL,
    location VARCHAR(255) NOT NULL,
    capacity INT DEFAULT 100,
    created_by INT NOT NULL,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE registrations (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    event_id INT NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'confirmed', 'cancelled') DEFAULT 'pending',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE
);


CREATE TABLE tickets (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    registration_id INT NOT NULL,
    qr_code VARCHAR(255),
    issued_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (registration_id) REFERENCES registrations(registration_id) ON DELETE CASCADE
);


CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    registration_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    payment_method ENUM('credit_card', 'debit_card', 'upi', 'cash') DEFAULT 'upi',
    FOREIGN KEY (registration_id) REFERENCES registrations(registration_id) ON DELETE CASCADE
);


CREATE TABLE feedbacks (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    event_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    feedback_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE
);


INSERT INTO users (name, email, password, role) VALUES
('Siddhartha Chaudhuri', 'sid@ems.com', 'hashedpass', 'organizer'),
('John Doe', 'john@example.com', 'hashedpass', 'attendee'),
('Admin User', 'admin@ems.com', 'hashedpass', 'admin');


INSERT INTO events (title, description, event_date, location, capacity, created_by)
VALUES ('Rock Concert', 'Live music night', '2025-11-10 19:00:00', 'Delhi', 200, 1),
       ('Tech Summit', 'AI & Robotics Conference', '2025-12-05 09:00:00', 'Bangalore', 300, 1);


INSERT INTO registrations (user_id, event_id, status)
VALUES (2, 1, 'confirmed');


INSERT INTO tickets (registration_id, qr_code)
VALUES (1, 'QR123XYZ');


INSERT INTO payments (registration_id, amount, payment_status, payment_method)
VALUES (1, 1500.00, 'completed', 'upi');


INSERT INTO feedbacks (user_id, event_id, rating, comment)
VALUES (2, 1, 5, 'Amazing concert!');


SELECT * FROM users;
SELECT * FROM events;
SELECT * FROM registrations;
SELECT * FROM tickets;
SELECT * FROM payments;
SELECT * FROM feedbacks;
SELECT event_id, title, event_date, capacity
FROM events;

-- Show attendees
SELECT name, email, role
FROM users
WHERE role = 'attendee';

-- shoe events that have alreay happened
SELECT title, event_date
FROM events
WHERE event_date < CURDATE();


-- See all events with organizer name
SELECT e.title, e.event_date, u.name AS organizer
FROM events e
JOIN users u ON e.created_by = u.user_id;

-- See all attendees for a given event
SELECT e.title, u.name AS attendee
FROM registrations r
JOIN users u ON r.user_id = u.user_id
JOIN events e ON r.event_id = e.event_id
WHERE e.event_id = 1;

-- Get feedback summary for each event
SELECT e.title, AVG(f.rating) AS avg_rating, COUNT(f.feedback_id) AS total_feedbacks
FROM feedbacks f
JOIN events e ON f.event_id = e.event_id
GROUP BY e.event_id;
