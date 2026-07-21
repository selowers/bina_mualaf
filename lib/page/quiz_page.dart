import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'quiz_data.dart';

class QuizPage extends StatefulWidget {
  final String userId;

  const QuizPage({super.key, String? userId}) : userId = userId ?? 'guest';

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final List<QuizQuestion> _questions = quizQuestions;

  final Map<String, int> _categoryTotals = {};
  final Map<String, int> _categoryCorrect = {};
  late List<int?> _selectedAnswers;

  bool _isLoading = true;
  bool _hasSavedResult = false;
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  int _score = 0;
  bool _showFeedback = false;

  @override
  void initState() {
    super.initState();
    _initializeCategoryTotals();
    _selectedAnswers = List<int?>.filled(_questions.length, null);
    _loadSavedResult();
  }

  void _initializeCategoryTotals() {
    for (final question in _questions) {
      _categoryTotals[question.category] =
          (_categoryTotals[question.category] ?? 0) + 1;
    }
  }

  Future<void> _loadSavedResult() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('quiz_completed_${widget.userId}') ?? false;
    if (completed) {
      final savedScore = prefs.getInt('quiz_score_${widget.userId}') ?? 0;
      final categoryJson = prefs.getString('quiz_category_correct_${widget.userId}');
      final answersJson = prefs.getString('quiz_selected_answers_${widget.userId}');
      final categoryData = <String, int>{};

      _selectedAnswers = List<int?>.filled(_questions.length, null);
      if (answersJson != null) {
        final decodedAnswers = json.decode(answersJson) as List<dynamic>;
        for (var i = 0; i < decodedAnswers.length && i < _selectedAnswers.length; i++) {
          _selectedAnswers[i] = decodedAnswers[i] == null ? null : decodedAnswers[i] as int;
        }
      }

      if (categoryJson != null) {
        final decoded = json.decode(categoryJson) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          categoryData[entry.key] = entry.value as int;
        }
      }

      setState(() {
        _hasSavedResult = true;
        _score = savedScore;
        _categoryCorrect.clear();
        _categoryCorrect.addAll(categoryData);
        _currentQuestionIndex = _questions.length;
        _showFeedback = false;
        _selectedOptionIndex = null;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveResult() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quiz_completed_${widget.userId}', true);
    await prefs.setInt('quiz_score_${widget.userId}', _score);
    await prefs.setString(
      'quiz_category_correct_${widget.userId}',
      json.encode(_categoryCorrect),
    );
    await prefs.setString(
      'quiz_selected_answers_${widget.userId}',
      json.encode(_selectedAnswers),
    );
    setState(() {
      _hasSavedResult = true;
    });
  }

  Future<void> _clearSavedResult() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quiz_completed_${widget.userId}');
    await prefs.remove('quiz_score_${widget.userId}');
    await prefs.remove('quiz_category_correct_${widget.userId}');
    await prefs.remove('quiz_selected_answers_${widget.userId}');
    setState(() {
      _hasSavedResult = false;
    });
  }

  QuizQuestion get _currentQuestion => _questions[_currentQuestionIndex];

  void _selectOption(int index) {
    if (_showFeedback || _currentQuestionIndex >= _questions.length) return;
    setState(() {
      _selectedOptionIndex = index;
      _selectedAnswers[_currentQuestionIndex] = index;
    });
  }

