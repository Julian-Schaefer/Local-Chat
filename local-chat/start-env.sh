docker-compose up
docker-compose exec cassandra cqlsh -e "CREATE KEYSPACE IF NOT EXISTS localchat WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};"