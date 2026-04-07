import 'dart:convert';

import 'package:bina_mualaf/model/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class ConsultationMessage {
  final String conversationId; // pembimbing_id + '_' + calon_mualaf_id
  final String senderId;
  final String senderName;
  final String senderRole;
  final String content;
  final String? voicePath;
  final String timestamp;

  ConsultationMessage({
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    this.voicePath,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'conversationId': conversationId,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'content': content,
        'voicePath': voicePath,
        'timestamp': timestamp,
      };

  factory ConsultationMessage.fromJson(Map<String, dynamic> json) => ConsultationMessage(
        conversationId: json['conversationId'],
        senderId: json['senderId'],
        senderName: json['senderName'],
        senderRole: json['senderRole'],
        content: json['content'],
        voicePath: json['voicePath'],
        timestamp: json['timestamp'],
      );
}

class Informasi extends StatefulWidget {
  const Informasi({super.key});

  @override
  _InformasiState createState() => _InformasiState();
}

class _InformasiState extends State<Informasi> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  User? _currentUser;
  List<User> _allUsers = [];
  List<User> get _pembimbingUsers => _allUsers.where((user) => user.role == 'pembimbing').toList();

  Future<void> _loadAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users') ?? '[]';
    final users = (json.decode(usersJson) as List<dynamic>)
        .map((e) => User.fromJson(e))
        .toList();
    setState(() {
      _allUsers = users;
    });
    // After loading users, load conversations if pembimbing
    if (_currentUser != null && _currentUser!.role == 'pembimbing') {
      _loadConversations();
    }
  }
  List<ConsultationMessage> _messages = [];
  List<ConsultationMessage> _allMessages = [];
  List<String> _conversations = []; // For pembimbing: list of conversation IDs
  String? _currentConversationId;
  static const _prefsKey = 'consultation_messages';
  bool _isRecording = false;
  String? _currentPlayingVoice;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadAllUsers();
    _loadAllMessages();
    _loadPembimbingUsers();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserJson = prefs.getString('current_user');
    if (currentUserJson != null) {
      setState(() {
        _currentUser = User.fromJson(json.decode(currentUserJson));
      });
      // Conversations will be loaded after users are loaded
    }
  }

  Future<void> _loadPembimbingUsers() async {
    // Now computed from _allUsers
  }

  Future<void> _loadConversations() async {
    // Get all calon mualaf users
    final calonMualafUsers = _allUsers.where((user) => user.role == 'calon_mualaf').toList();

    // Create conversation IDs for all calon mualaf (whether they have messages or not)
    final conversations = calonMualafUsers
        .map((user) => '${_currentUser!.id}_${user.id}')
        .toList();

    setState(() {
      _conversations = conversations;
      // Default to first conversation if exists
      if (_conversations.isNotEmpty) {
        _currentConversationId = _conversations.first;
        _updateMessagesForCurrentConversation();
      }
    });
  }

  Future<void> _loadAllMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey) ?? '[]';
    _allMessages = (json.decode(jsonString) as List<dynamic>)
        .map((e) => ConsultationMessage.fromJson(e))
        .toList();
    _updateMessagesForCurrentConversation();
  }

  void _updateMessagesForCurrentConversation() {
    if (_currentConversationId != null) {
      _messages = _allMessages
          .where((msg) => msg.conversationId == _currentConversationId)
          .toList()
        ..sort((a, b) => DateTime.parse(a.timestamp).compareTo(DateTime.parse(b.timestamp)));
    } else {
      _messages = [];
    }
    setState(() {});
  }



  Future<void> _saveAllMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(_allMessages.map((m) => m.toJson()).toList()));
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(const RecordConfig(), path: filePath);
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      setState(() {
        _isRecording = false;
      });
      if (path != null && _currentUser != null && _currentConversationId != null) {
        final message = ConsultationMessage(
          conversationId: _currentConversationId!,
          senderId: _currentUser!.id,
          senderName: _currentUser!.nama,
          senderRole: _currentUser!.role,
          content: '[Voice Message]',
          voicePath: path,
          timestamp: DateTime.now().toIso8601String(),
        );
        _allMessages.add(message);
        _updateMessagesForCurrentConversation();
        _saveAllMessages();
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _playVoice(String voicePath) async {
    try {
      if (_currentPlayingVoice == voicePath) {
        await _player.stop();
        setState(() {
          _currentPlayingVoice = null;
        });
      } else {
        await _player.stop();
        await _player.play(DeviceFileSource(voicePath));
        setState(() {
          _currentPlayingVoice = voicePath;
        });
        _player.onPlayerComplete.listen((event) {
          setState(() {
            _currentPlayingVoice = null;
          });
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentUser == null || _currentConversationId == null) return;

    final message = ConsultationMessage(
      conversationId: _currentConversationId!,
      senderId: _currentUser!.id,
      senderName: _currentUser!.nama,
      senderRole: _currentUser!.role,
      content: text,
      timestamp: DateTime.now().toIso8601String(),
    );

    _allMessages.add(message);
    _updateMessagesForCurrentConversation();
    _messageController.clear();
    _saveAllMessages();
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildChatBubble(ConsultationMessage message) {
    final isCurrentUser = _currentUser != null && message.senderId == _currentUser!.id;
    final alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isCurrentUser ? Colors.blueAccent : Colors.white;
    final textColor = isCurrentUser ? Colors.white : Colors.black87;

    return Align(
      alignment: alignment,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.senderName,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            if (message.voicePath != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _currentPlayingVoice == message.voicePath ? Icons.stop : Icons.play_arrow,
                      color: textColor,
                    ),
                    onPressed: () => _playVoice(message.voicePath!),
                  ),
                  Text(
                    'Voice Message',
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                ],
              )
            else
              Text(
                message.content,
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            const SizedBox(height: 6),
            Text(
              '${DateTime.parse(message.timestamp).hour.toString().padLeft(2, '0')}:${DateTime.parse(message.timestamp).minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: textColor.withAlpha((0.7 * 255).round()), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xff44aca0),
      appBar: AppBar(
        backgroundColor: const Color(0xff318c7b),
        title: Text(_currentUser!.role == 'pembimbing'
            ? 'Konsultasi - ${_currentUser!.nama}'
            : 'Chat dengan Pembimbing'),
      ),
      body: SafeArea(
        child: _currentUser!.role == 'pembimbing'
            ? _buildPembimbingView()
            : _buildCalonMualafView(),
      ),
    );
  }

  Widget _buildPembimbingView() {
    return Row(
      children: [
        // Conversations list
        Container(
          width: 120,
          color: Colors.white.withOpacity(0.9),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'Chats',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff318c7b),
                  ),
                ),
              ),
              Expanded(
                child: _conversations.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada chat',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _conversations.length,
                        itemBuilder: (context, index) {
                          final conversationId = _conversations[index];
                          final parts = conversationId.split('_');
                          final calonMualafId = parts.last;
                          final calonMualaf = _getUserById(calonMualafId);

                          final hasMessages = _checkHasMessages(conversationId);

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _currentConversationId = conversationId;
                              });
                              _updateMessagesForCurrentConversation();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _currentConversationId == conversationId
                                    ? const Color(0xff318c7b).withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: const Color(0xff318c7b),
                                        child: Text(
                                          calonMualaf?.nama.isNotEmpty == true
                                              ? calonMualaf!.nama[0].toUpperCase()
                                              : 'C',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (hasMessages)
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    calonMualaf?.nama ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (hasMessages)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Chat aktif',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
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
            ],
          ),
        ),
        // Chat area
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(12),
            child: _currentConversationId == null
                ? const Center(
                    child: Text('Pilih chat untuk mulai konsultasi'),
                  )
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Chat dengan ${_getConversationPartnerName()}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: _messages.isEmpty
                            ? const Center(
                                child: Text(
                                  'Belum ada pesan. Mulai konsultasi!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black54),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.only(top: 12, bottom: 12),
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  return _buildChatBubble(_messages[index]);
                                },
                              ),
                      ),
                      _buildMessageInput(),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalonMualafView() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff318c7b), Color(0xff5bd4c9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              const BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.15),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Konsultasi Pembimbing',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Halo, ${_currentUser!.nama}. Pilih pembimbing untuk konsultasi.',
                style: const TextStyle(fontSize: 15, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              const Text(
                'Daftar Pembimbing Tersedia',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: _pembimbingUsers.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada pembimbing terdaftar.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _pembimbingUsers.length,
                        itemBuilder: (context, index) {
                          final pembimbing = _pembimbingUsers[index];
                          final conversationId = '${pembimbing.id}_${_currentUser!.id}';
                          final isSelected = _currentConversationId == conversationId;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentConversationId = conversationId;
                              });
                              _updateMessagesForCurrentConversation();
                            },
                            child: Container(
                              width: 180,
                              margin: EdgeInsets.only(right: index == _pembimbingUsers.length - 1 ? 0 : 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color.fromRGBO(255, 255, 255, 0.3)
                                    : const Color.fromRGBO(255, 255, 255, 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected
                                    ? Border.all(color: Colors.white, width: 2)
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      pembimbing.nama.isNotEmpty ? pembimbing.nama[0].toUpperCase() : 'P',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff318c7b),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    pembimbing.nama,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    pembimbing.email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _currentConversationId == null
                        ? 'Pilih pembimbing untuk mulai chat'
                        : 'Chat dengan ${_getConversationPartnerName()}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _currentConversationId == null
                      ? const Center(
                          child: Text(
                            'Pilih pembimbing untuk memulai konsultasi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      : _messages.isEmpty
                          ? const Center(
                              child: Text(
                                'Mulai konsultasi dengan mengirim pesan.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black54),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(top: 12, bottom: 12),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                return _buildChatBubble(_messages[index]);
                              },
                            ),
                ),
                if (_currentConversationId != null) _buildMessageInput(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xfff1f1f1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Tulis pesan konsultasi...',
                border: InputBorder.none,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: _isRecording ? Colors.red : const Color(0xff318c7b),
            ),
            onPressed: _isRecording ? _stopRecording : _startRecording,
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xff318c7b)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  bool _checkHasMessages(String conversationId) {
    return _allMessages.any((msg) => msg.conversationId == conversationId);
  }

  User? _getUserById(String userId) {
    return _allUsers.firstWhere(
      (user) => user.id == userId,
      orElse: () => User(id: '', nama: '', email: '', password: '', role: ''),
    );
  }

  String _getConversationPartnerName() {
    if (_currentConversationId == null) return 'Unknown';
    final parts = _currentConversationId!.split('_');
    final partnerId = parts.first == _currentUser!.id ? parts.last : parts.first;
    final partner = _getUserById(partnerId);
    return partner?.nama ?? 'Unknown User';
  }
}
