import pg8000
import os
import json
from pathlib import Path

# PostgreSQL connection details from environment variables
db_host = os.getenv('host', 'localhost')
db_name = os.getenv('db', 'postgres')
db_user = os.getenv('user', 'postgres')
db_password = os.getenv('pass', 'password')

# Schema name
schema_name = "fetch_challenge"

# Establish the database connection using pg8000
conn = pg8000.connect(
    host=db_host,
    port=25060,
    database='defaultdb',
    user=db_user,
    password=db_password
)
cursor = conn.cursor()

# Ensure the schema exists
cursor.execute(f"CREATE SCHEMA IF NOT EXISTS {schema_name}")
conn.commit()

# Directory containing JSON files (Mac Downloads folder)
json_directory = str(Path.home() / "Downloads")

# Process each JSON file in the directory
for file_name in os.listdir(json_directory):
    if file_name.endswith(".json"):
        table_name = os.path.splitext(file_name)[0]  # Use file name (without extension) as table name
        full_table_name = f"{schema_name}.{table_name}"  # Add schema to table name
        file_path = os.path.join(json_directory, file_name)

        # Create table in the schema if not exists
        create_table_query = f"""
        CREATE TABLE IF NOT EXISTS {full_table_name} (
            id SERIAL PRIMARY KEY,
            data JSONB
        );
        """
        cursor.execute(create_table_query)
        conn.commit()

        # Load JSON data into the table
        with open(file_path, 'r') as json_file:
            for line in json_file:
                try:
                    json_data = json.loads(line)  # Parse each line as JSON
                    insert_query = f"INSERT INTO {full_table_name} (data) VALUES (%s)"
                    cursor.execute(insert_query, (json.dumps(json_data),))
                except Exception as e:
                    print(f"Error loading line in file {file_name}: {e}")

        print(f"Loaded {file_name} into table {full_table_name}")

# Commit changes and close connection
conn.commit()
cursor.close()
conn.close()
