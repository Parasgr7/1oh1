# Steps to run the project

## 1oh1 - P2P Communications

### Before running the below commands install:
#### 1. Ruby 2.3.3
#### 2. Rails 5.0.7.2
#### 3. Postgresql (DB)

Run Postgres Server in another terminal
```bash
    psql
    CREATE DATABASE mvp1oh1;
    \q (Exit from terminal)
    pg_ctl -D /usr/local/var/postgres start (run postgres server)

```
Download Development Database from below drive link and run the command below
```bash
    https://drive.google.com/file/d/1DNRIIJkXvYWOLITzWOoeeM80ZUcM1FP4/view?usp=sharing
    psql -U "username" mvp1oh1 < backup.sql

```
Run Rails Server in one terminal
```bash
   git clone <Bitbucket Url>
   cd mvp-1oh1
   bundle install
   rails server
```
