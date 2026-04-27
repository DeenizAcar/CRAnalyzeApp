// Pro maclardan matchup verisi topla.
// dart run tool/harvest.dart                           # default bolgeler, 50/region
// dart run tool/harvest.dart --regions=tr,us --per=20  # ozel

import 'dart:io';

import 'package:cr_analyze_app/data/api/supercell_api_client.dart';
import 'package:cr_analyze_app/data/harvest/batch_harvester.dart';
import 'package:cr_analyze_app/data/harvest/matchup_store.dart';
import 'package:cr_analyze_app/data/harvest/pro_player_list.dart';
import 'package:cr_analyze_app/utils/env.dart';

const Map<String, String> _regionAlias = {
  'tr': '57000239',
  'us': '57000249',
  'fr': '57000098',
  'de': '57000094',
  'it': '57000130',
  'es': '57000196',
  'br': '57000027',
  'ru': '57000182',
};

Future<void> main(List<String> args) async {
  // Args parse
  List<String>? regions;
  var perRegion = 50;
  for (final arg in args) {
    if (arg.startsWith('--regions=')) {
      final raw = arg.substring(10).split(',');
      regions = raw.map((r) => _regionAlias[r.toLowerCase().trim()] ?? r).toList();
    } else if (arg.startsWith('--per=')) {
      perRegion = int.parse(arg.substring(6));
    }
  }

  final api = SupercellApiClient(
    token: Env.crApiToken,
    baseUrl: Env.crApiBaseUrl ?? SupercellApiClient.royaleApiProxyBaseUrl,
  );
  final store = MatchupStore();

  try {
    stdout.writeln('=== Pro Tag Toplama ===');
    final list = ProPlayerList(api);
    final tags = await list.collectTags(regionIds: regions, perRegion: perRegion);
    stdout.writeln('Toplam ${tags.length} unique tag');
    stdout.writeln('');

    stdout.writeln('=== Battlelog Harvest ===');
    final harvester = BatchHarvester(
      api: api,
      store: store,
      log: stdout.writeln,
    );
    final result = await harvester.harvest(playerTags: tags);
    stdout.writeln('');
    stdout.writeln(result.toString());

    // Bundle: cache'i assets'e kopyala (web build'inde de erisilebilir)
    final src = File('.cache/matchups.json');
    final dst = File('assets/data/matchups.json');
    if (src.existsSync()) {
      if (!dst.parent.existsSync()) dst.parent.createSync(recursive: true);
      src.copySync(dst.path);
      stdout.writeln('assets/data/matchups.json guncellendi (${dst.lengthSync()} byte)');
    }
  } finally {
    await api.dispose();
  }
}
