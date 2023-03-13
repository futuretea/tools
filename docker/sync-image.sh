
#!/bin/bash

normalize_image()
{
  echo $1 | awk -F '/' '{if(NF>=3){print $0} else if(NF==2){print "docker.io/"$0}else if(NF==1){print "docker.io/library/"$0}}'
}

image=$(normalize_image ${2})
localhost=$1
docker run --rm smqasims/imagesync:v1.1.0 -s "${image}" -d $(echo "${image}" | awk -F "/" '{OFS="/"}$1="'"$localhost"'"')
