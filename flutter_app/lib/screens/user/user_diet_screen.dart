import 'package:flutter/material.dart';

class UserDietScreen extends StatefulWidget {
  const UserDietScreen({super.key});

  @override
  State<UserDietScreen> createState() => _UserDietScreenState();
}

class _UserDietScreenState extends State<UserDietScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Data ────────────────────────────────────────────────────────────────

  final List<_DietTab> _tabs = [
    _DietTab(
      label: 'Muscle Gain',
      emoji: '💪',
      color: const Color(0xFF1565C0),
      gradient: [const Color(0xFF1565C0), const Color(0xFF1E88E5)],
      headline: 'Muscle Gain (Bulking)',
      calories: '2500–3000 kcal',
      focus: 'Protein: 1.6–2g per kg body weight',
      meals: [
        _Meal('🌅 Early Morning', ['1 glass warm water', '5–6 soaked almonds', '2 whole eggs']),
        _Meal('🍳 Breakfast', [
          'Oats with milk',
          '1 banana',
          'Peanut butter (1 tbsp)',
          '2 egg whites / Paneer (50g)',
        ]),
        _Meal('🥗 Mid-Morning', ['Fruit bowl (apple + papaya)']),
        _Meal('🍛 Lunch', [
          '1 cup brown rice',
          'Grilled chicken (150g) / Paneer (100g)',
          'Dal',
          'Salad',
        ]),
        _Meal('💪 Pre-Workout', ['Banana', 'Black coffee']),
        _Meal('🥤 Post-Workout', ['Whey protein (1 scoop)', '5 boiled egg whites (alternative)']),
        _Meal('🌙 Dinner', ['2 chapati', 'Chicken curry / Paneer', 'Mixed vegetables']),
      ],
    ),
    _DietTab(
      label: 'Fat Loss',
      emoji: '🔥',
      color: const Color(0xFFC62828),
      gradient: [const Color(0xFFC62828), const Color(0xFFE53935)],
      headline: 'Fat Loss (Cutting)',
      calories: '1600–2000 kcal',
      focus: 'High Protein | Low Oil | Low Sugar',
      meals: [
        _Meal('🌅 Early Morning', ['Warm lemon water', '5 almonds']),
        _Meal('🍳 Breakfast', ['2 boiled eggs', 'OR Vegetable oats', 'Green tea']),
        _Meal('🥗 Mid-Morning', ['Apple / Guava']),
        _Meal('🍛 Lunch', [
          '2 chapati (no oil)',
          'Grilled chicken / Paneer (100g)',
          'Salad (no dressing)',
        ]),
        _Meal('☕ Evening Snack', ['Sprouts salad', 'Green tea']),
        _Meal('🌙 Dinner (Light)', [
          'Vegetable soup',
          'Boiled chicken / Paneer (small portion)',
        ]),
      ],
    ),
    _DietTab(
      label: 'Maintenance',
      emoji: '⚖️',
      color: const Color(0xFF2E7D32),
      gradient: [const Color(0xFF2E7D32), const Color(0xFF43A047)],
      headline: 'Maintenance Plan',
      calories: '2000–2300 kcal',
      focus: 'Balanced nutrition for sustained fitness',
      meals: [
        _Meal('🥣 Breakfast', ['Idli / Oats / Eggs', 'Fruit']),
        _Meal('🍛 Lunch', ['Rice or Chapati', 'Dal', 'Chicken / Paneer', 'Vegetables']),
        _Meal('🍎 Snacks', ['Fruits', 'Nuts']),
        _Meal('🌙 Dinner', ['Light chapati + vegetables', 'Protein source']),
      ],
    ),
    _DietTab(
      label: 'Tips',
      emoji: '💧',
      color: const Color(0xFF6A1B9A),
      gradient: [const Color(0xFF6A1B9A), const Color(0xFF9C27B0)],
      headline: 'General Tips',
      calories: '',
      focus: 'Healthy habits for better results',
      meals: [],
      tips: [
        '💧 Drink 3–4 liters of water daily',
        '🚫 Avoid sugary drinks',
        '🍕 Limit junk food',
        '😴 Sleep 7–8 hours every night',
        '🏋️ Maintain a consistent workout routine',
        '🥗 Eat whole, unprocessed foods',
        '⏰ Don\'t skip meals — eat every 3–4 hours',
        '📊 Track your calories & macros',
      ],
    ),
  ];

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 215,
            pinned: true,
            backgroundColor: const Color(0xFF4527A0),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4527A0), Color(0xFF7B1FA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                // Padding: top=status bar (~28), bottom=tab bar (~58)
                child: Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 62),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('🥗', style: TextStyle(fontSize: 34)),
                      SizedBox(height: 6),
                      Text(
                        'Diet Plans',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Complete Gym Diet Guide',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: _tabs
                  .map((t) => Tab(text: '${t.emoji} ${t.label}'))
                  .toList(),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: _tabs.map((tab) => _buildTabContent(tab)).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContent(_DietTab tab) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: tab.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: tab.color.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tab.headline,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (tab.calories.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '🔥 ${tab.calories}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                tab.focus,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Tips list (for Tips tab)
        if (tab.tips != null && tab.tips!.isNotEmpty)
          ...tab.tips!.map((tip) => _buildTipCard(tip, tab.color)),

        // Meal cards
        ...tab.meals.map((meal) => _buildMealCard(meal, tab.color)),

        // Personalized note
        if (tab.label != 'Tips') ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Share your age, height, weight, goal, and veg/non-veg preference with the trainer for a personalized diet plan.',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMealCard(_Meal meal, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Text(
              meal.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: accent,
              ),
            ),
          ),
          // Items
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: meal.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.circle, size: 7, color: accent.withOpacity(0.7)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(String tip, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(tip, style: const TextStyle(fontSize: 14, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

// ─── Models ──────────────────────────────────────────────────────────────────

class _DietTab {
  final String label;
  final String emoji;
  final Color color;
  final List<Color> gradient;
  final String headline;
  final String calories;
  final String focus;
  final List<_Meal> meals;
  final List<String>? tips;

  const _DietTab({
    required this.label,
    required this.emoji,
    required this.color,
    required this.gradient,
    required this.headline,
    required this.calories,
    required this.focus,
    required this.meals,
    this.tips,
  });
}

class _Meal {
  final String title;
  final List<String> items;
  const _Meal(this.title, this.items);
}
