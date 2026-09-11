import 'package:connect_call/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ConnectCall'),

        actions: [

            IconButton(
  icon: const Icon(Icons.person),
  tooltip: 'Profile',
  onPressed: () {
    Get.toNamed(AppRoutes.userProfile, arguments: User);
  },
),
          // Call History
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Call History',
            onPressed: () {
              Get.toNamed(AppRoutes.history);
            },
          ),
          

          // Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.offAllNamed('/login');
            },
          ),
        
        ],
      ),

      body: Column(
        children: [
          // Search users
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: controller.searchUsers,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Logged-in user
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Logged in as: ${currentUser.email}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 10),

          // Users list
          Expanded(
            child: Obx(() {
              // Loading
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // No users
              if (controller.filteredUsers.isEmpty) {
                return const Center(
                  child: Text(
                    'No users found',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                );
              }

              // Users
              return RefreshIndicator(
                onRefresh: controller.loadUsers,
                child: ListView.builder(
                  itemCount: controller.filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user =
                        controller.filteredUsers[index];

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                        ),
                      ),

                      title: Text(
                        user.name.isNotEmpty
                            ? user.name
                            : 'Unknown User',
                      ),

                      subtitle: Text(user.email),

                      // Online status
                      trailing: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: user.isOnline
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),

                      // Open user profile
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.userProfile,
                          arguments: user,
                        );
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}