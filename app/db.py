import os
import oracledb
from contextlib import contextmanager


def get_dsn() -> str:
    dsn = os.getenv("ORACLE_DSN")
    if not dsn:
        raise RuntimeError("ORACLE_DSN env var not set (e.g., host:port/service or 'localhost/XEPDB1')")
    return dsn


def get_credentials():
    user = os.getenv("ORACLE_USER")
    password = os.getenv("ORACLE_PASSWORD")
    if not user or not password:
        raise RuntimeError("ORACLE_USER or ORACLE_PASSWORD env var not set")
    return user, password


@contextmanager
def db_cursor():
    user, password = get_credentials()
    dsn = get_dsn()
    connection = oracledb.connect(user=user, password=password, dsn=dsn)
    try:
        with connection.cursor() as cursor:
            yield cursor
        connection.commit()
    finally:
        connection.close() 