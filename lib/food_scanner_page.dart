
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//
// ============================================================
// GEMINI API KEY
// ============================================================
//
// Google AI Studio se API key banao aur neeche paste karo.
//
// Example:
// const String _geminiApiKey = 'AIzaSyxxxxxxxxxxxxxxxx';
//
// IMPORTANT:
// API key ko public GitHub repository me upload mat karna.
//
String get _geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

//
// Current Gemini model.
// Gemini 2.0 Flash is no longer available after June 1, 2026.
//
const String _geminiModel = 'gemini-3.5-flash';

// Optional fallback: Google Vision API key. If provided, the app will use
// Vision LABEL_DETECTION when Gemini is not configured. Get a key at:
// https://console.cloud.google.com/apis/credentials
String get _visionApiKey => dotenv.env['VISION_API_KEY'] ?? '<YOUR_VISION_API_KEY>';

class FoodScannerPage extends StatefulWidget {
  const FoodScannerPage({super.key});

  @override
  State<FoodScannerPage> createState() => _FoodScannerPageState();
}

class _FoodScannerPageState extends State<FoodScannerPage> {
  final ImagePicker _picker = ImagePicker();

  Uint8List? selectedImage;

  bool showResult = false;
  bool isLoading = false;

  String? errorMessage;

  // ==========================================================
  // NUTRITION DATA
  // ==========================================================

  String foodName = "";

  int calories = 0;
  int protein = 0;
  int carbs = 0;
  int fat = 0;

  int magnesium = 0;
  int calcium = 0;

  double iron = 0;

  int fiber = 0;

  // ==========================================================
  // CAMERA
  // ==========================================================

