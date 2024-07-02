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
instance="pretix.eu"
organizer="denog"
tempfileslug="slugs.temp"
rm -f "$tempfile"
tempfile="response.temp"
rm -f "$tempfile"
datafile="attendees.full"
rm -f "$datafile"

url="https://pretix.eu/api/v1/organizers/denog/events/"
echo "DEBUG: url: $url"
curl -H "Authorization: Token ${api_token}" "${url}" | jq '.results[] | select(.live == true) | .slug' | sed 's/"//g'> ${tempfileslug}

cat ${tempfileslug} | while read event; do 
  # Onsite
  url="https://pretix.eu/api/v1/organizers/denog/events/${event}/checkinlists/"
  echo "DEBUG: url: $url"
  curl -H "Authorization: Token ${api_token}" "${url}" | jq '.results[] | select(.name == "Public Attendees List") | .id' > ${tempfile}
  checkin_list="`cat ${tempfile}`"
  rm -f ${tempfile}
  if [ -z "${checkin_list}" ]; then 
    continue
  fi
  #echo "checkin_list: $checkin_list"
  url="https://$instance/api/v1/organizers/$organizer/events/$event/checkinlists/$checkin_list/positions/"

  echo "DEBUG: event: $event, checkinlist: $checkin_list, url: $url"
  while [[ $url != "null" ]]; do
      curl -H "Authorization: Token ${api_token}" "${url}" > ${tempfile}
      url=$(jq -r .next ${tempfile})
      jq . "$tempfile" >> "$datafile"
  done
  rm -f "$tempfile"

  output="attendees_${event}.json"
  jq -s 'map(.results[]) | map({
      name: .attendee_name,
      company: ((.answers[] | select(.question_identifier=="COMPANY").answer)//null),
      irc: ((.answers[] | select(.question_identifier=="IRC").answer)//null),
      asn: ((.answers[] | select(.question_identifier=="ASN").answer)//null),
  })' "$datafile" > "_data/$output"
  rm -f "$datafile"
  # Create html page
  mkdir -p "${event}"
  cat template.index.markdown | sed "s/EVENT/attendees_${event}/" > "${event}/index.markdown"

  # Online
  url="https://pretix.eu/api/v1/organizers/denog/events/${event}/checkinlists/"
  echo "DEBUG: url: $url"
  curl -H "Authorization: Token ${api_token}" "${url}" | jq '.results[] | select(.name == "Public Attendees List Online") | .id' > ${tempfile}
  checkin_list="`cat ${tempfile}`"
  rm -f ${tempfile}
  if [ -z "${checkin_list}" ]; then 
    continue
  fi
  #echo "checkin_list: $checkin_list"
  url="https://$instance/api/v1/organizers/$organizer/events/$event/checkinlists/$checkin_list/positions/"

  echo "DEBUG: event: $event, checkinlist: $checkin_list, url: $url"
  while [[ $url != "null" ]]; do
      curl -H "Authorization: Token ${api_token}" "${url}" > ${tempfile}
      url=$(jq -r .next ${tempfile})
      jq . "$tempfile" >> "$datafile"
  done
  rm -f "$tempfile"

  # if we have online, then split output: 
  mv "_data/$output" "_data/attendees_${event}_onsite.json"
  output="attendees_${event}_online.json"
  jq -s 'map(.results[]) | map({
      name: .attendee_name,
      company: ((.answers[] | select(.question_identifier=="COMPANY").answer)//null),
      irc: ((.answers[] | select(.question_identifier=="IRC").answer)//null),
      asn: ((.answers[] | select(.question_identifier=="ASN").answer)//null),
  })' "$datafile" >> "_data/$output"
  rm -f "$datafile"

  # Create html page
  mkdir -p "${event}"
  cat template.index_online.markdown | sed "s/EVENT/attendees_${event}/" > "${event}/index.markdown"
done

rm -f "$tempfileslug"
