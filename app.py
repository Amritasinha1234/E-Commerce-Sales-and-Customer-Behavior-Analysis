from flask import Flask, render_template
from flask_socketio import SocketIO, emit
import mysql.connector
import time
from threading import Thread

app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")

# Database connection function
def connect_to_db():
    try:
        conn = mysql.connector.connect(
            host="localhost",
            user="root",
            password="1234",
            database="ecommercedb"
        )
        conn.autocommit = True
        if conn.is_connected():
            print("Connected to MySQL database")
        return conn
    except mysql.connector.Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None

# Function to fetch the current alert state
def fetch_alert_state(cursor):
    cursor.execute("SELECT AlertID, ProductID, AlertType FROM inventoryalerts")
    return {row[0]: {'ProductID': row[1], 'AlertType': row[2]} for row in cursor.fetchall()}

# Monitor database changes in a separate thread
def monitor_changes():
    conn = connect_to_db()
    if not conn:
        return

    cursor = conn.cursor()
    alert_state = fetch_alert_state(cursor)

    while True:
        new_alert_state = fetch_alert_state(cursor)
        
        # Check for new or updated alerts
        for alert_id, alert_info in new_alert_state.items():
            if alert_id not in alert_state:
                # New alert detected, emit to clients
                socketio.emit('new_alert', {
                    'AlertID': alert_id, 
                    'ProductID': alert_info['ProductID'], 
                    'AlertType': alert_info['AlertType']
                })
            elif new_alert_state[alert_id]['AlertType'] != alert_state[alert_id]['AlertType']:
                # Alert type change detected, emit to clients
                socketio.emit('update_alert', {
                    'AlertID': alert_id,
                    'ProductID': alert_info['ProductID'],
                    'oldAlertType': alert_state[alert_id]['AlertType'],
                    'newAlertType': alert_info['AlertType']
                })

        alert_state = new_alert_state
        time.sleep(1)

# Route for the main page
@app.route('/')
def index():
    return render_template('index.html')

# Start the database monitoring thread when the server starts
if __name__ == '__main__':
    monitor_thread = Thread(target=monitor_changes)
    monitor_thread.daemon = True
    monitor_thread.start()
    socketio.run(app, debug=True)
