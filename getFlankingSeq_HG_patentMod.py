#!/usr/bin/python
# -*- coding: utf-8 -*-
# Simon - Feb 2011
## HG patent-mod Tim Knutsen - Jan 2017
## This modification simplifies the output and assumes that the CT part of CT/C is the reference allele.
## The script then adds the correct offset to the right flank. 
import sys
import os.path
import getopt
#import difflib
from Bio import SeqIO

flankLen = 100

if len(sys.argv) < 4:
  print "v0.2"
  print "usage: "+sys.argv[0]+" <ref fasta> <SNP list> <flank length [100]> <output file>"
  print "input format:"
  print "Chr6	88738458	CT/C"
  print "Chr6	88738692	T/TA"
  print "Chr6	88739045	A/G"

  sys.exit(2)

FASTAfilename = sys.argv[1]
SNPsPosFilename = sys.argv[2]
flankLen = int(sys.argv[3])
outFile = sys.argv[4]

f=open(FASTAfilename)
seq_dict = SeqIO.to_dict(SeqIO.parse(f,"fasta"))

try:
    ofile=open( outFile,"w")
except IOError:
    print "Cannot open "+outFile

pufd = open(SNPsPosFilename, "rU")
snpType = ""
snpNumber = 1

for pline in pufd:
  parts=pline.split("\t")
  contigName=parts[0].strip()
  pos=int(parts[1].strip())
  iub=parts[2].strip()
  
  contigSeq = ""  
  try:
      contigSeq = str(seq_dict[contigName].seq)
  except KeyError:
      print "No contig in reference called "+contigName
      continue
      
  contigSeqLen = len(contigSeq)
  
  startPos = pos-flankLen
  if startPos < 0:
      print contigName+": Setting out of bounds left flank end position to 0"
      startPos = 0
      
  endPos = pos+flankLen
  if endPos > contigSeqLen:
      print contigName+": Setting out of bounds right flank end position to "+str(contigSeqLen)
      endPos = contigSeqLen
      
#  print "startPos "+str(startPos)+" endPos "+str(endPos)
#  print "contigName="+contigName
  refBase = contigSeq[pos-1] # Get Reference allel
#  print "refBase="+refBase
#  print "iub="+iub
  
  comps = iub.split("/")
  if( len(comps) != 2 ):
    print "Corrupted sequence string "+iub+": not in formay X/Y"
    continue
  
  ins = False
  dele = False 
  if( len(comps[0]) > len(comps[1]) ):
    dele = True
 #   print "comp0="+comps[0][0]
  elif( len(comps[1]) > len(comps[0]) ):
    ins = True
   
#  print "i="+str(ins)+" d="+str(dele)
  
  leftFlankOffset = 0
  rightFlankOffset = 0
  
  if dele:
    snpType = comps[0][0]+"["+comps[0][1:len(comps[0])]+"]"
    rightFlankOffset = len(comps[0][1:len(comps[0])])
    snpType = "["+comps[0][1:len(comps[0])]+"]"
 # elif ins:
 #   snpType = comps[0][0]+"["+comps[1][1:len(comps[1])]+"]"
 # 
 # elif ( (iub == "R") or (iub == "A/G") or (iub == "G/A") ):
 #     snpType = "[A/G]"
 # elif ( (iub == "Y") or (iub == "C/T") or (iub == "T/C") ):
 #     snpType = "[C/T]"
 # elif ( (iub == "K") or (iub == "G/T") or (iub == "T/G") ):
 #     snpType = "[G/T]"
 # elif ( (iub == "M") or (iub == "A/C") or (iub == "C/A") ):
 #     snpType = "[A/C]"
 # elif ( (iub == "S") or (iub == "G/C") or (iub == "C/G") ):
 #     snpType = "[G/C]"
 # elif ( (iub == "W") or (iub == "A/T") or (iub == "T/A") ):
 #     snpType = "[A/T]"
 # elif (iub=="A" or iub=="C" or iub=="G" or iub=="T"):
 #     snpType = "["+refBase+"/"+iub+"]"
 # else:
 #     snpType = "[!]"
 # 
 # print "iub="+iub+"  snpType="+snpType
  
  leftFlank = str( contigSeq[startPos-1:pos-1].upper() )
  rightFlank = str( contigSeq[pos+rightFlankOffset:endPos+rightFlankOffset].upper() )
  #ofile.write( contigName+"."+str(snpNumber).zfill(7)"\n" )
  #ofile.write( contigName+"."+str(pos).zfill(7)+"\t" ) # padded position number
  ofile.write( contigName+"\t"+str(pos)+"\t" )
  #ofile.write( leftFlank+snpType+rightFlank+"\n" )
  ofile.write( leftFlank+'['+iub+']'+rightFlank+"\n" )
  
  snpNumber = snpNumber + 1
  
ofile.close()
sys.exit(2)


