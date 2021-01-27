#!/bin/bash
#Script created by Teodor Naydenov
#Organization: ITGix
#we would start the script by ./check_galera.sh galera_container mysql_user(was cinder in our case) mysql_pass

container=$1
mysql_user=$2
mysql_pass=$3
 
devstack () {
wsrep_ready=$(mysql -h $container -u $mysql_user -p$mysql_pass -e "SHOW GLOBAL STATUS LIKE 'wsrep_ready';" | grep wsrep_ready | cut -f 2 )
wsrep_local_state_comment=$(mysql -h $container -u $mysql_user -p$mysql_pass -e "SHOW GLOBAL STATUS LIKE 'wsrep_local_state_comment';" | grep wsrep_local_state_comment | cut -f 2 )
wsrep_cluster_size=$(mysql -h $container -u $mysql_user -p$mysql_pass -e "SHOW GLOBAL STATUS LIKE 'wsrep_cluster_size';" | grep wsrep_cluster_size | cut -f 2 )
wsrep_connected=$(mysql -h $container -u $mysql_user -p$mysql_pass -e "SHOW GLOBAL STATUS LIKE 'wsrep_connected';" | grep wsrep_connected | cut -f 2 )
}

OPENSTACKS=("devstack")
for item in "${OPENSTACKS[@]}";
do
	if [ "$item" == "devstack" ];then
		devstack
		if [ "$wsrep_local_state_comment" == "Synced" ] && [ "$wsrep_ready" == "ON" ] && [ "$wsrep_connected" == "ON" ];then
			echo "OK:Galera node on $container is Synced and ON; Cluster has $wsrep_cluster_size nodes in total."
		else
			echo "ERROR:Galera node in $container is $wsrep_local_state_comment and $wsrep_ready and $wsrep_connected "
		fi
	fi
done


