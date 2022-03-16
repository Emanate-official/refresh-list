import 'package:flutter/material.dart';

import 'package:refresh_list/src/components/index.dart';
import 'package:refresh_list/src/utilities/index.dart';

class CustomLoadingList extends StatefulWidget {
  const CustomLoadingList({
    required this.builder,
    required this.length,
    required this.loadingIndicator,
    required this.onLoad,
    required this.onRefresh,
    Key? key,
    this.bottomIndicatorOffset = 0,
    this.controller,
    this.displayBuilderContent = true,
    this.loadingIndicatorOffset = 0,
    this.refreshColor = Colors.white,
    this.refreshBackground = Colors.black87,
    this.sliverBars = const <Widget>[],
  }) : super(key: key);

  final Widget Function(int) builder;
  final double bottomIndicatorOffset;
  final ScrollController? controller;
  final bool displayBuilderContent;
  final int length;
  final SizedBox loadingIndicator;
  final double loadingIndicatorOffset;
  final FutureFunction onLoad;
  final FutureFunction onRefresh;
  final Color refreshColor;
  final Color refreshBackground;
  final List<Widget> sliverBars;

  @override
  _CustomLoadingListState createState() => _CustomLoadingListState();
}

class _CustomLoadingListState extends State<CustomLoadingList> {
  late ScrollController controller;

  bool isLoading = false;
  double position = 0;

  @override
  void initState() {
    controller = widget.controller ?? ScrollController();

    position = widget.loadingIndicator.height!;
    controller.addListener(scrollHandler);

    super.initState();
  }

  void scrollHandler() {
    if (controller.hasClients && mounted) {
      double diff = controller.offset - controller.position.maxScrollExtent;

      if (diff > 0 && !isLoading) {
        setState(() => position = widget.loadingIndicator.height! - diff);
      } else {
        setState(() => position = widget.loadingIndicator.height!);
      }
    }
  }

  Future<void> load() async {
    if (mounted) {
      setState(() => isLoading = true);

      await Future<dynamic>.delayed(const Duration(seconds: 1));
      await widget.onLoad();

      setState(() {
        position = widget.loadingIndicator.height!;
        isLoading = false;
      });
    }
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
                edgeOffset: widget.displayBuilderContent
                    ? widget.loadingIndicatorOffset
                    : -10000,
                // Disable refresh handling if builder content is disabled
                color: widget.displayBuilderContent
                    ? widget.refreshColor
                    : Colors.transparent,
                backgroundColor: widget.displayBuilderContent
                    ? widget.refreshBackground
                    : Colors.transparent,
                onRefresh: widget.displayBuilderContent
                    ? widget.onRefresh
                    : () async {},
                child: CustomScrollView(
                  physics: widget.length > 0
                      ? (widget.displayBuilderContent
                          ? const BouncingScrollPhysics()
                          : const ClampingScrollPhysics())
                      : const NeverScrollableScrollPhysics(),
                  controller: controller,
                  slivers: [
                    ...widget.sliverBars,
                    // Display the list items if list has length
                    if (widget.length > 0 && widget.displayBuilderContent)
                      ...List.generate(
                        widget.length,
                        (index) => SliverToBoxAdapter(
                          child: widget.builder(index),
                        ),
                      ),
                    // Display loading indicators if list is empty
                    if (widget.length <= 0 && widget.displayBuilderContent)
                      ...List.generate(
                        Calculate.skeletonCount(
                          constraints,
                          widget.loadingIndicator.height ?? 0,
                        ),
                        (index) => SliverToBoxAdapter(
                          child: widget.loadingIndicator,
                        ),
                      ),
                    // Add loading indicator to bottom of list if loading
                    if (isLoading && widget.displayBuilderContent)
                      SliverToBoxAdapter(
                        child: widget.loadingIndicator,
                      ),
                    // Padding for bottom indicator offset
                    if (widget.displayBuilderContent)
                      SliverToBoxAdapter(
                        child: SizedBox(height: widget.bottomIndicatorOffset),
                      ),
                  ],
                ),
              ),
              if (!isLoading &&
                  position < widget.loadingIndicator.height! &&
                  widget.displayBuilderContent)
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
