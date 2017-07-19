
CREATE DATABASE IF NOT EXISTS `repository` DEFAULT CHARACTER SET latin1;

grant all on repository.* to 'jcr_user'@'%' identified by 'DoNotJackAround';

commit;