  Future<void> openCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImage = bytes;
        showResult = false;
        errorMessage = null;
      });

      await _analyzeImage(bytes);
    } catch (e) {
      debugPrint("CAMERA ERROR: $e");

      if (!mounted) return;

      setState(() {
        errorMessage = "Unable to open camera.";
      });
    }
  }

  // ---------------------------------------------------------
  // Vision API fallback helper
  // ---------------------------------------------------------
  Future<Map<String, dynamic>> _analyzeWithVision(
      Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);

    final url = Uri.parse(
        'https://vision.googleapis.com/v1/images:annotate?key=$_visionApiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [
              {'type': 'LABEL_DETECTION', 'maxResults': 10}
            ]
          }
        ]
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Vision API error: ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ==========================================================
  // GALLERY
  // ==========================================================

  Future<void> openGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImage = bytes;
        showResult = false;
        errorMessage = null;
      });

      await _analyzeImage(bytes);
    } catch (e) {
      debugPrint("GALLERY ERROR: $e");

      if (!mounted) return;

      setState(() {
        errorMessage = "Unable to open gallery.";
      });
    }
  }

  // ==========================================================
  // GEMINI IMAGE ANALYSIS
  // ==========================================================

  Future<void> _analyzeImage(Uint8List imageBytes) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      showResult = false;
      errorMessage = null;
    });

    try {
      // --------------------------------------------------------
      // CHECK API KEY / FALLBACK
      // --------------------------------------------------------

      if (_geminiApiKey.isEmpty || _geminiApiKey == 'YOUR_GEMINI_API_KEY') {
        // If Gemini isn't configured, try Vision API as a simpler fallback.
        if (!(_visionApiKey.isEmpty || _visionApiKey == '<YOUR_VISION_API_KEY>')) {
          final visionResult = await _analyzeWithVision(imageBytes);

          final annotations =
              (visionResult['responses']?[0]?['labelAnnotations']) as List?;

          final topLabel = (annotations != null && annotations.isNotEmpty)
              ? annotations[0]['description'] as String
              : 'Unknown';

          if (!mounted) return;

          setState(() {
            foodName = topLabel;
            // Vision doesn't provide nutrition values — set zeros.
            calories = 0;
            protein = 0;
            carbs = 0;
            fat = 0;
            magnesium = 0;
            calcium = 0;
            iron = 0;
            fiber = 0;
            showResult = true;
            isLoading = false;
          });

          return;
        }

        throw Exception(
          'Gemini API key is not configured. Provide a Gemini API key or a Vision API key.',
        );
      }

      // --------------------------------------------------------
      // IMAGE -> BASE64
      // --------------------------------------------------------

      final base64Image = base64Encode(imageBytes);

      // --------------------------------------------------------
      // GEMINI API URL
      // --------------------------------------------------------

      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        '$_geminiModel:generateContent',
      );

      // --------------------------------------------------------
      // PROMPT
      // --------------------------------------------------------

      const String prompt = '''
Analyze the food shown in this image.

Identify the food and estimate its nutrition for ONE typical serving.

Return ONLY valid JSON.
Do not use markdown.
Do not use ```json.
Do not add explanations.

Return exactly this structure:

{
  "foodName": "string",
  "calories": 0,
  "protein": 0,
  "carbs": 0,
  "fat": 0,
  "magnesium": 0,
  "calcium": 0,
  "iron": 0,
  "fiber": 0
}

Units:
- calories = kcal
- protein = grams
- carbs = grams
- fat = grams
- fiber = grams
- magnesium = mg
- calcium = mg
- iron = mg

If the image does not contain food, return:

{
  "foodName": "Not food",
  "calories": 0,
  "protein": 0,
  "carbs": 0,
  "fat": 0,
  "magnesium": 0,
  "calcium": 0,
  "iron": 0,
  "fiber": 0
}

Use reasonable nutritional estimates.
''';

      // --------------------------------------------------------
      // REQUEST
      // --------------------------------------------------------

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',

          // Gemini API authentication
          'x-goog-api-key': _geminiApiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'role': 'user',
              'parts': [
                {
                  'text': prompt,
                },
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image,
                  },
                },
              ],
            },
          ],

          // Ask Gemini for JSON response.
          'generationConfig': {
            'temperature': 0.2,
            'responseMimeType': 'application/json',
          },
        }),
      );

      // --------------------------------------------------------
      // DEBUG
      // --------------------------------------------------------

      debugPrint(
        'GEMINI STATUS: ${response.statusCode}',
      );

      debugPrint(
        'GEMINI BODY: ${response.body}',
      );

      // --------------------------------------------------------
      // API ERROR
      // --------------------------------------------------------

      if (response.statusCode != 200) {
        String message = response.body;

        try {
          final errorJson = jsonDecode(response.body);

          if (errorJson['error'] != null) {
            message =
                errorJson['error']['message']?.toString() ??
                response.body;
          }
        } catch (_) {}

        throw Exception(
          'Gemini API Error (${response.statusCode}): $message',
        );
      }

      // --------------------------------------------------------
      // DECODE RESPONSE
      // --------------------------------------------------------

      final decoded = jsonDecode(response.body);

      final candidates = decoded['candidates'];

      if (candidates == null ||
          candidates is! List ||
          candidates.isEmpty) {
        throw Exception(
          'Gemini returned no candidates.',
        );
      }

      final content = candidates[0]['content'];

      if (content == null) {
        throw Exception(
          'Gemini response content is empty.',
        );
      }

      final parts = content['parts'];

      if (parts == null ||
          parts is! List ||
          parts.isEmpty) {
        throw Exception(
          'Gemini response parts are empty.',
        );
      }

      String rawText = "";

      for (final part in parts) {
        if (part is Map && part['text'] != null) {
          rawText += part['text'].toString();
        }
      }

      if (rawText.trim().isEmpty) {
        throw Exception(
          'Gemini returned empty text.',
        );
      }

      // --------------------------------------------------------
      // CLEAN JSON
      // --------------------------------------------------------

      String cleanText = rawText.trim();

      // Remove markdown fences if Gemini adds them.
      cleanText = cleanText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Sometimes model may return extra text before/after JSON.
      final jsonObject = _extractJsonObject(cleanText);

      if (jsonObject == null) {
        throw Exception(
          'Invalid JSON received from Gemini. Raw output:\n$cleanText',
        );
      }

      // --------------------------------------------------------
      // PARSE JSON
      // --------------------------------------------------------

      Map<String, dynamic> data;
      try {
        final dynamic parsed = jsonDecode(jsonObject);

        if (parsed is! Map) {
          throw Exception('Gemini returned invalid nutrition data.');
        }

        data = Map<String, dynamic>.from(parsed);
      } catch (_) {
        data = _parseNutritionFromText(cleanText);
      }

      // --------------------------------------------------------
      // SAFE NUMBER HELPERS
      // --------------------------------------------------------

      int readInt(dynamic value) {
        if (value == null) return 0;

        if (value is num) {
          return value.round();
        }

        return int.tryParse(
              value.toString(),
            ) ??
            0;
      }

      double readDouble(dynamic value) {
        if (value == null) return 0;

        if (value is num) {
          return value.toDouble();
        }

        return double.tryParse(
              value.toString(),
            ) ??
            0;
      }

      // --------------------------------------------------------
      // UPDATE UI
      // --------------------------------------------------------

      if (!mounted) return;

      setState(() {
        foodName =
            data['foodName']?.toString() ??
            'Unknown food';

        calories = readInt(
          data['calories'],
        );

        protein = readInt(
          data['protein'],
        );

        carbs = readInt(
          data['carbs'],
        );

        fat = readInt(
          data['fat'],
        );

        magnesium = readInt(
          data['magnesium'],
        );

        calcium = readInt(
          data['calcium'],
        );

        iron = readDouble(
          data['iron'],
        );

        fiber = readInt(
          data['fiber'],
        );

        showResult = true;
        isLoading = false;
      });
    } catch (e) {
      // --------------------------------------------------------
      // ERROR
      // --------------------------------------------------------

      debugPrint(
        'GEMINI ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
        showResult = false;

        errorMessage =
            'Analysis failed.\n\n$e';
      });
    }
  }

  String? _extractJsonObject(String text) {
    int depth = 0;
    int? start;
    bool inString = false;
    bool escape = false;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (char == '\\' && !escape) {
        escape = true;
        continue;
      }

      if (char == '"' && !escape) {
        inString = !inString;
      }

      if (!inString) {
        if (char == '{') {
          depth++;
          start ??= i;
        } else if (char == '}') {
          depth--;
          if (depth == 0 && start != null) {
            return text.substring(start, i + 1);
          }
        }
      }

      escape = false;
    }

    if (start != null && depth > 0) {
      final candidate = text.substring(start).trim();
      final closingBraces = '}' * depth;
      final repaired = '$candidate$closingBraces';

      if (_tryParseJson(repaired) != null) {
        return repaired;
      }
    }

    return null;
  }

  dynamic _tryParseJson(String text) {
    try {
      return jsonDecode(text);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _parseNutritionFromText(String text) {
    final values = <String, dynamic>{
      'foodName': 'Unknown food',
      'calories': 0,
      'protein': 0,
      'carbs': 0,
      'fat': 0,
      'magnesium': 0,
      'calcium': 0,
      'iron': 0,
      'fiber': 0,
    };

    final regexMap = {
      'foodName': RegExp(r'"foodName"\s*:\s*"([^"]+)"', caseSensitive: false),
      'calories': RegExp(r'"calories"\s*:\s*([0-9]+)', caseSensitive: false),
      'protein': RegExp(r'"protein"\s*:\s*([0-9]+)', caseSensitive: false),
      'carbs': RegExp(r'"carbs"\s*:\s*([0-9]+)', caseSensitive: false),
      'fat': RegExp(r'"fat"\s*:\s*([0-9]+)', caseSensitive: false),
      'magnesium': RegExp(r'"magnesium"\s*:\s*([0-9]+)', caseSensitive: false),
      'calcium': RegExp(r'"calcium"\s*:\s*([0-9]+)', caseSensitive: false),
      'iron': RegExp(r'"iron"\s*:\s*([0-9]+(?:\.[0-9]+)?)', caseSensitive: false),
      'fiber': RegExp(r'"fiber"\s*:\s*([0-9]+)', caseSensitive: false),
    };

    for (final entry in regexMap.entries) {
      final match = entry.value.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        final raw = match.group(1)!;
        if (entry.key == 'foodName') {
          values['foodName'] = raw;
        } else if (entry.key == 'iron') {
          values['iron'] = double.tryParse(raw) ?? 0;
        } else {
          values[entry.key] = int.tryParse(raw) ?? 0;
        }
      }
    }
    return values;
  }

  // ==========================================================
  // RESET
  // ==========================================================

  void resetScanner() {
    setState(() {
      selectedImage = null;

      showResult = false;

      errorMessage = null;

      foodName = "";

      calories = 0;
      protein = 0;
      carbs = 0;
      fat = 0;

      magnesium = 0;
      calcium = 0;

      iron = 0;

      fiber = 0;
    });
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06111B),

      appBar: AppBar(
        backgroundColor: const Color(0xFF06111B),
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Food Scanner",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: "Food Scanner",
                applicationVersion: "1.0",
                children: const [
                  Text(
                    "Scan your food and get estimated nutrition information.",
                  ),
                ],
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            25,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==================================================
              // CAMERA AREA
              // ==================================================

              Container(
                height: 400,
                width: double.infinity,

                decoration: BoxDecoration(
                  color: const Color(0xFF111D28),
                  borderRadius:
                      BorderRadius.circular(28),

                  border: Border.all(
                    color: Colors.white12,
                  ),
                ),

                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(28),

                  child: Stack(
                    children: [
                      // ------------------------------------------------
                      // IMAGE
                      // ------------------------------------------------

                      if (selectedImage != null)
                        Positioned.fill(
                          child: Image.memory(
                            selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Positioned.fill(
                          child: Container(
                            color:
                                const Color(0xFF101B25),

                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,

                              children: [
                                Container(
                                  height: 80,
                                  width: 80,

                                  decoration:
                                      const BoxDecoration(
                                    shape:
                                        BoxShape.circle,

                                    color:
                                        Color(0xFF172635),
                                  ),

                                  child: const Icon(
                                    Icons.restaurant,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(
                                  height: 18,
                                ),

                                const Text(
                                  "Scan Your Food",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                const Text(
                                  "Take a photo of your meal\n"
                                  "to analyze its nutrition",
                                  textAlign:
                                      TextAlign.center,

                                  style: TextStyle(
                                    color:
                                        Colors.white60,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // ------------------------------------------------
                      // SCANNER CORNERS
                      // ------------------------------------------------

                      if (selectedImage == null)
                        Positioned.fill(
                          child: CustomPaint(
                            painter:
                                ScannerCornersPainter(),
                          ),
                        ),

                      // ------------------------------------------------
                      // BOTTOM TEXT
                      // ------------------------------------------------

                      if (selectedImage == null)
                        const Positioned(
                          bottom: 25,
                          left: 0,
                          right: 0,

                          child: Text(
                            "Place your food in the frame",
                            textAlign:
                                TextAlign.center,

                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),

                      // ------------------------------------------------
                      // LOADING
                      // ------------------------------------------------

                      if (isLoading)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black54,

                            child: const Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,

                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                  ),

                                  SizedBox(
                                    height: 14,
                                  ),

                                  Text(
                                    "Analyzing your food...",
                                    style: TextStyle(
                                      color:
                                          Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // ------------------------------------------------
                      // RESET
                      // ------------------------------------------------

                      if (selectedImage != null &&
                          !isLoading)
                        Positioned(
                          top: 15,
                          right: 15,

                          child: GestureDetector(
                            onTap: resetScanner,

                            child: Container(
                              padding:
                                  const EdgeInsets.all(
                                10,
                              ),

                              decoration:
                                  const BoxDecoration(
                                color: Colors.black54,
                                shape:
                                    BoxShape.circle,
                              ),

                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // ERROR
              // ==================================================

              if (errorMessage != null)
                Container(
                  width: double.infinity,

                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),

                  padding:
                      const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: Colors.red
                        .withOpacity(0.10),

                    borderRadius:
                        BorderRadius.circular(12),

                    border: Border.all(
                      color: Colors.redAccent
                          .withOpacity(0.30),
                    ),
                  ),

                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ),

              // ==================================================
              // CAMERA + GALLERY
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      icon: Icons.camera_alt,
                      title: "Camera",
                      onTap: isLoading
                          ? null
                          : openCamera,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _actionButton(
                      icon: Icons.photo_library,
                      title: "Gallery",
                      onTap: isLoading
                          ? null
                          : openGallery,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ==================================================
              // RESULT
              // ==================================================

              if (showResult)
                _nutritionResult(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _actionButton({
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
  }) {
    final bool disabled = onTap == null;

    return GestureDetector(
      onTap: onTap,

      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,

        child: Container(
          height: 55,

          decoration: BoxDecoration(
            color: const Color(0xFF152330),

            borderRadius:
                BorderRadius.circular(16),

            border: Border.all(
              color: Colors.white12,
            ),
          ),

          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 21,
              ),

              const SizedBox(width: 8),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NUTRITION RESULT
  // ============================================================

  Widget _nutritionResult() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF152330),

        borderRadius:
            BorderRadius.circular(22),

        border: Border.all(
          color: Colors.white10,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            "Analysis Result",
            style: TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Container(
                height: 45,
                width: 45,

                decoration: BoxDecoration(
                  color:
                      const Color(0xFF233544),

                  borderRadius:
                      BorderRadius.circular(12),
                ),

                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  foodName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),

              Text(
                "$calories kcal",
                style: const TextStyle(
                  color: Color(0xFFFFB52E),
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              _nutritionItem(
                "Protein",
                "$protein g",
              ),

              _nutritionItem(
                "Carbs",
                "$carbs g",
              ),

              _nutritionItem(
                "Fat",
                "$fat g",
              ),
            ],
          ),

          const SizedBox(height: 22),

          const Divider(
            color: Colors.white10,
          ),

          const SizedBox(height: 15),

          const Text(
            "Micronutrients",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _microNutrient(
                  "Magnesium",
                  "$magnesium mg",
                ),
              ),

              Expanded(
                child: _microNutrient(
                  "Calcium",
                  "$calcium mg",
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _microNutrient(
                  "Iron",
                  "${iron.toStringAsFixed(1)} mg",
                ),
              ),

              Expanded(
                child: _microNutrient(
                  "Fiber",
                  "$fiber g",
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Center(
            child: TextButton(
              onPressed: () {},

              child: const Text(
                "View Full Nutrition  ›",

                style: TextStyle(
                  color: Color(0xFF5CA9FF),
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NUTRITION ITEM
  // ============================================================

  Widget _nutritionItem(
    String title,
    String value,
  ) {
    return Column(
      children: [
        Text(
          title,

          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          value,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MICRO NUTRIENT
  // ============================================================

  Widget _microNutrient(
    String title,
    String value,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(right: 8),

      padding:
          const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color:
            const Color(0xFF101B25),

        borderRadius:
            BorderRadius.circular(13),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [
          Expanded(
            child: Text(
              title,

              overflow:
                  TextOverflow.ellipsis,

              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(width: 5),

          Text(
            value,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SCANNER CORNERS PAINTER
// ============================================================

class ScannerCornersPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top left

    canvas.drawLine(
      const Offset(18, 55),
      const Offset(18, 20),
      paint,
    );

    canvas.drawLine(
      const Offset(18, 20),
      const Offset(53, 20),
      paint,
    );

    // Top right

    canvas.drawLine(
      Offset(size.width - 18, 55),
      Offset(size.width - 18, 20),
      paint,
    );

    canvas.drawLine(
      Offset(size.width - 18, 20),
      Offset(size.width - 53, 20),
      paint,
    );

    // Bottom left

    canvas.drawLine(
      Offset(18, size.height - 55),
      Offset(18, size.height - 20),
      paint,
    );

    canvas.drawLine(
      Offset(18, size.height - 20),
      Offset(53, size.height - 20),
      paint,
    );

    // Bottom right

    canvas.drawLine(
      Offset(size.width - 18, size.height - 55),
      Offset(size.width - 18, size.height - 20),
      paint,
    );

    canvas.drawLine(
      Offset(size.width - 18, size.height - 20),
      Offset(size.width - 53, size.height - 20),
      paint,
    );
  }

  @override
  bool shouldRepaint(
    CustomPainter oldDelegate,
  ) {
    return false;
  }
}
