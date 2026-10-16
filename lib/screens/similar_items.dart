import 'package:flutter/material.dart';

import '../global/allitems.dart';
import '../global/activeuser.dart';
import '../global/item_matching.dart';
import '../theme/foundhub_theme.dart';
import 'item_details.dart';

class SimilarItemsPage extends StatefulWidget {
  final int? lostItemId;
  final int? foundItemId;

  const SimilarItemsPage({
    super.key,
    this.lostItemId,
    this.foundItemId,
  });

  @override
  State<SimilarItemsPage> createState() => _SimilarItemsPageState();
}

class _SimilarItemsPageState extends State<SimilarItemsPage> {
  Future<void> openMatchedItem(int itemId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailsPage(
          itemId: itemId,
          lostItemId: widget.lostItemId,
          foundItemId: widget.foundItemId,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFoundFlow = widget.foundItemId != null;
    final reportId = widget.foundItemId ?? widget.lostItemId;
    final report = reportId == null ? null : AllItems.findItem(reportId);
    final expectedType = isFoundFlow ? 'Found' : 'Lost';

    if (report == null ||
        report['reportType'] != expectedType ||
        report['ownerEmail'] != ActiveUser.activeUser['email']) {
      return Scaffold(
        appBar: AppBar(title: Text(isFoundFlow ? 'Similar Missing Items' : 'Similar Found Items')),
        body: const Center(child: Text('Your report is not available.')),
      );
    }

    final matches = isFoundFlow
        ? ItemMatching.similarLostItems(report)
        : ItemMatching.similarFoundItems(report);

    return Scaffold(
      appBar: AppBar(title: Text(isFoundFlow ? 'Similar Missing Items' : 'Similar Found Items')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FoundHubBrand(height: 38),
          const SizedBox(height: 18),
          Text(
            'Matches for ${report['keyItem']}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            isFoundFlow
                ? 'These missing reports match your found item by category, '
                    'item name, location, and date. Open a report and select I found your item.'
                : 'These found reports match your lost item by category, '
                    'item name, location, and date. Open a match to request its return.',
          ),
          const SizedBox(height: 18),
          if (matches.isEmpty)
            WebSection(
              title: isFoundFlow
                  ? 'No similar missing items yet'
                  : 'No similar found items yet',
              child: Text(
                isFoundFlow
                    ? 'There are no matching missing reports right now. '
                      'You can check again later from My Reports.'
                    : 'There are no matching found reports right now. '
                      'You can check again later from My Reports.',
              ),
            ),
          for (final item in matches)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: item['photoUrl'] != null &&
                            '${item['photoUrl']}'.trim().isNotEmpty
                        ? Image.network(
                            '${item['photoUrl']}',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const ColoredBox(
                                color: Color(0xFFF0F3F7),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  color: FoundHubTheme.navy,
                                ),
                              );
                            },
                          )
                        : const ColoredBox(
                            color: Color(0xFFF0F3F7),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              color: FoundHubTheme.navy,
                            ),
                          ),
                  ),
                ),
                title: Text('${item['keyItem']}'),
                subtitle: Text(
                  '${item['category']} • ${item['location']}\n'
                  'Reported by ${item['ownerName']}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openMatchedItem(item['id'] as int),
              ),
            ),
        ],
      ),
    );
  }
}
