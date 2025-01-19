#!/usr/bin/env python3

import json
import csv
import re
import requests
import time
import os

current_pretix_file = "_data/attendees_denog16_onsite.json"

instance="pretix.eu"
organizer="denog"

url="https://%s/api/v1/organizers/%s/" % (instance, organizer)

# for github runners:
#token = "Token %s" % api_token
env_token = os.environ["PRETIX_API_TOKEN"]
token = "Token %s" % env_token

headers = {
  'Accept': 'application/json, text/javascript',
  'Content-Type': 'application/json', 
  'Authorization': token,
}

events_url="%sevents/" % (url)

# ------------
def checkinlist_to_file( headers, checkinlists_url, checkinlist_id, event_slug, output_filename ): 
  checkinlists_pos_url="%s%s/positions/" % (checkinlists_url, checkinlist_id)
  results = []
  while checkinlists_pos_url is not None: 
    response = requests.get(checkinlists_pos_url, headers=headers)
    result = json.loads( response.content )
    results.extend( result['results'] )
    checkinlists_pos_url = result['next']
  # 
  persons = []
  for pos in results: 
    # map out some json fields:
    person = {}
    person['name'] = pos['attendee_name']
    person['company'] = None
    person['irc'] = None
    person['asn'] = None
    not_public = False
    for answer in pos['answers']:
      if answer['question_identifier'] == "COMPANY":
        person['company'] = answer['answer']
      if answer['question_identifier'] == "IRC":
        person['irc'] = answer['answer']
      if answer['question_identifier'] == "ASN":
        person['asn'] = answer['answer']
      if answer['question_identifier'] == "NOTPUBLIC":
        if answer['answer'] == 'True': 
          not_public = True
    if not_public:
      continue
    persons.append( person )
  # 
  json_data = json.dumps( persons )
  #  
  with open(output_filename, 'w', encoding='utf-8') as myfile: 
    json.dump( persons, myfile, ensure_ascii=False, indent=2 )
# ------------


# Search for all live events
params = { 'live': True }
response = requests.get(events_url, params=params, headers=headers)

#print (response, response.content)
events = json.loads( response.content )

# For each event get orders
for event in events['results']:
  print( "---------" )
  event_slug = event['slug']
  print( event_slug ) 
  # Get orders from Checkinlist
  checkinlists_url="%s%s/checkinlists/" % (events_url, event_slug)
  response = requests.get(checkinlists_url, headers=headers)
  checkinlists = json.loads( response.content )
  #print( checkinlists ) 
  # 
  checkinlist_onsite_id = 0
  checkinlist_online_id = 0
  for checkinlist in checkinlists['results']:
    #print( checkinlist ) 
    if checkinlist['name'] == "Public Attendees List":
      checkinlist_onsite_id = checkinlist['id']
    if checkinlist['name'] == "Public Attendees List Online":
      checkinlist_online_id = checkinlist['id']
  print( "Checkin-list IDs:", checkinlist_onsite_id, checkinlist_online_id )
  if checkinlist_onsite_id == 0:
    print( "Didn't find >Public Attendees List< for event %s" % slug )
    continue
  # 
  if checkinlist_online_id == 0:
    # this is an onsite event
    output_filename = "_data/attendees_%s.json" % event_slug
    checkinlist_to_file( headers, checkinlists_url, checkinlist_onsite_id, event_slug, output_filename )
    template = "template.index.markdown"
  else: 
    # onsite and online checkin-list
    output_filename = "_data/attendees_%s_online.json" % event_slug
    checkinlist_to_file( headers, checkinlists_url, checkinlist_online_id, event_slug, output_filename )
    output_filename = "_data/attendees_%s_onsite.json" % event_slug
    checkinlist_to_file( headers, checkinlists_url, checkinlist_onsite_id, event_slug, output_filename )
    template = "template.index_online.markdown"
  # Create html page
  os.makedirs( event_slug, exist_ok=True)
  outfile = "%s/index.markdown" % event_slug
  with open( outfile, 'w', encoding='utf-8') as myfile: 
    f = open( template, 'r')
    lines = f.readlines()
    nlines = [l.replace('EVENT', event_slug) for l in lines]
    myfile.writelines( nlines )
  myfile.close()


