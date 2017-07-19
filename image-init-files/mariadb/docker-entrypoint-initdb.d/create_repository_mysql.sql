CREATE DATABASE IF NOT EXISTS `hibernate` DEFAULT CHARACTER SET latin1;

USE hibernate;

GRANT ALL ON hibernate.* TO 'hib_user'@'%' identified by 'FreezingColdWinters'; 

commit;
