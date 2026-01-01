import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/subjects_provider.dart';
import '../models/subject_model.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SubjectsProvider>();
      provider.fetchSubjects();
      provider.fetchEnrolledSubjects();
      provider.fetchDepartments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search subjects...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // Tab bar
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Subjects'),
            Tab(text: 'All Subjects'),
          ],
        ),

        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildEnrolledSubjects(),
              _buildAllSubjects(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnrolledSubjects() {
    return Consumer<SubjectsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        var subjects = provider.enrolledSubjects;
        if (_searchQuery.isNotEmpty) {
          subjects = subjects
              .where((s) =>
                  s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
        }

        if (subjects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No subjects found'
                      : 'No enrolled subjects yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _tabController.animateTo(1),
                    child: const Text('Browse Subjects'),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchEnrolledSubjects(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              return _buildSubjectCard(subjects[index], index, true);
            },
          ),
        );
      },
    );
  }

  Widget _buildAllSubjects() {
    return Consumer<SubjectsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        var subjects = provider.subjects;
        if (_searchQuery.isNotEmpty) {
          subjects = provider.searchSubjects(_searchQuery);
        }

        if (subjects.isEmpty) {
          return Center(
            child: Text(
              'No subjects available',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        }

        // Group by department
        final departments = provider.departments;
        if (departments.isNotEmpty && _searchQuery.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => provider.fetchSubjects(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: departments.length,
              itemBuilder: (context, index) {
                final dept = departments[index];
                final deptSubjects = provider.getSubjectsByDepartment(dept.id);
                if (deptSubjects.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        dept.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...deptSubjects.map((s) {
                      final idx = subjects.indexOf(s);
                      return _buildSubjectCard(s, idx, false);
                    }),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchSubjects(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              return _buildSubjectCard(subjects[index], index, false);
            },
          ),
        );
      },
    );
  }

  Widget _buildSubjectCard(Subject subject, int index, bool showProgress) {
    final color = AppColors.getSubjectColor(index);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.go('/subjects/${subject.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.book, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${subject.topicsCount} topics, ${subject.lessonsCount} lessons',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    if (showProgress && subject.progress > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: subject.progress / 100,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation(color),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${subject.progress}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
