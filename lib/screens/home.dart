import 'package:flutter/material.dart';
import '../global/activeuser.dart';
import '../global/allitems.dart';
import '../theme/foundhub_theme.dart';
import 'item_details.dart';
import 'report_item.dart';
class HomePage extends StatefulWidget {
  const HomePage({
    super.key
  });
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  String query = '', reportType = 'All', category = 'All';
    final categories =[
    'All',
    'Gadgets',
    'Identification Card',
    'Personal Belongings',
    'School Supplies',
    'Wearables',
    'Others'
  ];
  Future<void> go(String path) async {
    await Navigator.pushNamed(context, path);
    if(mounted) setState(() {
    });
  }
  Future<void> openReportForm(String type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportItemPage(initialReportType: type),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override Widget build(BuildContext context) {
    if(!ActiveUser.loggedIn) return const Scaffold(body: Center(child: Text('Please log in.')));
    final myEmail = ActiveUser.activeUser['email'];
    final myItems = AllItems.allItemsList.where((item) {
      return item['ownerEmail'] == myEmail;
    }).toList();

    // Claims are not item reports, so filter them from the shared claim list.
    // A student sees only requests they sent or requests about their own items.
    final claims = AllItems.allClaimsList.where((claim) {
      final itemId = claim['itemId'];
      final claimedItem = itemId is int ? AllItems.findItem(itemId) : null;
      final relatedItem = claim['selectedLostId'] is int
          ? AllItems.findItem(claim['selectedLostId'] as int)
          : null;

      final belongsToMe = claim['requesterEmail'] == myEmail ||
          claimedItem?['ownerEmail'] == myEmail ||
          relatedItem?['ownerEmail'] == myEmail;

      if (!belongsToMe) return false;
      if (category != 'All' && claimedItem?['category'] != category) {
        return false;
      }

      final searchText = query.trim().toLowerCase();
      if (searchText.isEmpty) return true;

      return [
        claimedItem?['keyItem'],
        claimedItem?['category'],
        claimedItem?['location'],
        claim['requesterName'],
        claim['requesterEmail'],
        claim['status'],
      ].any((value) =>
          '${value ?? ''}'.toLowerCase().contains(searchText));
    }).toList().reversed.toList();

    final items = myItems.where((item) {
        if(reportType!= 'All' && item[
        'reportType'
      ]!= reportType) return false;
        if(category!= 'All' && item[
        'category'
      ]!= category) return false;
      final q = query.trim().toLowerCase();
        return q.isEmpty ||[
        'keyItem',
        'itemBrand',
        'location',
        'description',
        'category'
      ].any((k) => '${item[k] ?? ' '}'.toLowerCase().contains(q));
      }).toList()..sort((a, b) =>(b[
      'id'
      ] as int).compareTo(a[
      'id'
    ] as int));
    return Scaffold(appBar: AppBar(title: const FoundHubBrand(height: 32),
      actions: [
      IconButton(tooltip: 'My reports', onPressed: () =>go('/my-reports'),
      icon: const Icon(Icons.assignment_outlined)),
      IconButton(tooltip: 'My profile', onPressed: () =>go('/profile'),
      icon: const Icon(Icons.account_circle_outlined))
    ]), bottomNavigationBar: SafeArea(child: Container(color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(children: [
      Expanded(child: TextButton.icon(onPressed: () =>setState(() {
        reportType= 'All';
        category= 'All';
        query= '';
      }), icon: const Icon(Icons.home_outlined), label: const Text('Home'))),
      Expanded(child: TextButton.icon(onPressed: () =>go('/report'),
      icon: const Icon(Icons.add_circle_outline), label: const Text('Report'))),
      Expanded(child: TextButton.icon(onPressed: () =>go('/my-reports'),
      icon: const Icon(Icons.inventory_2_outlined), label: const Text('My Reports')))
    ]))), body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 980),
    child: ListView(padding: const EdgeInsets.fromLTRB(16, 16,
      16, 26), children: [
        Row(children: [
        Expanded(child: _quickAction(Icons.search, 'Report Lost',
        () => openReportForm('Lost'))),
        const SizedBox(width: 10),
        Expanded(child: _quickAction(Icons.add_box_outlined, 'Report Found',
        () => openReportForm('Found'))),
      ]),
      const SizedBox(height: 20),
      Text('Welcome back, ${ActiveUser.activeUser['fname']}!',
      style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 4),
      const Text('Here’s what’s happening on FoundHub.', style: TextStyle(color: FoundHubTheme.muted)),
      const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _count('Lost Reports', myItems.where((i) =>i[
          'reportType'
          ] == 'Lost' &&i[
          'status'
        ] == 'Listed').length, Icons.search, FoundHubTheme.navy)),
        const SizedBox(width: 10),
          Expanded(child: _count('Found Reports', myItems.where((i) =>i[
          'reportType'
          ] == 'Found' &&i[
          'status'
        ] == 'Listed').length, Icons.inventory_2_outlined, const Color(0xFF1D856F)))
      ]),
      const SizedBox(height: 20),
      WebSection(title: 'Search My Reports', subtitle: 'Search your reports and related claims.',
        child: Column(children: [
        TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search),
        hintText: 'Search reports and claims'), onChanged: (v) =>setState(() =>query=v)),
        const SizedBox(height: 12),
          Row(children: [
          Expanded(child: DropdownButtonFormField<String>(value: reportType,
          isExpanded: true, decoration: const InputDecoration(labelText: 'Report Type'),
            items: [
            'All',
            'Lost',
            'Found',
            'Claims'
          ].map((v) =>DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) =>setState(() =>reportType=v!))),
          const SizedBox(width: 10),
          Expanded(child: DropdownButtonFormField<String>(value: category,
          isExpanded: true, decoration: const InputDecoration(labelText: 'Category'),
          items: categories.map((v) =>DropdownMenuItem(value: v, child: Text(v,
          overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) =>setState(() =>category=v!)))
        ]),
      ])),
      const SizedBox(height: 24),
        Row(children: [
        Expanded(
          child: Text(
            reportType == 'Claims' ? 'My Claims' : 'My Recent Reports',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Text(
          reportType == 'Claims'
              ? '${claims.length} claims'
              : '${items.length} items',
          style: const TextStyle(color: FoundHubTheme.muted),
        ),
      ]),
      const SizedBox(height: 12),
      if (reportType == 'Claims' && claims.isEmpty)
        WebSection(
          title: 'No matching claims',
          child: Text('No claims match your search or category filter.'),
        ),
      if (reportType == 'Claims')
        ...claims.map((claim) {
          final itemId = claim['itemId'];
          final claimedItem = itemId is int ? AllItems.findItem(itemId) : null;
          // Keep the global claim status unchanged; show the same student-facing
          // status as the related lost report.
          final claimStatus = '${claim['status'] ?? 'Pending Claim'}';
          final status = claimStatus == 'Pending Claim'
              ? 'Pending Request'
              : claimStatus;

          if (claimedItem == null) {
            return const SizedBox.shrink();
          }

          // For claims sent by this student, display their original lost
          // report rather than the found report they requested.
          final lostId = claim['selectedLostId'];
          final linkedLostItem = lostId is int
              ? AllItems.findItem(lostId)
              : null;
          final isMyClaim = claim['requesterEmail'] == myEmail;
          final displayItem = isMyClaim &&
                  linkedLostItem != null &&
                  linkedLostItem['reportType'] == 'Lost' &&
                  linkedLostItem['ownerEmail'] == myEmail
              ? linkedLostItem
              : claimedItem;

          final imageUrl = '${displayItem['photoUrl'] ?? ''}';
          final reportLabel = '${displayItem['reportType'] ?? 'Found'}';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemDetailsPage(
                      itemId: displayItem['id'] as int,
                    ),
                  ),
                );

                if (mounted) {
                  setState(() {});
                }
              },
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE6EAF0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 76,
                      height: 84,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F5F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: imageUrl.startsWith('http')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: FoundHubTheme.muted,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.inventory_2_outlined,
                              color: FoundHubTheme.muted,
                              size: 30,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${displayItem['keyItem'] ?? 'Item'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: FoundHubTheme.navy,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${displayItem['category'] ?? ''}',
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
                                  '${displayItem['location'] ?? ''}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: FoundHubTheme.muted,
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
                              color: status == 'Claimed'
                                  ? const Color(0xFFE0F5EC)
                                  : const Color(0xFFFFF1D6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$reportLabel · $status',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: status == 'Claimed'
                                    ? const Color(0xFF197255)
                                    : const Color(0xFF946000),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: FoundHubTheme.muted,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      if (reportType != 'Claims') ...[
      if(items.isEmpty) WebSection(title: 'No matching reports',
        child: Column(children: [
        Center(child: Image.asset('assets/kit.png', height: 80)),
        const SizedBox(height: 10),
        const Text('No reports match your search. Submit a report or change the filters.')
      ])),
      ...items.map((item) =>Padding(padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(borderRadius: BorderRadius.circular(14),
      onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) =>ItemDetailsPage(itemId: item[
          'id'
        ] as int)));
        if(mounted) setState(() {
        });
      }, child: Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white,
      borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE6EAF0))),
        child: Row(children: [
        Container(width: 76, height: 84, decoration: BoxDecoration(color: const Color(0xFFF3F5F7),
        borderRadius: BorderRadius.circular(10)), child: '${item['photoUrl'] ?? ' '}'.startsWith('http') ?ClipRRect(borderRadius: BorderRadius.circular(10),
        child: Image.network('${item['photoUrl']}', fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>const Icon(Icons.image_not_supported_outlined,
        color: FoundHubTheme.muted))): const Icon(Icons.inventory_2_outlined,
        color: FoundHubTheme.muted, size: 30)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text('${item['keyItem']}', style: const TextStyle(fontWeight: FontWeight.w800,
          fontSize: 16, color: FoundHubTheme.navy), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 5),
          Text('${item['category']}', style: const TextStyle(color: FoundHubTheme.muted,
          fontSize: 12)),
          const SizedBox(height: 5),
            Row(children: [
            const Icon(Icons.location_on_outlined, size: 14, color: FoundHubTheme.muted),
            const SizedBox(width: 3),
            Expanded(child: Text('${item['location']}', overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: FoundHubTheme.muted)))
          ]),
          const SizedBox(height: 7),
          Container(padding: const EdgeInsets.symmetric(horizontal: 9,
            vertical: 3), decoration: BoxDecoration(color: item[
            'reportType'
          ] == 'Lost' ?const Color(0xFFFFF1D6): const Color(0xFFE0F5EC),
          borderRadius: BorderRadius.circular(6)), child: Text(item['status'] == 'Listed'
              ? '${item['reportType']}'
              : '${item['reportType']} · ${item['status']}',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11,
            color: item[
            'reportType'
          ] == 'Lost' ?const Color(0xFF946000): const Color(0xFF197255))))
        ])),
        const Icon(Icons.chevron_right, color: FoundHubTheme.muted)
      ])))))
      ],
    ]))));
  }
  Widget _quickAction(IconData icon, String text, VoidCallback action) => OutlinedButton.icon(onPressed: action,
  icon: Icon(icon, size: 19), label: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
  style: OutlinedButton.styleFrom(backgroundColor: Colors.white,
  side: const BorderSide(color: FoundHubTheme.gold, width: 1.5),
  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 6)),
  );
  Widget _count(String label, int number, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE6EAF0),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Keep the original gold top accent separate from the rounded border.
          Container(
            height: 5,
            color: FoundHubTheme.gold,
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 26),
                const SizedBox(height: 9),
                Text(
                  '$number',
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    color: FoundHubTheme.navy,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: FoundHubTheme.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
