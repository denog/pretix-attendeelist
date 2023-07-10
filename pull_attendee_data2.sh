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

event="denog15"

api_token="$PRETIX_API_TOKEN"
checkin_list_onsite="$PRETIX_CHECKIN_LIST_ID_ONSITE"
checkin_list_online="$PRETIX_CHECKIN_LIST_ID_ONLINE"

instance="pretix.eu"
organizer="denog"
output_onsite="attendees_${event}_onsite.json"
output_online="attendees_${event}_online.json"

url_onsite="https://$instance/api/v1/organizers/$organizer/events/$event/checkinlists/$checkin_list_onsite/positions/"
url_online="https://$instance/api/v1/organizers/$organizer/events/$event/checkinlists/$checkin_list_online/positions/"

tempfile="response.temp"
datafile="attendees.full"

rm -f "$tempfile"
rm -f "$datafile"

# Attendees onsite
while [[ $url_onsite != "null" ]]; do
    curl -H "Authorization: Token ${api_token}" "${url_onsite}" > ${tempfile}
    url_onsite=$(jq -r .next ${tempfile})
    jq . ${tempfile} >> $datafile
done
rm -f "$tempfile"

jq -s 'map(.results[]) | map({
    name: .attendee_name,
    company: ((.answers[] | select(.question_identifier=="COMPANY").answer)//null),
    irc: ((.answers[] | select(.question_identifier=="IRC").answer)//null),
    asn: ((.answers[] | select(.question_identifier=="ASN").answer)//null),
})' "$datafile" > "_data/$output_onsite"
rm -f "$datafile"

# Attendees online
while [[ $url_online != "null" ]]; do                                           
    curl -H "Authorization: Token ${api_token}" "${url_online}" > ${tempfile}
    url_online=$(jq -r .next ${tempfile})                                              
    jq . ${tempfile} >> $datafile                                               
done                                                                            
rm -f "$tempfile"
    
jq -s 'map(.results[]) | map({
    name: .attendee_name,                                                       
    company: ((.answers[] | select(.question_identifier=="COMPANY").answer)//null), 
    irc: ((.answers[] | select(.question_identifier=="IRC").answer)//null),     
    asn: ((.answers[] | select(.question_identifier=="ASN").answer)//null),     
})' "$datafile" > "_data/$output_online"                                        
rm -f "$datafile"

