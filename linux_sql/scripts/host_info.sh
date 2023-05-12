#setup arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

#Check the number of arguments is correct
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

#Save machine statistics in MB and current machine hostname to variables
vmstat_mb=$(vmstat --unit M)
#assign the result of lscpu to a variable to reuse
lscpu_out=`lscpu`
hostname=$(hostname -f)

#Retrieve hardware info
cpu_number=$(echo "$lscpu_out"  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out"  | egrep "^Architecture:" | awk '{print $2}' | xargs)
#get cpu model name
cpu_model=$(echo "$lscpu_out"  | egrep "^Model name:" | cut -d ':' -f 2-| xargs)
#get cpu mhz
cpu_mhz=$(echo "$lscpu_out"  | egrep "^CPU MHz:" | awk '{print $3}' | xargs)
#get l2 cache with the K suffix removed
l2_cache=$(echo "$lscpu_out"  | egrep "^L2 cache:" | awk '{print $3}' | sed 's/K$//')
#retrieve total memory in kb
total_mem=$(echo "$vmstat_mb" | tail -1 | awk '{print $4}')
#current UTC time in YYYY-MM-DD HH:MM:SS format
timestamp=$(date '+%Y-%m-%d %H:%M:%S')


#psql command to insert data into host_info table
insert_stmt="INSERT INTO host_info(hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, timestamp, total_mem) VALUES('$hostname', '$cpu_number', '$cpu_architecture', '$cpu_model', '$cpu_mhz', '$l2_cache', '$timestamp', '$total_mem')";

#environment variable for psql password
export PGPASSWORD=$psql_password
#Insert data into host_info table
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?