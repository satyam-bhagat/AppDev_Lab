// import 'package:catalog_app/core/store.dart';
// import 'package:catalog_app/models/catalog.dart';
// import 'package:catalog_app/pages/adminlogin_page.dart';
// import 'package:catalog_app/pages/adminpanel_page.dart';
// import 'package:catalog_app/pages/cart_page.dart';
// import 'package:catalog_app/pages/home_detail_page.dart';
// import 'package:catalog_app/pages/home_page.dart';
// import 'package:catalog_app/pages/login_page.dart';
// import 'package:catalog_app/pages/phone_auth_page.dart'; // <-- ADDED
// import 'package:catalog_app/pages/profile_page.dart';
// import 'package:catalog_app/pages/signup_page.dart';
// import 'package:catalog_app/pages/vipupsell.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:velocity_x/velocity_x.dart';
// import 'dart:async';

// class MyRoutes {
//   static const String loginRoute = "/login";
//   static const String signupRoute = "/signup";
//   static const String homeRoute = "/";
//   static const String homeDetailsRoute = "/detail";
//   static const String cartRoute = "/cart";
//   static const String profileRoute = "/profile";
//   static const String vipRoute = "/vip";
//   static const String adminLoginRoute = "/admin-login";
//   static const String adminPanelRoute = "/admin-panel";
//   static const String phoneAuthRoute = "/phone-auth"; // <-- ADDED

//   static final router = GoRouter(
//     initialLocation: homeRoute,
//     refreshListenable: StreamQueryListenable(
//       FirebaseAuth.instance.authStateChanges(),
//     ),
//     routes: [
//       GoRoute(
//         path: homeRoute,
//         builder: (context, state) => const HomePage(),
//       ),
//       GoRoute(
//         path: loginRoute,
//         builder: (context, state) => const LoginPage(),
//       ),
//       GoRoute(
//         path: signupRoute,
//         builder: (context, state) => const SignupPage(),
//       ),
//       GoRoute(
//         path: cartRoute,
//         builder: (context, state) => const CartPage(),
//       ),
//       GoRoute(
//         path: homeDetailsRoute,
//         builder: (context, state) {
//           Item catalog = state.extra as Item;
//           return HomeDetailPage(catalog: catalog);
//         },
//       ),
//       GoRoute(
//         path: profileRoute,
//         builder: (context, state) => const ProfilePage(),
//       ),
//       GoRoute(
//         path: vipRoute,
//         builder: (context, state) => const VipUpsellPage(),
//       ),
//       // --- ADDED THIS ROUTE ---
//       GoRoute(
//         path: phoneAuthRoute,
//         builder: (context, state) => const PhoneAuthPage(),
//       ),
//       // ---
//       GoRoute(
//         path: adminLoginRoute,
//         builder: (context, state) {
//           final params = state.extra as Map<String, String>;
//           return AdminLoginPage(
//             email: params['email']!,
//             password: params['password']!,
//           );
//         },
//       ),
//       GoRoute(
//         path: adminPanelRoute,
//         builder: (context, state) => const AdminPanelPage(),
//       ),
//     ],
//     redirect: (BuildContext context, GoRouterState state) {
//       final store = (VxState.store as MyStore);
//       final bool isLoggedIn = store.isLoggedIn;
//       final String role = store.role;

//       // --- ADDED phoneAuthRoute HERE ---
//       final allowedRoutes = [
//         loginRoute,
//         signupRoute,
//         adminLoginRoute,
//         phoneAuthRoute
//       ];
//       final isAuthRoute = allowedRoutes.contains(state.matchedLocation);

//       final adminRoute = state.matchedLocation == adminPanelRoute;

//       if (adminRoute) {
//         if (!isLoggedIn) return loginRoute;
//         if (role != 'admin') return homeRoute;
//         return null;
//       }

//       if (!isLoggedIn) {
//         if (state.matchedLocation == homeRoute) return null;
//         if (!isAuthRoute) return loginRoute;
//       }

//       if (isLoggedIn && isAuthRoute) {
//         return homeRoute;
//       }

//       return null;
//     },
//   );
// }

// // ... (StreamQueryListenable and MultiStream classes remain the same)
// class StreamQueryListenable extends ChangeNotifier {
//   late final Stream<dynamic> _stream;
//   StreamSubscription<dynamic>? _subscription;
//   StreamQueryListenable(this._stream) {
//     _subscription = _stream.listen((_) => notifyListeners());
//   }

//   @override
//   void dispose() {
//     _subscription?.cancel();
//     super.dispose();
//   }
// }

