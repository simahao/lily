import logging
import logging.config
import os

LOG_DIR = os.path.dirname(os.path.abspath(__file__))
log_config = {
    'version': 1,
    'formatters': {
        'verbose': {
            'class': 'logging.Formatter',
            'format': '%(asctime)s [%(name)s] %(levelname)-8s %(pathname)s:%(lineno)d - %(message)s',
            'datefmt': '%Y-%m-%d %H:%M:%S',
            'style': '%'
        },
        'simple': {
            'class': 'logging.Formatter',
            'format': '%(asctime)s %(levelname)-8s - %(message)s',
            'datefmt': '%Y-%m-%d %H:%M:%S',
            'style': '%'
        }
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'level': 'DEBUG',
            'formatter': 'simple'
        },
        'octopus': {
            'class': 'logging.FileHandler',
            'level': 'INFO',
            'filename': os.path.join(LOG_DIR, 'octopus.log'),
            'mode': 'a',
            'formatter': 'verbose',
            'encoding': 'utf-8'
        },
        'surveillance': {
            'class': 'logging.FileHandler',
            'level': 'INFO',
            'filename': os.path.join(LOG_DIR, 'surveillance.log'),
            'mode': 'a',
            'formatter': 'verbose',
            'encoding': 'utf-8'
        },
        'file': {
            'class': 'logging.FileHandler',
            'level': 'INFO',
            'filename': 'app.log',
            'mode': 'a',
            'formatter': 'verbose',
            'encoding': 'utf-8'
        },
        'rotate_file': {
            'class': 'logging.handlers.RotatingFileHandler',
            'level': 'INFO',
            'filename': 'app.log',
            'mode': 'a',
            'formatter': 'verbose',
            'maxBytes': 10485760,
            'backupCount': 3,
            'encoding': 'utf-8'
        }
    },
    'loggers': {
        'Octopus': {
            'handlers': ['octopus']
        },
        'Surveillance': {
            'handlers': ['surveillance']
        }
    },
    'root': {
        'level': 'INFO',
        'handlers': ['console']
    }
}
# propagate default is true,so message is propagated its parent's logger until root
# e.x. Octopus flush message to file, and progagate message to root logger, and flush to console
logging.config.dictConfig(log_config)
