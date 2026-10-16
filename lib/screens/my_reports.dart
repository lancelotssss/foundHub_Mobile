import 'package:flutter/material.dart';

import '../global/activeuser.dart';
import '../global/allitems.dart';
import '../theme/foundhub_theme.dart';
import 'item_details.dart';
import 'report_item.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  String get myEmail => (ActiveUser.activeUser['email'] ?? '').toString();

  bool isCompleted(Map<String, dynamic> item) {
    return item['status'] == 'Claimed' ||
        item['claimStatus'] == 'Claimed' ||
        item['status'] == 'Completed';
  }

  String reportStatus(Map<String, dynamic> item) {
    if (isCompleted(item)) return 'Completed';

    final pending = AllItems.allClaimsList.any((claim) {
      return claim['status'] == 'Pending Claim' &&
          (claim['itemId'] == item['id'] ||
              claim['selectedLostId'] == item['id']);
    });

    if (pending) {
      return item['reportType'] == 'Found'
          ? 'Found Lost Item Request'
          : 'Claim Request';
    }
    return '';
  }

  Future<void> openItem(Map<String, dynamic> item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailsPage(itemId: item['id'] as int),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> editItem(Map<String, dynamic> item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportItemPage(editId: item['id'] as int),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> deleteItem(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete report?'),
        content: const Text('This will remove the report and related requests.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() {
      AllItems.allItemsList.removeWhere((report) => report['id'] == item['id']);
      AllItems.allClaimsList.removeWhere((claim) {
        return claim['itemId'] == item['id'] ||
            claim['selectedLostId'] == item['id'];
      });
    });
  }

  Widget reportCard(Map<String, dynamic> item) {
    final isLost = item['reportType'] == 'Lost';
    final status = reportStatus(item);
    final photoUrl = (item['photoUrl'] ?? '').toString().trim();
    final canModify = item['status'] == 'Listed' && status.isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => openItem(item),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE6EAF0)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 76,
                    height: 84,
                    child: photoUrl.startsWith('http')
                        ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_not_supported_outlined,
                              color: FoundHubTheme.muted,
                            ),
                          )
                        : const ColoredBox(
                            color: Color(0xFFF3F5F7),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              color: FoundHubTheme.muted,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (item['keyItem'] ?? 'Item').toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: FoundHubTheme.navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        (item['category'] ?? '').toString(),
                        style: const TextStyle(
                          color: FoundHubTheme.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: FoundHubTheme.muted,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              (item['location'] ?? '').toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: FoundHubTheme.muted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: status == 'Completed'
                              ? const Color(0xFFDDF3E8)
                              : status.isNotEmpty
                                  ? const Color(0xFFFFF1D6)
                                  : isLost
                                      ? const Color(0xFFFFF1D6)
                                      : const Color(0xFFE0F5EC),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status.isEmpty
                              ? (item['reportType'] ?? '').toString()
                              : '${item['reportType']} · $status',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: status == 'Completed'
                                ? const Color(0xFF197255)
                                : status.isNotEmpty || isLost
                                    ? const Color(0xFF946000)
                                    : const Color(0xFF197255),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (canModify)
                  PopupMenuButton<String>(
                    tooltip: 'Report actions',
                    onSelected: (action) {
                      if (action == 'details') openItem(item);
                      if (action == 'edit') editItem(item);
                      if (action == 'delete') deleteItem(item);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'details', child: Text('View Details')),
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  )
                else
                  const Icon(Icons.chevron_right, color: FoundHubTheme.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget reportSection(String title, List<Map<String, dynamic>> reports) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            Text(
              '${reports.length} items',
              style: const TextStyle(color: FoundHubTheme.muted),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (reports.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'No $title yet.',
              style: const TextStyle(color: FoundHubTheme.muted),
            ),
          ),
        for (final report in reports) reportCard(report),
        const SizedBox(height: 12),
      ],
    );
  }

  String claimLabel(Map<String, dynamic> claim, bool received) {
    if (claim['status'] == 'Claimed') return 'Completed';
    if (claim['status'] == 'Pending Claim') {
      return received ? 'Found Lost Item Request' : 'Claim Request';
    }
    return (claim['status'] ?? 'Unknown').toString();
  }

  void cancelClaim(Map<String, dynamic> claim) {
    if (claim['status'] != 'Pending Claim' ||
        claim['requesterEmail'] != myEmail) return;

    setState(() {
      claim['status'] = 'Cancelled';
      final foundItem = claim['itemId'] is int
          ? AllItems.findItem(claim['itemId'] as int)
          : null;
      final lostItem = claim['selectedLostId'] is int
          ? AllItems.findItem(claim['selectedLostId'] as int)
          : null;

      if (foundItem != null) {
        final stillPending = AllItems.allClaimsList.any((request) {
          return request['itemId'] == foundItem['id'] &&
              request['status'] == 'Pending Claim';
        });
        foundItem['claimStatus'] = stillPending ? 'Pending Claim' : 'No Claim';
      }
      if (lostItem != null && lostItem['status'] != 'Claimed') {
        final stillPending = AllItems.allClaimsList.any((request) {
          return request['selectedLostId'] == lostItem['id'] &&
              request['status'] == 'Pending Claim';
        });
        lostItem['claimStatus'] = stillPending ? 'Pending Claim' : 'No Claim';
        lostItem['status'] = stillPending ? 'Pending Request' : 'Listed';
      }
    });
  }

  Widget claimSection(String title, List<Map<String, dynamic>> claims, bool received) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        if (claims.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text('No requests yet.'),
          ),
        for (final claim in claims) ...[
          Builder(builder: (context) {
            final foundItem = claim['itemId'] is int
                ? AllItems.findItem(claim['itemId'] as int)
                : null;
            final lostItem = claim['selectedLostId'] is int
                ? AllItems.findItem(claim['selectedLostId'] as int)
                : null;
            final displayedItem = received ? foundItem : (lostItem ?? foundItem);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  title: Text((displayedItem?['keyItem'] ?? 'Removed item').toString()),
                  subtitle: Text(
                    '${claimLabel(claim, received)}\n'
                    '${received ? 'Requested by' : 'Request sent to'}: '
                    '${received ? claim['requesterName'] ?? 'Student' : foundItem?['ownerName'] ?? 'Student'}',
                  ),
                  isThreeLine: true,
                  onTap: foundItem == null
                      ? null
                      : () => openItem(foundItem),
                  trailing: !received && claim['status'] == 'Pending Claim'
                      ? TextButton(
                          onPressed: () => cancelClaim(claim),
                          child: const Text('Cancel'),
                        )
                      : const Icon(Icons.chevron_right),
                ),
              ),
            );
          }),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mine = AllItems.allItemsList.where((item) {
      return item['ownerEmail'] == myEmail;
    }).toList();

    mine.sort((a, b) {
      final aDate = a['createdAt'];
      final bDate = b['createdAt'];
      if (aDate is DateTime && bDate is DateTime) {
        return bDate.compareTo(aDate);
      }
      return (b['id'] as int).compareTo(a['id'] as int);
    });

    final lostReports = mine.where((item) {
      return item['reportType'] == 'Lost' && !isCompleted(item);
    }).toList();
    final foundReports = mine.where((item) {
      return item['reportType'] == 'Found' && !isCompleted(item);
    }).toList();
    final claimedReports = mine.where(isCompleted).toList();

    final sentClaims = AllItems.allClaimsList.where((claim) {
      return claim['requesterEmail'] == myEmail;
    }).toList().reversed.toList();
    final receivedClaims = AllItems.allClaimsList.where((claim) {
      if (claim['itemId'] is! int) return false;
      return AllItems.findItem(claim['itemId'] as int)?['ownerEmail'] == myEmail;
    }).toList().reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Reports & Requests')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          reportSection('Found', foundReports),
          reportSection('Lost', lostReports),
          reportSection('Claimed', claimedReports),
          const Divider(height: 28),
          claimSection('Claim Requests I Sent', sentClaims, false),
          claimSection('Claim Requests I Received', receivedClaims, true),
        ],
      ),
    );
  }
}
