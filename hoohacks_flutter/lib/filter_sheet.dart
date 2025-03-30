import 'package:flutter/material.dart';
import 'package:hoohacks/constant.dart';

class FilterSheet extends StatefulWidget {
  final List<String> categories;
  final ScrollController scrollController;
  final String distanceFilter;
  final bool bookMarked;
  final Function setDistanceFilter;
  final Function onFilterChanged;
  final Function setBookMarked;
  const FilterSheet({
    super.key,
    required this.scrollController,
    required this.categories,
    required this.bookMarked,
    required this.distanceFilter,
    required this.setDistanceFilter,
    required this.onFilterChanged,
    required this.setBookMarked,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String distanceFilter = "none";
  late bool bookMarked = false;

  @override
  void initState() {
    distanceFilter = widget.distanceFilter;
    bookMarked = widget.bookMarked;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 60,
              height: 7,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Text(
              'Distances',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          Divider(
            color: Colors.grey.withOpacity(0.5),
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          Padding(
            padding: middleWidgetPadding,
            child: Wrap(
              children: [
                for (final distance in distanceFilters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(distance),
                      selected: distanceFilter == distance,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            distanceFilter = distance;
                            widget.setDistanceFilter(distance);
                          } else {
                            distanceFilter = "none";
                            widget.setDistanceFilter("none");
                          }
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Text(
              'Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          Divider(
            color: Colors.grey.withOpacity(0.5),
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          Padding(
            padding: middleWidgetPadding,
            child: Wrap(
              children: [
                for (final category in categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: widget.categories.contains(category),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            widget.categories.add(category);
                          } else {
                            widget.categories.remove(category);
                          }
                          widget.onFilterChanged();
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey.withOpacity(0.5),
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Text(
                  'Bookmarked Only',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: Switch(
                  value: bookMarked,
                  onChanged: (value) {
                    setState(() {
                      bookMarked = value;
                      widget.setBookMarked(value);
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
