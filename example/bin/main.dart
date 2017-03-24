import 'package:http/http.dart' as http;
import '../pubspec.update.g.dart';

main() async {
  var client = new http.Client();
  var update = await checkForUpdate(client);
  client.close();

  if (update == null)
    print('No update available - you are using the current version.');
  else {
    print('New version available - v$update');
  }
}
