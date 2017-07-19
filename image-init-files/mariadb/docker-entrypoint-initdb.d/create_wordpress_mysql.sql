CREATE DATABASE IF NOT EXISTS wordpress DEFAULT CHARACTER SET latin1;

grant all on wordpress.* to 'wp_user'@'%' identified by 'BirdBirdBirdIsTheWord';

commit;
