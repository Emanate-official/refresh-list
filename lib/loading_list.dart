library refresh_list;

import 'package:flutter/material.dart';

class RefreshList extends StatefulWidget {
  const RefreshList({
    required this.builder,
    required this.length,
    required this.loadingIndicator,
    required this.onLoad,
    required this.onRefresh,
    Key? key,
    this.refreshColor = Colors.white,
    this.refreshBackground = Colors.black87,
  }) : super(key: key);

  final Widget Function(int) builder;
  final int length;
  final SizedBox loadingIndicator;
  final FutureFunction onLoad;
  final FutureFunction onRefresh;
  final Color refreshColor;
  final Color refreshBackground;

  @override
  _RefreshListState createState() => _RefreshListState();
}

class _RefreshListState extends State<RefreshList> {
  final ScrollController _controller = ScrollController();

  bool isLoading = false;
  double position = 0;

  @override
  void initState() {
    super.initState();

    position = widget.loadingIndicator.height!;
    _controller.addListener(scrollHandler);
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
        if (widget.length > 0) {
          return Listener(
            onPointerUp: (_) {
              if (position <= 0) {
                load();
              }
            },
            child: Stack(
              children: <Widget>[
                RefreshIndicator(
                  color: widget.refreshColor,
                  backgroundColor: widget.refreshBackground,
                  onRefresh: widget.onRefresh,
                  child: RawScrollbar(
                    controller: _controller,
                    radius: const Radius.circular(20),
                    timeToFade: const Duration(milliseconds: 100),
                    mainAxisMargin: -40,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      controller: _controller,
                      physics: const BouncingScrollPhysics(),
                      itemCount: widget.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == widget.length) {
                          return Visibility(
                            visible: isLoading,
                            child: widget.loadingIndicator,
                          );
                        } else {
                          return widget.builder(index);
                        }
                      },
                    ),
                  ),
                ),
                if (!isLoading && position < widget.loadingIndicator.height!)
                  Container(
                    alignment: Alignment.bottomCenter,
                    margin: const EdgeInsets.only(right: 15),
                    child: widget.loadingIndicator,
                    transform: Matrix4.translationValues(0, position, 0),
                  ),
              ],
            ),
          );
        } else {
          return ListView.builder(
            itemCount:
                (constraints.maxHeight ~/ widget.loadingIndicator.height!) + 1,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (BuildContext context, int index) {
              return widget.loadingIndicator;
            },
          );
        }
      },
    );
  }
}

typedef FutureFunction = Future<void> Function();
