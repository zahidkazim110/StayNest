import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/hostel.dart';
import '../hostel_details/hostel_details_screen.dart';

class AIAssistantScreen extends StatefulWidget {
  final List<Hostel> hostels;
  const AIAssistantScreen({super.key, required this.hostels});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final controller = TextEditingController();
  final messages = <_ChatMessage>[
    const _ChatMessage(false, 'Hello! I can help you explore the sample hostels. Tell me your city, budget, room type or required facilities.'),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _send([String? suggestion]) {
    final question = (suggestion ?? controller.text).trim();
    if (question.isEmpty) return;
    controller.clear();
    final lower = question.toLowerCase();
    final budgetMatch = RegExp(r'(\d{4,6})').firstMatch(lower);
    final budget = budgetMatch == null ? null : int.tryParse(budgetMatch.group(1)!);
    final city = lower.contains('rawalpindi') ? 'Rawalpindi' : lower.contains('islamabad') ? 'Islamabad' : null;
    final room = ['single', 'double', 'shared'].where((item) => lower.contains(item)).firstOrNull;
    final matches = widget.hostels.where((hostel) {
      final cityOk = city == null || hostel.area.toLowerCase().contains(city.toLowerCase());
      final budgetOk = budget == null || hostel.monthlyRent <= budget;
      final roomOk = room == null || hostel.roomTypes.any((item) => item.toLowerCase() == room);
      return cityOk && budgetOk && roomOk;
    }).toList()..sort((a, b) => a.monthlyRent.compareTo(b.monthlyRent));

    String answer;
    if (lower.contains('hello') || lower.contains('hi')) {
      answer = 'Hi! Share your budget, preferred city and room type so I can filter the available sample listings.';
    } else if (lower.contains('compare')) {
      answer = 'Open Compare Hostels from the Home screen to compare rent, location, distance, room types and facilities side by side.';
    } else if (matches.isEmpty) {
      answer = 'I could not find a sample hostel matching all those details. Try increasing your budget or changing the city or room type.';
    } else {
      answer = 'I found ${matches.length} matching sample option(s). The lowest listed rent is PKR ${matches.first.monthlyRent} at ${matches.first.name}. These are local demo listings, not live availability.';
    }

    setState(() {
      messages.add(_ChatMessage(true, question));
      messages.add(_ChatMessage(false, answer, matches: matches.take(3).toList()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('StayNest AI Assistant', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
            child: const Row(children: [
              Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Expanded(child: Text('Demo assistant • Uses local sample hostel data, not a live AI service.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11))),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) => _bubble(messages[index]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            child: Wrap(
              spacing: 7,
              children: [
                ActionChip(label: const Text('Under PKR 18000'), onPressed: () => _send('Find hostels under 18000')),
                ActionChip(label: const Text('In Islamabad'), onPressed: () => _send('Find hostels in Islamabad')),
                ActionChip(label: const Text('Shared room'), onPressed: () => _send('Find a shared room')),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 5, 14, 12),
              child: Row(children: [
                Expanded(child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(hintText: 'Ask about hostels...', filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: AppColors.border))),
                )),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: _send, icon: const Icon(Icons.send_rounded), style: IconButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(_ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: message.isUser ? null : Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(message.text, style: TextStyle(color: message.isUser ? Colors.white : AppColors.textPrimary, fontSize: 13, height: 1.4)),
          if (message.matches.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...message.matches.map((hostel) => ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(hostel.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              subtitle: Text('PKR ${hostel.monthlyRent} • ${hostel.area}', style: const TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HostelDetailsScreen(hostel: hostel))),
            )),
          ],
        ]),
      ),
    );
  }
}

class _ChatMessage {
  final bool isUser;
  final String text;
  final List<Hostel> matches;
  const _ChatMessage(this.isUser, this.text, {this.matches = const []});
}
