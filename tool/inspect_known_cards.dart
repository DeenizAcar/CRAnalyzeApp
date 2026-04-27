import 'package:cr_analyze_app/data/api/supercell_api_client.dart';
import 'package:cr_analyze_app/data/card_catalog.dart';
import 'package:cr_analyze_app/utils/env.dart';

Future<void> main(List<String> args) async {
  final api = SupercellApiClient(
    token: Env.crApiToken,
    baseUrl: Env.crApiBaseUrl ?? SupercellApiClient.royaleApiProxyBaseUrl,
  );
  await CardCatalog.load(api);
  await api.dispose();
  final all = CardCatalog.allNames..sort();
  print('Toplam kart: ${all.length}');
  if (args.isNotEmpty) {
    final q = args.first.toLowerCase();
    for (final n in all) {
      if (n.toLowerCase().contains(q)) print('  -> $n');
    }
  } else {
    for (final n in all) {
      print('  $n');
    }
  }
}
