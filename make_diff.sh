#!/bin/bash

# EXAMPLE USAGE:
# sh make_diff.sh HIG-16-044.tex 422219 HEAD

note_papers=`echo $PWD | rev | cut -d'/' -f 3 | rev`

rm  auto_generated.bst BigDraft.pdf cms_draft_paper.pdf cms-tdr.cls pdfdraftcopy.sty pennames-pazo.sty ptdr-definitions.sty changepage.sty

texfile="$1"
svnold="$2"
svnnew="$3"

echo "Building diff between svn revision ${svnold} and ${svnnew}"

texfile="${texfile//.tex/}"

# compile old pdf
svn up -r ${svnold}
cp ${texfile}.tex old.tex
../../tdr --draft --copyPdf=old.pdf --style=paper b old
cp ../../../${note_papers}/tmp/old_temp.tex .
cp ../../../${note_papers}/tmp/old_temp.bbl old_temp.bbl

# compile new pdf
svn up -r ${svnnew}
cp ${texfile}.tex new.tex
../../tdr --draft --copyPdf=new.pdf --style=paper b new
cp ../../../${note_papers}/tmp/new_temp.tex .
cp ../../../${note_papers}/tmp/new_temp.bbl new_temp.bbl

# make symbolic links
mv auto_generated.bib auto_generated.bib.bkp
ln -s ../../../${note_papers}/tmp/auto_generated.bib .
ln -s ../../../${note_papers}/tmp/auto_generated.bst .
ln -s ../../../utils/trunk/general/BigDraft.pdf .
ln -s ../../../utils/trunk/general/cms_draft_paper.pdf .
ln -s ../../../utils/trunk/general/cms-tdr.cls
ln -s ../../../utils/trunk/general/pdfdraftcopy.sty
ln -s ../../../utils/trunk/general/pennames-pazo.sty .
ln -s ../../../utils/trunk/general/ptdr-definitions.sty .
ln -s ../../../utils/trunk/general/changepage.sty .

# download missing packages
wget -r -nH --cut-dirs=7 -nc ftp://ftp.tug.org/texlive/Contents/live/texmf-dist/tex/latex/adjustbox/
wget -r -nH --cut-dirs=7 -nc ftp://ftp.tug.org/texlive/Contents/live/texmf-dist/tex/latex/collectbox/

# create the diff
wget -O latexdiff-so http://mirror.switch.ch/ftp/mirror/tex/support/latexdiff/latexdiff-so
chmod +x latexdiff-so
./latexdiff-so --append-context2cmd="abstract" --exclude-textcmd="section,subsection,includegraphics" --math-markup=0 old_temp.tex new_temp.tex > diff_${texfile}_${svnold}_${svnnew}.tex
./latexdiff-so old_temp.bbl new_temp.bbl > diff_${texfile}_${svnold}_${svnnew}.bbl


pdflatex  diff_${texfile}_${svnold}_${svnnew}.tex 
# bibtex    diff_${texfile}_${svnold}_${svnnew}
pdflatex  diff_${texfile}_${svnold}_${svnnew}.tex 
pdflatex  diff_${texfile}_${svnold}_${svnnew}.tex 

# remove symbolic links
rm diff_${texfile}_${svnold}_${svnnew}.aux diff_${texfile}_${svnold}_${svnnew}.out diff_${texfile}_${svnold}_${svnnew}.tex diff_${texfile}_${svnold}_${svnnew}.bbl
rm  auto_generated.bst BigDraft.pdf cms_draft_paper.pdf cms-tdr.cls pdfdraftcopy.sty pennames-pazo.sty ptdr-definitions.sty changepage.sty
mv auto_generated.bib.bkp auto_generated.bib
