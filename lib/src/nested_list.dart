import 'package:flutter/material.dart';

import 'package:refresh_list/src/components/index.dart';
import 'package:refresh_list/src/utilities/index.dart';

class NestedLoadingList extends StatefulWidget {
  const NestedLoadingList({
    required this.builder,
    required this.length,
    required this.loadingIndicator,
    required this.onLoad,
    required this.onRefresh,
    Key? key,
    this.bottomIndicatorOffset = 0,
    this.loadingIndicatorOffset = 0,
    this.refreshColor = Colors.white,
    this.refreshBackground = Colors.black87,
    this.sliverBars = const <Widget>[],
  }) : super(key: key);

  final Widget Function(BuildContext, int) builder;
  final int length;
  final SizedBox loadingIndicator;
  final double bottomIndicatorOffset;
  final double loadingIndicatorOffset;
  final FutureFunction onLoad;
  final FutureFunction onRefresh;
  final Color refreshColor;
  final Color refreshBackground;
  final List<Widget> sliverBars;

  @override
  _NestedLoadingListState createState() => _NestedLoadingListState();
}

class _NestedLoadingListState extends State<NestedLoadingList> {
  ScrollController? controller;

  bool isLoading = false;
  double position = 0;

  @override
  void initState() {
    position = widget.loadingIndicator.height!;
    super.initState();
  }

  void innerScrollHandler() {
    if (controller?.hasClients ?? false) {
      double diff = controller!.offset - controller!.position.maxScrollExtent;

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
              NestedScrollView(
                headerSliverBuilder: (
                  BuildContext context,
                  bool innerBoxIsScrolled,
                ) {
                  return <Widget>[
                    ...widget.sliverBars,
                  ];
                },
                body: Builder(
                  builder: (BuildContext context) {
                    if (controller == null) {
                      controller = PrimaryScrollController.of(context);
                      controller!.addListener(innerScrollHandler);
                    }

                    final int loadingCount = Calculate.skeletonCount(
                      constraints,
                      widget.loadingIndicator.height ?? 0,
                    );

                    return RefreshIndicator(
                      edgeOffset: widget.loadingIndicatorOffset,
                      color: widget.refreshColor,
                      backgroundColor: widget.refreshBackground,
                      onRefresh: widget.onRefresh,
                      child: ListView.builder(
                        primary: widget.length > 0,
                        physics: widget.length > 0
                            ? const BouncingScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(0),
                        itemCount: widget.length > 0
                            ? widget.length + 2
                            : loadingCount,
                        itemBuilder: (BuildContext context, int index) {
                          if (widget.length > 0) {
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
                          } else {
                            return widget.loadingIndicator;
                          }
                        },
                      ),
                    );
                  },
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
      },
    );
  }
}
