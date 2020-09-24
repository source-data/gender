# -*- coding: utf-8 -*-
# t lemberger embo 2018

from genderize import Genderize
import argparse
import re

TAB = "\t"
NL = "\n"

def predict(filename):
    gender = []
    unique_id = []
    G = Genderize()
    regexp = re.compile(r'^(.*)\s')
    with open(filename, 'r', newline='') as f: # hopefully opens file in universal newline mode
       for idx, line in enumerate(f):
        #    print(line, idx)
           line = line.strip()
           unique_id.append(line.split('\t')[0])
        #    print(unique_id)
           if line: # skip empty lines
               s = regexp.search(line)
               if s:
                   firstname = s.group(1).split('\t')[1]
                   print(firstname)
                   g = G.get([firstname])[0]
                   print(TAB.join(["{}:{}".format(k, g[k]) for k in g]))
                   gender.append(g)
               else:
                   print("skipped", line)
    basename, ext = filename.split('.')
    resultfile = basename+"_genders."+ext
    with open(resultfile, 'w') as f:
        header = TAB.join(['unique_id'] + [k for k in gender[0]])
        f.write(header+NL)
#
        for idx, l in enumerate(gender):
           #'gender': 'male', 'probability': 1.0, 'count': 3753
           row = TAB.join([unique_id[idx]] + [str(l[k]) for k in l])
           f.write(row+NL)
#
    print("results written to {}".format(resultfile))



def main():
    parser = argparse.ArgumentParser(description='Top level module to manage training.', formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('file', default='names.txt', help='Name of the text file with the list of names; 1 name per line.')
    args = parser.parse_args()
    predict(args.file)
    
if __name__ == '__main__':
    main()
