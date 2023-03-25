
#!/bin/bash

normalize_image()
{
  echo $1 | awk -F '/' '{if(NF>=3){print $0} else if(NF==2){print "docker.io/"$0}else if(NF==1){print "docker.io/library/"$0}}'
}

cat $2 | while read -r img; do
image=$(normalize_image ${img})
localhost=$1
docker run --rm smqasims/imagesync:v1.2.0 -s "${image}" -d $(echo "${image}" | awk -F "/" '{OFS="/"}$1="'"$localhost"'"')
done
