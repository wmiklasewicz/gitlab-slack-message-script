#!/bin/bash

# variables
   ciJobId=$1
   gitLabToken=$2
   token=$3
   ciJobUrl="$4"
   ciProjectName="$5"
   ciProjectUrl="$6"
   slicon=point_right
   pipelineStatus=$(curl -X GET -H "PRIVATE-TOKEN: $gitLabToken" "https://gitlab.com/api/v4/projects/{project_id}/jobs/${ciJobId}" | jq '.status' | sed -e 's/^"//' -e 's/"$//')
   string="success"

   dateTime=$(date '+%d/%m/%Y')

     if [[ $pipelineStatus == $string ]]; then
         statusIcon=heavy_check_mark
     else
         statusIcon=x
     fi

slackmessage() {
   echo "### Sending Slack notification to channel..."
   echo $pipelineStatus
   curl -XPOST -H "Content-type: application/json" -d "{
   \"channel\": \"deployments\",
    \"blocks\": [
        {
            \"type\": \"section\",
            \"text\": {
                \"type\": \"mrkdwn\",
                \"text\": \"*Build info* \n Tests executed from: <${ciProjectUrl}|${ciProjectName}> \n Pipeline url: <${ciJobUrl}|Click here to see more job details>\"
            },
            	\"accessory\": {
				\"type\": \"image\",
				\"image_url\": \"https://i.ibb.co/PzdM04K/bug.png\",
				\"alt_text\": \"Allure logo image\"
			}
        },
        {
            \"type\": \"divider\"
        },
        {
            \"type\": \"section\",
            \"text\": {
                \"type\": \"mrkdwn\",
                \"text\": \"*Pipeline status*: ${pipelineStatus} :${statusIcon}:\"
            }
        },
		{
            \"type\": \"section\",
            \"text\": {
                \"type\": \"mrkdwn\",
                \"text\": \"*Test report*\"
            }
        },
        {
			\"type\": \"section\",
			\"text\": {
				\"type\": \"mrkdwn\",
				\"text\": \"No bugs allowed on this environment, click for more details :${slicon}:\"
			},
			\"accessory\": {
				\"type\": \"button\",
                \"url\":\"[link_to_the_report]",
				\"text\": {
					\"type\": \"plain_text\",
					\"text\": \"Test Report\"
				},
				\"value\": \"click_me_123\"
			}
		},
        {
			\"type\": \"context\",
			\"elements\": [
				{
					\"type\": \"mrkdwn\",
					\"text\": \"Last updated: ${dateTime}\"
				}
			]
		}
    ]
}" "https://hooks.slack.com/services/${token}"
}
#invoke function

slackmessage ${ciJobId} ${gitLabToken} ${token} ${ciJobUrl} ${ciProjectName} ${ciProjectUrl}
