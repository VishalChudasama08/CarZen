# app/database/connection.py
import os
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

ENV_PATH = Path(__file__).resolve().parents[3] / ".env"
load_dotenv(dotenv_path=ENV_PATH)

DB_USER = os.getenv("DATABASE_USER")
DB_PASSWORD = os.getenv("DATABASE_PASSWORD")
DB_HOST = os.getenv("DATABASE_HOST")
DB_PORT = os.getenv("DATABASE_PORT", "3306")
DB_NAME = os.getenv("DATABASE_NAME")

# Construct the MySQL Connection URL string
# mysql+pymysql://user:password@host/database
DATABASE_URL = (
    f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)
# Create the Engine (Note: connect_args removed as it is SQLite-only)
engine = create_engine(DATABASE_URL, echo=True, pool_pre_ping=True)

# Safe enum deserialization: support both lowercase enum values and uppercase member names seamlessly
from sqlalchemy.sql.sqltypes import Enum as SAEnum
_orig_object_value_for_elem = SAEnum._object_value_for_elem

def _safe_object_value_for_elem(self, elem):
    if elem is None:
        return None
    if elem in self._object_lookup:
        return self._object_lookup[elem]
    if isinstance(elem, str):
        elem_lower = elem.lower()
        for k, v in self._object_lookup.items():
            if k is not None and str(k).lower() == elem_lower:
                return v
            if hasattr(v, 'value') and str(v.value).lower() == elem_lower:
                return v
            if hasattr(v, 'name') and str(v.name).lower() == elem_lower:
                return v
        if elem_lower in ('old', 'oldcar', 'old_car'):
            for k, v in self._object_lookup.items():
                if k in ('OLD', 'oldCar'):
                    return v
    return _orig_object_value_for_elem(self, elem)

SAEnum._object_value_for_elem = _safe_object_value_for_elem

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Dependency to get database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
