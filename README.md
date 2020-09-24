# Gender prediction

A small utility based on [genderize](https://genderize.io/). 
Uses the Python client to the genderize web service (https://github.com/SteelPangolin/genderize).

## Install

Create virtual environment:

    $ python3 -m venv .venv

    
Activate virtual environment:

    $ source .venv/bin/activate

Install required dependencies:

    $ pip3 install -r requirements.txt

## Run

Run the analysis:

    $ python -m g names.txt

    
**important** The format of the input file should be: 

    unique_id   name

The unique_id is simply a number of identify each row that goes into the analysis

    unique_id indiv_referees
    1 Eva-Maria Mandelkow 
    2 Jurgen Gotz
    3 Karen Avraham
    4 Stephen High
    5 Ramanujan Hegde
    6 Alfred Goldberg

*Warning*: There is a limit of 1000 requests per day!


## Output

Output sample:

    $ python -m g names.txt
    name:Eva-Maria	gender:female	probability:1.0	count:6
    name:Jurgen	gender:male	probability:0.97	count:36
    name:Karen	gender:female	probability:1.0	count:5462
    name:Stephen	gender:male	probability:1.0	count:2608
    name:Ramanujan	gender:None
    name:Alfred	gender:male	probability:1.0	count:230
    name:Helene	gender:female	probability:1.0	count:255
    name:Silvio	gender:male	probability:1.0	count:183
    name:Junmin	gender:male	probability:1.0	count:2
    name:Mark	gender:male	probability:1.0	count:6176
    name:Henning	gender:male	probability:1.0	count:77
    name:Ted	gender:male	probability:1.0	count:376
    name:Olga	gender:female	probability:1.0	count:898
    name:Mala	gender:female	probability:0.97	count:33
    name:Thilo	gender:male	probability:1.0	count:11
    results written to names_genders.txt


## Usage directly from an eJP report file: 

*requires libraries dplyr, readr, mefa, argparse and XML*

    $ Rscript gender_parse.R -i names.txt -nlines 'number of lines that should be skipped when reading in the file'

    arguments:
    -i input file
    -nlines number of lines to skip when reading in the eJP report file


## Web application

### Usage

cd to the directory 'webapp/'

    $ python gender_webapp.py

Go to localhost:5001

Upload an eJP track report file. Results are automatically downloaded as a txt file.