  void _submitAnswer() {
    if (_selectedOptionIndex == null) return;

    final isCorrect = _selectedOptionIndex == _currentQuestion.correctIndex;
    if (isCorrect) {
      _score += 1;
      _categoryCorrect[_currentQuestion.category] =
          (_categoryCorrect[_currentQuestion.category] ?? 0) + 1;
    }

    setState(() {
      _showFeedback = true;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex + 1 >= _questions.length) {
      _completeQuiz();
      return;
    }

    setState(() {
      _currentQuestionIndex += 1;
      _selectedOptionIndex = null;
      _showFeedback = false;
    });
  }

  Future<void> _completeQuiz() async {
    await _saveResult();
    setState(() {
      _currentQuestionIndex = _questions.length;
      _showFeedback = false;
      _selectedOptionIndex = null;
    });
  }

  double get _percentScore =>
      _questions.isEmpty ? 0 : (_score / _questions.length) * 100;

  bool get _hasPassed => _percentScore >= 75;

  Future<void> _restartQuiz() async {
    await _clearSavedResult();
    setState(() {
      _currentQuestionIndex = 0;
      _selectedOptionIndex = null;
      _score = 0;
      _showFeedback = false;
      _categoryCorrect.clear();
      _selectedAnswers = List<int?>.filled(_questions.length, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
          backgroundColor: const Color(0xFF4A8CF7),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isCompleted = _currentQuestionIndex >= _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        backgroundColor: const Color(0xFF4A8CF7),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isCompleted ? _buildCompletionView(context) : _buildQuestionView(context),
        ),
      ),
    );
  }

  Widget _buildQuestionView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Materi: ${_currentQuestion.category}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Soal ${_currentQuestionIndex + 1} dari ${_questions.length}',
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            _currentQuestion.question,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: _currentQuestion.options.length,
            itemBuilder: (context, index) {
              final option = _currentQuestion.options[index];
              final selected = index == _selectedOptionIndex;
              final correct = index == _currentQuestion.correctIndex;
              final showCorrect = _showFeedback && correct;
              final showIncorrect = _showFeedback && selected && !correct;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: showCorrect
                      ? const Color(0xFFDFF8E1)
                      : showIncorrect
                          ? const Color(0xFFFFEBEE)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _selectOption(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 18,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: selected ? Colors.blue : Colors.black45,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option,
                              style: const TextStyle(fontSize: 15, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_showFeedback)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              _selectedOptionIndex == _currentQuestion.correctIndex
                  ? 'Jawaban benar!'
                  : 'Jawaban salah. Jawaban benar: ${_currentQuestion.options[_currentQuestion.correctIndex]}',
              style: TextStyle(
                fontSize: 15,
                color: _selectedOptionIndex == _currentQuestion.correctIndex
                    ? Colors.green[700]
                    : Colors.red[700],
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _showFeedback ? _nextQuestion : (_selectedOptionIndex != null ? _submitAnswer : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A8CF7),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _showFeedback ? 'Selanjutnya' : 'Kirim Jawaban',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompletionView(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  _hasPassed ? Icons.check_circle_outline : Icons.error_outline,
                  size: 72,
                  color: _hasPassed ? const Color(0xFF4A8CF7) : Colors.redAccent,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Selesai!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Skor Anda: $_score dari ${_questions.length}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Persentase: ${_percentScore.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  _hasPassed
                      ? 'Selamat! Anda lulus quiz.'
                      : 'Maaf, Anda belum lulus. Skor minimal 85% diperlukan untuk lulus.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _hasPassed ? Colors.green : Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Grafik menunjukkan hasil per kategori materi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildResultGraph(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _restartQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A8CF7),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(_hasPassed ? 'Ulang Quiz' : 'Coba Lagi'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Kembali ke Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultGraph() {
    final categories = [
      'Niat & Bacaan Sholat',
      'Tata Cara Wudhu',
      'Rukun Iman & Islam',
      'Doa Keseharian',
      'Murotal',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: categories.map((name) {
        final correct = _categoryCorrect[name] ?? 0;
        final total = _categoryTotals[name] ?? 0;
        final percent = total == 0 ? 0 : ((correct / total) * 100).round();

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '$correct/$total',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Container(height: 12, color: const Color(0xFFF0F0F0)),
                    FractionallySizedBox(
                      widthFactor: total == 0 ? 0 : correct / total,
                      child: Container(
                        height: 12,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4A8CF7), Color(0xFF80D7FF)],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$percent% benar',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
