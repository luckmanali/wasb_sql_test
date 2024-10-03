# SQL Testing Framework for Databases

## Overview
This project provides a generic SQL testing framework that supports various databases. The framework uses `pytest` and `yaml` to run dynamic SQL tests. You can define your tests and database connection configurations in a `config.yaml` file and run them against any supported database with minimal modifications.

## Setup
1. **Install Dependencies**:
   ```
   pip install trino pytest pyyaml
   ```
   *(Install relevant database connectors based on your use case)*

2. **Configure the `config.yaml` File**:
   Update the `config.yaml` file with the necessary database credentials and test cases (see below for configuration details).

## Usage
Run the tests using:
```
pytest test_sql_queries.py
```

## File Structure
- **`test_sql_queries.py`**: Main test script that connects to the database and dynamically executes tests based on the `config.yaml` file.
- **`config.yaml`**: Holds database configurations and test cases. Supports any database for which a Python connector is available.

## Configuring the `config.yaml` File
The `config.yaml` file contains two main sections:
1. **Database Configurations** (`db_config`):
   - **`db_type`**: The type of database (e.g., `trino`, `sqlite`, `postgresql`, `mysql`).
   - **`host`**, **`port`**, **`user`**, **`catalog`**, **`schema`**, etc.: Vary depending on the database type.
   - The connection is established using appropriate Python libraries depending on `db_type`.

2. **Test Cases** (`tests`):
   - Each test case has:
     - **`name`**: A unique name for the test.
     - **`description`**: A brief description of what the test checks.
     - **`query`**: The SQL query to run.
     - **`expected_result`**: The expected output of the query in the form of a list of tuples.

### Example `config.yaml`:
```yaml
db_config:
  db_type: "trino"  # Options: "trino", "sqlite", "postgresql", "mysql"
  host: "localhost"
  port: 8080
  user: "admin"
  catalog: "memory"  # Trino-specific parameter, optional for others
  schema: "default"

tests:
  - name: "Employee Table Structure"
    description: "Check that the EMPLOYEE table has unique employee IDs."
    query: "SELECT COUNT(DISTINCT employee_id) = COUNT(employee_id) AS employee_id_unique FROM EMPLOYEE;"
    expected_result: [(1,)]

  - name: "Total Employee Count"
    description: "Validate that the total number of employees matches the expected count."
    query: "SELECT COUNT(*) = 5 AS correct_employee_count FROM EMPLOYEE;"
    expected_result: [(1,)]

  - name: "Expense Amounts Validity"
    description: "Ensure all expenses are associated with valid employee IDs."
    query: "SELECT COUNT(*) = 0 FROM EXPENSE WHERE employee_id NOT IN (SELECT employee_id FROM EMPLOYEE);"
    expected_result: [(1,)]
```

## Adding New Tests
To add a new test case:
1. Open the `config.yaml` file.
2. Under the `tests` section, add a new block with:
   - **`name`**: Name of your test.
   - **`description`**: A brief description of what the test does.
   - **`query`**: The SQL query to be run.
   - **`expected_result`**: The expected result in the format of a list of tuples.

### Example of a New Test:
```yaml
  - name: "Check Total Expenses"
    description: "Ensure the total expenses are correctly calculated."
    query: "SELECT SUM(unit_price * quantity) FROM EXPENSE;"
    expected_result: [(12345.67,)]  # Replace with the correct expected value
```

## Supported Databases
The framework supports multiple databases depending on the `db_type` parameter in the `config.yaml` file:
1. **Trino**: Use `trino` as `db_type` and specify `host`, `port`, `catalog`, and `schema`.
2. **SQLite**: Use `sqlite` and specify the `database` file path.
3. **PostgreSQL**: Use `postgresql` and specify `host`, `port`, `database`, `user`, and `password`.
4. **MySQL**: Use `mysql` and specify `host`, `port`, `database`, `user`, and `password`.

## Expected Output
The framework will run all tests defined in the `config.yaml` file and report which tests passed or failed. The results will include a comparison between the actual and expected results, making it easy to identify issues.

## Future Enhancements
- Add support for more database types by integrating additional connectors.
- Provide detailed test reporting with logs for failed queries.
- Implement support for more complex SQL query validations.
- Improve terminal output pretty.