import 'package:flutter/material.dart';

import '../global/activeuser.dart';
import '../global/allitems.dart';
import 'similar_items.dart';

class ItemDetailsPage extends StatefulWidget {
  final int itemId;
  final int? lostItemId;
  final int? foundItemId;

  const ItemDetailsPage({
    super.key,
    required this.itemId,
    this.lostItemId,
    this.foundItemId,
  });

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  String formatDate(dynamic value) {
    if (value is! DateTime) {
      return 'Not specified';
    }

    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  Future<void> sendRequest(Map<String, dynamic> item) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return _ClaimRequestDialog(
          isFoundItem: item['reportType'] == 'Found',
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    final alreadyRequested = AllItems.allClaimsList.any((claim) {
      return claim['itemId'] == item['id'] &&
          claim['requesterEmail'] == ActiveUser.activeUser['email'] &&
          (claim['status'] == 'Pending Claim' ||
              claim['status'] == 'Claimed');
    });

    if (alreadyRequested) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You already have a pending request for this item.'),
        ),
      );
      return;
    }

    if (item['status'] != 'Listed') {
      return;
    }

    AllItems.allClaimsList.add({
      'id': AllItems.nextClaimId++,
      'itemId': item['id'],
      'selectedLostId': widget.lostItemId,
      'requesterEmail': ActiveUser.activeUser['email'],
      'requesterName': ActiveUser.activeUser['fullname'],
      'requesterPhone': ActiveUser.activeUser['phone'],
      'reason': result['reason'] ?? '',
      'photoUrl': result['photoUrl'] ?? '',
      'status': 'Pending Claim',
      'createdAt': DateTime.now(),
    });

    setState(() {
      item['claimStatus'] = 'Pending Claim';
      if (widget.lostItemId != null) {
        final lostItem = AllItems.findItem(widget.lostItemId!);
        if (lostItem != null) {
          lostItem['claimStatus'] = 'Pending Claim';
          lostItem['status'] = 'Pending Request';
        }
      }
    });

    // Return to Home after successfully submitting the claim request.
    // The claim is already saved in the global array before navigation.
    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  // A finder starts the request from a matching student's missing report.
  // The found item remains linked to the original lost report.
  void sendFoundItemRequest(
    Map<String, dynamic> lostItem,
    Map<String, dynamic> foundItem,
  ) {
    final finderEmail = ActiveUser.activeUser['email'];

    if (foundItem['ownerEmail'] != finderEmail ||
        foundItem['status'] != 'Listed' ||
        lostItem['reportType'] != 'Lost' ||
        lostItem['ownerEmail'] == finderEmail ||
        lostItem['status'] == 'Claimed') {
      return;
    }

    final existingRequest = AllItems.allClaimsList.any((claim) {
      return claim['itemId'] == foundItem['id'] &&
          claim['selectedLostId'] == lostItem['id'] &&
          claim['status'] == 'Pending Claim';
    });

    if (existingRequest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A request for this match is already pending.')),
      );
      return;
    }

    AllItems.allClaimsList.add({
      'id': AllItems.nextClaimId++,
      'itemId': foundItem['id'],
      'selectedLostId': lostItem['id'],
      'requesterEmail': lostItem['ownerEmail'],
      'requesterName': lostItem['ownerName'],
      'requesterPhone': lostItem['ownerPhone'],
      'initiatedByFinder': true,
      'finderEmail': finderEmail,
      'finderConfirmed': true,
      'claimantConfirmed': false,
      'reason': 'I found your item.',
      'photoUrl': foundItem['photoUrl'] ?? '',
      'status': 'Pending Claim',
      'createdAt': DateTime.now(),
    });

    foundItem['claimStatus'] = 'Pending Claim';
    lostItem['claimStatus'] = 'Pending Claim';
    lostItem['status'] = 'Pending Request';

    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  // A student may withdraw only their own pending request.
  void cancelRequest(Map<String, dynamic> item, Map<String, dynamic> request) {
    if (request['status'] != 'Pending Claim' ||
        request['requesterEmail'] != ActiveUser.activeUser['email']) {
      return;
    }

    setState(() {
      request['status'] = 'Cancelled';

      final hasOtherPending = AllItems.allClaimsList.any((claim) {
        return claim['itemId'] == item['id'] &&
            claim['status'] == 'Pending Claim';
      });
      item['claimStatus'] = hasOtherPending ? 'Pending Claim' : 'No Claim';

      final lostId = request['selectedLostId'];
      if (lostId is int) {
        final lostItem = AllItems.findItem(lostId);
        if (lostItem != null) {
          final hasPendingForLostItem = AllItems.allClaimsList.any((claim) {
            return claim['selectedLostId'] == lostId &&
                claim['status'] == 'Pending Claim';
          });
          lostItem['claimStatus'] = hasPendingForLostItem
              ? 'Pending Claim'
              : 'No Claim';
          if (lostItem['status'] != 'Claimed') {
            lostItem['status'] = hasPendingForLostItem
                ? 'Pending Request'
                : 'Listed';
          }
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Claim request cancelled.')),
    );
  }

  void declineRequest(Map<String, dynamic> request) {
    setState(() {
      request['status'] = 'Declined';
      final item = AllItems.findItem(request['itemId'] as int);
      if (item != null) {
        final hasPending = AllItems.allClaimsList.any((claim) =>
          claim['itemId'] == item['id'] && claim['status'] == 'Pending Claim');
        item['claimStatus'] = hasPending ? 'Pending Claim' : 'No Claim';
      }
      final lostId = request['selectedLostId'];
      if (lostId is int) {
        final lostItem = AllItems.findItem(lostId);
        if (lostItem != null && lostItem['status'] != 'Claimed') {
          final hasPendingForLost = AllItems.allClaimsList.any((claim) =>
              claim['selectedLostId'] == lostId &&
              claim['status'] == 'Pending Claim');
          lostItem['claimStatus'] = hasPendingForLost
              ? 'Pending Claim'
              : 'No Claim';
          lostItem['status'] = hasPendingForLost
              ? 'Pending Request'
              : 'Listed';
        }
      }
    });
  }

  // Both students confirm the handover before a claim is completed.
  void confirmHandover(
    Map<String, dynamic> item,
    Map<String, dynamic> request,
    List<Map<String, dynamic>> requests, {
    required bool isFinder,
  }) {
    if (request['status'] != 'Pending Claim') return;

    setState(() {
      if (isFinder) {
        request['finderConfirmed'] = true;
      } else {
        request['claimantConfirmed'] = true;
      }

      if (request['finderConfirmed'] == true &&
          request['claimantConfirmed'] == true) {
        request['status'] = 'Claimed';
        item['status'] = 'Claimed';
        item['claimStatus'] = 'Claimed';

        final lostId = request['selectedLostId'];
        if (lostId is int) {
          final lostItem = AllItems.findItem(lostId);
          if (lostItem != null) {
            lostItem['status'] = 'Claimed';
            lostItem['claimStatus'] = 'Claimed';
          }
        }

        for (final other in requests) {
          if (other['id'] != request['id'] &&
              other['status'] == 'Pending Claim') {
            other['status'] = 'Closed';
          }
        }
      }
    });
  }

  String requestLabel(Map<String, dynamic> request, {required bool isFinder}) {
    if (request['status'] == 'Claimed') return 'Completed';
    if (request['status'] == 'Pending Claim') {
      return isFinder ? 'Found Lost Item Request' : 'Claim Request';
    }
    return (request['status'] ?? 'Claim Request').toString();
  }

  Widget detailRow(String label, dynamic value) {
    final display = value == null || value.toString().trim().isEmpty
        ? 'Not specified'
        : value.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(display),
        ],
      ),
    );
  }

  Widget requestCard(
    Map<String, dynamic> request,
    Map<String, dynamic> item,
    List<Map<String, dynamic>> requests,
  ) {
    final canRespond = request['status'] == 'Pending Claim' &&
        item['status'] == 'Listed';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${request['requesterName'] ?? 'Student'} • ${requestLabel(request, isFinder: true)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Phone: ${request['requesterPhone'] ?? ''}"),
            Text("Reason: ${request['reason'] ?? ''}"),
            if ((request['photoUrl'] ?? '').toString().isNotEmpty)
              Text("Evidence URL: ${request['photoUrl']}"),
            if (canRespond)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () => declineRequest(request),
                    child: const Text('Decline'),
                  ),
                  FilledButton(
                    onPressed: request['finderConfirmed'] == true
                        ? null
                        : () => confirmHandover(
                              item, request, requests, isFinder: true),
                    child: Text(request['finderConfirmed'] == true
                        ? 'Waiting for claimant'
                        : 'I found this item'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = AllItems.findItem(widget.itemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Item not found.')),
      );
    }

    final mine = item['ownerEmail'] == ActiveUser.activeUser['email'];
    final lostReport = widget.lostItemId == null
        ? null
        : AllItems.findItem(widget.lostItemId!);
    final linkedFoundReport = widget.foundItemId == null
        ? null
        : AllItems.findItem(widget.foundItemId!);
    final canReportFoundMatch = !mine &&
        item['reportType'] == 'Lost' &&
        (item['status'] == 'Listed' || item['status'] == 'Pending Request') &&
        linkedFoundReport != null &&
        linkedFoundReport['reportType'] == 'Found' &&
        linkedFoundReport['ownerEmail'] == ActiveUser.activeUser['email'] &&
        linkedFoundReport['status'] == 'Listed';
    final hasActiveFoundMatch = AllItems.allClaimsList.any((claim) {
      return claim['itemId'] == linkedFoundReport?['id'] &&
          claim['selectedLostId'] == item['id'] &&
          claim['status'] == 'Pending Claim';
    });
    // New claims require a linked lost report. Existing pending claims can
    // still be cancelled when this page is reopened without lostItemId.
    final canSubmitClaim = !mine &&
        item['reportType'] == 'Found' &&
        item['status'] == 'Listed' &&
        lostReport != null &&
        lostReport['reportType'] == 'Lost' &&
        lostReport['ownerEmail'] == ActiveUser.activeUser['email'] &&
        (lostReport['status'] == 'Listed' ||
            lostReport['status'] == 'Pending Request');
    final requests = AllItems.allClaimsList.where((claim) {
      return claim['itemId'] == item['id'];
    }).toList();
    Map<String, dynamic>? myPendingRequest;
    for (final request in requests) {
      if (request['requesterEmail'] == ActiveUser.activeUser['email'] &&
          request['status'] == 'Pending Claim') {
        myPendingRequest = request;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Report Details')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Show the item photo above its name and report type.
          if ((item['photoUrl'] ?? '').toString().trim().isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                item['photoUrl'].toString().trim(),
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }

                  return Container(
                    height: 220,
                    color: const Color(0xFFEAF0F5),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 220,
                    color: const Color(0xFFEAF0F5),
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
          ],
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 6,
            children: [
              Text(
                (item['keyItem'] ?? 'Item').toString(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Chip(
                label: Text((item['reportType'] ?? 'Report').toString()),
                backgroundColor: item['reportType'] == 'Lost'
                    ? const Color(0xFFFFE8D9)
                    : const Color(0xFFDDF3E8),
                labelStyle: TextStyle(
                  color: item['reportType'] == 'Lost'
                      ? const Color(0xFF9B4500)
                      : const Color(0xFF17603B),
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide.none,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (item['claimStatus'] == 'Pending Claim' || item['status'] == 'Claimed')
          Chip(
            label: Text(item['status'] == 'Claimed'
                ? 'Completed'
                : (item['reportType'] == 'Found' && mine
                    ? 'Found Lost Item Request'
                    : 'Claim Request')),
            backgroundColor: item['claimStatus'] == 'Pending Claim'
                ? const Color(0xFFFFF0CC)
                : item['status'] == 'Claimed'
                    ? const Color(0xFFDDF3E8)
                    : const Color(0xFFEAF0F5),
            side: BorderSide.none,
          ),
          const SizedBox(height: 16),
          detailRow('Category', item['category']),
          detailRow('Brand', item['itemBrand']),
          detailRow('Location', item['location']),
          if (item['reportType'] == 'Lost') ...[
            detailRow('Start date', formatDate(item['startDate'])),
            detailRow('End date', formatDate(item['endDate'])),
          ] else
            detailRow('Date found', formatDate(item['dateFound'])),
          detailRow('Description', item['description']),
          detailRow('Reported by', item['ownerName']),
          const SizedBox(height: 14),
          // Students can check matches from their own reports at any time.
          // Lost reports lead to found items, where a return can be requested.
          // Found reports lead to missing items for identification.
          if (mine && (item['status'] == 'Listed' ||
              item['status'] == 'Pending Request')) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => item['reportType'] == 'Lost'
                          ? SimilarItemsPage(lostItemId: widget.itemId)
                          : SimilarItemsPage(foundItemId: widget.itemId),
                    ),
                  );

                  if (mounted) {
                    setState(() {});
                  }
                },
                icon: const Icon(Icons.search),
                label: const Text('See All Similar Items'),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (!mine && item['reportType'] == 'Found' &&
              myPendingRequest != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => cancelRequest(item, myPendingRequest!),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Request'),
              ),
            )
          else if (canSubmitClaim)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => sendRequest(item),
                icon: const Icon(Icons.handshake_outlined),
                label: const Text('Request to Get My Item Back'),
              ),
            ),
          if (canReportFoundMatch)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: hasActiveFoundMatch
                    ? null
                    : () => sendFoundItemRequest(item, linkedFoundReport!),
                icon: const Icon(Icons.volunteer_activism_outlined),
                label: Text(hasActiveFoundMatch
                    ? 'Waiting for the owner'
                    : 'I found your item'),
              ),
            ),
          // The claimant confirms the handover on their own lost report.
          if (mine && item['reportType'] == 'Lost')
            for (final claim in AllItems.allClaimsList.where((claim) =>
                claim['selectedLostId'] == item['id'] &&
                claim['requesterEmail'] == ActiveUser.activeUser['email'] &&
                claim['status'] == 'Pending Claim'))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: claim['claimantConfirmed'] == true
                        ? null
                        : () {
                            final foundItem = AllItems.findItem(claim['itemId'] as int);
                            if (foundItem != null) {
                              final related = AllItems.allClaimsList
                                  .where((entry) => entry['itemId'] == foundItem['id'])
                                  .toList();
                              confirmHandover(
                                foundItem, claim, related, isFinder: false);
                            }
                          },
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(claim['claimantConfirmed'] == true
                        ? 'Waiting for finder'
                        : 'This is my lost item'),
                  ),
                ),
              ),
          if (mine) ...[
            const Divider(),
            Text(
              'Student Requests',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (requests.isEmpty) const Text('No requests yet.'),
            for (final request in requests)
              requestCard(request, item, requests),
          ],
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}

// The dialog owns its controllers so they remain valid during exit animations.
class _ClaimRequestDialog extends StatefulWidget {
  final bool isFoundItem;

  const _ClaimRequestDialog({required this.isFoundItem});

  @override
  State<_ClaimRequestDialog> createState() => _ClaimRequestDialogState();
}

class _ClaimRequestDialogState extends State<_ClaimRequestDialog> {
  final formKey = GlobalKey<FormState>();
  String reason = '';
  String photoUrl = '';

  void submitRequest() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(context, {
      'reason': reason.trim(),
      'photoUrl': photoUrl.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isFoundItem ? 'Request to Claim' : 'I Found This Item',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                maxLines: 3,
                onChanged: (value) {
                  reason = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Reason / identifying details',
                  hintText: 'e.g., My initials are inside the wallet',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              TextFormField(
                onChanged: (value) {
                  photoUrl = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Evidence photo URL (optional)',
                  hintText: 'https://example.com/proof.jpg',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: submitRequest,
          child: const Text('Send Request'),
        ),
      ],
    );
  }
}
