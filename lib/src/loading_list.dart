import 'package:flutter/material.dart';

import 'package:refresh_list/src/components/index.dart';
import 'package:refresh_list/src/utilities/index.dart';

class RefreshList extends StatefulWidget {
  const RefreshList({
    required this.builder,
    required this.length,
    required this.loadingIndicator,
    required this.onLoad,
    required this.onRefresh,
    Key? key,
    this.bottomIndicatorOffset = 0,
    this.refreshColor = Colors.white,
    this.refreshBackground = Colors.black87,
    this.physics = const BouncingScrollPhysics(),
  }) : super(key: key);

  final Widget Function(BuildContext, int) builder;
  final int length;
  final SizedBox loadingIndicator;
  final FutureFunction onLoad;
  final FutureFunction onRefresh;
  final double bottomIndicatorOffset;
  final Color refreshColor;
  final Color refreshBackground;
  final ScrollPhysics physics;

  @override
  _RefreshListState createState() => _RefreshListState();
}

class _RefreshListState extends State<RefreshList> {
  final ScrollController controller = ScrollController();

  bool isLoading = false;
  double position = 0;

  @override
  void initState() {
    super.initState();

    position = widget.loadingIndicator.height!;
    controller.addListener(scrollHandler);
  }

  void scrollHandler() {
    if (controller.hasClients) {
      double diff = controller.offset - controller.position.maxScrollExtent;

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
    controller.removeListener(scrollHandler);
    controller.dispose();

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
                    controller: controller,
                    radius: const Radius.circular(20),
                    timeToFade: const Duration(milliseconds: 100),
                    mainAxisMargin: -40,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      controller: controller,
                      physics: widget.physics,
                      itemCount: widget.length + 2,
                      itemBuilder: (BuildContext context, int index) {
                        if (index > widget.length) {
                          return SizedBox(
                            height: widget.bottomIndicatorOffset,
                          );
                        } else if (index == widget.length) {
                          return Visibility(
                            visible: isLoading,
                            child: widget.loadingIndicator,
                          );
                        } else {
                          return widget.builder(context, index);
                        }
                      },
                    ),
                  ),
                ),
                if (!isLoading && position < widget.loadingIndicator.height!)
                  BottomIndicator(
                    bottomIndicatorOffset: widget.bottomIndicatorOffset,
                    loadingIndicator: widget.loadingIndicator,
                    position: position,
                  ),
              ],
            ),
          );
        } else {
          return ListView.builder(
            itemCount: Calculate.skeletonCount(
              constraints,
              widget.loadingIndicator.height ?? 0,
            ),
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
