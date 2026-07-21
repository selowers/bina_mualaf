import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';
import 'quiz_data.dart';

class QuizReviewPembimbingPage extends StatefulWidget {
  const QuizReviewPembimbingPage({super.key});

  @override
  State<QuizReviewPembimbingPage> createState() =>
      _QuizReviewPembimbingPageState();
}

class _QuizReviewPembimbingPageState extends State<QuizReviewPembimbingPage> {
  late Future<List<QuizResultSummary>> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _resultsFuture = _loadQuizResults();
  }

  Future<List<QuizResultSummary>> _loadQuizResults() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users') ?? '[]';
    final users = (json.decode(usersJson) as List<dynamic>)
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .where((user) => user.role == 'calon_mualaf')
        .toList();

    final results = <QuizResultSummary>[];
    for (final calon in users) {
      final completed = prefs.getBool('quiz_completed_${calon.id}') ?? false;
      final score = prefs.getInt('quiz_score_${calon.id}') ?? 0;
      final String? answersJson = prefs.getString(
        'quiz_selected_answers_${calon.id}',
      );
      final selectedAnswers = List<int?>.filled(quizQuestions.length, null);
      if (answersJson != null) {
        final decoded = json.decode(answersJson) as List<dynamic>;
        for (var i = 0; i < decoded.length && i < selectedAnswers.length; i++) {
          final item = decoded[i];
          selectedAnswers[i] = item == null ? null : (item as int);
        }
      }

      results.add(
        QuizResultSummary(
          calon: calon,
          completed: completed,
          score: score,
          selectedAnswers: selectedAnswers,
        ),
      );
    }

    results.sort((a, b) {
      if (a.completed != b.completed) {
        return a.completed ? -1 : 1;
      }
      return a.calon.nama.toLowerCase().compareTo(b.calon.nama.toLowerCase());
    });
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Quiz Calon Mualaf'),
        backgroundColor: const Color(0xFF4A8CF7),
      ),
      body: FutureBuilder<List<QuizResultSummary>>(
        future: _resultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat hasil quiz: ${snapshot.error}'),
            );
          }

          final results = snapshot.data ?? [];
          if (results.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Belum ada calon mualaf terdaftar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final result = results[index];
              final percent = result.completed
                  ? (result.score / quizQuestions.length * 100).round()
                  : 0;
              final subtitle = result.completed
                  ? 'Skor: ${result.score}/${quizQuestions.length} • $percent%'
                  : 'Belum mengerjakan quiz';

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: result.completed
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QuizReviewDetailPage(summary: result),
                          ),
                        );
                      }
                    : null,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFF4A8CF7),
                          child: Text(
                            result.calon.nama.isNotEmpty
                                ? result.calon.nama[0].toUpperCase()
                                : 'C',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.calon.nama,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                result.calon.email,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: result.completed
                                      ? Colors.black87
                                      : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (result.completed)
                          Container(
                            decoration: BoxDecoration(
                              color: result.passed
                                  ? const Color(0xFFE8F7E8)
                                  : const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            child: Text(
                              result.passed ? 'Lulus' : 'Tidak lulus',
                              style: TextStyle(
                                color: result.passed
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFD32F2F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class QuizReviewDetailPage extends StatelessWidget {
  final QuizResultSummary summary;

  const QuizReviewDetailPage({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final percent = summary.completed
        ? (summary.score / quizQuestions.length * 100).round()
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Hasil Quiz'),
        backgroundColor: const Color(0xFF4A8CF7),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFF4A8CF7),
                          child: Text(
                            summary.calon.nama.isNotEmpty
                                ? summary.calon.nama[0].toUpperCase()
                                : 'C',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                summary.calon.nama,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                summary.calon.email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      summary.completed
                          ? 'Skor akhir: ${summary.score}/${quizQuestions.length} • $percent%'
                          : 'Calon mualaf belum menyelesaikan quiz.',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    if (summary.completed)
                      Text(
                        summary.passed
                            ? 'Status: Lulus'
                            : 'Status: Tidak lulus',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: summary.passed
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFD32F2F),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Jawaban Quiz',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              ...quizQuestions.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value;
                final selectedIndex = summary.selectedAnswers[index];
                final selectedText = selectedIndex == null
                    ? 'Belum dipilih'
                    : question.options[selectedIndex];
                final correctText = question.options[question.correctIndex];
                final isCorrect = selectedIndex == question.correctIndex;
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? const Color(0xFFF2F8F3)
                        : const Color(0xFFFFF1F1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isCorrect
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFD32F2F),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFD32F2F),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.question,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Kategori: ${question.category}'),
                      const SizedBox(height: 8),
                      Text('Jawaban yang dipilih: $selectedText'),
                      const SizedBox(height: 4),
                      Text('Jawaban benar: $correctText'),
                      const SizedBox(height: 10),
                      Text(
                        isCorrect ? 'Benar' : 'Salah',
                        style: TextStyle(
                          color: isCorrect
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFD32F2F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizResultSummary {
  final User calon;
  final bool completed;
  final int score;
  final List<int?> selectedAnswers;

  QuizResultSummary({
    required this.calon,
    required this.completed,
    required this.score,
    required this.selectedAnswers,
  });

  bool get passed => completed && quizQuestions.isNotEmpty
      ? (score / quizQuestions.length * 100) >= 85
      : false;
}
