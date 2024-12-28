#!/bin/bash

POSTS_XML="Posts.xml"
COMMENTS_XML="Comments.xml"
TAGS_XML="Tags.xml"
QUESTION_TAGS_XML="Question_tags.xml"

QUESTIONS_CSV="questions.csv"
ANSWERS_CSV="answers.csv"
COMMENTS_CSV="comments.csv"
TAGS_CSV="tags.csv"
QUESTION_TAGS_CSV="question_tags.csv"
QUESTIONS_IDS_TAGS_CSV="questions_ids_tags.csv"

DATABASE_FILE="db.sql"
QUESTIONS_TABLE="questions"
ANSWERS_TABLE="answers"
COMMENTS_TABLE="comments"
TAGS_TABLE="tags"
QUESTION_TAGS_TABLE="question_tags"

echo "Create questions csv starting"
echo "Remove old csv (1/2)"
rm -rf  $QUESTIONS_CSV
echo "Grep xml (2/3)"
cat $POSTS_XML | grep "PostTypeId=\"1\"" > $QUESTIONS_CSV
echo "Create csv (3/3)"
sed -i -e 's/^  //g' \
       -e 's/<row Id="//g'  \
       -e 's/" PostTypeId="1"//g'  \
       -e 's/ AcceptedAnswerId="[^"]*"//g'  \
       -e 's/ CreationDate="/,/g'  \
       -e 's/" Score="/,/g'  \
       -e 's/" ViewCount="/,/g'  \
       -e 's/" Body=/,/g'  \
       -e 's/ OwnerUserId="[^"]*"//g'  \
       -e 's/ OwnerDisplayName="[^"]*"//g'  \
       -e 's/ LastEditorUserId="[^"]*"//g'  \
       -e 's/ LastEditorDisplayName="[^"]*"//g'  \
       -e 's/ LastEditDate="[^"]*"//g'  \
       -e 's/ LastActivityDate="[^"]*"//g'  \
       -e 's/ Title=/,/g'  \
       -e 's/ Tags="[^"]*"//g'  \
       -e 's/ AnswerCount="/,/g'  \
       -e 's/" CommentCount="/,/g'  \
       -e 's/ FavoriteCount="[^"]*"//g'  \
       -e 's/ CloDate="[^"]*"//g'  \
       -e 's/ CommunityOwnedDate="[^"]*"//g'  \
       -e 's/ ContentLicense="[^"]*"//g'  \
       -e 's/\r//g'  \
       -e 's/" \/>$//g' $QUESTIONS_CSV
echo "Completed!"
echo " "

echo "Create answers csv starting"
echo "Remove old csv (1/3)"
rm -rf  $ANSWERS_CSV
echo "Grep xml (2/3)"
cat $POSTS_XML | grep "PostTypeId=\"2\"" > $ANSWERS_CSV
echo "Create csv (3/3)"
sed -i -e 's/^  //g'  \
       -e 's/<row Id="//g'  \
       -e 's/" PostTypeId="2"//g'  \
       -e 's/ ParentId="/,/g'  \
       -e 's/" CreationDate="/,/g'  \
       -e 's/" Score="/,/g'  \
       -e 's/" Body=/,/g'  \
       -e 's/ OwnerUserId="[^"]*"//g'  \
       -e 's/ OwnerDisplayName="[^"]*"//g'  \
       -e 's/ LastEditorUserId="[^"]*"//g'  \
       -e 's/ LastEditorDisplayName="[^"]*"//g'  \
       -e 's/ LastEditDate="[^"]*"//g'  \
       -e 's/ LastActivityDate="[^"]*"//g'  \
       -e 's/ CommentCount="/,/g'  \
       -e 's/ CommunityOwnedDate="[^"]*"//g'  \
       -e 's/ ContentLicense="[^"]*"//g'  \
       -e 's/\r//g'  \
       -e 's/" \/>$//g' $ANSWERS_CSV
echo "Completed!"
echo " "

echo "Create comments csv starting"
echo "Remove oldcsv (1/3)"
rm -rf  $COMMENTS_CSV
echo "Grep xml (2/3)"
cat $COMMENTS_XML | grep "Text=\"" > $COMMENTS_CSV
echo "Create csv (3/3)"
sed -i -e 's/^  //g'  \
       -e 's/<row Id="//g'  \
       -e 's/" PostId="/,/g'  \
       -e 's/" Score="/,/g'  \
       -e 's/" Text=/,/g'  \
       -e 's/ CreationDate="/,/g'  \
       -e 's/" UserDisplayName="[^"]*"//g'  \
       -e 's/" UserId="[^"]*"//g'  \
       -e 's/\r//g'  \
       -e 's/ \/>$//g' $COMMENTS_CSV
