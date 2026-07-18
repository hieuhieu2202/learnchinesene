import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../database/db_helper.dart';
import '../../../models/hanzi_character.dart';
import 'hanzi_writing_screen.dart';

class HanziWritingHomeScreen extends StatefulWidget {
  const HanziWritingHomeScreen({super.key});

  @override
  State<HanziWritingHomeScreen> createState() => _HanziWritingHomeScreenState();
}

class _HanziWritingHomeScreenState extends State<HanziWritingHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _keyword = '';
  int? _selectedHskLevel;
  List<HanziCharacter> _characters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCharacters() async {
    setState(() => _isLoading = true);
    try {
      final list = await DbHelper.instance.getCharactersForWriting(
        keyword: _keyword.isEmpty ? null : _keyword,
        hskLevel: _selectedHskLevel,
      );
      setState(() {
        _characters = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _keyword = value;
      });
      _loadCharacters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Luyện viết chữ Hán',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm theo chữ Hán, pinyin, nghĩa...',
                prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFF0E7E5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFF0E7E5)),
                ),
              ),
            ),
          ),
          // HSK filter chip row
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip(null, 'Tất cả'),
                ...List.generate(
                    6, (i) => _buildFilterChip(i + 1, 'HSK ${i + 1}')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Character List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _characters.isEmpty
                    ? const Center(
                        child: Text(
                          'Không tìm thấy chữ Hán nào.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: _characters.length,
                        itemBuilder: (context, index) {
                          final char = _characters[index];
                          // c.stroke_count is 0 or c.stroke_count < 1 when no paths are available
                          final hasStrokeData = char.strokeCount > 0;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: const Color(0xFFF0E7E5)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x05461419),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              clipBehavior: Clip.antiAlias,
                              borderRadius: BorderRadius.circular(20),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE9E5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    char.character,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'FZKaiTiPinyin',
                                    ),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    if (char.hskLevel != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'HSK ${char.hskLevel}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.red,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    char.meaning ?? '',
                                    style: const TextStyle(
                                        color: AppColors.muted, fontSize: 13),
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${char.strokeCount} nét',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    if (!hasStrokeData)
                                      const Text(
                                        'Chưa có nét',
                                        style: TextStyle(
                                            color: AppColors.error,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold),
                                      ),
                                  ],
                                ),
                                onTap: () {
                                  if (!hasStrokeData) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Chữ này chưa có dữ liệu luyện viết.'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HanziWritingScreen(
                                          characterId: char.id),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int? level, String label) {
    final isSelected = _selectedHskLevel == level;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() {
            _selectedHskLevel = selected ? level : null;
          });
          _loadCharacters();
        },
        selectedColor: AppColors.red.withOpacity(0.2),
        checkmarkColor: AppColors.red,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.red : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
