import 'dart:convert';

import 'package:android/dto/find_dto.dart';
import 'package:android/exception/illegal_state_exception.dart';
import 'package:android/synchronization/server_driver.dart';

/// Class used to sequentially download all data from the server resource that
/// supports pagination and returning ids of all items.
class PageDownloader {
  /// All the items that have not yet been downloaded. Intialized after first
  /// nextPage() call.
  List<dynamic> missingItemsIds;

  final ServerClient _client;
  final String _baseUri;
  final int _pageSize;

  int _totalPages;
  int _currentPage = -1;

  PageDownloader(this._client, this._baseUri, this._pageSize);

  bool hasNextPage() {
    return _totalPages == null || _currentPage < _totalPages;
  }

  Future<List<dynamic>> nextPage() async {
    if (missingItemsIds == null) {
      await _init();
    }
    if (!hasNextPage()) {
      throw IllegalStateException('There is no next page.');
    }
    _currentPage++;

    var response = FindDto.fromJson(
      jsonDecode(
        (await _client
                .get(this._baseUri + '?page=$_currentPage&size=$_pageSize'))
            .body,
      ),
    );

    _totalPages = response.totalPages;
    response.content.forEach((item) => missingItemsIds.remove(item['id']));
    return response.content;
  }

  Future<Null> _init() async {
    var response = await this._client.get(this._baseUri + '/ids');
    this.missingItemsIds = jsonDecode(response.body);
  }
}
