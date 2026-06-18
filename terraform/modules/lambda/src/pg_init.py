import json
import boto3
import pg8000
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_db_password():
    """Retrieve database password from AWS Secrets Manager"""
    secret_arn = os.environ['SECRET_ARN']
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_arn)
    secret = json.loads(response['SecretString'])
    return secret['password']

def lambda_handler(event, context):
    """Initialize database schema and indexes for the entries table"""
    db_name = os.environ['DB_NAME']
    db_user = os.environ['DB_USER']
    db_host = os.environ['DB_HOST']
    db_port = int(os.environ.get('DB_PORT', '5432'))

    logger.info(f"Connecting to database at {db_host}:{db_port}/{db_name}")

    conn = None
    tables = []
    indexes = []
    
    try:
        # Establish database connection
        conn = pg8000.connect(
            host=db_host,
            database=db_name,
            user=db_user,
            password=get_db_password(),
            port=db_port,
            timeout=10
        )
        
        # Disable autocommit - we want explicit transaction control
        conn.autocommit = False
        
        logger.info("Database connection established")

        # Execute all DDL operations in a single transaction
        with conn.cursor() as cur:
            logger.info("Starting database initialization transaction")
            
            # Create the entries table
            cur.execute("""
                CREATE TABLE IF NOT EXISTS entries (
                    id          VARCHAR                  PRIMARY KEY,
                    data        JSONB                    NOT NULL,
                    created_at  TIMESTAMP WITH TIME ZONE NOT NULL,
                    updated_at  TIMESTAMP WITH TIME ZONE NOT NULL
                )
            """)
            logger.info("Table 'entries' created/verified")
            
            # Create index on created_at for efficient time-based queries
            cur.execute("""
                CREATE INDEX IF NOT EXISTS idx_entries_created_at
                ON entries (created_at)
            """)
            logger.info("Index 'idx_entries_created_at' created/verified")
            
            # Create GIN index on data for efficient JSONB querying
            cur.execute("""
                CREATE INDEX IF NOT EXISTS idx_entries_data_gin
                ON entries USING GIN (data)
            """)
            logger.info("Index 'idx_entries_data_gin' created/verified")
            
            # Verify table creation
            cur.execute("""
                SELECT table_name
                FROM information_schema.tables
                WHERE table_schema = 'public'
                  AND table_name = 'entries'
            """)
            tables = [row[0] for row in cur.fetchall()]
            logger.info(f"Verified tables: {tables}")

            # Verify indexes creation
            cur.execute("""
                SELECT indexname
                FROM pg_indexes
                WHERE tablename = 'entries'
                  AND indexname IN (
                      'idx_entries_created_at',
                      'idx_entries_data_gin'
                  )
            """)
            indexes = [row[0] for row in cur.fetchall()]
            logger.info(f"Verified indexes: {indexes}")
            
            # Commit the entire transaction - all or nothing
            conn.commit()
            logger.info("Transaction committed successfully")

        logger.info("Database initialization complete")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Database initialization complete',
                'tables': tables,
                'indexes': indexes,
            })
        }

    except Exception as e:
        logger.error(f"Database initialization failed: {str(e)}")
        
        # Rollback transaction on any error
        if conn is not None:
            try:
                conn.rollback()
                logger.info("Transaction rolled back due to error")
            except Exception as rollback_error:
                logger.warning(f"Error during rollback: {rollback_error}")
        
        # Re-raise the exception to trigger Lambda failure
        raise

    finally:
        # Always close the connection if it exists and is open
        if conn is not None and not getattr(conn, 'is_closed', False):
            try:
                conn.close()
                logger.info("Database connection closed")
            except Exception as close_error:
                logger.warning(f"Error while closing connection: {close_error}")