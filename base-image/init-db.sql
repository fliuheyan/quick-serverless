GRANT ALL ON *.* TO 'root'@'localhost' identified by '' WITH GRANT OPTION;
GRANT ALL ON *.* TO 'root'@'127.0.0.1' identified by '' WITH GRANT OPTION;
GRANT ALL ON *.* TO 'root'@'%' identified by '' WITH GRANT OPTION;

use Fantasy;
create table users
(
  id integer auto_increment,
  name varchar(100),
  primary key(id)
);
