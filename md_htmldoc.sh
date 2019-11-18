#!/usr/bin/env bash
set -e
if [ -z "$1" ]
then
  echo "No argument supplied"
  exit 1
fi

ORIG=$(pwd)
DIR="$( cd "$1" && pwd )"
SCRIPTPATH=$(dirname "$(readlink -f "$0")")
PANDOC_OPTIONS="--filter ${SCRIPTPATH}/link_filter.py --standalone --mathjax --css=/home/joshuab/pandoc.css --to=html5 --smart"

cd $DIR

# make way for html
HTML_DIR=$(basename $(dirname $DIR))_htmldoc
rm --interactive=once -rf ${HTML_DIR}
mkdir -p ${HTML_DIR}

# mimic parent repo's directory structure in ../$HTML_DIR
PARENT_REPO_CACHED_FILES=$( git ls-files)

echo copying directory structure...
for i in ${PARENT_REPO_CACHED_FILES[@]} ; do

    FROM="$(dirname $i)"
    TO="$HTML_DIR/$(dirname $i)"
    printf "    %35s" "$FROM"
    printf "  --mkdir-->"
    printf "    %35s\n" "$TO"
    mkdir -p "$TO"
done

# discover docs in parent repo
PARENT_REPO_DOCUMENTATION=$(find . | egrep '\.(md|tex)$' | egrep -v '\./md_htmldoc')
DOC_RELEVANT=$(python $SCRIPTPATH/get_references.py $PARENT_REPO_DOCUMENTATION)

echo docs...
echo "${DOC_RELEVANT}"

# for each documentation-relevant file
echo extracting docs...
for i in ${DOC_RELEVANT[@]} ; do

    FROM=$i
    TO=${HTML_DIR}/${i}

    if [[ $i == *.md ]] ; then
        # generate html, replaicng .md links with .html links
        printf "    %35s" $FROM
        printf " --pandoc--> "
        printf "%-35s\n" ${TO/\.md/.html}
        pandoc ${PANDOC_OPTIONS} $FROM -o ${TO/\.md/.html}
	elif [[ $i == *.tex ]] ; then
        printf "    %35s" $FROM
        printf " --pandoc--> "
        printf "%-35s\n" ${TO/\.tex/.html}
        pandoc ${PANDOC_OPTIONS} -f latex $FROM -o ${TO/\.tex/.html}
    else
        # copy hyperlinked files
        printf "    %35s" $FROM
        printf " ----cp----> "
        printf "%-35s\n" $TO
        cp $FROM $TO
    fi
done


# clean up any empty directories we may have created
find $HTML_DIR -type d -empty -delete

cd $ORIG
