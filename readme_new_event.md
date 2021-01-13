
## Pretix
1) Extend API User rights to new Event
2) Find Checkin List API ID

## github secrets
1) Update Checkin List API ID

## pull_attendee_data.sh
1) Update event var to current event tag
  event="denogmeetup21-01"

2) Update output file to new name
"$datafile" > _data/attendees_meetup2021-01.json

## index.markdown
1) Update to new data file name  
{% assign sorted = site.data.attendees_meetup2021-01 | sort_natural: 'name' %}




