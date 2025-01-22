import 'package:flutter/material.dart';
import 'package:party_scan/services/database.dart';
import '../../components/edit_user_dialog.dart';

class ManageUsersScreen extends StatefulWidget {
  final List<Map<String, dynamic>> users;

  const ManageUsersScreen({super.key, required this.users});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}
class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String searchQuery = '';
  List<Map<String, dynamic>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    filteredUsers = widget.users;
  }

  void filterUsers(String query) {
    setState(() {
      searchQuery = query;
      filteredUsers = widget.users.where((user) {
        return user['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
               user['code'].toString().toLowerCase().contains(query.toLowerCase()) ||
               user['phone'].toString().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: true,
            title: const Text('Manage Users'),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.teal.withOpacity(0.4), Colors.cyan.withOpacity(0.1)]),
                ),
                child: TextField(
                  onChanged: filterUsers,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    fillColor: Colors.blue.withOpacity(0.1),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var user = filteredUsers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(user['code']?.substring(user['code'].length - 3) ?? ''),
                    ),
                    title: Text(user['name'] ?? ''),
                    subtitle: Text('Code: ${user['code'] ?? ''}\nDesignation: ${user['designation'] ?? ''}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => EditUserDialog(usersData: [user]),
                        );
                      },
                    ),
                    onLongPress: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete User'),
                        content: Text('Are you sure you want to delete ${user['name']}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                Database.deleteUser(user['code']??'');
                                widget.users.removeAt(index);
                                filterUsers(searchQuery);
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: filteredUsers.length,
            ),
          ),
        ],
      ),
    );
  }
}