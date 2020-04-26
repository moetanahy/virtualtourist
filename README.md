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
* Use Codable for the DTO for PhotoResponse, then modify to have same object for both Photo and PhotoResponse 
* Using a Repostory Pattern which will accomodate for CoreData & Codable calls

## Flickr API

Had a lot of back and forth to find the right URL.

Just discovered this one which is critical - allows downloading the Image

https://www.flickr.com/services/api/misc.urls.html

The previous API I was using was wrong (flickr.photos.getInfo) is overkill and gets too much information, we don't need this.  with the information returned from the JSON in flickr.photos.search we can construct the JPEG url.




## Useful tools and docs

### Check Database

You can find the Database on my local computer at

/Users/moe/Library/Developer/CoreSimulator/Devices/2AC3E393-111B-45D3-9618-698334225705/data/Containers/Data/Application/F4D5FFDE-2872-418F-9E5D-33F585773679/Library/Application Support/

Use DB Database Browser for SQLLite to view the files above and can save

### Setting up Unit Testing

https://paul-samuels.com/blog/2019/01/07/swift-codable-testing/

## Tasks

### Dealing with Photos.

1. PhotoAlbumViewController kicks off loading the data
2. PhotoAlbumViewController creates observer to listen for new data on the pin store
3. FlickrClient deals with getting the data and saving it in the store (let's make this one call)

## Useful code references

* https://medium.com/@calmone/ios-mapkit-in-swift-4-drop-the-pin-at-the-point-of-long-press-2bed878fdf93
* https://medium.com/@andrea.prearo/working-with-codable-and-core-data-83983e77198e
* https://paul-samuels.com/blog/2019/01/07/swift-codable-testing/
