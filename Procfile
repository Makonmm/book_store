release: python manage.py migrate
web: gunicorn BookStore.wsgi:application --bind 0.0.0.0:$PORT
