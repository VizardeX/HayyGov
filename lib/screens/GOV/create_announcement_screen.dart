import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _titleController = TextEditingController();
  final _infoController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUrlController = TextEditingController();

  DateTime? _startDateTime;
  DateTime? _endDateTime;

  PlatformFile? _selectedPdf;
  String? _pdfUrl;
  bool _uploadingPdf = false;

  Future<void> _pickDateTime({
    required BuildContext context,
    required Function(DateTime) onPicked,
    DateTime? initialDateTime,
  }) async {
    final now = initialDateTime ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );
      if (pickedTime != null) {
        final fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        onPicked(fullDateTime);
      }
    }
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.extension == 'pdf') {
      setState(() {
        _selectedPdf = result.files.single;
      });
    }
  }

  Future<String?> _uploadPdf(PlatformFile file) async {
    final dio = Dio();
    final String uploadUrl = 'https://api.pdf.co/v1/file/upload';
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path!, filename: file.name),
    });
    try {
      final response = await dio.post(
        uploadUrl,
        data: formData,
        options: Options(
          headers: {
            'x-api-key':
                'wajeehf168@gmail.com_np48vBNdG1NsB8mOhWXAECThcALtbd3CJnCFlmy3NHq0WKbdHtzdl7gKvTlRpHSo',
          },
        ),
      );
      print(
        'PDF.co response: \\nStatus: \\${response.statusCode}\\nData: \\${response.data}',
      );
      if (response.statusCode == 200 && response.data['url'] != null) {
        return response.data['url'];
      } else if (response.data['presignedUrl'] != null) {
        return response.data['url'] ?? response.data['presignedUrl'];
      } else {
        // Print error message from API
        print('PDF.co error: \\${response.data}');
        return null;
      }
    } catch (e) {
      print('PDF upload error: \\n$e');
      if (e is DioError && e.response != null) {
        print(
          'DioError response: \\nStatus: \\${e.response?.statusCode}\\nData: \\${e.response?.data}',
        );
      }
    }
    return null;
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final info = _infoController.text.trim();
    final location = _locationController.text.trim();
    final picture = _imageUrlController.text.trim();

    if (title.isEmpty ||
        info.isEmpty ||
        location.isEmpty ||
        picture.isEmpty ||
        _startDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    setState(() {
      _uploadingPdf = true;
    });
    String? pdfUrl;
    if (_selectedPdf != null) {
      pdfUrl = await _uploadPdf(_selectedPdf!);
      if (pdfUrl == null) {
        setState(() {
          _uploadingPdf = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to upload PDF")));
        return;
      }
    }
    setState(() {
      _uploadingPdf = false;
    });

    final data = {
      "Title": title,
      "Info": info,
      "Location": location,
      "Picture": picture,
      "Time": _startDateTime,
    };
    if (_endDateTime != null) {
      data["EndTime"] = _endDateTime;
    }
    if (pdfUrl != null) {
      data["PdfUrl"] = pdfUrl;
    }
    try {
      await FirebaseFirestore.instance.collection("Announcements").add(data);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Announcement created")));

      Navigator.pop(context);
    } catch (e) {
      print("🔥 Firestore write error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating announcement: $e")),
      );
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final date =
        "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    final time =
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    return "$date $time";
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFFE5E0DB);
    final Color cardColor = Colors.white;
    final Color borderColor = const Color(0xFFD6CFC7);
    final Color accentColor = const Color(0xFF22211F);
    final Color submitBg = const Color(0xFF22211F);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create Announcement',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            // Card with form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 2),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title field: both Arabic and English in one box
                    TextField(
                      controller: _titleController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Enter title... / ...أدخل العنوان',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F5F2), // subtle off-white
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB0A99F), width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB0A99F), width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF22211F), width: 2.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Image URL input only (no preview or arrow)
                    TextField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        hintText: 'Image URL...',
                        filled: true,
                        fillColor: const Color(0xFFF7F5F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB0A99F), width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB0A99F), width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF22211F), width: 2.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 18),
                    // PDF picker
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _uploadingPdf ? null : _pickPdf,
                            icon: const Icon(
                              Icons.picture_as_pdf,
                              color: Color(0xFFB71C1C),
                            ),
                            label: const Text(
                              'Attach PDF',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEEDFD3),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                  color: Color(0xFFD6CFC7),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (_selectedPdf != null)
                          Expanded(
                            child: Text(
                              _selectedPdf!.name,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (_uploadingPdf)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Start and End DateTime pickers with calendar icon
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: _formatDateTime(_startDateTime),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Start date & time...',
                              prefixIcon: IconButton(
                                icon: Icon(
                                  Icons.calendar_today,
                                  color: accentColor,
                                ),
                                onPressed: () async {
                                  await _pickDateTime(
                                    context: context,
                                    onPicked: (dateTime) {
                                      setState(() {
                                        _startDateTime = dateTime;
                                      });
                                    },
                                    initialDateTime: _startDateTime,
                                  );
                                },
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF7F5F2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFB0A99F), width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFB0A99F), width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF22211F), width: 2.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: _formatDateTime(_endDateTime),
                            ),
                            decoration: InputDecoration(
                              hintText: 'End date & time...',
                              prefixIcon: IconButton(
                                icon: Icon(
                                  Icons.calendar_today,
                                  color: accentColor,
                                ),
                                onPressed: () async {
                                  await _pickDateTime(
                                    context: context,
                                    onPicked: (dateTime) {
                                      setState(() {
                                        _endDateTime = dateTime;
                                      });
                                    },
                                    initialDateTime: _endDateTime,
                                  );
                                },
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF7F5F2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFB0A99F), width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFB0A99F), width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF22211F), width: 2.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Time & Date label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Time & Date",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        Text(
                          "الوقت والتاريخ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Location field
                    Row(
                      children: [
                        Icon(Icons.location_on, color: accentColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              hintText: 'Location',
                              filled: true,
                              fillColor: const Color(0xFFF7F5F2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFB0A99F), width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFB0A99F), width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF22211F), width: 2.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Description field: both Arabic and English in one box
                    TextField(
                      controller: _infoController,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Description... / ...وصف',
                        filled: true,
                        fillColor: const Color(0xFFF7F5F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB0A99F), width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB0A99F), width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF22211F), width: 2.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Submit button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 130,
              ), // More horizontal padding for a smaller button
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: submitBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ), // Less vertical padding for a shorter button
                  elevation: 0,
                  minimumSize: const Size(0, 36), // Reduce min height
                ),
                onPressed: _submit,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize:
                      MainAxisSize.min, // Make row as small as possible
                  children: const [
                    Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ), // Smaller font
                    ),
                    SizedBox(width: 8), // Less space between texts
                    Text(
                      "تقديم",
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
