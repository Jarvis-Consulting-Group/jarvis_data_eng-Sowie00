#Setup arguments

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

#Check the number of arguments are correct
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

#assign the output of vmstat to variable and set the unit to MB
vmstat_mb=$(vmstat --unit M)
#get VM hostname
hostname=$(hostname -f)

#get usage specification variables
#get amount of free memory in MB
memory_free=$(echo "$vmstat_mb" | awk '{print $4}'| tail -n1 | xargs)
#get CPU idle time percentage
cpu_idle=$(echo "$vmstat_mb" | awk '{print $15}' | tail -n1 | xargs)
#get percentage for CPU time spent on system processes
cpu_kernel=$(echo "$vmstat_mb" | awk '{print $13}' | tail -n1 | xargs)
#retrieve disk_io info
disk_io=$(vmstat -d | awk '{print $10}' | tail -n1)
#get storage space available for "/" (root) directory and remove M suffix
disk_available=$(df -BM / | tail -n1 | awk '{print $4}' | sed 's/M$//')

#current UTC time in YYYY-MM-DD HH:MM:SS format
timestamp=$(date +"%Y-%m-%d %H:%M:%S")
#environment variable for psql password
export PGPASSWORD=$psql_password
host_id=$(psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -t -c "SELECT id FROM host_info WHERE hostname = '$hostname';")
#sql statement to insert server usage data into host_usage table
insert_stmt="INSERT INTO host_usage(timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available) VALUES('$timestamp', $host_id, '$memory_free', '$cpu_idle', '$cpu_kernel', '$disk_io', '$disk_available');"



#Insert server usage data into host_info table
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?