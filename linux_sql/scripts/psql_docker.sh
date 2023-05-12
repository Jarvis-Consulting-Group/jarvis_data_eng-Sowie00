#! /bin/sh

#store CLI arguments
cmd=$1
db_username=$2
db_password=$3

#Check status of docker and if it isn't on, start it
#Make sure you understand `||` cmd
sudo systemctl status docker || systemctl start docker

#check container status (try the following cmds on terminal)
docker container inspect jrvs-psql
container_status=$?

#Use switch cases to handle create|stop|start operations
case $cmd in
  create)

  #Check if the container status is 0, meaning it already exists
  if [ $container_status -eq 0 ]; then
		echo 'Container already exists'
		exit 1
	fi

  #Make sure proper number of arguments are provided, in this case 3
  if [ $# -ne 3 ]; then
    echo 'Create requires username and password'
    exit 1
  fi

  #create the container
	docker volume create pgdata
  #start the container
	docker run --name jrvs-psql -e POSTGRES_USER="$db_username" -e POSTGRES_PASSWORD="$db_password" -d -v pgdata:/var/lib/postgresql/data -p 5432:5432 postgres:9.6-alpine
	#exit value of the last command that was executed
	exit $?
	;;

  start|stop)
  #check whether or not container exists
  if [ $container_status -ne 0 ]; then
    echo 'Container has not been created.'
      exit 1
      fi

  #start or stop the container
	  docker container $cmd jrvs-psql
	  exit $?
	;;
  
  *)
	echo 'Illegal command'
	echo 'Commands: start|stop|create'
	exit 1
	;;
esac