# Todo

- Removing Alphabet and States from the tape & extract the data from those fields
- Change structure to read the blank char at a different position on the tape:
  - `1.+=|ABCDE|.|A|E|A.A.RA1A1RA+A+RA=B.LB1C=LB+E.LC1C1LC+D1RD1D1RD=E.R|_11+1111=`
- Using the tape as empty memory, we would use it to store the initial state:
  - `~~~~~~~~A~|.|A|E|A.A.RA1A1RA+A+RA=B.LB1C=LB+E.LC1C1LC+D1RD1D1RD=E.R|_1+1=`

Methods to implement:
 - Moving N times to the LEFT or RIGHT
 - Searching N times a spefic char to the LEFT or RIGHT
 - Execute actions and then write the current char in memory
 - Create join states
 - Create loop around actions
