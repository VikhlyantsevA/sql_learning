Run MYSQL in docker container (https://hub.docker.com/_/mysql):
```bash
docker run \
  --name <container_name> \
  -p <desired_host_port>:3306 \
  -v /<path_to_mysql>/mysql/conf.d:/etc/mysql/conf.d \
  -v /<path_to_mysql>/mysql/data:/var/lib/mysql \
  -v /<path_to_mysql>/mysql/share:/etc/mysql/share \
  -e MYSQL_ROOT_PASSWORD=<your_password> \
  -d mysql:latest
```
Use your own volumes with -v flag. <br>
`/etc/mysql/conf.d` - path to mysql config-file <br>
`/var/lib/mysql` - mysql save data here; <br>
`/etc/mysql/share` - created folder for files exchanging (dump-files for example). <br>
---

Get into docker container with mysql database
```bash
docker exec -it <container_name | container_id> bash
```
---

Make dump of database within docker container:
```bash
mysqldump  -u <username> -p <database_name> > <dump_file_path>
```
or make dump of database on host machine ($MYSQL_ROOT_PASSWORD mentioned below is usually set when container is built in):
```bash
docker exec <container_name | container_id> sh -c 'exec mysqldump -u <username> --password="$MYSQL_ROOT_PASSWORD" <database_name>' > <dump_file_path>
```

---
Deploy dump to database (within docker container or on host machine)
Create database before to apply dump file with query like `CREATE DATABASE IF NOT EXISTS <new_database_name>`
```bash
mysql -u <user_name> -p <new_database_name> < <dump_file_path>
```
or make dump of database on host machine
```bash
docker exec -i <container_name | container_id> sh -c 'exec mysql -u <username> --password="$MYSQL_ROOT_PASSWORD" <new_database_name>' < <dump_file_path>
```

---
You can add code below to /etc/mysql/conf.d/config-file.cnf to run mysql and mysqldump utilities without enter of username and password manually
```editorconfig
[client]
user=<user_name>
password=<user_password>
```

---
To check volumes (pairs of host paths and container paths) to find where config-file.cnf is located on host machine perform this:
```bash
docker inspect -f '{{ .Mounts }}' <container_id>
```
