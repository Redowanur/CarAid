import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/demo_data.dart';
import '../../models/booking.dart';
import '../../state/app_state.dart';
import '../../widgets/app_button.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.animateTo(
              _scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
            );
          }
        });

        final mechanic = appState.mechanic;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: AppColors.tealSoft,
                  child: Text(
                    initials(mechanic?.name ?? 'CM'),
                    style: AppText.label(
                      size: 11,
                      color: AppColors.tealDark,
                      weight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mechanic?.name ?? 'CarAid mechanic',
                        style: AppText.body(size: 14, weight: FontWeight.w700),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                color: AppColors.teal, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            mechanic?.isOnline == true
                                ? 'Online · usually replies fast'
                                : 'Offline',
                            style: AppText.body(
                                size: 10.5, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.phone_in_talk_outlined,
                    color: AppColors.teal),
                onPressed: () async {
                  final uri = Uri(scheme: 'tel', path: mechanic?.phone ?? '');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: appState.chat.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded,
                                size: 42, color: AppColors.faint),
                            const SizedBox(height: 12),
                            Text('No messages yet', style: AppText.h3()),
                            const SizedBox(height: 4),
                            Text(
                              'Say hello to your mechanic.',
                              style: AppText.body(
                                  size: 12, color: AppColors.muted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                        itemCount: appState.chat.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) return const _ChatIntro();
                          final message = appState.chat[index - 1];
                          return _Bubble(message: message);
                        },
                      ),
              ),
              const _QuickReplies(),
              _Composer(controller: _controller),
            ],
          ),
        );
      },
    );
  }
}

class _ChatIntro extends StatelessWidget {
  const _ChatIntro();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.border.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Secure chat · ${appState.requestId}',
          style: AppText.body(size: 10.5, color: AppColors.muted),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;

  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;
    final time = message.time;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: mine ? AppColors.teal : AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 18 : 5),
            bottomRight: Radius.circular(mine ? 5 : 18),
          ),
          border: mine ? null : Border.all(color: AppColors.border),
          boxShadow: mine ? null : AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: AppText.body(
                size: 13,
                color: mine ? AppColors.white : AppColors.ink,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}${mine ? ' · Seen' : ''}',
              style: AppText.body(
                size: 9.5,
                color: mine
                    ? AppColors.white.withOpacity(0.7)
                    : AppColors.faint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickReplies extends StatelessWidget {
  const _QuickReplies();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: chatQuickReplies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final reply = chatQuickReplies[index];
          return GestureDetector(
            onTap: () => appState.sendChat(reply),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                reply,
                style: AppText.body(size: 11.5, color: AppColors.muted),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;

  const _Composer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            CircleIconButton(
              icon: Icons.send_rounded,
              background: AppColors.teal,
              foreground: AppColors.white,
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }

  void _send() {
    appState.sendChat(controller.text);
    controller.clear();
  }
}
