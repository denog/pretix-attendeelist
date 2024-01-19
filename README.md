# denog-attendees

This repository uses GitHub Workflows to list all attendees of DENOG Events. New data is pulled every 20 minutes.

## Development Enviroment

Run ``bundle install`` and ``bundle exec jekyll serve`` to see how the list will look like.

The general layout is in the ``_layouts`` directory, and the list itself is rendered from the data file in
``index.markdown``.

If you need to update the data manually, run the `./pull_attendee_data.sh` script. It requires `curl` and `jq` to
be installed.


## pull_attendee_data.sh

This script gets from pretix API all live events from DENOG. 
For all live events find checkin_list "Public Attendees List", get all attendees and expose them via 
  https://www.denog.de/pretix-attendeelist/slugname/


## pull_attendee_data2.sh

This is used for the conference with onsite and online participants. 


## Setup New Event

How to setup a new event:

### In Pretix
- Extend API User rights to new Event (if API User doesn't access to all events by default)
- Find Checkin List API ID

### In github secrets
- Update Checkin List API ID

### In pull_attendee_data2.sh
- Update event var to current event tag event="denogmeetup21-01"
- Update output file to new name "$datafile" > _data/attendees_meetup2021-01.json

### Copy index.markdown
- Rename to e.g. denogmeetup21-01.markdown (Pretix Short)
- Update the following line to new data file name defined in last step
{% assign sorted = site.data.attendees_meetup2021-01 | sort_natural: 'name' %}
