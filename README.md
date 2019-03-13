# tdrdiff

Create a handy pdf diff for TDR repository based on different svn revisions. It will highlight changes on the text but not (yet) on the figures.

Original instructions provided by Ferenc Sikler.

Similar implementation available here https://twiki.cern.ch/twiki/bin/view/Main/TdrDiffInstr

# EXAMPLE of USAGE:

\# The script requires that all the local modifications are pushed to SVN before to run, otherwise will not run.

\# Please commit before to use!

cd tdr2/notes-or-papers/CADI-YY-XXX/trunk

wget -O master.zip https://github.com/perrozzi/tdrdiff/archive/master.zip

unzip master.zip
cp cp2git/* ./
rm master.zip

chmod +x make_diff.sh

\# to retrieve the desired svn revisions you can look at the "Head Id: XXXXXX" in the first page (top right) of a note/paper. 
\# HEAD will be interpreted as the latest svn revision available.
\# For papers is also possible to specify the CADI version (correspondind svn revision will be retrieved from the PDF)

sh make_diff.sh CADI-YY-XXX.tex 422219 432319

sh make_diff.sh HIG-16-044.tex 422219 HEAD

echo "sh make_diff.sh HIG-16-044.tex v1 v2    \#(only possible for papers, not notes/PAS)


# EXAMPLE of OUTPUT:
https://twiki.cern.ch/twiki/pub/CMS/HIG16044/diff_HIG-16-044_paper_v5_v6.pdf
