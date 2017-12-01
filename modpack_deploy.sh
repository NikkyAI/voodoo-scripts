#!/bin/bash
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
upload_folder=$DIR/.upload/modpacks

source $DIR/scripts/server_upload.sh

cd $DIR/modpacks
modpacks=$MODPACKS
#modpacks=( fuckitbrokeagain cpack )

cd $DIR
mkdir --parent $upload_folder
[ ! -f $DIR/tools/launcher-builder.jar ] && ./deploy_launcher.sh
for modpack in "${modpacks[@]}"; do
    version=${modpack}_`date +%Y.%m.%d.%H%M%S`
    java -jar $DIR/tools/launcher-builder.jar \
        --version $version \
        --input $DIR/modpacks/$modpack \
        --output $upload_folder \
        --manifest-dest $upload_folder/$modpack.json
        
    retval=$?
    if [ $retval -ne 0 ]; then
        echo "launcher builder failed with error code $retval" 1>&2
        exit $retval
    fi

    mkdir $upload_folder/$modpack

    $DIR/scripts/filetree.py \
        --out $upload_folder/$modpack/index.html \
        --pack $modpack \
        --url $URLBASE

    echo -e "$version" > $upload_folder/$modpack/version.txt
    echo $upload_folder/$modpack/version.txt
    cat $upload_folder/$modpack/version.txt
done

#TODO: generate packages.json
python script/packages.py --dir $DIR/.upload/modpacks $modpacks
#cd $DIR

#echo "\`\`\`" > $upload_folder/_h5ai.footer.md
#tree modpacks \
#    -P "*.jar|*.cfg|*.yml" \
#    -I .upload \
#    >> $upload_folder/_h5ai.header.md
#echo "\`\`\`" >> $upload_folder/_h5ai.footer.md

$DIR/upload.sh