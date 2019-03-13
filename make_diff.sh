#!/bin/bash

# check the number of arguments
if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters. Example of usage:"
    echo "sh make_diff.sh HIG-16-044.tex 422219 422423"
    echo "sh make_diff.sh HIG-16-044.tex 422219 HEAD"
    echo "sh make_diff.sh HIG-16-044.tex v1 v2 (only possible for papers, not notes/PAS)"
    exit 1
fi

# detect any uncommited modification
if [[ -n $(svn status -q . | awk '$1 ~ /[!?ABCDGKLMORST]/') ]]; then
    echo "The working copy at $(pwd) appears to have local modifications, commit before to run!"
    exit 1
fi


# detect whether it's a note or a paper from the working path
note_papers=`echo $PWD | rev | cut -d'/' -f 3 | rev`

echo 'note_papers = '$note_papers
# read -p "Press any key to continue... " -n1 -s

# dummy deletion of pre-existing symbolic links that could be present
rm  auto_generated.bst BigDraft.pdf cms_draft_paper.pdf cms-tdr.cls pdfdraftcopy.sty pennames-pazo.sty ptdr-definitions.sty changepage.sty

# read -p "Press any key to continue... " -n1 -s

# defined target tex file and svn revisions to compare
texfile="$1"
# strip the tex file extension
texfile="${texfile//.tex/}"

echo 'texfile = '$texfile
# read -p "Press any key to continue... " -n1 -s

svnold="$2"
svnnew="$3"

# if needed, convert HEAD to the actual commit
if [ $svnnew = "HEAD" ]; then
    svnnew=`svn up -r HEAD | awk '{ print $3 }'`
    svnnew="${svnnew%?}"
fi

echo 'svnold = '$svnold
echo 'svnnew = '$svnnew


# if paper versions are passed as arguments instead of svn revisions, 
# download the files and retrieve the corresponding svn revisions
# currently only possible for papers
for arg in svnnew svnold; do
    eval svnver=\$$arg
    if [[ $svnver == *"v"* ]]; then
      if ! [[ $note_papers == "papers" ]]; then
          echo "passing a version instead of svn revision only possible for papers, not for notes/PAS"
          exit 1
      fi
      cern-get-sso-cookie -u https://icms-dev.cern.ch/tools/api/getCadiPaperPDF -o ~/private/sso-cookie --reprocess
      curl -L -k --cookie ~/private/sso-cookie --cookie-jar ~/private/sso-cookie https://icms-dev.cern.ch/tools/api/getCadiPaperPDF?cadiFileName=${texfile}-paper-${svnver}.pdf -o ${texfile}-${svnver}.pdf && file ${texfile}-${svnver}.pdf
      pdftotext -f 1 ${texfile}-${svnver}.pdf
      svnver1=`grep Head\ Id ${texfile}-${svnver}.txt -a1 | tail -n1`
      eval $arg=\$svnver1
      rm ${texfile}-${svnver}.pdf ${texfile}-${svnver}.txt
    fi
done


echo "Building diff between svn revision ${svnold} and ${svnnew} for ${note_papers} CADI entry ${texfile}"


if [[ $note_papers == "papers" ]]; then
    note_papers="utils/trunk"
fi

echo "note_papers= " $note_papers


# download and compile the "flattener" to parse all \input{file} in the main file
# wget -O flatex.c http://mirrors.ctan.org/support/flatex/flatex.c
cc flatex.c -o flatex


# update the repository to the "old" svn revision and compile the corresponding "old" pdf
svn up -r ${svnold}
cp ${texfile}.tex ${texfile}.tex.bkp
./flatex ${texfile}.tex > /dev/null
sed -i -- 's/\%FLATEX\-REM\://g' ${texfile}.flt
mv ${texfile}.flt ${texfile}.tex
cp ${texfile}.tex old.tex
../../../utils/trunk/tdr --draft --copyPdf=old.pdf --style=paper b old
cp ../../../${note_papers}/tmp/old_temp.tex .
cp ../../../${note_papers}/tmp/old_temp.bbl old_temp.bbl
mv ${texfile}.tex.bkp ${texfile}.tex

