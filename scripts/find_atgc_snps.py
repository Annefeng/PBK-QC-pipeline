#!/usr/bin/python
from sys import argv
bimfile = argv[-1]
assert bimfile.endswith('.bim')

for line in file(bimfile):
       	line = line.strip().split()
       	alleles = line[-2:]
       	if sorted(alleles) in (['C','G'],['A','T']):
       		print line[1]
