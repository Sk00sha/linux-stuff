-- Seed data for the module 09 client demonstration.
CREATE TABLE IF NOT EXISTS greetings (id serial PRIMARY KEY, message text NOT NULL);
INSERT INTO greetings (message) VALUES ('Caleston Mercury is live!');
