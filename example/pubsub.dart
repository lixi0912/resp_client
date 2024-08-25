
import 'package:resp_client/resp_client.dart';
import 'package:resp_client/resp_commands.dart';
import 'package:resp_client/resp_server.dart';

void main(List<String> args) async {
  // create a server connection using sockets
  final server = await connectSocket('localhost');
  // create a client using the server connection
  final client = RespClient(server);
  final commands = RespCommandsTier2(client);
  final configResult = await commands.config(['set', 'notify-keyspace-events', 'AKE']);
  print('notify-keyspace-events: $configResult');
  // execute a command
  final stream = commands.psubscribe(['__keyspace@*__:*']);
  final streamWithoutErrors = stream.handleError((err) {
    print('err:$err');
  });
  await for (final value in streamWithoutErrors) {
    print(value);
    break;
  }
  await commands.punsubscribe(['__keyspace@*__:*']);
  var list = await commands.clientList();
  print('client-list:$list');
  // close connection to the server
  await server.close();
}
