import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> fetchRepairCenters(double lat, double lon, String product) async {
  Map<String, String> productCategoryMap = {
    // Computing Devices
    "laptop": 'node["shop"="computer"](around:10000,$lat,$lon);',
    "desktop": 'node["shop"="computer"](around:10000,$lat,$lon);',
    "pc": 'node["shop"="computer"](around:10000,$lat,$lon);',
    
    // Mobile Devices
    "mobile": 'node["shop"="mobile_phone"](around:10000,$lat,$lon);',
    "smartphone": 'node["shop"="mobile_phone"](around:10000,$lat,$lon);',
    "tablet": 'node["shop"="mobile_phone"](around:10000,$lat,$lon);',

    // Audio & Visual Equipment
    "tv": 'node["shop"="electronics"](around:10000,$lat,$lon);',
    "television": 'node["shop"="electronics"](around:10000,$lat,$lon);',
    "radio": 'node["shop"="radio"](around:10000,$lat,$lon);',
    "speakers": 'node["shop"="hifi"](around:10000,$lat,$lon);',
    "home theater": 'node["shop"="hifi"](around:10000,$lat,$lon);',
    "sound system": 'node["shop"="hifi"](around:10000,$lat,$lon);',

    // Camera & Photography
    "camera": 'node["shop"="photo"](around:10000,$lat,$lon);',
    "dslr": 'node["shop"="photo"](around:10000,$lat,$lon);',
    "cctv": 'node["shop"="electronics"](around:10000,$lat,$lon);',

    // Home Appliances
    "fridge": 'node["shop"="appliance"](around:10000,$lat,$lon);',
    "refrigerator": 'node["shop"="appliance"](around:10000,$lat,$lon);',
    "washing machine": 'node["shop"="appliance"](around:10000,$lat,$lon);',
    "dryer": 'node["shop"="appliance"](around:10000,$lat,$lon);',
    "microwave": 'node["shop"="appliance"](around:10000,$lat,$lon);',
    "oven": 'node["shop"="appliance"](around:10000,$lat,$lon);',
    "stove": 'node["shop"="appliance"](around:10000,$lat,$lon);',
    "chimney": 'node["shop"="appliance"](around:10000,$lat,$lon);',
    "ac": 'node["shop"="electronics"](around:10000,$lat,$lon);',
    "air conditioner": 'node["shop"="electronics"](around:10000,$lat,$lon);',
    "geyser": 'node["shop"="electronics"](around:10000,$lat,$lon);',
    "heater": 'node["shop"="electronics"](around:10000,$lat,$lon);',

    // Kitchen Appliances
    "blender": 'node["shop"="electronics"](around:10000,$lat,$lon);',
    "juicer": 'node["shop"="electronics"](around:10000,$lat,$lon);',
    "toaster": 'node["shop"="electronics"](around:10000,$lat,$lon);',
    "coffee maker": 'node["shop"="electronics"](around:10000,$lat,$lon);',
    "dishwasher": 'node["shop"="appliance"](around:10000,$lat,$lon);',

    // Others
    "fan": 'node["shop"="electronics"](around:10000,$lat,$lon);',
    "iron": 'node["shop"="electronics"](around:10000,$lat,$lon);',
    "vacuum cleaner": 'node["shop"="electronics"](around:10000,$lat,$lon);',
    "electronics": 'node["shop"="electronics"](around:10000,$lat,$lon);',
  };

  // Convert product name to lowercase for better matching
  String lowerProduct = product.toLowerCase();
  String osmFilter = "";

  // Check if product matches a specific repair shop type
  productCategoryMap.forEach((key, value) {
    if (lowerProduct.contains(key)) {
      osmFilter = value;
    }
  });

  // If no specific shop is found, fetch general repair centers
  if (osmFilter.isEmpty) {
    osmFilter = 'node["amenity"="repair"](around:5000,$lat,$lon);';
  }

  final String overpassQuery = """
  [out:json];
  (
    $osmFilter
  );
  out body;
  """;

  final String url = "https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(overpassQuery)}";

  final response = await http.get(Uri.parse(url));
  print("API Response: ${response.body}"); // Debugging

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data['elements'].isEmpty) {
      return [];
    }

    return data['elements'].map<Map<String, dynamic>>((place) {
      return {
        "name": place["tags"]["name"] ?? "Unknown Repair Center",
        "lat": place["lat"].toString(),
        "lon": place["lon"].toString(),
      };
    }).toList();
  } else {
    throw Exception('Failed to load repair centers');
  }
}
