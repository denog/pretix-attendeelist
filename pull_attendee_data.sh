#!/bin/bash

#######
# This script retrieves attendee data from the pretix API and saves it to a JSON file.
#
# It removes all order secrets, and includes answers to selected questions.
# This script is currently used to render the attendee list of DENOG12, but
# can be easily adapted to your event. It is run using GitHub Workflows.
#
# To run this script, please provide the following variables:
# - api_token: the pretix API token, as per https://docs.pretix.eu/en/latest/api/auth.html
#             Create a team that has only read access to the orders of your event.
# - checkin_list is the ID of the checkin list to be used for this attendee list.
# - instance, organizer and event identify your pretix event
####

api_token="$PRETIX_API_TOKEN"
checkin_list="$PRETIX_CHECKIN_LIST_ID"
instance="pretix.eu"
organizer="denog"
event="denogmeetup21-01"
url="https://$instance/api/v1/organizers/$organizer/events/$event/checkinlists/$checkin_list/positions/"

tempfile="response.temp"
datafile="attendees.full"

rm $datafile

while [[ $url != "null" ]]; do
    curl -H "Authorization: Token ${api_token}" "${url}" > ${tempfile}
    url=$(jq -r .next ${tempfile})
    jq . ${tempfile} >> $datafile
done

rm $tempfile

jq -s 'map(.results[]) | map({
    name: .attendee_name,
    company: ((.answers[] | select(.question_identifier=="COMPANY").answer)//null),
    irc: ((.answers[] | select(.question_identifier=="IRC").answer)//null),
    asn: ((.answers[] | select(.question_identifier=="ASN").answer)//null),
})' "$datafile" > _data/attendees_meetup2021-01.json

rm $datafile
