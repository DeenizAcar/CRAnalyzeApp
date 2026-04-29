import 'package:flutter/material.dart';

import '../../data/card_catalog.dart';

/// CRL düello modu: tüm CR kartlarını listeler, arama barı ile filtre,
/// tıklayınca onTap callback ile bildirir. Seçili kartlar [selectedNames]
/// set'inden okunur.
class CardPickerGrid extends StatefulWidget {
  final Set<String> selectedNames;
  final void Function(String cardName) onToggle;
  final VoidCallback? onClearAll;

  const CardPickerGrid({
    super.key,
    required this.selectedNames,
    required this.onToggle,
    this.onClearAll,
  });

  @override
  State<CardPickerGrid> createState() => _CardPickerGridState();
}

class _CardPickerGridState extends State<CardPickerGrid> {
  final _controller = TextEditingController();
  String _query = '';

  // Sıralı kart adı listesi cache: CardCatalog.allNames her cagrida
  // List olusturuyor + sort ediyor; bir kez yapsin.
  late final List<String> _allNamesSorted = [...CardCatalog.allNames]..sort();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> _filteredNames() {
    if (_query.isEmpty) return _allNamesSorted;
    final q = _query.toLowerCase();
    return _allNamesSorted.where((n) => n.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final names = _filteredNames();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Kart ara (ör: fire, hog, evo)',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
              ),
            ),
            if (widget.selectedNames.isNotEmpty && widget.onClearAll != null) ...[
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: widget.onClearAll,
                icon: const Icon(Icons.refresh, size: 16),
                label: Text('Sıfırla (${widget.selectedNames.length})'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white60,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${names.length} kart — rakip oynadıkça tıkla',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
        ),
        const SizedBox(height: 8),
        if (names.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Eşleşen kart bulunamadı.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              const tileWidth = 44.0;
              const spacing = 4.0;
              final cols = (constraints.maxWidth / (tileWidth + spacing))
                  .floor()
                  .clamp(6, 16);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: 0.8,
                ),
                itemCount: names.length,
                itemBuilder: (context, i) {
                  final name = names[i];
                  return _CardPickerTile(
                    name: name,
                    selected: widget.selectedNames.contains(name),
                    onTap: () => widget.onToggle(name),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

class _CardPickerTile extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const _CardPickerTile({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final url = CardCatalog.iconFor(name);
    final theme = Theme.of(context);

    Widget image = url != null
        ? Image.network(
            url,
            fit: BoxFit.contain,
            // 44px tile + DPR ~2 = 88px decode yeterli; default decode ~300px (asil resim genisligi)
            cacheWidth: 96,
            gaplessPlayback: true,
            filterQuality: FilterQuality.low,
          )
        : Center(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(fontSize: 7),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );

    // Sadece secili tile'da grayscale uygula; default rebuild'lerde GPU iş yok.
    if (selected) {
      image = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.3, 0.3, 0.3, 0, 0,
          0.3, 0.3, 0.3, 0, 0,
          0.3, 0.3, 0.3, 0, 0,
          0,   0,   0,   1, 0,
        ]),
        child: image,
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF12172A),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: selected
                    ? const Color(0xFF4CAF50)
                    : Colors.white12,
                width: selected ? 1.5 : 0.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: image,
          ),
          if (selected)
            const Positioned(
              right: 1,
              top: 1,
              child: Icon(Icons.check_circle,
                  size: 14, color: Color(0xFF4CAF50)),
            ),
        ],
      ),
    );
  }
}
