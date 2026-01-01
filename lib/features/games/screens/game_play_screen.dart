import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../providers/games_provider.dart';

class GamePlayScreen extends StatefulWidget {
  final String gameId;
  const GamePlayScreen({super.key, required this.gameId});
  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  int _currentQuestion = 0, _score = 0, _correct = 0, _timeLeft = 30;
  Timer? _timer;
  bool _answered = false, _gameEnded = false;

  @override
  void initState() { super.initState(); _loadGame(); }

  Future<void> _loadGame() async {
    final p = context.read<GamesProvider>();
    await p.fetchGameDetail(widget.gameId);
    await p.startGame(widget.gameId);
    _startTimer();
  }

  void _startTimer() { _timer?.cancel(); _timeLeft = context.read<GamesProvider>().currentGame?.timeLimit ?? 30; _timer = Timer.periodic(const Duration(seconds: 1), (_) { if (_timeLeft > 0) setState(() => _timeLeft--); else _nextQuestion(); }); }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() => _answered = true);
    final q = context.read<GamesProvider>().currentGame?.questions?[_currentQuestion];
    if (q != null && index == q.correctAnswerIndex) { _score += 10; _correct++; }
    Future.delayed(const Duration(milliseconds: 800), _nextQuestion);
  }

  void _nextQuestion() {
    final g = context.read<GamesProvider>().currentGame;
    if (_currentQuestion >= (g?.questions?.length ?? 1) - 1) { _endGame(); return; }
    setState(() { _currentQuestion++; _answered = false; });
    _startTimer();
  }

  Future<void> _endGame() async {
    _timer?.cancel();
    setState(() => _gameEnded = true);
    await context.read<GamesProvider>().endGame(score: _score, correctAnswers: _correct, totalQuestions: context.read<GamesProvider>().currentGame?.questions?.length ?? 0);
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async { final c = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Leave Game?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Leave'))])); return c ?? false; },
    child: Scaffold(
      appBar: AppBar(title: Text('Score: $_score'), actions: [Padding(padding: const EdgeInsets.all(12), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: _timeLeft < 10 ? AppColors.error : AppColors.primary, borderRadius: BorderRadius.circular(20)), child: Row(children: [const Icon(Icons.timer, color: Colors.white, size: 16), const SizedBox(width: 4), Text('$_timeLeft', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))])))]),
      body: Consumer<GamesProvider>(builder: (_, p, __) {
        if (p.isLoading) return const Center(child: CircularProgressIndicator());
        if (_gameEnded) return _buildResult();
        final g = p.currentGame; if (g?.questions == null || g!.questions!.isEmpty) return const Center(child: Text('No questions'));
        final q = g.questions![_currentQuestion];
        return Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          LinearProgressIndicator(value: (_currentQuestion + 1) / g.questions!.length),
          const SizedBox(height: 24),
          Text('Question ${_currentQuestion + 1}/${g.questions!.length}', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          Text(q.question, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ...q.answers.asMap().entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: ElevatedButton(
            onPressed: _answered ? null : () => _selectAnswer(e.key),
            style: ElevatedButton.styleFrom(backgroundColor: _answered ? (e.key == q.correctAnswerIndex ? AppColors.success : Colors.grey.shade300) : AppColors.primary, padding: const EdgeInsets.all(16)),
            child: Text(e.value.answer, textAlign: TextAlign.center),
          ))),
        ]));
      }),
    ),
  );

  Widget _buildResult() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.emoji_events, size: 64, color: AppColors.accent)),
    const SizedBox(height: 24),
    const Text('Game Over!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    const SizedBox(height: 16),
    Text('Score: $_score', style: const TextStyle(fontSize: 24, color: AppColors.primary)),
    Text('$_correct correct answers', style: TextStyle(color: Colors.grey.shade600)),
    const SizedBox(height: 32),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      OutlinedButton(onPressed: () => context.go('/games'), child: const Text('Back')),
      const SizedBox(width: 16),
      ElevatedButton(onPressed: () => context.push('/game/${widget.gameId}/leaderboard'), child: const Text('Leaderboard')),
    ]),
  ]));
}
