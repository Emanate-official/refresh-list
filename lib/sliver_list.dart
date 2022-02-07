library refresh_list;

import 'package:flutter/material.dart';

class SliverLoadingList extends StatefulWidget {
  const SliverLoadingList({
    required this.builder,
    required this.length,
    required this.loadingIndicator,
    required this.onLoad,
    required this.onRefresh,
    Key? key,
    this.loadingIndicatorOffset = 0,
    this.refreshColor = Colors.white,
    this.refreshBackground = Colors.black87,
    this.sliverBars = const <Widget>[],
  }) : super(key: key);

  final Widget Function(int) builder;
  final int length;
  final SizedBox loadingIndicator;
  final double loadingIndicatorOffset;
  final FutureFunction onLoad;
  final FutureFunction onRefresh;
  final Color refreshColor;
  final Color refreshBackground;
  final List<Widget> sliverBars;

  @override
  _SliverLoadingListState createState() => _SliverLoadingListState();
}

class _SliverLoadingListState extends State<SliverLoadingList> {
  final ScrollController _controller = ScrollController();

  bool isLoading = false;
  double position = 0;

  @override
  void initState() {
    position = widget.loadingIndicator.height!;
    _controller.addListener(scrollHandler);

    super.initState();
  }

  void scrollHandler() {
    if (_controller.hasClients) {
      double diff = _controller.offset - _controller.position.maxScrollExtent;

      if (diff > 0 && !isLoading) {
        setState(() => position = widget.loadingIndicator.height! - diff);
      } else {
        setState(() => position = widget.loadingIndicator.height!);
      }
    }
  }

  Future<void> load() async {
    setState(() => isLoading = true);

    await Future<dynamic>.delayed(const Duration(seconds: 1));
    await widget.onLoad();

    setState(() {
      position = widget.loadingIndicator.height!;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(scrollHandler);
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Listener(
          onPointerUp: (_) {
            if (position <= 0) {
              load();
            }
          },
          child: Stack(
            children: <Widget>[
              RefreshIndicator(
                edgeOffset: widget.loadingIndicatorOffset,
                color: widget.refreshColor,
                backgroundColor: widget.refreshBackground,
                onRefresh: widget.onRefresh,
                child: RawScrollbar(
                  controller: _controller,
                  radius: const Radius.circular(20),
                  timeToFade: const Duration(milliseconds: 100),
                  mainAxisMargin: -40,
                  child: CustomScrollView(
                    physics: widget.length > 0
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    controller: _controller,
                    slivers: [
                      ...widget.sliverBars,
                      // Display the list items if list has length
                      if (widget.length > 0)
                        ...List.generate(
                          widget.length,
                          (index) => widget.builder(index),
                        ),
                      // Display loading indicators if list is empty
                      if (widget.length <= 0)
                        ...List.generate(
                          (constraints.maxHeight ~/
                                  widget.loadingIndicator.height!) +
                              1,
                          (index) => SliverToBoxAdapter(
                            child: widget.loadingIndicator,
                          ),
                        ),
                      // Add loading indicator to bottom of list if loading
                      if (isLoading)
                        SliverToBoxAdapter(
                          child: widget.loadingIndicator,
                        ),
                    ],
                  ),
                ),
              ),
              if (!isLoading && position < widget.loadingIndicator.height!)
                Container(
                  alignment: Alignment.bottomCenter,
                  child: widget.loadingIndicator,
                  transform: Matrix4.translationValues(0, position, 0),
                ),
            ],
          ),
        );
      },
    );
  }
}

typedef FutureFunction = Future<void> Function();
