import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../providers/exam_provider.dart';

class ExamTakeScreen extends StatefulWidget {
  final String examId;
  const ExamTakeScreen({super.key, required this.examId});
  @override
  State<ExamTakeScreen> createState() => _ExamTakeScreenState();
}

class _ExamTakeScreenState extends State<ExamTakeScreen> {
  Timer? _timer;
  @override
  void initState() { super.initState(); _startExam(); }
  Future<void> _startExam() async {
    final success = await context.read<ExamProvider>().startExam(widget.examId);
    if (success) _startTimer();
  }
  void _startTimer() { _timer = Timer.periodic(const Duration(seconds: 1), (_) {
    final p = context.read<ExamProvider>();
    if (p.remainingTime > 0) p.updateRemainingTime(p.remainingTime - 1);
    else _submit();
  }); }
  Future<void> _submit() async {
    _timer?.cancel();
    final attempt = await context.read<ExamProvider>().submitExam();
    if (attempt != null && mounted) context.pushReplacement('/exam/${widget.examId}/result', extra: attempt.id.toString());
  }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      final c = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
        title: const Text('Leave Exam?'), content: const Text('Progress will be lost.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Leave'))],
      ));
      if (c == true) context.read<ExamProvider>().resetExam();
      return c ?? false;
    },
    child: Scaffold(
      appBar: AppBar(title: Consumer<ExamProvider>(builder: (_, p, __) {
        final m = p.remainingTime ~/ 60, s = p.remainingTime % 60;
        return Text('${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}');
      }), actions: [TextButton(onPressed: _submit, child: const Text('Submit'))]),
      body: Consumer<ExamProvider>(builder: (_, p, __) {
        final q = p.currentExam?.questions?[p.currentQuestionIndex];
        if (q == null) return const Center(child: CircularProgressIndicator());
        return Column(children: [
          LinearProgressIndicator(value: (p.currentQuestionIndex + 1) / (p.currentExam?.questions?.length ?? 1)),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Q${p.currentQuestionIndex + 1}', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text(q.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),
            ...q.answers.map((a) => Card(
              color: p.selectedAnswers[q.id] == a.id ? AppColors.primary.withOpacity(0.1) : null,
              child: ListTile(leading: Radio<int>(value: a.id, groupValue: p.selectedAnswers[q.id], onChanged: (v) => p.selectAnswer(q.id, v!)), title: Text(a.answer), onTap: () => p.selectAnswer(q.id, a.id)),
            )),
          ]))),
          Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            if (p.currentQuestionIndex > 0) Expanded(child: OutlinedButton(onPressed: p.previousQuestion, child: const Text('Previous'))),
            if (p.currentQuestionIndex > 0) const SizedBox(width: 12),
            Expanded(child: ElevatedButton(onPressed: p.currentQuestionIndex >= (p.currentExam?.questions?.length ?? 1) - 1 ? _submit : p.nextQuestion, child: Text(p.currentQuestionIndex >= (p.currentExam?.questions?.length ?? 1) - 1 ? 'Submit' : 'Next'))),
          ])),
        ]);
      }),
    ),
  );
}
