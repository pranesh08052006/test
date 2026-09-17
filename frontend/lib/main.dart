import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:excel/excel.dart' hide Border;

void main() {
  runApp(const ZealApp());
}

class ZealApp extends StatelessWidget {
  const ZealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zeal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const LoginPage(),
      routes: {
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        final error = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error['detail'] ?? 'Login failed')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection error')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignup() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created! You can now login.')));
        }
      } else {
        final error = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error['detail'] ?? 'Signup failed')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection error')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]), child: const Icon(Icons.bolt, color: Colors.black, size: 40)),
            const SizedBox(height: 32),
            Text('Zeal', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xFF111827))),
            const SizedBox(height: 8),
            Text('Automation Hub Engine', style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF6B7280), fontWeight: FontWeight.w500)),
            const SizedBox(height: 48),
            _buildTextField(_emailController, 'Enter your email', Icons.email_outlined),
            const SizedBox(height: 16),
            _buildTextField(_passwordController, 'Enter your password', Icons.lock_outline, isPassword: true),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: _isLoading ? null : _handleLogin, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Login', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(width: 8), const Icon(Icons.arrow_forward, size: 20)]))),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, height: 56, child: OutlinedButton(onPressed: _isLoading ? null : _handleSignup, style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.black, width: 2), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('Create Account', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)))),
            const SizedBox(height: 48),
          ]),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword && _obscurePassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: isPassword ? IconButton(icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)) : null,
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  String? _uploadedFileName;
  String? _uploadedFileSize;
  bool _isUploading = false;

  double? _revenue;
  double? _pending;
  int? _activeBills;
  
  List<String>? _headers;
  List<List<String>>? _excelRows;
  List<Map<String, String>>? _quickPayments;

  void _handleLogout() { Navigator.pushReplacementNamed(context, '/'); }

  void _handleFileSelection() {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.xlsx,.csv';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        setState(() => _isUploading = true);
        final file = files[0];
        final reader = html.FileReader();

        reader.onLoadEnd.listen((e) {
          try {
            final result = reader.result;
            if (result == null) throw "File load yielded null";
            Uint8List bytes;
            if (result is ByteBuffer) bytes = result.asUint8List();
            else if (result is Uint8List) bytes = result;
            else bytes = Uint8List.fromList(result as dynamic);
            
            if (file.name.toLowerCase().endsWith('.csv')) {
              _parseCsvData(utf8.decode(bytes), file.name, file.size);
            } else {
              _parseExcelData(bytes, file.name, file.size);
            }
          } catch (err) {
            setState(() => _isUploading = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Loader Error: $err')));
          }
        });
        reader.readAsArrayBuffer(file);
      }
    });
  }

  void _parseCsvData(String content, String name, int size) {
    try {
      List<List<String>> allRows = [];
      List<String> lines = const LineSplitter().convert(content);
      for (var l in lines) {
        if (l.trim().isEmpty) continue;
        allRows.add(l.split(RegExp(r',(?=(?:[^"]*"[^"]*")*[^"]*$)')).map((s) => s.replaceAll('"', '').trim()).toList());
      }
      _processFinalData(allRows, name, size);
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CSV System Error: $e')));
    }
  }

  void _parseExcelData(Uint8List bytes, String name, int size) {
    try {
      var excel = Excel.decodeBytes(bytes);
      List<List<String>> allRows = [];

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null) continue;
        for (var row in sheet.rows) {
          if (row == null) continue;
          allRows.add(row.map((cell) => cell?.value?.toString() ?? "").toList());
        }
        break; 
      }
      _processFinalData(allRows, name, size);
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Extraction Error: $e')));
    }
  }

  void _processFinalData(List<List<String>> rows, String name, int size) {
    if (rows.isEmpty) throw "Empty file";
    
    List<String> headers = rows[0];
    List<List<String>> dataRows = rows.skip(1).toList();
    
    // Find the price column index by keyword search
    int priceIndex = -1;
    for (int i = 0; i < headers.length; i++) {
      String h = headers[i].toLowerCase();
      if (h.contains('price') || h.contains('amount') || h.contains('cost') || h.contains('bill') || h.contains('total') || h.contains('rupee') || h.contains('₹') || h.contains('$')) {
        priceIndex = i;
        break;
      }
    }
    
    // If no header match, use the last column (usually where totals are)
    if (priceIndex == -1 && headers.length > 1) {
      priceIndex = headers.length - 1;
    } else if (priceIndex == -1) {
      priceIndex = 0; // Fallback
    }

    double totalRev = 0;
    List<Map<String, String>> quickList = [];
    
    for (var row in dataRows) {
      if (row.isEmpty) continue;
      String customer = row[0];
      
      String amountStr = row.length > priceIndex ? row[priceIndex] : "0";
      double amount = double.tryParse(amountStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      
      // Secondary Check: If the number looks like a phone number (10 digits), it's probably wrong.
      if (amountStr.replaceAll(RegExp(r'[^0-9]'), '').length >= 10 && row.length > 1) {
         // Try one more column over
         int altIndex = (priceIndex + 1) % row.length;
         if (altIndex != 0) {
           amountStr = row[altIndex];
           amount = double.tryParse(amountStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
         }
      }

      totalRev += amount;
      quickList.add({'name': customer, 'amount': '\$${amount.toStringAsFixed(2)}'});
    }

    setState(() {
      _isUploading = false;
      _uploadedFileName = name;
      _uploadedFileSize = '${(size / 1024).toStringAsFixed(1)} KB';
      _headers = headers;
      _excelRows = dataRows;
      _quickPayments = quickList;
      _revenue = totalRev;
      _pending = totalRev * 0.2;
      _activeBills = dataRows.length;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Linked to Column: ${priceIndex != -1 ? headers[priceIndex] : "Last"}')));
    setState(() => _currentIndex = 0);
  }

  void _deleteFile() {
    setState(() { _uploadedFileName = null; _uploadedFileSize = null; _revenue = null; _pending = null; _activeBills = null; _headers = null; _excelRows = null; _quickPayments = null; });
  }

  void _openFile() {
    showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: Colors.white, title: Text('File Info', style: GoogleFonts.inter(fontWeight: FontWeight.w800)), content: Text('File: $_uploadedFileName\nRows: ${_excelRows?.length ?? 0}'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: Padding(padding: const EdgeInsets.all(12.0), child: Container(decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.bolt, color: Colors.white, size: 20))), title: Text('Zeal', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.black)), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.black)), const Padding(padding: EdgeInsets.only(right: 16.0, left: 8.0), child: CircleAvatar(radius: 18, backgroundColor: Color(0xFFFFB6C1), child: Icon(Icons.person, color: Colors.white, size: 20)))]),
      body: _buildBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(onPressed: () => setState(() => _currentIndex = 4), backgroundColor: Colors.black, elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.add, color: Colors.white, size: 28)),
      bottomNavigationBar: BottomAppBar(shape: const CircularNotchedRectangle(), notchMargin: 8, color: Colors.white, child: SizedBox(height: 64, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildBottomNavItem(0, Icons.grid_view_rounded, 'Home'), _buildBottomNavItem(1, Icons.chat_bubble_outline, 'Orders'), const SizedBox(width: 40), _buildBottomNavItem(2, Icons.analytics_outlined, 'Analytics'), _buildBottomNavItem(3, Icons.settings_outlined, 'Settings')]))),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildHomeView();
      case 3: return _buildSettingsView();
      case 4: return _buildUploadView();
      default: return _buildHomeView();
    }
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return Expanded(child: GestureDetector(onTap: () => setState(() => _currentIndex = index), child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: isSelected ? Colors.black : const Color(0xFF9CA3AF), size: 22), const SizedBox(height: 2), Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? Colors.black : const Color(0xFF9CA3AF)))])));
  }

  Widget _buildHomeView() {
    if (_revenue == null) return _buildEmptyHomeState();
    return SingleChildScrollView(padding: const EdgeInsets.all(20.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('DASHBOARD OVERVIEW', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF6B7280), letterSpacing: 1)), const SizedBox(height: 8), Text('Hello, Staff', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF111827))), const SizedBox(height: 24), _buildRevenueCard(), const SizedBox(height: 16), _buildSmallStatsRow(), const SizedBox(height: 32), _buildRecentPaymentsHeader(), const SizedBox(height: 16), _buildQuickPaymentList(), const SizedBox(height: 100)]));
  }

  Widget _buildEmptyHomeState() {
    return Center(child: Padding(padding: const EdgeInsets.all(40.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 40)]), child: const Icon(Icons.analytics_outlined, size: 64, color: Color(0xFFE5E7EB))), const SizedBox(height: 32), Text('No Data Extracted', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF111827))), const SizedBox(height: 12), Text('Upload your spreadsheet to mirror your\ndata format automatically.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6B7280), height: 1.5)), const SizedBox(height: 40), ElevatedButton.icon(onPressed: () => setState(() => _currentIndex = 4), icon: const Icon(Icons.add, size: 18), label: Text('Upload Dataset', style: GoogleFonts.inter(fontWeight: FontWeight.w700)), style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))])));
  }

  Widget _buildRevenueCard() {
    return Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.account_balance_wallet, color: Colors.black, size: 24)), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(20)), child: Text('+12.4%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)))]), const SizedBox(height: 20), Text("Today's Revenue", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF6B7280))), const SizedBox(height: 4), Text('\$${_revenue?.toStringAsFixed(2) ?? "0.00"}', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xFF111827)))]));
  }

  Widget _buildSmallStatsRow() {
    return Row(children: [Expanded(child: _buildSmallStat('Pending', '\$${_pending?.toStringAsFixed(2) ?? "0.00"}', Icons.more_horiz, const Color(0xFFFFEDD5), const Color(0xFF9A3412))), const SizedBox(width: 16), Expanded(child: _buildSmallStat('Rows', '${_excelRows?.length ?? 0} Count', Icons.description_outlined, const Color(0xFFEEF2FF), const Color(0xFF3730A3)))]);
  }

  Widget _buildRecentPaymentsHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Purchase Preview', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF111827))),
        TextButton(onPressed: () { if (_excelRows != null) { Navigator.push(context, MaterialPageRoute(builder: (context) => FullMirrorReportPage(headers: _headers ?? [], rows: _excelRows!))); } }, child: Text('Show All', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700)))
    ]);
  }

  Widget _buildSettingsView() {
    return SingleChildScrollView(padding: const EdgeInsets.all(20.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ACCOUNT SETTINGS', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF6B7280), letterSpacing: 1)), const SizedBox(height: 24), _buildSettingsCard(), const SizedBox(height: 32), _buildLogoutButton(), const SizedBox(height: 32), Center(child: Text('Zeal v1.0.4', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF))))]));
  }

  Widget _buildSettingsCard() {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))]), child: Column(children: [_buildSettingsTile(Icons.person_outline, 'Profile Information', 'Update your name and email'), const Divider(height: 32), _buildSettingsTile(Icons.notifications_outlined, 'Notifications', 'Manage alerts and messages'), const Divider(height: 32), _buildSettingsTile(Icons.security_outlined, 'Privacy & Security', 'Manage your password')]));
  }

  Widget _buildLogoutButton() {
    return SizedBox(width: double.infinity, height: 56, child: ElevatedButton.icon(onPressed: _handleLogout, icon: const Icon(Icons.logout, size: 20), label: Text('Logout', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFEE2E2), foregroundColor: const Color(0xFFB91C1C), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))));
  }

  Widget _buildUploadView() {
    return SingleChildScrollView(padding: const EdgeInsets.all(24.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('DATA INGESTION', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF6B7280), letterSpacing: 1)), const SizedBox(height: 24), Text('Upload Dataset', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF111827))), const SizedBox(height: 32), _buildDropZone(), const SizedBox(height: 32), if (_uploadedFileName != null) _buildUploadedFileCard(), const SizedBox(height: 120)]));
  }

  Widget _buildDropZone() {
    return Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: const Color(0xFFE5E7EB), width: 2)), child: Column(children: [Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(20)), child: _isUploading ? const CircularProgressIndicator(color: Colors.black) : const Icon(Icons.file_upload_outlined, color: Colors.black, size: 40)), const SizedBox(height: 24), Text(_isUploading ? 'Uploading...' : 'Drop your files here', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF111827))), const SizedBox(height: 8), Text('Excel (.xlsx) or CSV files supported.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6B7280))), const SizedBox(height: 32), ElevatedButton(onPressed: _isUploading ? null : _handleFileSelection, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Browse Files'))]));
  }

  Widget _buildUploadedFileCard() {
    final fileName = _uploadedFileName;
    if (fileName == null) return const SizedBox.shrink();
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.description, color: Color(0xFF059669))), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(fileName, style: GoogleFonts.inter(fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(_uploadedFileSize ?? 'Calculating...', style: GoogleFonts.inter(fontSize: 11, color: Color(0xFF6B7280)))])), IconButton(onPressed: _openFile, icon: const Icon(Icons.visibility_outlined, color: Colors.blue, size: 20)), IconButton(onPressed: _deleteFile, icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20))]));
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle) {
    return Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.black)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700)), Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)))])) , const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB))]);
  }

  Widget _buildSmallStat(String label, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 18)), const SizedBox(height: 16), Text(label, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280))), Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800))]));
  }

  Widget _buildQuickPaymentList() {
    final payments = _quickPayments;
    if (payments == null || payments.isEmpty) return const SizedBox.shrink();
    return Column(children: payments.take(5).map((p) => ListTile(title: Text(p['name'] ?? 'Data'), trailing: Text(p['amount'] ?? '', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)), leading: const CircleAvatar(radius: 12, backgroundColor: Color(0xFFF3F4F6)))).toList());
  }
}

class FullMirrorReportPage extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  const FullMirrorReportPage({super.key, required this.headers, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)), title: Text('Show All Records', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.black))),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('COMPLETE REPLICA', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF6B7280), letterSpacing: 1)),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]),
                child: DataTable(
                  headingTextStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF9CA3AF)),
                  dataTextStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF111827)),
                  columns: headers.map((h) => DataColumn(label: Text(h.toUpperCase()))).toList(),
                  rows: rows.map((r) => DataRow(cells: r.map((c) => DataCell(Text(c))).toList())).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