import 'package:catalog_app/core/store.dart';
import 'package:catalog_app/models/catalog.dart';
// import 'package:catalog_app/models/user.dart';
// import 'package:catalog_app/pages/admin_login_page.dart';
// import 'package:catalog_app/pages/admin_panel_page.dart';
import 'package:catalog_app/pages/adminlogin_page.dart';
import 'package:catalog_app/pages/adminpanel_page.dart';
import 'package:catalog_app/pages/cart_page.dart';
import 'package:catalog_app/pages/checkout_page.dart';
import 'package:catalog_app/pages/home_detail_page.dart';
import 'package:catalog_app/pages/home_page.dart';
import 'package:catalog_app/pages/login_page.dart';
import 'package:catalog_app/pages/phone_auth_page.dart';
import 'package:catalog_app/pages/profile_page.dart';
import 'package:catalog_app/pages/signup_page.dart';
// import 'package:catalog_app/pages/vip_upsell_page.dart';
import 'package:catalog_app/pages/vipupsell.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velocity_x/velocity_x.dart';
import 'dart:async';

class MyRoutes {
  static const String loginRoute = "/login";
  static const String signupRoute = "/signup";
  static const String homeRoute = "/";
  static const String homeDetailsRoute = "/detail";
  static const String cartRoute = "/cart";
  static const String profileRoute = "/profile";
  static const String vipRoute = "/vip";
  static const String adminLoginRoute = "/admin-login";
  static const String adminPanelRoute = "/admin-panel";
  static const String phoneAuthRoute = "/phone-auth";
  static const String checkoutRoute = "/checkout";

  static final router = GoRouter(
    initialLocation: homeRoute,

    // --- FIX 1: Simplify the refresh listener ---
    // This removes the static error and listens ONLY to auth state.
    refreshListenable: StreamQueryListenable(
      FirebaseAuth.instance.authStateChanges(),
    ),
    // --- END FIX 1 ---

    routes: [
      GoRoute(
        path: homeRoute,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: loginRoute,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: signupRoute,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: cartRoute,
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: checkoutRoute,
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: homeDetailsRoute,
        builder: (context, state) {
          Item catalog = state.extra as Item;
          return HomeDetailPage(catalog: catalog);
        },
      ),
      GoRoute(
        path: profileRoute,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: vipRoute,
        builder: (context, state) => const VipUpsellPage(),
      ),
      GoRoute(
        path: phoneAuthRoute,
        builder: (context, state) => const PhoneAuthPage(),
      ),
      GoRoute(
        path: adminLoginRoute,
        builder: (context, state) {
          final params = state.extra as Map<String, String>;
          return AdminLoginPage(
            email: params['email']!,
            password: params['password']!,
          );
        },
      ),
      GoRoute(
        path: adminPanelRoute,
        builder: (context, state) => const AdminPanelPage(),
      ),
    ],

    // --- FIX 2: Simplify the redirect logic ---
    // This logic is now fast and has no race condition.
    // It only checks Firebase, not the VxStore.
    redirect: (BuildContext context, GoRouterState state) {
      // 1. Get the user's login status *directly* from Firebase.
      final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

      // 2. Check if the user is on an auth page (login, signup, etc.)
      final allowedRoutes = [
        loginRoute,
        signupRoute,
        adminLoginRoute,
        phoneAuthRoute
      ];
      final isAuthRoute = allowedRoutes.contains(state.matchedLocation);

      // 3. Check if the user is trying to access the admin panel
      final isAdminRoute = state.matchedLocation == adminPanelRoute;

      // --- REDIRECT LOGIC ---

      // If on an admin route, check role (we DO need the store here)
      if (isAdminRoute) {
        // This check happens *after* login, so the store is updated.
        final storeRole = (VxState.store as MyStore).role;
        if (!isLoggedIn) return loginRoute; // Not logged in
        if (storeRole != 'admin') return homeRoute; // Logged in, but NOT admin
        return null; // Is admin, allow access
      }

      // If user is NOT logged in
      if (!isLoggedIn) {
        // If they are on the home page, let them stay (as a guest)
        if (state.matchedLocation == homeRoute) return null;
        // If they are on any other page, but not an auth page, send to login
        if (!isAuthRoute) return loginRoute;
      }

      // If user IS logged in
      if (isLoggedIn) {
        // If they are on an auth page (Login, Signup), send them to Home.
        // This is what solves your "stuck" problem.
        if (isAuthRoute) return homeRoute;
      }

      // No redirect needed
      return null;
    },
    // --- END FIX 2 ---
  );
}

// Helper class for GoRouter
class StreamQueryListenable extends ChangeNotifier {
  late final Stream<dynamic> _stream;
  StreamSubscription<dynamic>? _subscription;
  StreamQueryListenable(this._stream) {
    _subscription = _stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
