// lib/home/tabs/profile_tab.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  Future<String?> _getUserRole(String uid) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return userDoc['role'] as String?;
    }
    return null;
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Implement delete account functionality here
      debugPrint("User confirmed account deletion.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account deletion is not implemented yet.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("User not logged in."));
    }

    return FutureBuilder<String?>(
      future: _getUserRole(user.uid),
      builder: (context, snapshot) {
        String? role = snapshot.data;
        bool isAdmin = role == 'admin';

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // User Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  user.displayName != null && user.displayName!.isNotEmpty
                      ? user.displayName![0].toUpperCase()
                      : 'U',
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              // User Email
              Text(
                user.email ?? 'No Email',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              // Log Out Button
              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text("Log Out"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Delete Account Button
              ElevatedButton.icon(
                onPressed: () async {
                  await _confirmDeleteAccount(context);
                },
                icon: const Icon(Icons.delete),
                label: const Text("Delete Account"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Admin Only: Manage Harmful Ingredients
              if (isAdmin)
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to Harmful Ingredients Management Screen
                    debugPrint("Navigate to Harmful Ingredients Management Screen");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Navigation not implemented yet.")),
                    );
                  },
                  icon: const Icon(Icons.manage_accounts),
                  label: const Text("Manage Harmful Ingredients"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
