#!/bin/bash

# EXAMPLE USAGE:
# sh make_diff.sh HIG-16-044.tex 422219 HEAD

# detect any uncommited modification
if [[ -n $(svn status -q . | awk '$1 ~ /[!?ABCDGKLMORST]/') ]]; then
    echo "The working copy at $(pwd) appears to have local modifications, commit before to run!"
    exit 1
fi

# detect whether it's a note or a paper from the working path
note_papers=`echo $PWD | rev | cut -d'/' -f 3 | rev`

# dummy deletion of pre-existing symbolic links that could be present
rm  auto_generated.bst BigDraft.pdf cms_draft_paper.pdf cms-tdr.cls pdfdraftcopy.sty pennames-pazo.sty ptdr-definitions.sty changepage.sty

# defined target tex file and svn revisions to compare
texfile="$1"
svnold="$2"
svnnew="$3"
# strip the tex file extension
texfile="${texfile//.tex/}"

echo "Building diff between svn revision ${svnold} and ${svnnew} for ${note_papers} CADI entry ${texfile}"

# update the repository to the "old" svn revision and compile the corresponding "old" pdf
svn up -r ${svnold}
cp ${texfile}.tex old.tex
../../tdr --draft --copyPdf=old.pdf --style=paper b old
cp ../../../${note_papers}/tmp/old_temp.tex .
cp ../../../${note_papers}/tmp/old_temp.bbl old_temp.bbl

# update the repository to the "new" svn revision and compile the corresponding "new" pdf
svn up -r ${svnnew}
cp ${texfile}.tex new.tex
../../tdr --draft --copyPdf=new.pdf --style=paper b new
cp ../../../${note_papers}/tmp/new_temp.tex .
cp ../../../${note_papers}/tmp/new_temp.bbl new_temp.bbl

# copy auto_generated.bib to a temporary file
mv auto_generated.bib auto_generated.bib.bkp
# make symbolic links
ln -s ../../../${note_papers}/tmp/auto_generated.bib .
ln -s ../../../${note_papers}/tmp/auto_generated.bst .
ln -s ../../../utils/trunk/general/BigDraft.pdf .
ln -s ../../../utils/trunk/general/cms_draft_paper.pdf .
ln -s ../../../utils/trunk/general/cms-tdr.cls
ln -s ../../../utils/trunk/general/pdfdraftcopy.sty
ln -s ../../../utils/trunk/general/pennames-pazo.sty .
ln -s ../../../utils/trunk/general/ptdr-definitions.sty .
ln -s ../../../utils/trunk/general/changepage.sty .

# download missing packages to ensure flawless pdflatex compilation
wget -r -nH --cut-dirs=7 -nc ftp://ftp.tug.org/texlive/Contents/live/texmf-dist/tex/latex/adjustbox/
wget -r -nH --cut-dirs=7 -nc ftp://ftp.tug.org/texlive/Contents/live/texmf-dist/tex/latex/collectbox/

# download the standalone version of latexdiff
wget -O latexdiff-so http://mirror.switch.ch/ftp/mirror/tex/support/latexdiff/latexdiff-so
chmod +x latexdiff-so
# create the diff of "new" vs "old" for the main tex
./latexdiff-so --append-context2cmd="abstract" --exclude-textcmd="section,subsection,includegraphics" --math-markup=0 old_temp.tex new_temp.tex > diff_${texfile}_${svnold}_${svnnew}.tex
# create the diff of "new" vs "old" for the bibliography
./latexdiff-so old_temp.bbl new_temp.bbl > diff_${texfile}_${svnold}_${svnnew}.bbl

# compile the diff 3 times to ensure proper bibliography links
# use "yes" command syntax to allow pdflated to proceed on errors requiring simple "return"
yes "" | pdflatex  diff_${texfile}_${svnold}_${svnnew}.tex 
yes "" | pdflatex  diff_${texfile}_${svnold}_${svnnew}.tex 
yes "" | pdflatex  diff_${texfile}_${svnold}_${svnnew}.tex 

# restore original auto_generated.bib
mv auto_generated.bib.bkp auto_generated.bib
# cleanup: remove unused files and symbolic links
rm diff_${texfile}_${svnold}_${svnnew}.aux diff_${texfile}_${svnold}_${svnnew}.out diff_${texfile}_${svnold}_${svnnew}.tex diff_${texfile}_${svnold}_${svnnew}.bbl diff_${texfile}_${svnold}_${svnnew}.blg
rm auto_generated.bst BigDraft.pdf cms_draft_paper.pdf cms-tdr.cls pdfdraftcopy.sty pennames-pazo.sty ptdr-definitions.sty changepage.sty
rm old.tex old_temp.tex old_temp.bbl new.tex new_temp.tex new_temp.bbl old_auto.pdf new_auto.pdf
rm -f trimclip.sty tc-xetex.def tc-pgf.def tc-pdftex.def tc-dvips.def collectbox.sty adjustbox.sty adjcalc.sty latexdiff-so
