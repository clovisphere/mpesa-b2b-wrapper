from flask import Flask, request
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text

from config.default import config

db = SQLAlchemy()


def create_app(config_name):
    """Create an application instance."""
    app = Flask(__name__)
    app.config.from_object(config[config_name])
    config[config_name].init_app(app)
    db.init_app(app)


    @app.before_request
    def log_request_info():
        """Log the request."""
        app.logger.debug(f'path={request.path}, method={request.method}, data={request.get_data(as_text=True)}')

    @app.after_request
    def log_response_info(response):
        """Log the response."""
        app.logger.debug(f'response={response.get_json(force=True)}')
        return response
    
    # our very basic health check 🌡️ 😽
    @app.route('/health', methods=['GET'])
    def health():
        response, status = {'status': 'healthy 😊'}, 200
        try:
            db.session.execute(text('SELECT 1'))
        except Exception:
            response['status'] = 'unhealthy 😣'
            status = 500
        return response, status

    # register blueprints
    from .api_1_0 import error_bp, api_bp
    app.register_blueprint(error_bp)
    app.register_blueprint(api_bp, url_prefix='/api/v1.0')
    return app
