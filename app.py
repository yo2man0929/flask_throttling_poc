from flask import Flask, jsonify
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_httpauth import HTTPBasicAuth
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
auth = HTTPBasicAuth()

# throttling default limit
default_limit = "10 per second"
no_throttling_users = ["user3"]  # user3 will not have rate limits

# Initialize Limiter
limiter = Limiter(
    app,
    key_func=lambda: auth.username(),
    default_limits=[default_limit]
)

users = {
    "user1": generate_password_hash("password1"),
    "user2": generate_password_hash("password2"),
    "user3": generate_password_hash("password3")  # Add user3 with a password
}

@auth.verify_password
def verify_password(username, password):
    if username in users and \
            check_password_hash(users.get(username), password):
        return username

@app.route('/')
@auth.login_required
@limiter.limit(default_limit, exempt_when=lambda: auth.username() in no_throttling_users)
def index():
    return jsonify({"message": "flask_throttling_poc, {}!".format(auth.current_user())})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)

