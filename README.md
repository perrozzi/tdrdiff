# tdrdiff

Create a handy pdf diff for TDR repository based on different svn revisions.

Original instructions provided by Ferenc Sikler.

Similar implementation available here https://twiki.cern.ch/twiki/bin/view/Main/TdrDiffInstr

# EXAMPLE of USAGE:

\# The script requires that all the local modifications are pushed to SVN before to run, otherwise will not run.

\# Please commit before to use!

cd tdr2/notes-or-papers/CADI-YY-XXX/trunk

wget -O master.zip https://github.com/perrozzi/tdrdiff/archive/master.zip

unzip -p master.zip tdrdiff-master/make_diff.sh > make_diff.sh

rm master.zip

chmod +x make_diff.sh

\# to retrieve the desired svn revisions you can look at the "Head Id: XXXXXX" in the first page (top right) of a note/paper. 
\# HEAD will be interpreted as the latest svn revision available

sh make_diff.sh CADI-YY-XXX.tex 422219 432319

# EXAMPLE of OUTPUT:
https://twiki.cern.ch/twiki/pub/CMS/HIG16044/diff_HIG-16-044_paper_v5_v6.pdf
