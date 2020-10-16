denog-attendees
===============

This repository uses GitHub Workflows to list all attendees of DENOG 12. New data is pulled every 20 minutes.

Development
-----------

Run ``bundle install`` and ``bundle exec jekyll serve`` to see how the list will look like.

The general layout is in the ``_layouts`` directory, and the list itself is rendered from the data file in
``index.markdown``.

If you need to update the data manually, run the `./pull_attendee_data.sh` script. It requires `curl` and `jq` to
be installed.
