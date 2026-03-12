import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/features/report/data/models/periodic_report_response.dart';
import 'package:edutool/features/report/presentation/bloc/report_bloc.dart';
import 'package:edutool/features/report/presentation/bloc/report_event.dart';
import 'package:edutool/features/report/presentation/bloc/report_state.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Admin Reports Screen
// ═══════════════════════════════════════════════════════════════════════════════

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    context.read<ReportBloc>().add(const ReportLoadAll(page: 0, size: 100));
  }

  Future<void> _onRefresh() async {
    _loadReports();
    await context.read<ReportBloc>().stream.firstWhere((s) => s is! ReportLoading);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportBloc, ReportState>(
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insert_chart_outlined, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('Chưa có báo cáo định kỳ nào', style: TextStyle(color: AppColors.textHint)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: state.reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final r = state.reports[index];
                return _ReportCard(report: r);
              },
            ),
          );
        }

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.textHint),
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
    );
  }
}

class _ReportCard extends StatelessWidget {
  final PeriodicReportResponse report;

  const _ReportCard({required this.report});

  void _showReportDetailBottomSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      report.courseName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  _StatusChip(status: report.status),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                report.description ?? 'Báo cáo #${report.reportId}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 16),
              _InfoRow(icon: Icons.code, label: 'Mã môn', value: report.courseCode),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.date_range,
                label: 'Kỳ báo cáo',
                value: '${_formatDate(report.reportFromDate)} – ${_formatDate(report.reportToDate)}',
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.schedule,
                label: 'Nộp từ',
                value: '${_formatDate(report.submitStartAt)} – ${_formatDate(report.submitEndAt)}',
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.description_outlined,
                label: 'Đã nộp',
                value: '${report.reportDetailCount} bài nộp',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Đóng'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showReportDetailBottomSheet(context, theme),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      report.courseName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  _StatusChip(status: report.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                report.description ?? 'Báo cáo #${report.reportId}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.date_range,
              label: 'Kỳ báo cáo',
              value: '${_formatDate(report.reportFromDate)} – ${_formatDate(report.reportToDate)}',
            ),
            const SizedBox(height: 6),
            _InfoRow(
              icon: Icons.schedule,
              label: 'Nộp từ',
              value: '${_formatDate(report.submitStartAt)} – ${_formatDate(report.submitEndAt)}',
            ),
          ],
        ),
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
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'ACTIVE':
        color = AppColors.success;
        break;
      case 'INACTIVE':
        color = AppColors.error;
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
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
