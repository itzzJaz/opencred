import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'models.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {this.subtitle, super.key});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle!, style: TextStyle(color: Colors.grey[600]))],
    ]),
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {this.color = OpenCredTheme.blue, super.key});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(color: color.withOpacity(.10), borderRadius: BorderRadius.circular(18)),
    child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
  );
}

class ApplicantAvatar extends StatelessWidget {
  const ApplicantAvatar({required this.applicant, this.size = 52, super.key});
  final Applicant applicant;
  final double size;
  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: size / 2,
    backgroundColor: OpenCredTheme.ink,
    child: ClipOval(
      child: Image.asset(
        applicant.avatarAsset,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    ),
  );
}

class Disclosure extends StatelessWidget {
  const Disclosure({required this.title, required this.body, this.icon = Icons.info_outline, super.key});
  final String title;
  final String body;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: OpenCredTheme.sand.withOpacity(.65), borderRadius: BorderRadius.circular(20)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: OpenCredTheme.blue, size: 20), const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 4),
        Text(body, style: TextStyle(color: Colors.grey[700], height: 1.35)),
      ])),
    ]),
  );
}
