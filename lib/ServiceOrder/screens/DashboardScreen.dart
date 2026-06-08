// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'DashboardHome.dart';
// import 'NotificationScreen.dart';
// import 'WorkGroupScreen.dart';
// import 'PETaskListScreen.dart';

// class DashboardScreen extends StatefulWidget {
//   final Map<String, dynamic>? user; // Accept user data from LoginScreen

//   const DashboardScreen({super.key, this.user});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   int myIndex = 0;

//   final List<Widget> _pages = [
//     const DashboardHome(),
//     const NotificationScreen(),
//     const WorkGroupScreen(),
//     const PETaskListScreen(),
//   ];

//   void _openEndDrawer() {
//     _scaffoldKey.currentState?.openEndDrawer();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Default user data if not provided (for testing)
//     final user = widget.user ??
//         {
//           'Name': 'Guest',
//           'ServiceId': 'SVC000',
//           'Email': 'guest@example.com',
//           'PhotoUrl': 'https://via.placeholder.com/150', // Placeholder image
//         };

//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         toolbarHeight: 70,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(20),
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 5,
//         systemOverlayStyle: const SystemUiOverlayStyle(
//           statusBarColor: Colors.transparent,
//           statusBarIconBrightness: Brightness.light,
//         ),
//         automaticallyImplyLeading: false,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text(
//           'Service Order',
//           style: TextStyle(
//             color: Theme.of(context).cardColor,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.menu, color: Colors.white),
//             onPressed: _openEndDrawer,
//           ),
//         ],
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Color.fromARGB(226, 16, 37, 89),
//                 Color.fromARGB(255, 8, 11, 66),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//         ),
//       ),
//       body: myIndex < _pages.length ? _pages[myIndex] : _pages[0],
//       endDrawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Color.fromARGB(226, 16, 37, 89),
//                     Color.fromARGB(255, 8, 11, 66),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   // User Photo
//                   CircleAvatar(
//                     radius: 30,
//                     backgroundImage: NetworkImage(
//                         user['PhotoUrl'] ?? 'https://via.placeholder.com/150'),
//                   ),
//                   const SizedBox(width: 10),
//                   // User Details
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         user['Name'] ?? 'Guest',
//                         style:
//                             const TextStyle(color: Theme.of(context).cardColor, fontSize: 20),
//                       ),
//                       Text(
//                         user['Email'] ?? 'guest@example.com',
//                         style: const TextStyle(
//                             color: Colors.white70, fontSize: 14),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: const Text('Profile'),
//               onTap: () {
//                 setState(() => myIndex = 0);
//                 Navigator.pop(context);
//                 // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
//               },
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: myIndex,
//         type: BottomNavigationBarType.fixed,
//         onTap: (index) {
//           if (index >= 0 && index < _pages.length) {
//             setState(() {
//               myIndex = index;
//             });
//           }
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.group), label: 'Work Groups'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.event), label: 'PE Task List'),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../PlannedEvent/service/AuthService.dart' as auth;
import 'DashboardHome.dart';
import 'NotificationScreen.dart';
import 'WorkGroupScreen.dart';
import 'PETaskListScreen.dart';
import 'SelectWorkgroupScreen.dart';
import '../components/Sidebar.dart';
// adjust path if needed
import 'RegularRecordScreen.dart';
import 'UrgentRecordScreen.dart';
import 'HoldRecordScreen.dart';
import 'OLAViolateRecordScreen.dart';
import 'DormantRecordScreen.dart';
import 'ProjectsScreen.dart';
import 'DataManagementScreen.dart';
import 'WorkgroupReportScreen.dart';
import 'OPMCReportScreen.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  const DashboardScreen({super.key, this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int myIndex = 0;
  Map<String, dynamic>? _currentUser;
  bool _isLoadingUser = true;

  Future<void> _loadUserInfo() async {
    if (widget.user != null) {
      setState(() {
        _currentUser = widget.user;
        _isLoadingUser = false;
      });
      return;
    }

    try {
      final user = await auth.AuthService().getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoadingUser = false;
      });
    } catch (e) {
      setState(() => _isLoadingUser = false);
    }
  }

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _pages = [
      DashboardHome(
        user: widget.user,
        onNavigate: (sidebarIndex) => _handleNavigation(sidebarIndex),
      ),
      const NotificationScreen(),
      const WorkGroupScreen(),
      const PETaskListScreen(),
      RegularRecordScreen(
        user: widget.user ?? {},
        onBack: () => setState(() => myIndex = 0),
      ), // index 4
      UrgentRecordScreen(
        user: widget.user ?? {},
        onBack: () => setState(() => myIndex = 0),
      ), // index 5
      HoldRecordScreen(
        user: widget.user ?? {},
        onBack: () => setState(() => myIndex = 0),
      ), // index 6
      OLAViolateRecordScreen(
        user: widget.user ?? {},
        onBack: () => setState(() => myIndex = 0),
      ), // index 7
      DormantRecordScreen(
        user: widget.user ?? {},
        onBack: () => setState(() => myIndex = 0),
      ), // index 8
      ProjectsScreen(
        user: widget.user ?? {},
        onBack: () => setState(() => myIndex = 0),
      ), // index 9
      DataManagementScreen(
        user: widget.user ?? {},
        onBack: () => setState(() => myIndex = 0),
      ), // index 10
      WorkgroupReportScreen(
        user: widget.user ?? {},
        onBack: () => setState(() => myIndex = 0),
      ), // index 11
      OPMCReportScreen(
        user: widget.user ?? {},
        onBack: () => setState(() => myIndex = 0),
      ), // index 12
    ];
  }

  void _handleNavigation(int sidebarIndex) {
    int pageIndex = 0;
    if (sidebarIndex == 0) {
      pageIndex = 0;
    } else if (sidebarIndex == 1)
      pageIndex = 4; // Regular
    else if (sidebarIndex == 2)
      pageIndex = 5; // Urgent
    else if (sidebarIndex == 3)
      pageIndex = 6; // Hold
    else if (sidebarIndex == 4)
      pageIndex = 7; // OLA
    else if (sidebarIndex == 5)
      pageIndex = 8; // Dormant
    else if (sidebarIndex == 6)
      pageIndex = 9; // Projects
    else if (sidebarIndex == 7)
      pageIndex = 10; // Data Management
    else if (sidebarIndex == 8)
      pageIndex = 11; // Workgroup Reports
    else if (sidebarIndex == 9)
      pageIndex = 12; // OPMC Reports

    else if (sidebarIndex == 14)
      pageIndex = 2; // Work Groups
    else if (sidebarIndex == 15)
      pageIndex = 3; // Task List
    else
      pageIndex = 0;

    setState(() {
      myIndex = pageIndex;
    });
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = _currentUser ??
        {
          'Name': 'Guest',
          'ServiceId': 'SVC000',
          'Email': 'guest@example.com',
          'UserRole': 'Admin',
          'PhotoBase64': '',
        };

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SelectWorkgroupScreen(),
          ),
        );
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: (myIndex >= 4 && myIndex <= 8)
            ? null
            : AppBar(
                toolbarHeight: 70,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 5,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                ),
                automaticallyImplyLeading: false,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                iconTheme: const IconThemeData(color: Colors.white),

                // Updated title with role
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Service Order',
                      style: TextStyle(
                        color: Theme.of(context).cardColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user['UserRole'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                actions: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SelectWorkgroupScreen(),
                        ),
                      );
                    },
                  ),
                ],
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(226, 16, 37, 89),
                        Color.fromARGB(255, 8, 11, 66),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
        body: myIndex < _pages.length ? _pages[myIndex] : _pages[0],
        endDrawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(226, 16, 37, 89),
                      Color.fromARGB(255, 8, 11, 66),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        user['PhotoUrl'] ?? 'https://via.placeholder.com/150',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user['Name'] ?? 'Guest',
                          style: TextStyle(
                              color: Theme.of(context).cardColor, fontSize: 20),
                        ),
                        Text(
                          user['Email'] ?? 'guest@example.com',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  setState(() => myIndex = 0);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: myIndex == 5 ? 1 : (myIndex > 2 ? 0 : myIndex),
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              if (index == 1) {
                myIndex = 5;
              } else {
                myIndex = index;
              }
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
            BottomNavigationBarItem(
                icon: Icon(Icons.group), label: 'Work Groups'),
          ],
        ),
        drawer: AppSidebar(
          user: user,
          currentIndex: myIndex,
          onItemSelected: (index) {
            _handleNavigation(index);
          },
        ),
      ),
    );
  }
}
