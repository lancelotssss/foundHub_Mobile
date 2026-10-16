import 'allitems.dart';

class ItemMatching {
  // Matches the React student similar-items rules using global arrays.
  static List<Map<String, dynamic>> similarFoundItems(
    Map<String, dynamic> lostItem,
  ) {
    final category = '${lostItem['category'] ?? ''}'.trim().toLowerCase();
    final name = '${lostItem['keyItem'] ?? ''}'.trim().toLowerCase();
    final location = '${lostItem['location'] ?? ''}'.trim().toLowerCase();
    final start = lostItem['startDate'];
    final end = lostItem['endDate'];

    final foundItems = AllItems.allItemsList.where((found) {
      if (found['reportType'] != 'Found' || found['status'] != 'Listed') {
        return false;
      }

      if (found['ownerEmail'] == lostItem['ownerEmail']) {
        return false;
      }

      if ('${found['category'] ?? ''}'.trim().toLowerCase() != category) {
        return false;
      }

      final foundName = '${found['keyItem'] ?? ''}'.toLowerCase();
      if (name.isNotEmpty && !foundName.contains(name)) {
        return false;
      }

      final foundLocation = '${found['location'] ?? ''}'.toLowerCase();
      if (location.isNotEmpty && !foundLocation.contains(location)) {
        return false;
      }

      final foundDate = found['dateFound'];
      if (start is DateTime && end is DateTime) {
        if (foundDate is! DateTime) {
          return false;
        }

        final firstDay = DateTime(start.year, start.month, start.day);
        final lastDay = DateTime(end.year, end.month, end.day);
        final day = DateTime(foundDate.year, foundDate.month, foundDate.day);
        if (day.isBefore(firstDay) || day.isAfter(lastDay)) {
          return false;
        }
      }

      return true;
    }).toList();

    foundItems.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    return foundItems;
  }
  // When a student finds an item, compare it against missing-item reports
  // created by other students. Found reporters can view these reports,
  // but claim requests are started by the student who lost the item.
  static List<Map<String, dynamic>> similarLostItems(
    Map<String, dynamic> reportedFoundItem,
  ) {
    final category = '${reportedFoundItem['category'] ?? ''}'.trim().toLowerCase();
    final name = '${reportedFoundItem['keyItem'] ?? ''}'.trim().toLowerCase();
    final location = '${reportedFoundItem['location'] ?? ''}'.trim().toLowerCase();
    final foundDate = reportedFoundItem['dateFound'];

    final results = AllItems.allItemsList.where((lost) {
      if (lost['reportType'] != 'Lost' || lost['status'] != 'Listed') {
        return false;
      }

      if (lost['ownerEmail'] == reportedFoundItem['ownerEmail']) {
        return false;
      }

      if ('${lost['category'] ?? ''}'.trim().toLowerCase() != category) {
        return false;
      }

      final lostName = '${lost['keyItem'] ?? ''}'.trim().toLowerCase();
      final lostLocation = '${lost['location'] ?? ''}'.trim().toLowerCase();

      if (name.isNotEmpty && !lostName.contains(name) && !name.contains(lostName)) {
        return false;
      }

      if (location.isNotEmpty &&
          !lostLocation.contains(location) &&
          !location.contains(lostLocation)) {
        return false;
      }

      final start = lost['startDate'];
      final end = lost['endDate'];

      if (foundDate is DateTime && start is DateTime && end is DateTime) {
        final day = DateTime(foundDate.year, foundDate.month, foundDate.day);
        final firstDay = DateTime(start.year, start.month, start.day);
        final lastDay = DateTime(end.year, end.month, end.day);

        if (day.isBefore(firstDay) || day.isAfter(lastDay)) {
          return false;
        }
      }

      return true;
    }).toList();

    results.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    return results;
  }
}
