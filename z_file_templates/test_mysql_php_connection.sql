CREATE DATABASE example_database;
CREATE USER 'example_user'@'localhost' IDENTIFIED WITH mysql_native_password BY 'example_password';
GRANT ALL ON example_database.* TO 'example_user'@'localhost';

CREATE TABLE example_database.todo_list (
    item_id INT AUTO_INCREMENT,
    content VARCHAR(255),
    PRIMARY KEY(item_id)
);

INSERT INTO example_database.todo_list (content) VALUES ("My 1st important item");
INSERT INTO example_database.todo_list (content) VALUES ("My 2nd important item");
INSERT INTO example_database.todo_list (content) VALUES ("My 3rd important item");
INSERT INTO example_database.todo_list (content) VALUES ("and this one more thing");
