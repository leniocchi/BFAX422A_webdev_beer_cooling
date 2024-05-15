# Web-Entwicklung: Beer-Cooling

I want to develop a web-app where the user gets information about the cooling time of beer.

User decides between different selection options:

* storage
    * outdoor:
        * temperature from current user location / user input: location
    * indoor:
        * temperature from user input (room-temperature)
    * fridge:
        * temperature from user input (fridge-temperature)

* beer
    * sort
    * brand

* beer temperature preference
    * cold/medium

## Client

* Flutter-UI
* OpenAI integration for communication with the user (storage, beer, temperature preference)
* Location request
* HTTP-Requests

## Server

* connection to an existing beer-database
* endpoints for OpenAI (CRUD-Operations):
    * post & upgrade & delete beer element 
    * for each beer element:
        * post/put storage
        * post/put beer sort and brand
        * post/put temperature preference
* location-api
* data interpretation (calculation of cooling time)
    * more beer -> more volume -> longer cooling time

## Technologies

### Client

* Flutter-UI
* flutter geolocator package: to query the user's location

### Server

* OpenAI API
* Geolocation API (optional): To determine the user's location
* beer-database

# Additionally

* get: additional information (maybe fun facts) about the beer
* get: a specific drinking toast to the selected type of beer (-> chatgpt)
* Wine
