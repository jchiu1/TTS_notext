import string, sys, os, math, array, re, operator

ifile = open( sys.argv[1],'r')
ofile = open( sys.argv[2],'w')

lines = ifile.readlines()

for l in lines:
    token = l.split("(")
    text = token[0].strip()
    name = token[1].strip()[:-1]
    ofile.write("( " + name +" \""+text+"\" )\n")

ifile.close()
ofile.close()
