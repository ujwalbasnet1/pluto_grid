import 'package:pluto_grid/pluto_grid.dart';

abstract class IPaginationRowState {
  int get page;

  int get pageSize;

  int get totalPage;

  bool get isPaginated;

  void setPageSize(int pageSize, {bool notify = true});

  void setPage(
    int page, {
    bool resetCurrentState = true,
    bool notify = true,
  });

  void resetPage({
    bool resetCurrentState = true,
    bool notify = true,
  });
}

mixin PaginationRowState implements IPlutoGridState {
  static int defaultPageSize = 40;

  int _pageSize = defaultPageSize;

  int _page = 1;

  final FilteredListRange _range = FilteredListRange(0, defaultPageSize);

  Iterable<PlutoRow> get _rowsToPaginate {
    return hasRowGroups
        ? refRows.filterOrOriginalList.where(isRootGroupedRow)
        : refRows.filterOrOriginalList;
  }

  int get _length => _rowsToPaginate.length;

  int get _adjustPage {
    if (page > totalPage) {
      return totalPage;
    }

    if (page < 1 && totalPage > 0) {
      return 1;
    }

    return page;
  }

  @override
  int get page => _page;

  @override
  int get pageSize => _pageSize;

  @override
  int get totalPage => (_length / _pageSize).ceil();

  @override
  bool get isPaginated => refRows.hasRange;

  @override
  void setPageSize(int pageSize, {bool notify = true}) {
    _pageSize = pageSize;

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void setPage(
    int page, {
    bool resetCurrentState = true,
    bool notify = true,
  }) {
    _page = page;

    int from = (page - 1) * _pageSize;

    if (from < 0) {
      from = 0;
    }

    int to = page * _pageSize;

    if (to > _length) {
      to = _length;
    }

    if (hasRowGroups) {
      PlutoRow lastRow(PlutoRow row) {
        return isExpandedGroupedRow(row)
            ? lastRow(row.type.group.children.filterOrOriginalList.last)
            : row;
      }

      if (_rowsToPaginate.isEmpty) {
        from = 0;
        to = 0;
      } else {
        var fromRow = _rowsToPaginate.elementAt(from);

        var toRow = lastRow(_rowsToPaginate.elementAt(to - 1));

        from = refRows.filterOrOriginalList.indexOf(fromRow);

        to = refRows.filterOrOriginalList.indexOf(toRow) + 1;
      }
    }

    _range.setRange(from, to);

    refRows.setFilterRange(_range);

    if (resetCurrentState) {
      clearCurrentCell(notify: false);

      clearCurrentSelecting(notify: false);
    }

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void resetPage({
    bool resetCurrentState = true,
    bool notify = true,
  }) {
    setPage(
      _adjustPage,
      resetCurrentState: resetCurrentState,
      notify: notify,
    );
  }
}
