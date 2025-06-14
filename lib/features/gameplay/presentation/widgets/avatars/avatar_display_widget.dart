// file: lib/features/gameplay/presentation/widgets/avatars/avatar_display_widget.dart

// Flutter package imports
import 'package:flutter/material.dart';

// Project imports
import 'package:neural_break/features/gameplay/presentation/components/ui_manager.dart';

class AvatarDisplayWidget extends StatefulWidget {
  final UIManager uiManager;
  final double avatarSize;
  const AvatarDisplayWidget(
      {super.key, required this.uiManager, this.avatarSize = 150});

  @override
  AvatarDisplayWidgetState createState() => AvatarDisplayWidgetState();
}

class AvatarDisplayWidgetState extends State<AvatarDisplayWidget> {
  late final UIManager uiManager;

  @override
  void initState() {
    super.initState();
    uiManager = widget.uiManager;
    uiManager.controller.addListener(_onPoseChanged);
  }

  @override
  void dispose() {
    uiManager.controller.removeListener(_onPoseChanged);
    super.dispose();
  }

  void _onPoseChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.uiManager.buildAvatar(widget.avatarSize);
  }
}
