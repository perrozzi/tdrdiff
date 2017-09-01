# tdrdiff

Create an handy pdf diff for TDR repository based on different svn revisions

# EXAMPLE of USAGE:
cd tdr2/notes-or-papers/CADI-YY-XXX/trunk

wget -O master.zip https://github.com/perrozzi/tdrdiff/archive/master.zip

unzip -p master.zip make_diff.sh > make_diff.sh

chmod +x make_diff.sh

sh make_diff.sh CADI-YY-XXX.tex 422219 432319