# update the repository to the "new" svn revision and compile the corresponding "new" pdf
svn up -r ${svnnew}
cp ${texfile}.tex ${texfile}.tex.bkp
./flatex ${texfile}.tex > /dev/null
sed -i -- 's/\%FLATEX\-REM\://g' ${texfile}.flt
mv ${texfile}.flt ${texfile}.tex
cp ${texfile}.tex new.tex
../../../utils/trunk/tdr --draft --copyPdf=new.pdf --style=paper b new
cp ../../../${note_papers}/tmp/new_temp.tex .
cp ../../../${note_papers}/tmp/new_temp.bbl new_temp.bbl
mv ${texfile}.tex.bkp ${texfile}.tex


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
# wget -r -nH --cut-dirs=7 -nc ftp://ftp.tug.org/texlive/Contents/live/texmf-dist/tex/latex/adjustbox/
# wget -r -nH --cut-dirs=7 -nc ftp://ftp.tug.org/texlive/Contents/live/texmf-dist/tex/latex/collectbox/

# download the standalone version of latexdiff
# wget -O latexdiff-so https://mirror.hmc.edu/ctan/support/latexdiff/latexdiff-so
chmod +x latexdiff-so
# create the diff of "new" vs "old" for the main tex
./latexdiff-so --append-context2cmd="abstract" --exclude-textcmd="section,subsection,includegraphics" --math-markup=0 old_temp.tex new_temp.tex > diff_${texfile}_${svnold}_${svnnew}.tex
# create the diff of "new" vs "old" for the bibliography
./latexdiff-so old_temp.bbl new_temp.bbl > diff_${texfile}_${svnold}_${svnnew}.bbl

ls -lrt diff_${texfile}_${svnold}_${svnnew}.bbl diff_${texfile}_${svnold}_${svnnew}.tex
echo ""
echo "READ BEFORE TO CONTINUE!!!"
echo ""
echo "The program is now going to compile the files above: " diff_${texfile}_${svnold}_${svnnew}.bbl diff_${texfile}_${svnold}_${svnnew}.tex
echo "If they have null size, a problem occurred and debug in the make_diff.sh is needed."
echo "Even if the sizes are not null, it could be that an infinite loop will be triggered, due to LaTeX bugs in the old or new file version."
echo "In this latter case, a manual editing of the tex and bbl files is needed to remove such a problem, then a recompilation will produce the awaited pdf."
echo "Good luck!"
echo ""
read -p "Press any key to continue..." -n1 -s; echo ""

# compile the diff 3 times to ensure proper bibliography links
# use "yes" command syntax to allow pdflated to proceed on errors requiring simple "return"
yes "" | pdflatex  diff_${texfile}_${svnold}_${svnnew}.tex 
yes "" | pdflatex  diff_${texfile}_${svnold}_${svnnew}.tex 
yes "" | pdflatex  diff_${texfile}_${svnold}_${svnnew}.tex 

# restore original auto_generated.bib
rm auto_generated.bib
mv auto_generated.bib.bkp auto_generated.bib
# mv ${texfile}.tex.bkp ${texfile}.tex
# cleanup: remove unused files and symbolic links
rm diff_${texfile}_${svnold}_${svnnew}.aux diff_${texfile}_${svnold}_${svnnew}.out diff_${texfile}_${svnold}_${svnnew}.bbl diff_${texfile}_${svnold}_${svnnew}.blg
# rm diff_${texfile}_${svnold}_${svnnew}.tex 
rm auto_generated.bst BigDraft.pdf cms_draft_paper.pdf cms-tdr.cls pdfdraftcopy.sty pennames-pazo.sty ptdr-definitions.sty changepage.sty
rm old.tex old_temp.tex old_temp.bbl new.tex new_temp.tex new_temp.bbl old_auto.pdf new_auto.pdf
rm -f trimclip.sty tc-xetex.def tc-pgf.def tc-pdftex.def tc-dvips.def collectbox.sty adjustbox.sty adjcalc.sty latexdiff-so flatex

svn up -r HEAD
