import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/features/report/data/models/periodic_report_response.dart';
import 'package:edutool/features/report/presentation/bloc/report_bloc.dart';
import 'package:edutool/features/report/presentation/bloc/report_event.dart';
import 'package:edutool/features/report/presentation/bloc/report_state.dart';

/// Student screen — lists active periodic-report submissions for a course.
///
/// UX rules (from user_flows_guide.md):
/// - Pull to Refresh via [RefreshIndicator]
/// - Empty State with icon + message (never blank)
/// - Snackbar for error feedback
class ReportListScreen extends StatefulWidget {
  final int courseId;

  const ReportListScreen({super.key, required this.courseId});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    context.read<ReportBloc>().add(ReportLoadActive(courseId: widget.courseId));
  }

  Future<void> _onRefresh() async {
    _loadReports();
    // Wait for the bloc to leave the Loading state.
    await context.read<ReportBloc>().stream.firstWhere(
      (s) => s is! ReportLoading,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo định kỳ')),
      body: BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state is ReportFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is ReportLoading || state is ReportInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReportLoaded) {
            if (state.reports.isEmpty) {
              return _EmptyState(onRefresh: _onRefresh);
            }
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: state.reports.length,
                itemBuilder: (context, index) =>
                    _ReportCard(report: state.reports[index]),
              ),
            );
          }

          // Failure fallback — retry UI.
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 12),
                Text(
                  state is ReportFailure ? state.message : 'Đã xảy ra lỗi',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _loadReports,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Private widgets
// ═══════════════════════════════════════════════════════════════════════════════

/// Empty state with icon + message per UX guide §3.2.
class _EmptyState extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          const Icon(
            Icons.assignment_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có đợt báo cáo nào cho môn học này',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Card for a single periodic report.
class _ReportCard extends StatelessWidget {
  final PeriodicReportResponse report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final submittable = report.isSubmittable;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title row ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    report.description ?? 'Báo cáo #${report.reportId}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _StatusChip(submittable: submittable),
              ],
            ),
            const SizedBox(height: 12),

            // ── Report period ──────────────────────────────────────
            _InfoRow(
              icon: Icons.date_range,
              label: 'Kỳ báo cáo',
              value:
                  '${_formatDate(report.reportFromDate)} – ${_formatDate(report.reportToDate)}',
            ),
            const SizedBox(height: 6),

            // ── Submission window ──────────────────────────────────
            _InfoRow(
              icon: Icons.schedule,
              label: 'Nộp từ',
              value:
                  '${_formatDate(report.submitStartAt)} – ${_formatDate(report.submitEndAt)}',
            ),
            const SizedBox(height: 6),

            // ── Submission count ───────────────────────────────────
            _InfoRow(
              icon: Icons.description_outlined,
              label: 'Đã nộp',
              value: '${report.reportDetailCount}',
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final h = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$d/$m/${dt.year} $h:$min';
    } catch (_) {
      return raw;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final bool submittable;

  const _StatusChip({required this.submittable});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: submittable
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.textHint.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        submittable ? 'Đang mở' : 'Đã đóng',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: submittable ? AppColors.success : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}
