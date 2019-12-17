#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage() {
    cat <<HELP
USAGE:
    sqldemo.sh 
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 0 ]; then
    useage
    exit 1
fi
DEMODIR=$(mktemp -d)
echo "${DEMODIR}"
cd "${DEMODIR}"
cat >"${DEMODIR}"/demo.sql <<EOF
CREATE DATABASE IF NOT EXISTS demo;
use demo;

CREATE TABLE IF NOT EXISTS demo_data (
  id INT NOT NULL AUTO_INCREMENT,
  data VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB;

DROP PROCEDURE IF EXISTS init_data;
DELIMITER //
CREATE PROCEDURE init_data(IN number INT,OUT total INT)
BEGIN
  DECLARE i INT DEFAULT 1;
  SET @tmp_id=(SELECT id FROM demo_data LIMIT 1);
  IF (@tmp_id IS NULL) THEN
    WHILE (i<=number) DO
      INSERT INTO demo_data VALUES(i,i);
      SET i=i+1;
    END WHILE;
  END IF;
  SELECT COUNT(*) FROM demo_data INTO total;
END //
DELIMITER ;

CALL init_data(1000, @total);
SELECT @total;

DROP TABLE IF EXISTS demo;
CREATE TEMPORARY TABLE demo AS (
    SELECT * FROM demo_data
);
EOF
mysql -u root -h 127.0.0.1 -p
