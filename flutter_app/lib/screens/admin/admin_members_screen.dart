import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../models/user_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'add_edit_member_screen.dart';

class AdminMembersScreen extends StatefulWidget {
  const AdminMembersScreen({super.key});

  @override
  State<AdminMembersScreen> createState() => _AdminMembersScreenState();
}

class _AdminMembersScreenState extends State<AdminMembersScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<UserModel> _members = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getUsers();
      if (response.statusCode == 200 && response.data['success']) {
        setState(() {
          _members = (response.data['data'] as List)
              .map((json) => UserModel.fromJson(json))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Show add member dialog
              _showAddMemberDialog();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMembers,
              child: _members.isEmpty
                  ? Center(child: Text('No members found'))
                  : ListView.builder(
                      itemCount: _members.length,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        final member = _members[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(member.name[0].toUpperCase()),
                            ),
                            title: Text(member.name),
                            subtitle: Text('${member.email}\n${member.phone}'),
                            trailing: member.membershipType != null
                                ? Chip(
                                    label: Text(member.membershipType!),
                                    backgroundColor: Colors.green.shade100,
                                  )
                                : null,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AddEditMemberScreen(member: member),
                                ),
                              ).then((updated) {
                                if (updated == true) {
                                  _loadMembers();
                                }
                              });
                            },
                            onLongPress: () {
                              _showDeleteDialog(member);
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  void _showAddMemberDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditMemberScreen(),
      ),
    ).then((added) {
      if (added == true) {
        _loadMembers();
      }
    });
  }

  void _showDeleteDialog(UserModel member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Member'),
        content: Text('Are you sure you want to delete ${member.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteMember(member.id);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMember(String memberId) async {
    try {
      final response = await _apiService.deleteUser(memberId);
      if (response.statusCode == 200 && response.data['success']) {
        Fluttertoast.showToast(msg: 'Member deleted successfully');
        _loadMembers();
      } else {
        Fluttertoast.showToast(msg: response.data['message'] ?? 'Failed to delete member');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    }
  }
}
