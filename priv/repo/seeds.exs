alias UScore.Repo

# Generate 1,000,000 user seeds with 0 points (default value for this column)
Repo.query!("TRUNCATE TABLE users;")

Repo.query!("""
INSERT INTO users (inserted_at, updated_at) (
  SELECT date_now, date_now FROM generate_series(1, 1000000), NOW() as date_now
);
""")
