# 📒 SecureNote — Secure Notes App with Flutter

## **SecureNote** adalah aplikasi catatan berbasis Flutter yang dirancang dengan fokus pada **keamanan data pengguna**.

### ✨ Fitur Utama

* 🔐 **Enkripsi data di penyimpanan (AES-256)**
  Semua catatan dienkripsi sebelum disimpan ke local storage (Hive).
* 🔑 **App Lock dengan PIN**
  Aplikasi terkunci menggunakan PIN yang disimpan dalam bentuk hash.
* 🔍 **Pencarian catatan realtime**
* 📝 **Tambah, edit, hapus catatan**
* ↩️ **Undo delete (Snackbar)**
* 🌗 **Light & Dark Theme**
* 🔒 **Auto lock saat aplikasi ditutup / background**

### 🛡️ Keamanan

* Data **tidak disimpan dalam plaintext**
* File database lokal (`.hive`) aman meskipun diakses langsung
* Kunci enkripsi saat ini **hardcoded untuk keperluan development**

> ⚠️ Catatan:
> Implementasi selanjutnya direncanakan menggunakan **PBKDF2 (PIN-based key derivation)** agar kunci enkripsi tidak disimpan di source code.
##

# 📒 SecureNote — Secure Notes App with Flutter

## **SecureNote** is a Flutter-based note-taking application with a strong focus on **data security**.

### ✨ Key Features

* 🔐 **AES-256 encryption at rest**
  Notes are encrypted before being stored in local storage (Hive).
* 🔑 **PIN-based App Lock**
  The app is protected using a hashed PIN.
* 🔍 **Realtime note search**
* 📝 **Create, edit, and delete notes**
* ↩️ **Undo delete via Snackbar**
* 🌗 **Light & Dark theme**
* 🔒 **Auto lock on app background / restart**

### 🛡️ Security

* Notes are **never stored in plaintext**
* Local database files cannot be read without the encryption key
* Current encryption key is **hardcoded for development/demo purposes**

> ⚠️ Note:
> A future improvement will derive the encryption key from the user’s PIN using **PBKDF2**, removing hardcoded keys and improving security for production use.

---

## 🚀 Tech Stack

* Flutter
* Dart
* Hive (Local Storage)
* AES Encryption
* Riverpod (State Management)

---

## 📌 Status

* ✅ Encryption at rest implemented
* ✅ App Lock implemented
* 🔄 PBKDF2 key derivation (planned)
* 🔄 Biometric unlock (planned)

---
