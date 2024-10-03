from trino.dbapi import connect as trino_connect
import yaml
import pytest

# Load test configurations from a YAML file
def load_config(config_file="config.yaml"):
    with open(config_file, 'r') as file:
        config = yaml.safe_load(file)
    return config

# Establish a database connection based on configuration
@pytest.fixture(scope="module")
def db_connection():
    config = load_config()
    conn = trino_connect(
        host=config['db_config']['host'],
        port=config['db_config']['port'],
        user=config['db_config']['user'],
        catalog=config['db_config']['catalog'],
        schema=config['db_config']['schema']
    )
    yield conn
    conn.close()

# Automatically generate test cases from configuration
def pytest_generate_tests(metafunc):
    config = load_config()
    if "test_case" in metafunc.fixturenames:
        test_cases = config['tests']
        metafunc.parametrize("test_case", test_cases)

# Execute each test case dynamically
def test_sql_queries(db_connection, test_case):
    cursor = db_connection.cursor()
    cursor.execute(test_case['query'])
    result = cursor.fetchall()
    assert result == test_case['expected_result'], f"Test '{test_case['name']}' failed. Expected: {test_case['expected_result']}, Got: {result}"
