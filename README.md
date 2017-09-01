# tdrdiff

Create an handy pdf diff for TDR repository based on different svn revisions.

Original instructions provided by Ferenc Sikler.

Similar implementation available here https://twiki.cern.ch/twiki/bin/view/Main/TdrDiffInstr

# EXAMPLE of USAGE:
cd tdr2/notes-or-papers/CADI-YY-XXX/trunk

wget -O master.zip https://github.com/perrozzi/tdrdiff/archive/master.zip

unzip -p master.zip tdrdiff-master/make_diff.sh > make_diff.sh

rm master.zip

chmod +x make_diff.sh

sh make_diff.sh CADI-YY-XXX.tex 422219 432319
