# Setup

## To get going locally:

pre-requisits (known version numbers):

- postgres (11.1)


```bash
cp .env.example .env    # and set ENV vars
```

create postgres database and users:

```bash
# [in psql]
CREATE USER admin WITH CREATEDB LOGIN;
CREATE DATABASE avid_occupancy_development WITH OWNER admin;
```

## Migrations
```
rake db:migrate
rake db:migrate[1]
```
