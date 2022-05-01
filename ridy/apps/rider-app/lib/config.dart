import 'dart:io';
import 'package:flutter/foundation.dart';

String serverUrl = "http://x.x.x.x:4000/";
String wsUrl = serverUrl.replaceFirst("http", "ws");
bool isSinglePointMode = false;
MapProvider mapProvider = MapProvider.openStreetMap;

enum MapProvider { openStreetMap, googleMap, mapBox }

// MapBox Configuration (Only if Map Provider is set to mapBox)
String mapBoxAccessToken = "";
String mapBoxUserId = "";
String mapBoxTileSetId = "";

// Nominatim configuration (Only for Open Streep Maps and MapBox)
List<String>? nominatimCountries; // ISO 3166-1alpha2 codes

// Google Places Configuration (Only for Google Map Provider)
String placesApiKey = "";
String placesCountry = "en";

String loginTermsAndConditionsUrl = "";

// Login & Wallet locale
String defaultCurrency = "USD";
String defaultCountryCode = "+1";
