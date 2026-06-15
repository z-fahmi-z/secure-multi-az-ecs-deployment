import json
import boto3
import pg8000
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_db_password():
    secret_arn = os.environ['SECRET_ARN']
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_arn)
    secret = json.loads(response['SecretString'])
    return secret['password']

def lambda_handler(event, context):
    db_name = os.environ['DB_NAME']
    db_user = os.environ['DB_USER']
    db_host = os.environ['DB_HOST']
    db_port = int(os.environ.get('DB_PORT', '5432'))

    logger.info(f"Connecting to database at {db_host}:{db_port}/{db_name}")

    conn = None
    try:
        conn = pg8000.connect(
            host=db_host,
            database=db_name,
            user=db_user,
            password=get_db_password(),
            port=db_port,
            timeout=10
        )

        # Single transaction, rolls back everything if any statement fails
        with conn:
            with conn.cursor() as cur:
                cur.execute("""
                    CREATE TABLE IF NOT EXISTS entries (
                        id          VARCHAR                  PRIMARY KEY,
                        data        JSONB                    NOT NULL,
                        created_at  TIMESTAMP WITH TIME ZONE NOT NULL,
                        updated_at  TIMESTAMP WITH TIME ZONE NOT NULL
                    )
                """)

                cur.execute("""
                    CREATE INDEX IF NOT EXISTS idx_entries_created_at
                    ON entries (created_at)
                """)

                cur.execute("""
                    CREATE INDEX IF NOT EXISTS idx_entries_data_gin
                    ON entries USING GIN (data)
                """)

                # Verify tables
                cur.execute("""
                    SELECT table_name
                    FROM information_schema.tables
                    WHERE table_schema = 'public'
                      AND table_name = 'entries'
                """)
                tables = [row[0] for row in cur.fetchall()]

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
        raise

    finally:
        # Only close if connection exists AND is not already closed
        if conn is not None and not getattr(conn, 'is_closed', False):
            try:
                conn.close()
            except Exception as close_error:
                logger.warning(f"Error while closing connection: {close_error}")