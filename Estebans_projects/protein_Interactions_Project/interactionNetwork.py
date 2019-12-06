#!/usr/bin/env python

from flask import Flask, request, redirect, url_for, render_template, flash
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import engine, PrimaryKeyConstraint

DBUSER = 'root'
DBPASS = 'Ayaat2012'
DBHOST = 'localhost'
DBPORT = '3306'
DBNAME = 'public'

app = Flask(__name__)
# app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///students.sqlite3'
app.config['SQLALCHEMY_DATABASE_URI'] = \
    'mysql://{user}:{passwd}@{host}:{port}/{db}'.format(
        user=DBUSER,
        passwd=DBPASS,
        host=DBHOST,
        port=DBPORT,
        db=DBNAME)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
#app.secret_key = 'foobarbaz'
db = SQLAlchemy(app)

class uniprot_mapping(db.Model):
    __tablename__ = 'uniprot_mapping'
    __table_args__ = (
        PrimaryKeyConstraint('string_id', 'uniprot_id'),
    )
    string_id = db.Column('string_id', db.Text)
    species = db.Column('species', db.Integer)
    uniprot_id = db.Column('uniprot_id', db.Text)
    identity = db.Column('identity', db.Numeric)
    bit_score = db.Column('bit_score', db.Numeric)

    def __init__(self, string_id, species, uniprot_id, identity, bit_score):
        self.string_id = string_id
        self.species = species
        self.uniprot_id = uniprot_id
        self.identity = identity
        self.bit_score = bit_score

#send the request to the server
@app.route('/', methods = ["GET", "POST"])
def home():
    queryId = request.args.get('uniprot_id');
    allProteins = request.args.get('allProteins').split(',');
    offset = request.args.get('offset');

    allProteinsList = [];
    for protein in allProteins:
        allProteinsList.append("'"+protein+"'");
    allProteinsList = ",".join(allProteinsList);

    print (allProteinsList);

    #query the database:
    db_query_results = db.engine.execute("SELECT m2.uniprot FROM links INNER JOIN mapping ON links.protein1 = mapping.ensembl "
                                       "INNER join mapping as m2 ON m2.ensembl = links.protein2 "
                                        "WHERE mapping.uniprot = '"+queryId+"' AND m2.uniprot IN ("+allProteinsList+") "
                                        "ORDER BY links.combined_score DESC LIMIT 5 OFFSET "+offset)
    #get a list of nodes from the returned proteins:
    nodes =[];
    for pro in db_query_results:
        #print(pro);
        nodes.append(pro[0]);
    print(nodes);
    return ",".join(nodes)

app.run(debug=True, host='0.0.0.0')