echo "Completed!"
echo " "

echo "Create tags csv starting"
echo "Remove old csv (1/3)"
rm -rf $TAGS_CSV
echo "Grep xml (2/3)"
cat $TAGS_XML | grep "TagName=\"" > $TAGS_CSV
echo "Create csv (3/3)"
sed -i -e 's/^  //g'  \
       -e 's/<row Id="//g'  \
       -e 's/" TagName=/,/g'  \
       -e 's/ Count="[^"]*"//g'  \
       -e 's/ ExcerptPostId="[^"]*"//g'  \
       -e 's/ WikiPostId="[^"]*"//g'  \
       -e 's/\r//g'  \
       -e 's/ \/>$//g' $TAGS_CSV
echo "Completed!"
echo " "

echo "Create question tags csv starting"
echo "Remove old csv and xml (1/6)"
rm -rf $QUESTION_TAGS_CSV $QUESTIONS_IDS_TAGS_CSV $QUESTION_TAGS_XML
echo "Grep xml (2/6)"
cat $POSTS_XML | grep "Tags=\"" > $QUESTION_TAGS_XML
echo "Clear xml (3/6)"
sed -i 's/PostTypeId=".* Tags="*//g' $QUESTION_TAGS_XML
echo "Get columns (4/5)"
cut -d "\"" -f2,3 $QUESTION_TAGS_XML > $QUESTIONS_IDS_TAGS_CSV
echo "Create ids, tags csv; (5/6)"
sed -i -e 's/" /,/g' \
       -e 's/|/ /g' \
       -e 's/, /:"/g' \
       -e 's/ $/"/g' $QUESTIONS_IDS_TAGS_CSV
echo "Create csv (6/6)"
declare -A TAG_MAP
while IFS=',' read -r TAG_ID TAG_NAME; do
    TAG_NAME=${TAG_NAME//\"/}
    TAG_MAP["$TAG_NAME"]="$TAG_ID"
done < $TAGS_CSV
> $QUESTION_TAGS_CSV
while IFS=':' read -r QUESTION_ID TAGS; do
    TAGS=${TAGS//\"/}
    for TAG_NAME in $TAGS; do
        TAG_ID=${TAG_MAP["$TAG_NAME"]}
        if [[ -n "$TAG_ID" ]]; then
            echo "$QUESTION_ID,$TAG_ID" >> $QUESTION_TAGS_CSV
        fi
    done
done < $QUESTIONS_IDS_TAGS_CSV
echo "Completed!"
echo " "

echo "Create database starting"
echo "Remove old database file (1/3)"
rm -rf $DATABASE_FILE
echo "Create tables (2/3)"
sqlite3 $DATABASE_FILE "CREATE TABLE $QUESTIONS_TABLE (id INTEGER PRIMARY KEY, creation_date TEXT, views, score TEXT, body TEXT, title TEXT, answers INTEGER, comments INTEGER);"
sqlite3 $DATABASE_FILE "CREATE TABLE $ANSWERS_TABLE (id INTEGER PRIMARY KEY, question_id INTEGER, creation_date TEXT, score TEXT, body TEXT, comments INTEGER);"
sqlite3 $DATABASE_FILE "CREATE TABLE $COMMENTS_TABLE (id INTEGER PRIMARY KEY, post_id INTEGER, score TEXT, text TEXT, creation_date TEXT);"
sqlite3 $DATABASE_FILE "CREATE TABLE $TAGS_TABLE (id INTEGER PRIMARY KEY, name TEXT);"
sqlite3 $DATABASE_FILE "CREATE TABLE $QUESTION_TAGS_TABLE (question_id INTEGER, tag_id INTEGER);"
echo "Import csv (3/3)"
echo -e ".separator ","\n.import ./"$QUESTIONS_CSV" "$QUESTIONS_TABLE | sqlite3 $DATABASE_FILE
echo -e ".separator ","\n.import ./"$ANSWERS_CSV" "$ANSWERS_TABLE | sqlite3 $DATABASE_FILE
echo -e ".separator ","\n.import ./"$COMMENTS_CSV" "$COMMENTS_TABLE | sqlite3 $DATABASE_FILE
echo -e ".separator ","\n.import ./"$TAGS_CSV" "$TAGS_TABLE | sqlite3 $DATABASE_FILE
echo -e ".separator ","\n.import ./"$QUESTION_TAGS_CSV" "$QUESTION_TAGS_TABLE | sqlite3 $DATABASE_FILE
echo "Completed!"
echo " "

echo "Remove csv files (1/1)"
rm -rf $QUESTIONS_CSV $ANSWERS_CSV $COMMENTS_CSV $TAGS_CSV $QESTION_TAGS_CSV $QESTIONS_IDS_TAGS_CSV
