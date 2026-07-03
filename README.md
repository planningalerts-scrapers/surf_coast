**Archived as it is replaced by the `multiple_t1_data_table` scraper**

---
# Surf Coast Shire Council Development Applications for PlanningAlerts

Note that the system on the council side that is showing the development applications
is the same as used by Stonnington. At some point it might be worthwhile to combine
these two scrapers into one.

This is a scraper that runs on [Morph](https://morph.io). To get started [see the documentation](https://morph.io/documentation)

Add any issues to https://github.com/planningalerts-scrapers/issues/issues

Set `MORPH_AUSTRALIAN_PROXY` to an Australian proxy, preferably one that rotates its IP address

## Expected Output
    
    Requesting pageful of details ...
    Storing 26/0097 - 3410 Princes Highway, WINCHELSEA VIC 3241
    Storing 26/0098 - 35 ODonohue Road, ANGLESEA VIC 3230
    ...
    Storing 26/0093 (VicSmart) - 49 Wybellenna Drive, FAIRHAVEN VIC 3231
    Storing PG19/0086 - 2 - 125 Austin Street, WINCHELSEA VIC 3241 & 135 Austin Street and 50 Witcombe Street and part 235 Austin Street, WINCHELSEA VIC 3241
    Requesting pageful of details ...
    ...
    Storing 26/0073 - 2 Cottage Crescent, TORQUAY VIC 3228
    Finished - processed 44 records

Expected runtime: ~ 5 seconds

## To run the scraper

    bundle exec ruby scraper.rb

## To run style and coding checks

    bundle exec rubocop

## To check for security updates

    gem install bundler-audit
    bundle-audit
