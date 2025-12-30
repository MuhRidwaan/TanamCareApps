// Conditional export: use native implementation on IO platforms and a web stub on Web.
export 'ai_service_io.dart' if (dart.library.html) 'ai_service_web.dart';
