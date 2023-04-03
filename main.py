from flask import Flask,render_template,request,redirect,url_for,g,flash,session
import pyodbc,mysql.connector

app = Flask(__name__)
app.secret_key = b'_5#y2L"F4Q8z\n\xec]/'
conn = pyodbc.connect('Driver={MySQL ODBC 8.0 ANSI Driver};'
                      'Server=localhost;'
                      'Database=dbms_project2;'
                      'UID=root;'
                      'PWD=root')

def get_db():
    if 'db' not in g:
        g.db = conn
    return g.db

@app.teardown_appcontext
def close_db(error):
    if 'db' in g:
        g.db.close()




@app.route('/', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        staff_name = request.form['username']
        staff_id = request.form['password']
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM backend_staff WHERE staff_name=? AND staff_id=?", (staff_name, staff_id))
        user = cursor.fetchone()
        if user is not None:
            session['logged_in'] = True
            session['user_id'] = user[0]
            return redirect(url_for('home'))
        else:
            error = 'Invalid Credentials. Please try again.'
    return render_template('login.html', error=error)

'''
@app.route('/register', methods=['POST'])
def register():
    # Get the form data
    username = request.form['username']
    email = request.form['email']
    password = request.form['password']
    confirm_password = request.form['confirm_password']

    # Check if the passwords match
    if password != confirm_password:
        return 'Passwords do not match'

    # Insert the data into the database
    cursor = conn.cursor()
    cursor.execute("INSERT INTO users (username, email, password) VALUES (?, ?, ?)", (username, email, password))
    conn.commit()

    # Return a success message
    return redirect(url_for('login'))
'''

@app.route('/home')
def home():
    return render_template('home.html')


@app.route('/patient')
def patient():
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM patient')
    patient = cursor.fetchall()
    return render_template('patient.html', patient=patient)

import datetime

@app.route('/add_patient', methods=['POST'])
def add_patient():
    cursor = conn.cursor()
    try:
        # Get form data from request
        patient_id = request.form['patient_id']
        patient_name = request.form['patient_name']
        patient_dob = request.form['patient_dob']
        patient_sex = request.form['patient_sex']
        patient_address = request.form['patient_address']
        patient_status = request.form['patient_status']
        total_duration = request.form['total_duration']
        staff_id = request.form['staff_id']

        # Insert new row into patient table
        cursor.execute('INSERT INTO patient (patient_id, patient_name, patient_dob, patient_sex, patient_address, patient_status, total_duration, staff_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', (patient_id, patient_name, patient_dob, patient_sex, patient_address, patient_status, total_duration, staff_id))
        conn.commit()

        # Redirect back to index page
        return redirect(url_for('patient'))

    except Exception as e:
        # Rollback changes if there was an error
        conn.rollback()
        flash('Error inserting new patient: ' + str(e))
        return redirect(url_for('patient'))
    
@app.route('/programs')
def programs():
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM programs')
    programs = cursor.fetchall()
    return render_template('programs.html', programs=programs)




app.run(debug=True)

