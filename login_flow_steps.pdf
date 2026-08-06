# Login to Home Navigation Guide

## What this does
1. Show the login page first.
2. Let the user enter a username.
3. Press `Login`.
4. Open the home page.
5. Show the entered username on the home page.

## Files involved
- `lib/main.dart`
- `lib/simple_login_demo.dart`
- `lib/home_page_demo.dart`

## 1. Start at the login page
In `lib/main.dart`, use:

```dart
home: const SimpleLoginPage(),
```

This makes the app open the login screen first.

## 2. Save the username
In `lib/simple_login_demo.dart`, add a controller:

```dart
final TextEditingController _usernameController = TextEditingController();
```

Then attach it to the username field:

```dart
TextField(
  controller: _usernameController,
  decoration: InputDecoration(
    labelText: 'Username',
    hintText: 'Enter your username',
    prefixIcon: const Icon(Icons.person),
  ),
),
```

This stores the username typed by the user.

## 3. Press the login button
When the button is pressed, navigate to the home page and send the username:

```dart
final userName = _usernameController.text.trim();
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => HomePage(
      userName: userName.isEmpty ? 'Guest' : userName,
    ),
  ),
);
```

## 4. Show the username on the home page
In `lib/home_page_demo.dart`, make `HomePage` receive the username:

```dart
final String userName;

const HomePage({super.key, required this.userName});
```

Then display it in the greeting:

```dart
Text(
  widget.userName.isEmpty ? 'Guest' : widget.userName,
  style: const TextStyle(
    color: Colors.white,
    fontSize: 27,
    fontWeight: FontWeight.bold,
  ),
),
```

## Save this as a PDF
1. Open `login_flow_steps.md` in VS Code.
2. Use `File` > `Save As` if you want a copy.
3. Use `File` > `Print`.
4. Choose `Save as PDF` from the printer list.

Or use extensions like `Markdown PDF` in VS Code to export directly.
