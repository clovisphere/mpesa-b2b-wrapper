# MPESA B2B API (wrapper)

[![PyTest](https://github.com/clovisphere/mpesa-b2b-wrapper/actions/workflows/pytest.yml/badge.svg?branch=main)](https://github.com/clovisphere/mpesa-b2b-wrapper/actions/workflows/pytest.yml)
[![Coverage Status](https://coveralls.io/repos/github/clovisphere/mpesa-b2b-wrapper/badge.svg?branch=main)](https://coveralls.io/github/clovisphere/mpesa-b2b-wrapper?branch=main)

A wrapper that makes it easy to integrate with the [MPESA B2B API](https://developer.safaricom.co.ke/Documentation).

![(simple) B2B Flow](docs/b2b_flow.svg)

The below endpoints are available:

```bash
[POST] api/v1.0/payment/initiate                      ✅
[POST] api/v1.0/payment/timeout                       ✅
[POST] api/v1.0/payment/confirm                       ✅
````

☝🏽 See [requests.http](requests.http) for sample requests + payloads.

<u>TODO</u>:

- [x] Unit tests
- [x] Logging
- [ ] Swagger docs
- [x] CI/CD
- [x] Dockerize
- [x] Deployment (or how-to section on how to deploy or run the app in production)

## Usage

Make a copy of [env.sample](env.sample) file named `.env`, and make sure all the **ENVIRONMENT_VARIABLES** are set.

```bash
$ cp env.sample .env  # make a copy of .env.sample called .env
```

### (1) Development

Prerequisites:

- [Python](https://www.python.org/downloads/release/python-3112/)
- [Pipenv](https://pipenv.pypa.io/en/latest/)
- [SQLite](https://www.sqlite.org/index.html)

With [Docker](https://www.docker.com/):

Make sure you have both [docker](https://www.docker.com/) and 
[docker-compose](https://docs.docker.com/compose/) installed locally.

```bash
$ make build-start-container-dev
````

Without [Docker](https://www.docker.com/):

```bash
# clone the repo
$ git clone git@github.com:clovisphere/mpesa-b2b-wrapper.git
# cd into project root
$ cd mpesa-b2b-wrapper
# generate a secret key
$ export SECRET_KEY=$(python -c "import secrets;print(secrets.token_urlsafe(16))")
# set database
$ export SQLALCHEMY_DATABASE_URI_DEV=sqlite:///demo-dev.db
# install dependencies
$ pipenv install
# activate virtualenv
$ pipenv shell
# run migrations
$ flask db upgrade
# run the app in debug mode
$ flask run --debug --host=0.0.0.0 --port=8000
```

If you need any help with migration, please refer to [Flask-Migrate](https://flask-migrate.readthedocs.io/en/latest/).

Test it out:

1. [/health](http://localhost:8000/health)

with [httpie](https://httpie.io/):

```http :8000/health```

you'd get:

```json
{
    "status": "healthy 😊"
}
```

To run unittest,

```bash
# install dev dependencies
$ pipenv install --dev
# run tests
$ coverage run -m pytest
# generate coverage report
$ coverage report -m
```


### (2) Production

Prerequisites:

- [Nginx](https://www.nginx.com/)
- [Python](https://www.python.org/downloads/release/python-3112/)
- [Node.js](https://nodejs.org/en/)
- [MySQL](https://www.mysql.com/) or [PostgreSQL](https://www.postgresql.org/)

<u>IMPORTANT</u>:

1. You need to create a **.env** file in the project root, and copy all the **ENVIRONMENT_VARIABLES** in [env.sample](./env.sample) to it.
2. Make sure to add your **PUBLIC KEY** in [config/cert](config/cert), the name of the key is to be specified in the **.env** file as **SSL_CERT**.

With [Docker](https://www.docker.com/):

```bash
# DATABASE_URL is of the form: mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}
$ make build-start-container-prod DATABASE_URL=url_to_your_prod_db
```

Without [Docker](https://www.docker.com/):

You may follow [this guide](https://www.digitalocean.com/community/tutorials/how-to-serve-flask-applications-with-gunicorn-and-nginx-on-ubuntu-18-04) to set up your server.


```bash
$ cd /var/www
$ git clone git@github.com:clovisphere/mpesa-b2b-wrapper.git
$ sudo chown -R $USER:www-data /var/www/mpesa-b2b-wrapper
$ sudo chmod -R 755 /var/www/mpesa-b2b-wrapper
$ pip install pipenv
$ pipenv install --system --deploy --ignore-pipfile
$ npm install pm2 -g
```

Set the below <u>**ENVIRONMENT_VARIABLES**</u> (they should be set in **.env**).

```bash
$ export FLASK_ENV=production
$ export SECRET_KEY=$(python -c "import secrets;print(secrets.token_urlsafe(16))") 
$ export SQLALCHEMY_DATABASE_URI=mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}
```

Create database tables with the below command:

```bash
$ flask db upgrade
```

Let's use [PM2](https://pm2.keymetrics.io/) to manage the application.

```bash
# create and start app
$ pm2 --name mpesa-b2b-wrapper start 'gunicorn --bind=0.0.0.0:5000 wsgi:app --workers=4 --timeout=120 --log-level=info'
# List the status of all application managed by PM2
$ pm2 ls
# To display logs in realtime
$ pm2 logs
# To restart or reload the app
$ pm2 [reload|restart] mpesa-b2b-wrapper
# To stop or delete the app
$ pm2 [stop|delete] mpesa-b2b-wrapper
```

###### Troubleshooting

- If for some reason, you choose to use [PostgreSQL](https://www.postgresql.org/)
instead of [MySQL](https://www.mysql.com/), you need to install the
below dependencies (assuming you are using a Debian-based distro):

```bash
$ sudo apt-get install libpq-dev
$ sudo apt-get install python3-psycopg2
$ export SQLALCHEMY_DATABASE_URI=postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}
```

- To use a different Python version in your [Pipfile](./Pipfile), follow [this guide](https://bilard.medium.com/change-python-version-in-pipenv-1ac7b8f9b7b9).

## Author

Clovis Mugaruka

- [github.com/clovisphere](https://github.com/clovisphere)
- [twitter/clovisphere](https://twitter.com/clovisphere)

## License

Copyright ©️ 2023, [Clovis Mugaruka](https://clovisphere.com).\
Released under the [MIT License](LICENSE).

