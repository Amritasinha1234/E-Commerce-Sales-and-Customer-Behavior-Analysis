import mysql.connector
import time

# Connect to MySQL
def connect_to_db():
    try:
        conn = mysql.connector.connect(
            host="localhost",
            user="root",
            password="1234",
            database="ecommercedb"
        )
        conn.autocommit = True  # Enable auto-commit to avoid cached results
        if conn.is_connected():
            print("Connected to MySQL database")
        return conn
    except mysql.connector.Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None

# Function to fetch the current state of inventory alerts
def fetch_alert_state(cursor):
    cursor.execute("SELECT AlertID, ProductID, AlertType FROM inventoryalerts")
    return {row[0]: {'ProductID': row[1], 'AlertType': row[2]} for row in cursor.fetchall()}

# Monitor changes in the database
def monitor_changes():
    conn = connect_to_db()
    if not conn:
        return

    cursor = conn.cursor()

    # Initial state
    alert_state = fetch_alert_state(cursor)
    print("Initial alert state:", alert_state)  # Debugging: Print initial alert state

    print("Starting to monitor database changes...\n")
    
    try:
        while True:
            # Check for new or updated inventory alerts
            new_alert_state = fetch_alert_state(cursor)
            print("New alert state:", new_alert_state)  # Debugging: Print each new alert state

            for alert_id, alert_info in new_alert_state.items():
                if alert_id not in alert_state:
                    # New alert detected
                    print(f"New alert added: AlertID {alert_id}, ProductID {alert_info['ProductID']}, AlertType {alert_info['AlertType']}")
                elif new_alert_state[alert_id]['AlertType'] != alert_state[alert_id]['AlertType']:
                    # Alert type change detected
                    print(f"Alert {alert_id} for Product {alert_info['ProductID']} changed AlertType from {alert_state[alert_id]['AlertType']} to {alert_info['AlertType']}")

            # Update the alert state
            alert_state = new_alert_state

            # Wait for 1 second before checking again (for faster testing)
            time.sleep(1)

    except KeyboardInterrupt:
        print("Monitoring stopped.")

    finally:
        cursor.close()
        conn.close()
        print("MySQL connection closed.")

# Run the monitor
if __name__ == "__main__":
    monitor_changes()
