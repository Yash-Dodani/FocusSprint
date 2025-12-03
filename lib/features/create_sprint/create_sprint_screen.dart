import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/primary_button.dart';
import '../../data/models/sprint.dart';
import '../../providers/sprint_provider.dart';
import '../timer/timer_screen.dart';

class CreateSprintScreen extends StatefulWidget {
  const CreateSprintScreen({super.key});

  @override
  State<CreateSprintScreen> createState() => _CreateSprintScreenState();
}

class _CreateSprintScreenState extends State<CreateSprintScreen> {
  final TextEditingController _titleController = TextEditingController();
  SprintCategory _selectedCategory = SprintCategory.study;
  int _durationMinutes = 25;

  final List<int> _quickDurations = [1, 5, 10, 15, 25];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _selectQuickDuration(int minutes) {
    setState(() => _durationMinutes = minutes);
  }

  Future<void> _startSprint() async {
    final provider = context.read<SprintProvider>();

    final title = _titleController.text.trim().isEmpty
        ? 'Deep focus sprint'
        : _titleController.text.trim();

    final sprint = Sprint(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      durationMinutes: _durationMinutes,
      category: _selectedCategory,
      completed: false,
      createdAt: DateTime.now(),
    );

    await provider.addSprint(sprint);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => TimerScreen(sprint: sprint)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF19192A) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF14141F);
    final textSecondary = isDark ? Colors.white70 : const Color(0xFF6B6B80);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('New Sprint')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.9, end: 1.0),
                      duration: const Duration(milliseconds: 250),
                      builder: (context, value, child) =>
                          Transform.scale(scale: value, child: child),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B2EFF).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Set your next focus sprint 🎯',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Title',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.4 : 0.06,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: TextField(
                        controller: _titleController,
                        style: TextStyle(color: textPrimary, fontSize: 15),
                        cursorColor: const Color(0xFF5B2EFF),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Deep focus sprint',
                          hintStyle: TextStyle(color: textSecondary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildCategoryChip('Study', SprintCategory.study),
                        _buildCategoryChip('Coding', SprintCategory.coding),
                        _buildCategoryChip('Reading', SprintCategory.reading),
                        _buildCategoryChip('Fitness', SprintCategory.fitness),
                        _buildCategoryChip('Custom', SprintCategory.custom),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Quick duration',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _quickDurations.map((m) {
                        final selected = _durationMinutes == m;
                        return ChoiceChip(
                          label: Text('${m}m'),
                          selected: selected,
                          onSelected: (_) => _selectQuickDuration(m),
                          selectedColor: const Color(0xFF5B2EFF),
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : textPrimary,
                          ),
                          backgroundColor: cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Duration (minutes)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '$_durationMinutes min',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            min: 1,
                            max: 60,
                            divisions: 59,
                            value: _durationMinutes.toDouble(),
                            label: '$_durationMinutes min',
                            onChanged: (value) {
                              setState(() {
                                _durationMinutes = value.round();
                              });
                            },
                            activeColor: const Color(0xFF5B2EFF),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: PrimaryButton(
                          label: 'Start sprint',
                          fullWidth: true,
                          icon: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                          onPressed: _startSprint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, SprintCategory category) {
    final isSelected = _selectedCategory == category;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isSelected
        ? const Color(0xFF5B2EFF)
        : (isDark ? const Color(0xFF29293A) : const Color(0xFFF1F1F7));

    final textColor = isSelected
        ? Colors.white
        : (isDark ? Colors.white70 : Colors.black87);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _selectedCategory = category);
      },
      selectedColor: bg,
      backgroundColor: bg,
      labelStyle: TextStyle(color: textColor, fontSize: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isSelected
            ? BorderSide.none
            : BorderSide(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black12,
              ),
      ),
    );
  }
}
