#  Virtual Tourist

This is the Virtual Tourist Project for Udacity

## Architecture

Building Blocks I need to get done are:
* CoreData Stack, Data Model for Pin -> Photo
* API calls to Flickr
* UI interaction and display

## Work Flow needs to accomodate for

The different flows need to consider:

***Map View Screen***
* When no pins exist, allow a user to enter a pin
* When pins exist, display them

***Collection Screen***
* When no collection exists for a pin, then this load the collection from Flickr
* When the collection exists, just display it from Flickr

## Code Structure

I'll do it in two steps:
* The way I was taught in Udacity
   * in the first trial of CoreData (which was using sequential statements to get the data and load it)
   * Swap to using ResultsControllers and Observers to get this loading with less code overhead
* Using a Repostory Pattern which will accomodate for CoreData & Codable calls


## Useful code references

* https://medium.com/@calmone/ios-mapkit-in-swift-4-drop-the-pin-at-the-point-of-long-press-2bed878fdf93
* 




