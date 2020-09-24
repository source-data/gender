import os
import argparse
from flask import Flask, jsonify, make_response, render_template, request, redirect, url_for, send_from_directory, flash, send_file
from utils import cleanup

app = Flask(__name__, )

app.secret_key = 'super secret key'

app.config['UPLOAD_FOLDER'] = 'webapp/input'
app.config['RESULTS_FOLDER'] = 'webapp/results'


if not os.path.exists(app.config['UPLOAD_FOLDER']):
    os.makedirs(app.config['UPLOAD_FOLDER'])
if not os.path.exists(app.config['RESULTS_FOLDER']):
    os.makedirs(app.config['RESULTS_FOLDER'])


@app.route("/")
@app.route("/home")
def home():
    cleanup('webapp/results/')
    cleanup('webapp/input/')
    return render_template("home.html")


@app.route('/about')
def about():
    return render_template('about.html')


@app.route("/upload", methods=['POST'])
def upload():
    if request.method == "POST":
        upload_file = request.files['eJP_txt_file']
        if upload_file:
            upload_file.save(os.path.join(app.config['UPLOAD_FOLDER'], upload_file.filename))
            return redirect(url_for('processGenderize'))   


@app.route('/process', methods = ['GET', 'POST'])
def processGenderize():
    input_file = os.listdir('webapp/input/')[0]
    output_file = input_file.split('.txt')[0]+'_annotated.txt'
    output_file = os.path.join('results', output_file)
    os.system('Rscript gender_parse.R -i ' + input_file + ' -nlines ' + '17')
    # print('output file is ', output_file)
    return send_file(output_file, as_attachment = True)


if __name__ == "__main__":
    app.run(debug=True, host = 'localhost', port = 5001)
