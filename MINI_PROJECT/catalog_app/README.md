# 📱 Catalog App (Flutter + Firebase)

A **multi-role e-commerce catalog application** built using **Flutter**,
**Firebase**, and **VelocityX**, featuring secure authentication,
VIP-tiered access, and a fully functional admin management panel.

## 🎯 Aim

To build a **secure, scalable, and feature-rich catalog app** that
supports **four different user experiences**---**Guest**, **User**,
**VIP**, and **Admin**---powered entirely by **Firebase Authentication**
and **Cloud Firestore**.

## 🛠️ Technology Stack

### Frontend

    -   Flutter\
    -   Dart\
    -   VelocityX (VxState)\
    -   GoRouter (Auth-aware routing)

### Backend (BaaS)

    -   Firebase Authentication\
    -   Cloud Firestore\
    -   Firebase Storage

### External API

    -   FakeStoreAPI (Product data)

## ✨ Key Features

### 1. Advanced Authentication & Security

✔️ Email/Password Login\
✔️ Google Sign-In\
✔️ Phone (OTP) Login\
✔️ Secure Sign-Up with Confirm Password\
✔️ Auth-Aware Routing with GoRouter\
✔️ Password Reset via Email

### 2. Role-Based Access Control (RBAC)

  Role        Description
  ----------- --------------------------------------------
  **Guest**   Not logged in; read-only access.
  **User**    Basic user; cart and profile enabled.
  **VIP**     VIP tier with item unlocks based on level.
  **Admin**   Full access + admin panel.

### 3. VIP & Admin System

#### Admin Login

    -   Admin email/password login\
    -   Secret admin code from `app_config/admin_code`

#### Admin Panel Includes

    -   Dashboard (Total Users, VIP Members, Admin Accounts)\
    -   User Management (search, update role, update VIP Level)

#### VIP Levels

    -   Level 1 -- Silver\
    -   Level 2 -- Gold\
    -   Level 3 -- Platinum

### 4. User & E-Commerce Features

    -   Edit profile (name, username, phone, birth date, gender)\
    -   Profile picture upload\
    -   Dynamic cart\
    -   Product search

## 📌 Expected App Flow

### Guest

    -   Browse only\
    -   Must sign in to add items

### User Sign-Up

Creates Firestore document:

    {"role": "user", "vipLevel": 0}

### Admin Login Flow

    1.  Sign in\
    2.  Enter Admin Code\
    3.  Admin Panel access

## 🚀 Future Improvements

      -   Dark Mode\
      -   Payment Gateway\
      -   Order History\
      -   Push Notifications
