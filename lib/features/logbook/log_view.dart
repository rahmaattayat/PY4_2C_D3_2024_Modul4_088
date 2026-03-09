import 'package:flutter/material.dart';
import 'package:logbook_app_088/features/onboarding/onboarding_view.dart';
import 'log_controller.dart';
import 'models/log_model.dart';

const _kPurple = Color(0xFF8B5CF6);
const _kDarkPurple = Color(0xFF4C1D95);
const _kDeepPurple = Color(0xFF2E1065);
const _kPurpleDark = Color(0xFF7C3AED);

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final LogController _controller = LogController(username: widget.username);
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    _controller.dispose();
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _controller.loadLogs();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  (String, String) _getGreetingInfo() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return ('☀️', 'Selamat Pagi');
    if (hour >= 11 && hour < 15) return ('🌤️', 'Selamat Siang');
    if (hour >= 15 && hour < 18) return ('🌇', 'Selamat Sore');
    return ('🌙', 'Selamat Malam');
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pekerjaan':
        return Colors.blueAccent;
      case 'Urgent':
        return Colors.redAccent;
      default:
        return Colors.purpleAccent;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Pekerjaan':
        return Icons.work_rounded;
      case 'Urgent':
        return Icons.priority_high_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Widget _buildBlob(double size, Color color, {double opacity = 0.1}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      );

  OutlineInputBorder _inputBorder({Color color = Colors.transparent, double width = 1}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: color == Colors.transparent ? BorderSide.none : BorderSide(color: color, width: width),
      );

  InputDecoration _buildInputDecoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _kPurple, size: 20),
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: _kPurple, fontWeight: FontWeight.bold),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _inputBorder(),
        enabledBorder: _inputBorder(color: Colors.grey.shade200),
        focusedBorder: _inputBorder(color: _kPurple, width: 1.5),
        errorBorder: _inputBorder(color: Colors.redAccent),
      );

  Widget _buildCategorySelector(String selectedCategory, void Function(String) onSelect) {
    final categories = ['Pekerjaan', 'Pribadi', 'Urgent'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(color: _kPurple, fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: categories.map((cat) {
            final isSelected = selectedCategory == cat;
            final color = _getCategoryColor(cat);
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? color : color.withValues(alpha: 0.2), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getCategoryIcon(cat),
                        color: isSelected ? Colors.white : color,
                        size: 18,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDialogActions({
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
    required String confirmLabel,
    required Color confirmColor,
  }) =>
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                foregroundColor: Colors.grey.shade600,
                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text("Batal", style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
      );

  void _showToast(String message, {bool isEdit = false}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        isEdit: isEdit,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  void _showLogDialog({int? index, LogModel? log}) {
    final isEdit = log != null;
    _titleController.text = isEdit ? log.title : '';
    _contentController.text = isEdit ? log.description : '';
    String selectedCategory = isEdit ? log.category : 'Pribadi';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: !isEdit,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: isEdit ? 0 : 10,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isEdit ? Colors.blue : _kPurple).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isEdit ? Icons.edit_note_rounded : Icons.note_add_rounded,
                        color: isEdit ? Colors.blue : _kPurple,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isEdit ? "Edit Catatan" : "Tambah Catatan",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _kDeepPurple),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _titleController,
                      decoration: _buildInputDecoration("Judul Catatan", Icons.title_rounded),
                      validator: (v) => (v == null || v.isEmpty) ? "Judul tidak boleh kosong" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contentController,
                      maxLines: 3,
                      decoration: _buildInputDecoration("Isi Deskripsi", Icons.description_rounded),
                      validator: (v) => (v == null || v.isEmpty) ? "Deskripsi tidak boleh kosong" : null,
                    ),
                    const SizedBox(height: 16),
                    _buildCategorySelector(
                      selectedCategory,
                      (val) => setDialogState(() => selectedCategory = val),
                    ),
                    const SizedBox(height: 24),
                    _buildDialogActions(
                      onCancel: () => Navigator.pop(context),
                      onConfirm: () {
                        if (formKey.currentState!.validate()) {
                          isEdit
                              ? _controller.updateLog(
                                  index!,
                                  _titleController.text,
                                  _contentController.text,
                                  selectedCategory,
                                )
                              : _controller.addLog(
                                  _titleController.text,
                                  _contentController.text,
                                  selectedCategory,
                                );
                          Navigator.pop(context);
                          _showToast(
                            isEdit ? 'Catatan berhasil diperbarui!' : 'Catatan berhasil disimpan!',
                            isEdit: isEdit,
                          );
                        }
                      },
                      confirmLabel: isEdit ? "Update" : "Simpan",
                      confirmColor: isEdit ? Colors.blue : _kPurple,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 26),
              ),
              const SizedBox(height: 14),
              const Text(
                'Keluar Aplikasi?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _kDeepPurple),
              ),
              const SizedBox(height: 6),
              Text(
                'Yakin ingin logout?\nData Anda tetap tersimpan di perangkat.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Batal"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Logout"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingView()),
        (_) => false,
      );
    }
  }

  Future<bool?> _showConfirmDeleteDialog(String title) => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Hapus Catatan"),
          content: Text("Hapus '$title'? Tindakan ini tidak bisa dibatalkan."),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Hapus"),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final (emoji, greeting) = _getGreetingInfo();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: _kPurple.withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showLogDialog(),
          backgroundColor: _kPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add_task_rounded),
          label: const Text("Catatan Baru", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF3E8FF), Color(0xFFEDE9FE), Color(0xFFF8F5FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              SizedBox(
                height: 90,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(right: -18, top: -22, child: _buildBlob(110, _kPurple, opacity: 0.12)),
                    Positioned(right: 55, top: -10, child: _buildBlob(50, const Color(0xFFDB2777), opacity: 0.08)),
                    Positioned(left: -10, bottom: -15, child: _buildBlob(70, _kPurple, opacity: 0.07)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_kPurple, _kPurpleDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: _kPurple.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                widget.username[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 13),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$emoji $greeting',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                widget.username,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: _kDarkPurple,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _confirmLogout,
                            icon: const Icon(Icons.logout_rounded, color: _kPurple, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: _kPurple.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── OFFLINE BANNER ── with better styling
              ValueListenableBuilder<bool>(
                valueListenable: _controller.isOffline,
                builder: (context, isOffline, _) {
                  if (!isOffline) return const SizedBox.shrink();
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFCD34D),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFCD34D).withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          color: Color(0xFFD97706),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Mode Offline – Hanya data lokal yang tersimpan",
                            style: TextStyle(
                              color: const Color(0xFF92400E),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Search bar with better styling
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _kPurple.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: _controller.searchLog,
                    decoration: InputDecoration(
                      hintText: "Cari catatan...",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: _kPurple,
                        size: 22,
                      ),
                      suffixIcon: const Icon(
                        Icons.tune_rounded,
                        color: _kPurple,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: _kPurple.withValues(alpha: 0.1),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: _kPurple.withValues(alpha: 0.08),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: _kPurple,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Daftar catatan
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: _kPurple))
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'Gagal memuat: $_error',
                                  style: const TextStyle(color: Colors.redAccent),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadData,
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          )
                        : ValueListenableBuilder<List<LogModel>>(
                            valueListenable: _controller.filteredLogs,
                            builder: (context, logs, child) {
                              return RefreshIndicator(
                                onRefresh: _loadData,
                                color: _kPurple,
                                child: logs.isEmpty
                                    ? ListView(
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        children: [
                                          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                                          Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 100,
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                    color: _kPurple.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(28),
                                                    border: Border.all(
                                                      color: _kPurple.withValues(alpha: 0.15),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    _controller.isOffline.value
                                                        ? Icons.cloud_off_rounded
                                                        : Icons.note_add_rounded,
                                                    size: 50,
                                                    color: _kPurple.withValues(alpha: 0.5),
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Text(
                                                  _controller.isOffline.value
                                                      ? 'Mode Offline'
                                                      : 'Belum Ada Catatan',
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w800,
                                                    color: _kDeepPurple,
                                                    letterSpacing: -0.3,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(horizontal: 32),
                                                  child: Text(
                                                    _controller.isOffline.value
                                                        ? 'Koneksikan perangkat untuk melihat data terbaru'
                                                        : 'Mulai dengan membuat catatan pertamamu!',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey.shade600,
                                                      fontWeight: FontWeight.w500,
                                                      height: 1.5,
                                                      letterSpacing: 0.1,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : ListView.builder(
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                                        itemCount: logs.length,
                                        itemBuilder: (context, index) {
                                          final log = logs[index];
                                          final catColor = _getCategoryColor(log.category);

                                          return Dismissible(
                                            key: Key(log.date.toString()),
                                            direction: DismissDirection.endToStart,
                                            confirmDismiss: (_) => _showConfirmDeleteDialog(log.title),
                                            onDismissed: (_) => _controller.removeLog(index),
                                            background: Container(
                                              margin: const EdgeInsets.only(bottom: 12),
                                              decoration: BoxDecoration(
                                                color: Colors.redAccent,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              alignment: Alignment.centerRight,
                                              padding: const EdgeInsets.only(right: 20),
                                              child: const Icon(
                                                Icons.delete_forever_rounded,
                                                color: Colors.white,
                                                size: 26,
                                              ),
                                            ),
                                            child: Container(
                                              margin: const EdgeInsets.only(bottom: 14),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(24),
                                                border: Border.all(
                                                  color: catColor.withValues(alpha: 0.15),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: catColor.withValues(alpha: 0.08),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(24),
                                                child: IntrinsicHeight(
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 6,
                                                        decoration: BoxDecoration(
                                                          color: catColor,
                                                          borderRadius: const BorderRadius.only(
                                                            topLeft: Radius.circular(24),
                                                            bottomLeft: Radius.circular(24),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  // Category badge
                                                                  Container(
                                                                    padding: const EdgeInsets.symmetric(
                                                                      horizontal: 10,
                                                                      vertical: 5,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                      color: catColor.withValues(alpha: 0.12),
                                                                      borderRadius:
                                                                          BorderRadius.circular(10),
                                                                      border: Border.all(
                                                                        color: catColor.withValues(alpha: 0.25),
                                                                        width: 1,
                                                                      ),
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        Icon(
                                                                          _getCategoryIcon(log.category),
                                                                          size: 12,
                                                                          color: catColor,
                                                                        ),
                                                                        const SizedBox(width: 4),
                                                                        Text(
                                                                          log.category,
                                                                          style: TextStyle(
                                                                            color: catColor,
                                                                            fontSize: 10,
                                                                            fontWeight: FontWeight.w700,
                                                                            letterSpacing: 0.4,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const Spacer(),
                                                                  // Timestamp
                                                                  Text(
                                                                    _controller
                                                                        .formatTimestamp(log.date),
                                                                    style: TextStyle(
                                                                      color: Colors.grey.shade500,
                                                                      fontSize: 11,
                                                                      fontWeight: FontWeight.w500,
                                                                      letterSpacing: 0.1,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(height: 8),
                                                              Text(
                                                                log.title,
                                                                style: const TextStyle(
                                                                  fontWeight: FontWeight.w800,
                                                                  color: _kDeepPurple,
                                                                  fontSize: 16,
                                                                  letterSpacing: -0.2,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 4),
                                                              Text(
                                                                log.description,
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                  color: Colors.grey.shade600,
                                                                  fontSize: 13,
                                                                  height: 1.5,
                                                                  fontWeight: FontWeight.w400,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 10),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment.end,
                                                                children: [
                                                                  _buildActionBtn(
                                                                    Icons.edit_rounded,
                                                                    Colors.blue,
                                                                    () => _showLogDialog(
                                                                      index: index,
                                                                      log: log,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
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
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final bool isEdit;
  final VoidCallback onDone;

  const _ToastWidget({
    required this.message,
    required this.isEdit,
    required this.onDone,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  late final Animation<double> _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
    CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
  );

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 1800), () async {
      if (mounted) await _ctrl.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isEdit ? Colors.blue : _kPurple;

    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: color.withOpacity(0.15), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.1),
                      ),
                      child: Icon(Icons.check_rounded, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.message,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}