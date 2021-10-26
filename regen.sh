#!/bin/sh

# This script generates a manifest file for a ComputerCraft
# computer to read, so it knows what to download.

if [ -z "$MANIFEST" ] ; then
    MANIFEST=manifest
fi

if [ -n "$(git status --porcelain)" ] ; then
    if [ -z "$ALLOW_DIRTY" ] ; then
        echo "Working tree dirty. Exiting."
        exit 1
    fi
fi

# List of path patterns we want to include.
INCLUDE_PATHS=""
TMP_INCLUDE_PATHS="$(mktemp)"

cat - <<EOF >> "$TMP_INCLUDE_PATHS"
./etc/*
./bin/*
EOF

FIRST="1"
while read line ; do
    if [ -n "$FIRST" ] ; then
        INCLUDE_PATHS="-path '$line'"
    else
        INCLUDE_PATHS="$IGNORE_FLAGS -or -path '$line'"
    fi
done < "$TMP_INCLUDE_PATHS"
rm "$TMP_INCLUDE_PATHS"


IGNORE_PATHS=""
while read line ; do
    IGNORE_PATHS="$IGNORE_PATHS -not -path '$line'"
done < .gitignore

CMD="find . -type f $INCLUDE_PATHS $IGNORE_PATHS -exec sha1sum {} \;"
CMD_TMP="$(mktemp)"
eval $CMD > "$CMD_TMP"

echo "{" > "$MANIFEST"

# We include this in the manifest so we can, in theory, obtain a manifest file by whatever means,
# and use it to get a perfect copy of the repository as it was when the file hashes it lists were correct.
COMMIT="$(git rev-parse HEAD)"
echo "   \"COMMIT\": \"$COMMIT\"" >> "$MANIFEST"

# The `HTTP_ROOT` key is allowed to be any HTTP server that can serve the files in the repository
# per `/$COMMIT/path/from/root/of/repository`
echo "   ,\"HTTP_ROOT\": \"https://raw.githubusercontent.com/Monadic-Cat/mc-cc/\"" >> "$MANIFEST"

echo "   ,\"files\": [" >> "$MANIFEST"
SEP=""
while read line ; do
    FIRST=""
    SECOND=""
    for word in $line ; do
        if [ -z "$FIRST" ] ; then
            FIRST="$word"
        elif [ -z "$SECOND" ] ; then
            SECOND="$word"
        else
            echo "wtf sha1sum said more than 2 words for a line"
            echo "Line: $line"
            exit 1
        fi
    done
    echo "      $SEP{\"name\": \"$SECOND\", \"hash\": \"$FIRST\" }" >> "$MANIFEST"
    SEP=","
done < "$CMD_TMP"
echo "   ]" >> "$MANIFEST"

echo "}" >> "$MANIFEST"

rm "$CMD_TMP"
