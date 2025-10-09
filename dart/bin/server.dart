import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;

Future<Response> _handleRoot(Request request) async {
  final keyword = request.url.queryParameters['keyword'] ?? '';
  final target = request.url.queryParameters['target'] ?? '';
  var found = 'false';
  
  if (keyword.isNotEmpty && target.isNotEmpty) {
    try {
      final response = await http.get(Uri.parse(target)).timeout(
        const Duration(seconds: 10)
      );
      
      if (response.body.contains(keyword)) {
        found = 'true';
      }
      
      print('found=$found, keyword=$keyword, uri=$target');
    } catch (e) {
      print('Error: $e');
    }
  }
  
  return Response.ok(found);
}

void main(List<String> args) async {
  final app = Router();
  app.get('/', _handleRoot);
  
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(app);

  final server = await serve(handler, InternetAddress.anyIPv4, 31337);
  print('listening on 0.0.0.0:${server.port}');
}