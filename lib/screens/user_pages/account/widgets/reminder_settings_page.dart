import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:learn_english/components/app_background.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class ReminderSettingsPage extends StatefulWidget {
  const ReminderSettingsPage({super.key});

  @override
  State<ReminderSettingsPage> createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends State<ReminderSettingsPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar',
    ],
  );

  GoogleSignInAccount? _currentUser;
  DateTime? _selectedDateTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      _showMessage("Không thể đăng nhập Google", success: false);
    }
  }

  /// Chọn ngày + giờ bằng OmniDateTimePicker
  Future<void> _pickDateTime() async {
    DateTime? pickedDateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      is24HourMode: true,
      isShowSeconds: false,
      type: OmniDateTimePickerType.dateAndTime,
      borderRadius: BorderRadius.circular(16),
      constraints: const BoxConstraints(
        maxWidth: 350,
        maxHeight: 600,
      ),
      theme: ThemeData(
        primaryColor: const Color(0xFF5D8BF4),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF5D8BF4),
          onPrimary: Colors.white,
          onSurface: Colors.black,
        ),
      ),
    );

    if (pickedDateTime != null) {
      setState(() => _selectedDateTime = pickedDateTime);
    }
  }

  Future<void> _addEventToGoogleCalendar() async {
    if (_currentUser == null) {
      _showMessage("Bạn cần đăng nhập Google trước", success: false);
      return;
    }
    if (_selectedDateTime == null) {
      _showMessage("Vui lòng chọn thời gian nhắc nhở", success: false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authHeaders = await _currentUser!.authHeaders;
      final client = GoogleAuthClient(authHeaders);
      final calendarApi = calendar.CalendarApi(client);

      final startTime = _selectedDateTime!;
      final endTime = startTime.add(const Duration(minutes: 30));

      final event = calendar.Event(
        summary: "Học tiếng Anh",
        description: "Nhắc nhở học tập",
        start: calendar.EventDateTime(
          dateTime: startTime,
          timeZone: "Asia/Ho_Chi_Minh",
        ),
        end: calendar.EventDateTime(
          dateTime: endTime,
          timeZone: "Asia/Ho_Chi_Minh",
        ),
        reminders: calendar.EventReminders(
          useDefault: false,
          overrides: [
            calendar.EventReminder(method: "popup", minutes: 10),
          ],
        ),
      );

      await calendarApi.events.insert(event, "primary");
      _showMessage("✅ Đã thêm nhắc nhở vào Google Calendar", success: true);
    } catch (e) {
      _showMessage("❌ Lỗi khi thêm sự kiện: $e", success: false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSignedIn = _currentUser != null;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Cài đặt nhắc nhở học tập"),
          backgroundColor: const Color(0xFF5AA0E3),
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.login, color: Color(0xFF21588E)),
                  title: Text(
                    isSignedIn
                        ? "Đã đăng nhập: ${_currentUser!.email}"
                        : "Đăng nhập Google",
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: _handleSignIn,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.access_time, color: Color(
                      0xFF1C5A95)),
                  title: Text(
                    _selectedDateTime == null
                        ? "Chọn thời gian nhắc nhở"
                        : "Nhắc nhở: ${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} "
                        "${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: _pickDateTime,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _addEventToGoogleCalendar,
                icon: const Icon(Icons.add_alert),
                label: _isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text("Thêm vào Google Calendar",
                    style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D69A8),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper client để gọi API Google
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = IOClient();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
